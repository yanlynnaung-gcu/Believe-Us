import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http_parser/http_parser.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:thae_nge_lay/core/errors/failure.dart';
import 'package:thae_nge_lay/core/network/api_client.dart';
import 'package:thae_nge_lay/core/network/websocket_sync_service.dart';
import 'package:thae_nge_lay/features/chat/domain/models/chat_message.dart';
import 'package:thae_nge_lay/features/chat/domain/repositories/chat_repository.dart';

part 'chat_repository_impl.g.dart';

class ChatRepositoryImpl implements ChatRepository {
  final Dio _dio;
  final WebSocketSyncService _ws;
  final Uuid _uuid = const Uuid();

  static final Map<String, List<ChatMessage>> _messagesStore = {};
  static final StreamController<List<ChatMessage>> _chatStreamController =
      StreamController<List<ChatMessage>>.broadcast();
  StreamSubscription? _wsSub;

  ChatRepositoryImpl({Dio? dio, WebSocketSyncService? ws})
    : _dio = dio ?? Dio(),
      _ws = ws ?? WebSocketSyncService() {
    _initWsListener();
  }

  void _initWsListener() {
    _wsSub?.cancel();
    _wsSub = _ws.onEvent('CHAT_MESSAGE').listen((event) {
      try {
        final raw = event.data;
        final msg = ChatMessage.fromJson(Map<String, dynamic>.from(raw));
        _addIncomingMessage(msg);
      } catch (e) {
        debugPrint('[Chat WS Parse Error] $e');
      }
    });
  }

  void _addIncomingMessage(ChatMessage msg) {
    final list = _getList(msg.coupleSpaceId);
    if (!list.any((m) => m.id == msg.id)) {
      list.add(msg);
      _chatStreamController.add(list);
    }
  }

  List<ChatMessage> _getList(String coupleSpaceId) {
    return _messagesStore.putIfAbsent(coupleSpaceId, () => []);
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages(
    String coupleSpaceId,
  ) async {
    try {
      // 1. Fetch remote messages from Spring Boot backend
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

          final local = _getList(coupleSpaceId);
          for (final r in remoteList) {
            if (!local.any((m) => m.id == r.id)) {
              local.add(r);
            }
          }
        }
      } catch (_) {}

      final list = _getList(coupleSpaceId);
      final sorted = List<ChatMessage>.from(list)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Right(sorted);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Stream<List<ChatMessage>> streamMessages(String coupleSpaceId) async* {
    // Initial fetch from backend
    unawaited(getMessages(coupleSpaceId));

    final initial = List<ChatMessage>.from(_getList(coupleSpaceId))
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    yield initial;

    yield* _chatStreamController.stream.map((_) {
      final current = List<ChatMessage>.from(_getList(coupleSpaceId))
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return current;
    });
  }

  void _addAndNotify(ChatMessage msg) {
    final list = _getList(msg.coupleSpaceId);
    if (!list.any((m) => m.id == msg.id)) {
      list.add(msg);
      _chatStreamController.add(list);
    }
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

      _addAndNotify(msg);

      // Async push to Spring Boot backend
      try {
        await _dio.post(ApiEndpoints.chatMessagesPath, data: msg.toJson());
      } catch (dioErr) {
        debugPrint('[Chat Send Backend Warning] $dioErr');
      }

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
      String resolvedRemotePath = audioPath;

      // 1. Upload local audio file via multipart form-data to Spring Boot backend
      final localFile = File(
        audioPath.startsWith('file://')
            ? audioPath.replaceFirst('file://', '')
            : audioPath,
      );

      if (localFile.existsSync()) {
        try {
          final fileName = localFile.path.split(Platform.pathSeparator).last;
          final formData = FormData.fromMap({
            'file': await MultipartFile.fromFile(
              localFile.path,
              filename: fileName,
              contentType: MediaType('audio', 'm4a'),
            ),
            'coupleSpaceId': coupleSpaceId,
          });

          final uploadResp = await _dio.post(
            ApiEndpoints.chatVoiceUploadPath,
            data: formData,
          );

          if (uploadResp.statusCode == 200 && uploadResp.data is Map) {
            final data = uploadResp.data as Map;
            final uploadedUrl = data['audioUrl'] ?? data['audioPath'];
            if (uploadedUrl != null && uploadedUrl.toString().isNotEmpty) {
              resolvedRemotePath = uploadedUrl.toString();
              debugPrint(
                '[Chat Voice Upload] Audio uploaded to backend: $resolvedRemotePath',
              );
            }
          }
        } catch (uploadErr) {
          debugPrint(
            '[Chat Voice Upload Warning] Multipart upload failed: $uploadErr',
          );
        }
      }

      final msg = ChatMessage(
        id: 'msg_${_uuid.v4().substring(0, 8)}',
        senderId: senderId,
        receiverId: receiverId,
        coupleSpaceId: coupleSpaceId,
        type: MessageType.voice,
        audioPath: resolvedRemotePath,
        audioDurationSeconds: durationSeconds,
        waveformSamples: waveforms,
        createdAt: DateTime.now(),
      );

      _addAndNotify(msg);

      try {
        await _dio.post(ApiEndpoints.chatMessagesPath, data: msg.toJson());
      } catch (dioErr) {
        debugPrint('[Chat Voice Send Backend Warning] $dioErr');
      }

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

      _addAndNotify(msg);

      try {
        await _dio.post(ApiEndpoints.chatMessagesPath, data: msg.toJson());
      } catch (dioErr) {
        debugPrint('[Chat Gift Send Backend Warning] $dioErr');
      }

      return Right(msg);
    } catch (e) {
      return Left(Failure.server(e.toString()));
    }
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

    final localCount = _getList(
      coupleSpaceId,
    ).where((m) => m.receiverId == receiverId && !m.isRead).length;
    return Right(localCount);
  }

  @override
  Future<Either<Failure, int>> markMessagesAsRead({
    required String coupleSpaceId,
    required String receiverId,
  }) async {
    try {
      final list = _getList(coupleSpaceId);
      int marked = 0;
      for (int i = 0; i < list.length; i++) {
        if (list[i].receiverId == receiverId && !list[i].isRead) {
          list[i] = list[i].copyWith(isRead: true);
          marked++;
        }
      }
      if (marked > 0) {
        _chatStreamController.add(list);
      }

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
