import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/storage/local_storage_service.dart';
import 'package:thae_nge_lay/features/chat/presentation/controllers/unread_messages_controller.dart';
import 'package:thae_nge_lay/features/gifting/presentation/controllers/unseen_gifts_controller.dart';
import 'package:thae_nge_lay/features/home/presentation/widgets/home_redesign_widgets.dart';
import 'package:thae_nge_lay/features/location_trust/presentation/controllers/partner_movement_status_controller.dart';

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
  HttpClient createHttpClient(SecurityContext? context) {
    return _FakeHttpClient();
  }
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
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _FakeHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;
  @override
  int get contentLength => _transparentPng.length;
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

class FakeLocalStorageService implements LocalStorageService {
  @override
  bool get isOnboardingCompleted => true;
  @override
  Future<void> setOnboardingCompleted(bool value) async {}
  @override
  String? get activeUserId => 'usr_me';
  @override
  Future<void> setActiveUserId(String? id) async {}
  @override
  String? get authToken => 'test_token';
  @override
  Future<void> setAuthToken(String? token) async {}
  @override
  String? get userProfileJson => null;
  @override
  Future<void> setUserProfileJson(String? json) async {}
  @override
  bool get isLocationPermissionGranted => true;
  @override
  Future<void> setLocationPermissionGranted(bool value) async {}
  @override
  String getDeviceId() => 'dev_fake_badge_001';
  @override
  String getDeviceName() => 'Fake Badge Device';
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
  @override
  Future<void> clearAll() async {}
  @override
  Future<void> init() async {}
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _MockHttpOverrides();
  });

  group('Real-Time Badges & Live Status on RomanticBottomNavBar', () {
    test('UnreadMessagesNotifier tracks and clears message counts correctly', () {
      final container = ProviderContainer(
        overrides: [
          localStorageServiceProvider
              .overrideWithValue(FakeLocalStorageService()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(unreadMessagesProvider.notifier);
      expect(container.read(unreadMessagesProvider), 0);

      notifier.increment();
      notifier.increment();
      notifier.increment();
      expect(container.read(unreadMessagesProvider), 3);

      notifier.reset();
      expect(container.read(unreadMessagesProvider), 0);
    });

    test('UnseenGiftsNotifier tracks and clears unseen gifts count', () {
      final container = ProviderContainer(
        overrides: [
          localStorageServiceProvider
              .overrideWithValue(FakeLocalStorageService()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(unseenGiftsProvider.notifier);
      expect(container.read(unseenGiftsProvider), 0);

      notifier.increment();
      expect(container.read(unseenGiftsProvider), 1);

      notifier.reset();
      expect(container.read(unseenGiftsProvider), 0);
    });

    test('PartnerMovementStatusNotifier updates speed and moving state', () {
      final container = ProviderContainer(
        overrides: [
          localStorageServiceProvider
              .overrideWithValue(FakeLocalStorageService()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(partnerMovementStatusProvider.notifier);
      notifier.updateStatus(
        isMoving: true,
        speedKmh: 24.0,
        placeLabel: 'Moving (24 km/h)',
      );

      final state = container.read(partnerMovementStatusProvider);
      expect(state.isMoving, isTrue);
      expect(state.speedKmh, 24.0);
      expect(state.placeLabel, contains('Moving'));
    });

    testWidgets(
      'RomanticBottomNavBar renders unread chat count, live moving pill, and gift box badges',
      (tester) async {
        final container = ProviderContainer(
          overrides: [
            localStorageServiceProvider
                .overrideWithValue(FakeLocalStorageService()),
          ],
        );
        addTearDown(container.dispose);

        // Preload states
        container.read(unreadMessagesProvider.notifier).increment();
        container.read(unreadMessagesProvider.notifier).increment();
        container.read(unreadMessagesProvider.notifier).increment(); // 3 unread
        container.read(unseenGiftsProvider.notifier).increment(); // 1 unseen gift
        container.read(partnerMovementStatusProvider.notifier).updateStatus(
              isMoving: true,
              speedKmh: 15.0,
              placeLabel: 'Moving (15 km/h)',
            );

        int selectedIndex = 0;

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: ScreenUtilInit(
              designSize: const Size(393, 852),
              builder: (context, child) => MaterialApp(
                home: Scaffold(
                  body: RomanticBottomNavBar(
                    selectedIndex: selectedIndex,
                    onTabSelected: (idx) {
                      selectedIndex = idx;
                    },
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // 1. Verify Unread Messages Badge (#E84A7F with '3')
        expect(find.text('3'), findsOneWidget);

        // 2. Verify Live Movement Pill ('🚗 Moving')
        expect(find.text('🚗 Moving'), findsOneWidget);

        // 3. Verify Unseen Gift Badge ('🎁')
        expect(find.text('🎁'), findsOneWidget);

        // 4. Tap Chat Tab -> Automatically clears unread messages badge
        await tester.tap(find.byIcon(LucideIcons.messageCircle), warnIfMissed: false);
        await tester.pump();
        expect(container.read(unreadMessagesProvider), 0);
        expect(find.text('3'), findsNothing);

        // 5. Tap Gift Tab -> Automatically clears unseen gifts badge
        await tester.tap(find.byIcon(LucideIcons.gift), warnIfMissed: false);
        await tester.pump();
        expect(container.read(unseenGiftsProvider), 0);
        expect(find.text('🎁'), findsNothing);

        // 6. Stop movement -> Movement pill disappears
        container.read(partnerMovementStatusProvider.notifier).updateStatus(
              isMoving: false,
              speedKmh: 0.0,
              placeLabel: 'Sweet Home',
            );
        await tester.pump();
        expect(find.text('🚗 Moving'), findsNothing);
      },
    );
  });
}
