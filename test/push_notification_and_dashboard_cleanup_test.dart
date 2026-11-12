import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/notifications/notification_manager.dart';
import 'package:thae_nge_lay/core/router/route_names.dart';
import 'package:thae_nge_lay/core/storage/local_storage_service.dart';
import 'package:thae_nge_lay/features/auth/domain/models/user_profile.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';
import 'package:thae_nge_lay/features/home/presentation/screens/sc_home_dashboard_screen.dart';
import 'package:thae_nge_lay/features/home/presentation/widgets/wd_full_bleed_couple_hero.dart';
import 'package:thae_nge_lay/features/home/presentation/widgets/wd_push_test_hub.dart';
import 'package:thae_nge_lay/features/home/presentation/widgets/wd_couple_bond_banner.dart';

// 1x1 transparent PNG bytes for mocking NetworkImage in widget tests
final Uint8List _transparentPng = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

class _MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _FakeHttpClient();
}

class _FakeHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;
  @override
  Duration idleTimeout = const Duration(seconds: 15);
  @override
  Duration? connectionTimeout = const Duration(seconds: 15);

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _FakeHttpClientRequest();

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _FakeHttpClientRequest();
}

class _FakeHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  HttpHeaders get headers => _FakeHttpHeaders();
  @override
  bool followRedirects = true;
  @override
  int maxRedirects = 5;
  @override
  bool persistentConnection = true;

  @override
  Future<HttpClientResponse> close() async => _FakeHttpClientResponse();
}

class _FakeHttpHeaders extends Fake implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _FakeHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;
  @override
  int get contentLength => _transparentPng.length;
  @override
  HttpHeaders get headers => _FakeHttpHeaders();
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_transparentPng]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

class FakeLocalStorageService extends Fake implements LocalStorageService {
  @override
  String? get userProfileJson => jsonEncode({
        'id': 'usr_test_101',
        'displayName': 'Ko Ko',
        'emailOrPhone': 'lover@believeus.app',
        'role': 'BOYFRIEND',
        'partnerId': 'usr_test_202',
        'coupleSpaceId': 'space_sacred_777',
        'isProfileComplete': true,
      });

  @override
  String? get activeUserId => 'usr_test_101';

  @override
  bool get isOnboardingCompleted => true;

  @override
  Future<void> setActiveUserId(String? id) async {}

  @override
  Future<void> setUserProfileJson(String? json) async {}

  @override
  Future<void> setAuthToken(String? token) async {}

  @override
  String? get coverPhotoPath => null;
  @override
  Future<void> setCoverPhotoPath(String? path) async {}
  @override
  String? get partnerAvatarPath => null;
  @override
  Future<void> setPartnerAvatarPath(String? path) async {}
  @override
  String? get partnerName => null;
  @override
  Future<void> setPartnerName(String? name) async {}
  @override
  DateTime? get partnerBirthday => null;
  @override
  Future<void> setPartnerBirthday(DateTime? date) async {}
  @override
  DateTime? get anniversaryDate => null;
  @override
  Future<void> setAnniversaryDate(DateTime? date) async {}
  @override
  int? get daysTogether => null;
  @override
  Future<void> setDaysTogether(int? days) async {}
}

class _MockAuthStateNotifier extends AuthStateNotifier {
  @override
  UserProfile? build() {
    return const UserProfile(
      id: 'usr_test_101',
      displayName: 'Ko Ko',
      emailOrPhone: 'lover@believeus.app',
      role: 'BOYFRIEND',
      partnerId: 'usr_test_202',
      coupleSpaceId: 'space_sacred_777',
      isProfileComplete: true,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _MockHttpOverrides();

  group('Home Dashboard Cleanup & Background Push Notifications Tests', () {
    testWidgets('Dashboard UI is cleaned up: WdPushTestHub and WdCoupleBondBanner removed',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageServiceProvider.overrideWithValue(FakeLocalStorageService()),
            authStateProvider.overrideWith(() => _MockAuthStateNotifier()),
          ],
          child: ScreenUtilInit(
            designSize: const Size(393, 852),
            minTextAdapt: true,
            builder: (context, _) => const MaterialApp(
              home: HomeDashboardScreen(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      // 1. Verify WdPushTestHub is completely absent
      expect(find.byType(WdPushTestHub), findsNothing);
      expect(find.text('Push Notification Engine'), findsNothing);

      // 2. Verify duplicate settings/logout banner WdCoupleBondBanner is absent
      expect(find.byType(WdCoupleBondBanner), findsNothing);
      expect(find.textContaining('1-to-1 Sacred Connection'), findsNothing);

      // 3. Verify FullBleedCoupleHero is present and contains the title bar settings icon
      expect(find.byType(FullBleedCoupleHero), findsOneWidget);
      expect(find.byIcon(LucideIcons.settings), findsOneWidget);
    });

    test('NotificationManager: KPay and WavePay heads-up banners trigger properly', () async {
      final notifManager = NotificationManager.instance;
      await notifManager.init();

      await notifManager.showTransactionNotification(
        provider: 'KBZPay',
        amount: '50,000 MMK',
        senderName: 'Thae Thae',
        note: 'Sweet bubble tea and roses ❤️',
      );

      await notifManager.showTransactionNotification(
        provider: 'WavePay',
        amount: '30,000 MMK',
        senderName: 'Thae Thae',
      );

      expect(notifManager.fcmToken, isNotEmpty);
    });

    test('NotificationManager: Chat, Arrival and Pairing banners trigger properly', () async {
      final notifManager = NotificationManager.instance;

      await notifManager.showChatMessageNotification(
        senderName: 'Thae Thae',
        message: 'Can’t wait to hold you in my arms tonight ❤️',
        type: 'text',
      );

      await notifManager.showChatMessageNotification(
        senderName: 'Thae Thae',
        message: '',
        type: 'voice',
      );

      await notifManager.showArrivalNotification(
        partnerName: 'Thae Thae',
        placeName: 'Sule Square, Downtown',
      );

      await notifManager.showPairingNotification(
        partnerName: 'Thae Thae',
        coupleSpaceId: 'space_forever_999',
      );
    });

    test('NotificationManager: Tap payload routing and cold start wake up navigation', () async {
      final notifManager = NotificationManager.instance;

      notifManager.navigateToRoute(AppRoutes.chat);
      expect(notifManager.consumePendingRoute(), equals(AppRoutes.chat));
      expect(notifManager.consumePendingRoute(), isNull);

      notifManager.navigateToRoute(AppRoutes.gifting);
      expect(notifManager.consumePendingRoute(), equals(AppRoutes.gifting));
      expect(notifManager.consumePendingRoute(), isNull);
    });
  });
}
