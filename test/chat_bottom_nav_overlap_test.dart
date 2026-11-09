import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:thae_nge_lay/core/storage/local_storage_service.dart';
import 'package:thae_nge_lay/features/chat/presentation/screens/chat_screen.dart';
import 'package:thae_nge_lay/features/home/presentation/screens/home_dashboard_screen.dart';
import 'package:thae_nge_lay/features/home/presentation/widgets/home_redesign_widgets.dart';

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
  HttpClient createHttpClient(SecurityContext? context) {
    return _createMockHttpClient();
  }
}

HttpClient _createMockHttpClient() {
  final client = _FakeHttpClient();
  return client;
}

class _FakeHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;
  @override
  Duration idleTimeout = const Duration(seconds: 15);
  @override
  Duration? connectionTimeout = const Duration(seconds: 15);

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return _FakeHttpClientRequest();
  }

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return _FakeHttpClientRequest();
  }
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
  void add(List<int> data) {}

  @override
  Future<HttpClientResponse> close() async {
    return _FakeHttpClientResponse();
  }
}

class _FakeHttpHeaders extends Fake implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
  @override
  void forEach(void Function(String name, List<String> values) action) {}
  @override
  List<String>? operator [](String name) => null;
  @override
  String? value(String name) => null;
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
  Future<void> clearAll() async {}
  @override
  Future<void> init() async {}
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _MockHttpOverrides();
  });

  group('UI/UX Layout: Floating Bottom Nav Bar & Chat Input Box Overlap Fix', () {
    testWidgets(
      'ChatScreen calculates dynamic bottom spacing above floating navbar when keyboard is closed',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              localStorageServiceProvider
                  .overrideWithValue(FakeLocalStorageService()),
            ],
            child: ScreenUtilInit(
              designSize: const Size(390, 844),
              builder: (context, child) => const MaterialApp(
                home: ChatScreen(hasBottomNavBar: true, bottomNavHeight: 76.0),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));

        // Find AnimatedPadding that wraps the input box
        final animatedPaddingFinder = find.byType(AnimatedPadding);
        expect(animatedPaddingFinder, findsOneWidget);

        final animatedPadding =
            tester.widget<AnimatedPadding>(animatedPaddingFinder);
        final padding = animatedPadding.padding as EdgeInsets;

        // When keyboard is closed, bottom padding should be >= 76.0 (bottomNavHeight + safeAreaBottom + 8.h)
        expect(padding.bottom, greaterThanOrEqualTo(76.0));
      },
    );

    testWidgets(
      'ChatScreen docks cleanly right above keyboard when keyboard is open (viewInsets.bottom > 0)',
      (tester) async {
        // Simulate keyboard open by setting MediaQuery viewInsets.bottom
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              localStorageServiceProvider
                  .overrideWithValue(FakeLocalStorageService()),
            ],
            child: ScreenUtilInit(
              designSize: const Size(390, 844),
              builder: (context, child) => const MaterialApp(
                home: MediaQuery(
                  data: MediaQueryData(
                    viewInsets: EdgeInsets.only(bottom: 300),
                    padding: EdgeInsets.only(bottom: 34),
                  ),
                  child: ChatScreen(
                    hasBottomNavBar: true,
                    bottomNavHeight: 76.0,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));

        final animatedPaddingFinder = find.byType(AnimatedPadding);
        expect(animatedPaddingFinder, findsOneWidget);

        final animatedPadding =
            tester.widget<AnimatedPadding>(animatedPaddingFinder);
        final padding = animatedPadding.padding as EdgeInsets;

        // When keyboard is open, bottom padding docks flush at ~10.h (not inflated by navbar height)
        expect(padding.bottom, lessThan(30.0));
      },
    );

    testWidgets(
      'HomeDashboardScreen auto-hides FloatingGlassNavBar via AnimatedSlide and AnimatedOpacity when keyboard opens',
      (tester) async {
        // Closed keyboard state
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              localStorageServiceProvider
                  .overrideWithValue(FakeLocalStorageService()),
            ],
            child: ScreenUtilInit(
              designSize: const Size(390, 844),
              builder: (context, child) => const MaterialApp(
                home: MediaQuery(
                  data: MediaQueryData(
                    viewInsets: EdgeInsets.zero,
                    padding: EdgeInsets.only(bottom: 34),
                  ),
                  child: HomeDashboardScreen(),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));

        expect(find.byType(FloatingGlassNavBar), findsOneWidget);

        // Verify AnimatedSlide has Offset.zero when keyboard closed
        final slideFinder = find.ancestor(
          of: find.byType(FloatingGlassNavBar),
          matching: find.byType(AnimatedSlide),
        );
        expect(slideFinder, findsOneWidget);
        final slideWidget = tester.widget<AnimatedSlide>(slideFinder);
        expect(slideWidget.offset, equals(Offset.zero));

        // Verify AnimatedOpacity is 1.0
        final opacityFinder = find.ancestor(
          of: find.byType(FloatingGlassNavBar),
          matching: find.byType(AnimatedOpacity),
        );
        expect(opacityFinder, findsOneWidget);
        final opacityWidget = tester.widget<AnimatedOpacity>(opacityFinder);
        expect(opacityWidget.opacity, equals(1.0));

        // Now simulate keyboard opening (viewInsets.bottom = 320)
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              localStorageServiceProvider
                  .overrideWithValue(FakeLocalStorageService()),
            ],
            child: ScreenUtilInit(
              designSize: const Size(390, 844),
              builder: (context, child) => const MaterialApp(
                home: MediaQuery(
                  data: MediaQueryData(
                    viewInsets: EdgeInsets.only(bottom: 320),
                    padding: EdgeInsets.only(bottom: 34),
                  ),
                  child: HomeDashboardScreen(),
                ),
              ),
            ),
          ),
        );
        await tester.pump(); // Start animation
        await tester.pump(const Duration(milliseconds: 250)); // Finish 200ms animation

        // Check target values
        final openSlideWidget = tester.widget<AnimatedSlide>(slideFinder);
        expect(openSlideWidget.offset.dy, greaterThan(1.0)); // Slides down

        final openOpacityWidget = tester.widget<AnimatedOpacity>(opacityFinder);
        expect(openOpacityWidget.opacity, equals(0.0)); // Fades out completely
      },
    );
  });
}
