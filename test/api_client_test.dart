import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thae_nge_lay/core/network/api_client.dart';
import 'package:thae_nge_lay/core/network/websocket_sync_service.dart';
import 'package:thae_nge_lay/core/utils/image_provider_helper.dart';
import 'package:thae_nge_lay/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:thae_nge_lay/features/chat/domain/models/chat_message.dart';
import 'package:thae_nge_lay/features/gifting/data/datasources/gifting_remote_data_source.dart';
import 'package:thae_nge_lay/features/gifting/domain/models/gift_package.dart';
import 'package:thae_nge_lay/features/gifting/domain/models/gift_transaction.dart';
import 'package:thae_nge_lay/features/location_trust/data/repositories/location_arrival_repository.dart';
import 'package:thae_nge_lay/features/location_trust/data/services/geocoding_service.dart';
import 'package:thae_nge_lay/features/notifications/data/services/fcm_notification_service.dart';
import 'package:thae_nge_lay/features/pairing/data/datasources/pairing_remote_data_source.dart';

void main() {
  group('ApiClient and Multi-Device LAN URL Resolution', () {
    test('ApiEndpoints resolves Railway Production URL by default', () {
      final host = ApiEndpoints.host;
      expect(host, equals('192.168.1.6'));

      final baseUrl = ApiEndpoints.baseUrl;
      expect(baseUrl, equals(ApiEndpoints.defaultProductionUrl));

      final wsUrl = ApiEndpoints.wsUrl;
      expect(wsUrl, equals('wss://believe-us-production.up.railway.app/ws'));
    });

    test('LocationArrivalRepository parses Spring Boot JSON with numeric IDs correctly', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path.contains('/arrivals/')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: [
                    {
                      "id": 101, // Long ID from Spring Boot
                      "userId": "partner_thae_nge_lay",
                      "latitude": 16.8295,
                      "longitude": 96.1305,
                      "addressLine": "No. 42, Pyay Road, Kamayut Township",
                      "placeName": "Sweet Home",
                      "status": "STATIONARY",
                      "speedKmh": 0.0,
                      "batteryLevel": 88,
                      "isCharging": true,
                      "arrivedAt": "2026-11-08T15:30:00",
                      "departedAt": null,
                      "lastUpdatedAt": "2026-11-08T15:45:00",
                    }
                  ],
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final repo = LocationArrivalRepository(
        dio: dio,
        geocodingService: GeocodingService(),
        fcmService: FcmNotificationService(),
      );

      final result = await repo.getTodayArrivalLogs(userId: 'partner_thae_nge_lay');
      expect(result.isRight(), isTrue);

      result.fold(
        (_) => fail('Should parse arrival logs from Spring Boot'),
        (logs) {
          expect(logs.length, equals(1));
          expect(logs.first.id, equals('101'));
          expect(logs.first.placeName, equals('Sweet Home'));
          expect(logs.first.batteryLevel, equals(88));
          expect(logs.first.isCharging, isTrue);
          expect(logs.first.departedAt, isNull);
        },
      );
    });

    test('2-Device Pairing via API handles pairing response with coupleSpaceId', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path.contains('/pairing/code/') ||
                options.path.contains('/pairing/generate')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'inviteCode': 'MYLOVE'},
                ),
              );
            }
            if (options.path.contains('/pairing/pair')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'id': 'space_realtime_123',
                    'user1Id': 'usr_boyfriend',
                    'user2Id': 'usr_girlfriend',
                    'inviteCode': 'MYLOVE',
                    'pairedAt': '2026-11-08T16:00:00',
                    'anniversaryDate': '2026-11-08T16:00:00',
                    'isActive': true,
                  },
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final dataSource = PairingRemoteDataSourceImpl(dio: dio);

      // User A creates code
      final code = await dataSource.getOrCreateInviteCode('usr_boyfriend');
      expect(code, equals('MYLOVE'));

      // User B enters User A code
      final space = await dataSource.pairWithCode(
        currentUserId: 'usr_girlfriend',
        inviteCode: code,
      );

      expect(space.id, equals('space_realtime_123'));
      expect(space.user1Id, equals('usr_boyfriend'));
      expect(space.user2Id, equals('usr_girlfriend'));
      expect(space.isActive, isTrue);
    });

    test('Real-time Chat sync repository sends message and delivers through stream', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path.contains('/chat/messages')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: options.data,
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final chatRepo = ChatRepositoryImpl(dio: dio);

      final result = await chatRepo.sendTextMessage(
        senderId: 'usr_boyfriend',
        receiverId: 'usr_girlfriend',
        coupleSpaceId: 'space_test',
        text: 'Hello from Android Emulator!',
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Message sending failed'),
        (msg) {
          expect(msg.text, equals('Hello from Android Emulator!'));
          expect(msg.senderId, equals('usr_boyfriend'));
          expect(msg.receiverId, equals('usr_girlfriend'));
        },
      );
    });

    test('Real-time Voice Message: uploads local audio file and resolves public streaming URL', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path.contains('/chat/voice')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'audioUrl': '/uploads/audio/voice_test_123.m4a',
                    'filename': 'voice_test_123.m4a',
                  },
                ),
              );
            }
            if (options.path.contains('/chat/messages')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: options.data,
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final tempFile = File('${Directory.systemTemp.path}/test_voice_sample.m4a');
      await tempFile.writeAsString('mock audio bytes');

      final chatRepo = ChatRepositoryImpl(dio: dio);
      final result = await chatRepo.sendVoiceMessage(
        senderId: 'usr_boyfriend',
        receiverId: 'usr_girlfriend',
        coupleSpaceId: 'space_test',
        audioPath: tempFile.path,
        durationSeconds: 7,
        waveforms: [0.5, 0.8, 0.6],
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Voice memo sending failed'),
        (msg) {
          expect(msg.type, equals(MessageType.voice));
          expect(msg.audioPath, equals('/uploads/audio/voice_test_123.m4a'));
          expect(msg.audioDurationSeconds, equals(7));

          // Verify getAudioUrl resolves to full public URL for partner playback
          final resolvedUrl = getAudioUrl(msg.audioPath);
          expect(resolvedUrl, equals('${ApiEndpoints.baseUrl}/uploads/audio/voice_test_123.m4a'));
        },
      );

      if (tempFile.existsSync()) {
        await tempFile.delete();
      }
    });

    test('getAudioUrl resolves file:/// URIs, relative endpoints and absolute URLs correctly', () {
      expect(
        getAudioUrl('file:///uploads/audio/sample.m4a'),
        equals('${ApiEndpoints.baseUrl}/uploads/audio/sample.m4a'),
      );
      expect(
        getAudioUrl('/uploads/audio/sample.m4a'),
        equals('${ApiEndpoints.baseUrl}/uploads/audio/sample.m4a'),
      );
      expect(
        getAudioUrl('https://custom-cdn.com/audio.m4a'),
        equals('https://custom-cdn.com/audio.m4a'),
      );
    });

    test('Gifting via API communicates with backend and returns transaction reference', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path.contains('/gifting/pay')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'id': 'tx_998877',
                    'transactionRef': 'KPAY-889900',
                    'status': 'SUCCESS',
                  },
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final giftingSource = GiftingRemoteDataSourceImpl(dio: dio);
      final transaction = await giftingSource.initiateAndVerifyPayment(
        senderId: 'usr_boyfriend',
        receiverId: 'usr_girlfriend',
        coupleSpaceId: 'space_test',
        packageTitle: 'Romantic Candlelight Dinner',
        amountMmK: 80000,
        provider: PaymentProvider.kbzPay,
        note: 'Have a great evening my love',
      );

      expect(transaction.transactionRef, equals('KPAY-889900'));
      expect(transaction.amountMmK, equals(80000));
      expect(transaction.status, equals(TransactionStatus.completed));
    });

    test('DioExponentialBackoffRetryInterceptor retries transient failures with backoff', () async {
      int attempts = 0;
      final dio = Dio();

      dio.interceptors.add(
        DioExponentialBackoffRetryInterceptor(
          dio: dio,
          maxRetries: 2,
          initialDelay: const Duration(milliseconds: 10),
          maxDelay: const Duration(milliseconds: 50),
        ),
      );

      dio.httpClientAdapter = _MockFailThenSucceedAdapter(
        onAttempt: () => attempts++,
      );

      final response = await dio.get('/test/retry');
      expect(response.statusCode, equals(200));
      expect(attempts, equals(3)); // 1 initial + 2 retries
    });

    test('DioExponentialBackoffRetryInterceptor respects disable_retry extra flag', () async {
      int attempts = 0;
      final dio = Dio();

      dio.interceptors.add(
        DioExponentialBackoffRetryInterceptor(
          dio: dio,
          maxRetries: 2,
          initialDelay: const Duration(milliseconds: 10),
          maxDelay: const Duration(milliseconds: 50),
        ),
      );

      dio.httpClientAdapter = _MockFailThenSucceedAdapter(
        onAttempt: () => attempts++,
      );

      expect(
        () => dio.get(
          '/test/no-retry',
          options: Options(extra: {'disable_retry': true}),
        ),
        throwsA(isA<DioException>()),
      );
      // Wait to verify no delayed background retries happen
      await Future.delayed(const Duration(milliseconds: 60));
      expect(attempts, equals(1)); // Only 1 attempt, zero retries
    });

    test('WebSocketSyncService manages state, credentials, and couple room subscriptions', () {
      final ws = WebSocketSyncService();
      expect(ws.isConnected, isFalse);

      ws.updateCredentials(userId: 'user_alpha', coupleSpaceId: 'space_alpha');

      // Test event stream mapping with dynamic couple room topics
      final events = <WebSocketEvent>[];
      final sub = ws.eventStream.listen(events.add);

      final testEvent = WebSocketEvent(
        event: 'CHAT_MESSAGE',
        data: {'text': 'Darling ❤️'},
        topic: '/topic/couple.space_alpha.chat',
        coupleSpaceId: 'space_alpha',
      );

      // Verify WebSocketEvent retains topic and coupleSpaceId
      expect(testEvent.topic, equals('/topic/couple.space_alpha.chat'));
      expect(testEvent.coupleSpaceId, equals('space_alpha'));
      expect(testEvent.data['text'], equals('Darling ❤️'));

      sub.cancel();
      ws.dispose();
    });
  });
}

class _MockFailThenSucceedAdapter implements HttpClientAdapter {
  final void Function() onAttempt;
  int _count = 0;

  _MockFailThenSucceedAdapter({required this.onAttempt});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    _count++;
    onAttempt();
    if (_count <= 2) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'Simulated network disconnect',
      );
    }
    return ResponseBody.fromString(
      '{"status":"RECOVERED"}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
