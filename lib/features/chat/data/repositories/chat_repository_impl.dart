import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:thae_nge_lay/core/errors/failure.dart';
import 'package:thae_nge_lay/core/network/api_client.dart';
import 'package:thae_nge_lay/core/network/websocket_sync_service.dart';
import 'package:thae_nge_lay/features/chat/data/datasources/chat_memory_store.dart';
import 'package:thae_nge_lay/features/chat/data/services/chat_audio_upload_service.dart';
import 'package:thae_nge_lay/features/chat/domain/models/chat_message.dart';
import 'package:thae_nge_lay/features/chat/domain/repositories/chat_repository.dart';

part 'chat_repository_impl.g.dart';

class ChatRepositoryImpl implements ChatRepository {
  final Dio _dio;
  final WebSocketSyncService _ws;
  final Uuid _uuid = const Uuid();
  final ChatMemoryStore _store;
  final ChatAudioUploadService _uploadService;
  StreamSubscription? _wsSub;

  ChatRepositoryImpl({
    Dio? dio,
    WebSocketSyncService? ws,
    ChatMemoryStore? store,
    ChatAudioUploadService? uploadService,
  })  : _dio = dio ?? Dio(),
        _ws = ws ?? WebSocketSyncService(),
        _store = store ?? ChatMemoryStore(),
        _uploadService = uploadService ??
            ChatAudioUploadService(dio: dio ?? Dio()) {
    _initWsListener();
  }

  void _initWsListener() {
    _wsSub?.cancel();
    _wsSub = _ws.onEvent('CHAT_MESSAGE').listen((event) {
      try {
        final raw = event.data;
        final msg = ChatMessage.fromJson(Map<String, dynamic>.from(raw));
        _store.addMessage(msg);
      } catch (e) {
        debugPrint('[Chat WS Parse Error] $e');
      }
    });
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages(
    String coupleSpaceId,
  ) async {
    try {
      try {
        final response = await _dio.get(
          '${ApiEndpoints.chatMessagesPath}/$coupleSpaceId',
        );
        if (response.statusCode == 200 && response.data is List) {
          final remoteList = (response.data as List)
              .map(
                (j) =>
                    ChatMessage.fromJson(Map<String, dynamic>.from(j as Map)),
              )
              .toList();
          _store.addRemoteMessages(coupleSpaceId, remoteList);
        }
      } catch (_) {}

      return Right(_store.getSortedList(coupleSpaceId));
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Stream<List<ChatMessage>> streamMessages(String coupleSpaceId) async* {
    unawaited(getMessages(coupleSpaceId));
    yield _store.getSortedList(coupleSpaceId);

    yield* _store.stream.map((_) => _store.getSortedList(coupleSpaceId));
  }

  @override
  Future<Either<Failure, ChatMessage>> sendTextMessage({
    required String senderId,
    required String receiverId,
    required String coupleSpaceId,
    required String text,
  }) async {
    try {
      if (text.trim().isEmpty) {
        return const Left(Failure.unexpected('Cannot send empty message.'));
      }
      final msg = ChatMessage(
        id: 'msg_${_uuid.v4().substring(0, 8)}',
        senderId: senderId,
        receiverId: receiverId,
        coupleSpaceId: coupleSpaceId,
        type: MessageType.text,
        text: text.trim(),
        createdAt: DateTime.now(),
      );

      _store.addMessage(msg);
      _pushToBackend(msg);
      return Right(msg);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatMessage>> sendVoiceMessage({
    required String senderId,
    required String receiverId,
    required String coupleSpaceId,
    required String audioPath,
    required int durationSeconds,
    required List<double> waveforms,
  }) async {
    try {
      final remotePath = await _uploadService.uploadAudio(
        audioPath: audioPath,
        coupleSpaceId: coupleSpaceId,
      );

      final msg = ChatMessage(
        id: 'msg_${_uuid.v4().substring(0, 8)}',
        senderId: senderId,
        receiverId: receiverId,
        coupleSpaceId: coupleSpaceId,
        type: MessageType.voice,
        audioPath: remotePath,
        audioDurationSeconds: durationSeconds,
        waveformSamples: waveforms,
        createdAt: DateTime.now(),
      );

      _store.addMessage(msg);
      _pushToBackend(msg);
      return Right(msg);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatMessage>> sendGiftMessage({
    required String senderId,
    required String receiverId,
    required String coupleSpaceId,
    required Map<String, dynamic> giftData,
  }) async {
    try {
      final msg = ChatMessage(
        id: 'msg_${_uuid.v4().substring(0, 8)}',
        senderId: senderId,
        receiverId: receiverId,
        coupleSpaceId: coupleSpaceId,
        type: MessageType.gift,
        giftData: giftData,
        createdAt: DateTime.now(),
      );

      _store.addMessage(msg);
      _pushToBackend(msg);
      return Right(msg);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  void _pushToBackend(ChatMessage msg) {
    _dio.post(ApiEndpoints.chatMessagesPath, data: msg.toJson()).catchError(
      (dioErr) {
        debugPrint('[Chat Send Backend Warning] $dioErr');
        return Response(requestOptions: RequestOptions());
      },
    );
  }

  @override
  Future<Either<Failure, int>> getUnreadCount({
    required String coupleSpaceId,
    required String receiverId,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.chatUnreadPath}/$coupleSpaceId',
        queryParameters: {'receiverId': receiverId},
      );
      if (response.statusCode == 200 && response.data != null) {
        final count = (response.data['unreadCount'] as num?)?.toInt() ?? 0;
        return Right(count);
      }
    } catch (_) {}

    final localCount = _store
        .getList(coupleSpaceId)
        .where((m) => m.receiverId == receiverId && !m.isRead)
        .length;
    return Right(localCount);
  }

  @override
  Future<Either<Failure, int>> markMessagesAsRead({
    required String coupleSpaceId,
    required String receiverId,
  }) async {
    try {
      final marked = _store.markMessagesAsRead(
        coupleSpaceId: coupleSpaceId,
        receiverId: receiverId,
      );

      try {
        await _dio.post(
          '${ApiEndpoints.chatReadPath}/$coupleSpaceId',
          queryParameters: {'receiverId': receiverId},
        );
      } catch (_) {}

      return Right(marked);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }
}

@Riverpod(keepAlive: true)
ChatRepository chatRepository(Ref ref) {
  return ChatRepositoryImpl(
    dio: ref.watch(dioClientProvider),
    ws: ref.watch(webSocketSyncServiceProvider),
  );
}
