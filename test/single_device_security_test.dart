import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:thae_nge_lay/core/network/api_client.dart';
import 'package:thae_nge_lay/core/network/websocket_sync_service.dart';
import 'package:thae_nge_lay/core/router/app_router.dart';
import 'package:thae_nge_lay/features/auth/domain/models/user_profile.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';
import 'package:thae_nge_lay/features/auth/presentation/listeners/single_device_security_listener.dart';

class _MockDioAdapter implements HttpClientAdapter {
  Map<String, dynamic>? lastResolvedBody;
  String? lastResolvedPath;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastResolvedPath = options.path;
    if (options.data is Map) {
      lastResolvedBody = Map<String, dynamic>.from(options.data as Map);
    }

    return ResponseBody.fromString(
      '{"success": true}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Single-Device Session Security & Login Permission Flow', () {
    late WebSocketSyncService wsSync;
    late _MockDioAdapter mockDioAdapter;
    late Dio testDio;

    setUp(() {
      wsSync = WebSocketSyncService();
      mockDioAdapter = _MockDioAdapter();
      testDio = Dio()..httpClientAdapter = mockDioAdapter;
    });

    tearDown(() {
      wsSync.dispose();
    });

    testWidgets(
      'Receiving DEVICE_LOGIN_ATTEMPT displays modal alert dialog with Allow/Deny actions',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            webSocketSyncServiceProvider.overrideWithValue(wsSync),
            dioClientProvider.overrideWithValue(testDio),
            authStateProvider.overrideWith(() => _MockAuthStateNotifier()),
          ],
        );
        addTearDown(container.dispose);

        // Build UI with navigatorKey
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              navigatorKey: rootNavigatorKey,
              home: Builder(
                builder: (context) {
                  container.read(singleDeviceSecurityListenerProvider);
                  return const Scaffold(
                    body: Center(child: Text('Protected Home')),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('Protected Home'), findsOneWidget);
        expect(find.text('Allow other device login?'), findsNothing);

        // Simulate WebSocket alert event from backend
        wsSync.simulateIncomingEvent(
          WebSocketEvent(
            event: 'DEVICE_LOGIN_ATTEMPT',
            data: {
              'ticketId': 'tkt_test_999',
              'deviceId': 'dev_test_secondary',
              'deviceName': 'MacBook Pro 16',
              'attemptedAt': 1729384918,
            },
          ),
        );

        await tester.pumpAndSettle();

        // Verify Modal Alert Dialog is displayed
        expect(find.text('Allow other device login?'), findsOneWidget);
        expect(
          find.text('A new login attempt from "MacBook Pro 16" was detected.'),
          findsOneWidget,
        );
        expect(find.text('Deny'), findsOneWidget);
        expect(find.text('Allow'), findsOneWidget);

        // Tap Deny
        await tester.tap(find.text('Deny'));
        await tester.pumpAndSettle();

        // Dialog should be dismissed
        expect(find.text('Allow other device login?'), findsNothing);
        expect(mockDioAdapter.lastResolvedPath, contains('/login-ticket/tkt_test_999/resolve'));
        expect(mockDioAdapter.lastResolvedBody?['approved'], isFalse);
      },
    );

    testWidgets(
      'Allow button on modal alert dialog resolves ticket as approved and triggers logout',
      (tester) async {
        final mockAuthNotifier = _MockAuthStateNotifier();
        final container = ProviderContainer(
          overrides: [
            webSocketSyncServiceProvider.overrideWithValue(wsSync),
            dioClientProvider.overrideWithValue(testDio),
            authStateProvider.overrideWith(() => mockAuthNotifier),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              navigatorKey: rootNavigatorKey,
              home: Builder(
                builder: (context) {
                  container.read(singleDeviceSecurityListenerProvider);
                  return const Scaffold(body: Text('Active Session Screen'));
                },
              ),
            ),
          ),
        );

        // Simulate event
        wsSync.simulateIncomingEvent(
          WebSocketEvent(
            event: 'DEVICE_LOGIN_ATTEMPT',
            data: {
              'ticketId': 'tkt_allow_123',
              'deviceName': 'Samsung Galaxy S24',
            },
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Allow other device login?'), findsOneWidget);

        // Tap Allow
        await tester.tap(find.text('Allow'));
        await tester.pumpAndSettle();

        expect(find.text('Allow other device login?'), findsNothing);
        expect(mockDioAdapter.lastResolvedPath, contains('/login-ticket/tkt_allow_123/resolve'));
        expect(mockDioAdapter.lastResolvedBody?['approved'], isTrue);
        expect(mockAuthNotifier.logoutCalled, isTrue);
      },
    );

    testWidgets(
      'Receiving SESSION_TERMINATED triggers logout and displays notification',
      (tester) async {
        final mockAuthNotifier = _MockAuthStateNotifier();
        final container = ProviderContainer(
          overrides: [
            webSocketSyncServiceProvider.overrideWithValue(wsSync),
            dioClientProvider.overrideWithValue(testDio),
            authStateProvider.overrideWith(() => mockAuthNotifier),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              navigatorKey: rootNavigatorKey,
              home: Builder(
                builder: (context) {
                  container.read(singleDeviceSecurityListenerProvider);
                  return const Scaffold(body: Text('Home Screen'));
                },
              ),
            ),
          ),
        );

        // Simulate SESSION_TERMINATED
        wsSync.simulateIncomingEvent(
          WebSocketEvent(
            event: 'SESSION_TERMINATED',
            data: {
              'deviceName': 'iPhone 15 Pro',
            },
          ),
        );

        await tester.pumpAndSettle();
        expect(mockAuthNotifier.logoutCalled, isTrue);
        expect(
          find.text('Session signed out: logged in from iPhone 15 Pro.'),
          findsOneWidget,
        );
      },
    );
  });
}

class _MockAuthStateNotifier extends AuthStateNotifier {
  bool logoutCalled = false;

  @override
  UserProfile? build() {
    return const UserProfile(
      id: 'usr_test_mock',
      emailOrPhone: 'mock@believeus.app',
      displayName: 'Ko Ko',
      role: 'BOYFRIEND',
    );
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
    state = null;
  }
}
