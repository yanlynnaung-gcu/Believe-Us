import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:thae_nge_lay/core/errors/failure.dart';
import 'package:thae_nge_lay/core/storage/local_storage_service.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/features/auth/domain/models/user_profile.dart';
import 'package:thae_nge_lay/features/home/presentation/widgets/home_redesign_widgets.dart';
import 'package:thae_nge_lay/features/location/data/services/location_service.dart';
import 'package:thae_nge_lay/features/location/presentation/screens/partner_map_screen.dart';
import 'package:thae_nge_lay/features/location/presentation/utils/romantic_marker_generator.dart';
import 'package:thae_nge_lay/features/location_trust/data/repositories/location_arrival_repository.dart';
import 'package:thae_nge_lay/features/location_trust/domain/models/partner_location_arrival_model.dart';
import 'package:thae_nge_lay/features/location_trust/domain/models/trusted_place_model.dart';
import 'package:thae_nge_lay/features/location_trust/presentation/controllers/location_detail_controller.dart';
import 'package:thae_nge_lay/features/location_trust/presentation/screens/partner_location_detail_screen.dart';
import 'package:thae_nge_lay/features/pairing/data/repositories/pairing_repository_impl.dart';
import 'package:thae_nge_lay/features/pairing/domain/models/couple_summary.dart';
import 'package:thae_nge_lay/features/pairing/domain/repositories/pairing_repository.dart';
import 'package:thae_nge_lay/features/settings/presentation/screens/contact_us_screen.dart';
import 'package:thae_nge_lay/features/settings/presentation/screens/settings_screen.dart';

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

class _FakeLocalStorageService implements LocalStorageService {
  @override
  bool get isOnboardingCompleted => true;
  @override
  Future<void> setOnboardingCompleted(bool value) async {}
  @override
  String? get activeUserId => 'user_123';
  @override
  Future<void> setActiveUserId(String? id) async {}
  @override
  String? get authToken => 'token_123';
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
  String getDeviceId() => 'dev_fake_test_001';
  @override
  String getDeviceName() => 'Fake Test Device';
  @override
  Future<void> clearAll() async {}
  @override
  Future<void> init() async {}
}

class _FakeLocationArrivalRepository extends Fake
    implements LocationArrivalRepository {
  @override
  Future<Either<Failure, List<PartnerLocationArrivalModel>>>
      getTodayArrivalLogs({
    String userId = 'partner_thae_nge_lay',
  }) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<TrustedPlaceModel>>> getTrustedPlaces({
    String userId = 'partner_thae_nge_lay',
  }) async {
    return const Right([]);
  }
}

class _FakeLocationService extends Fake implements LocationService {
  @override
  Future<Position?> getCurrentPosition() async {
    return Position(
      longitude: 96.1603,
      latitude: 16.7795,
      timestamp: DateTime.now(),
      accuracy: 5.0,
      altitude: 10.0,
      altitudeAccuracy: 1.0,
      heading: 0.0,
      headingAccuracy: 1.0,
      speed: 0.0,
      speedAccuracy: 1.0,
    );
  }

  @override
  double calculateDistanceInKm({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return 5.2;
  }

  @override
  Future<int> getBatteryLevel() async => 85;

  @override
  Future<bool> isCharging() async => false;

  @override
  Stream<Position> getPositionStream() => const Stream.empty();
}

class _FakePairingRepository extends Fake implements PairingRepository {
  @override
  Future<Either<Failure, CoupleSummary>> getCoupleSummary({
    required String coupleSpaceId,
    String? userId,
  }) async {
    return Right(CoupleSummary(
      coupleSpaceId: coupleSpaceId,
      coverPhotoUrl: '/uploads/covers/our_space.jpg',
      daysTogether: 42,
      myProfile: const UserProfile(
        id: 'usr_me',
        displayName: 'Ko Ko',
        emailOrPhone: 'koko@believeus.app',
        role: 'BOYFRIEND',
      ),
      partnerProfile: UserProfile(
        id: 'usr_partner',
        displayName: 'Thae Thae',
        emailOrPhone: 'thae@believeus.app',
        role: 'GIRLFRIEND',
        birthday: DateTime(2000, 8, 20),
      ),
    ));
  }
}

Widget createTestApp(Widget child) {
  return ProviderScope(
    overrides: [
      localStorageServiceProvider
          .overrideWithValue(_FakeLocalStorageService()),
      locationArrivalRepositoryProvider
          .overrideWithValue(_FakeLocationArrivalRepository()),
      locationServiceProvider
          .overrideWithValue(_FakeLocationService()),
      pairingRepositoryProvider
          .overrideWithValue(_FakePairingRepository()),
    ],
    child: ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      builder: (context, _) => MaterialApp(
        home: child,
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _MockHttpOverrides();

  group('Feature 2: Contact Us & Settings Screens', () {
    testWidgets('ContactUsScreen renders romantic header and all 4 contact channels',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(const ContactUsScreen()));
      await tester.pumpAndSettle();

      // Check Header
      expect(find.text('Contact Us ✨'), findsOneWidget);
      expect(find.text('We Love Hearing From You'), findsOneWidget);
      expect(find.text('Direct Channels'), findsOneWidget);

      // Check all 4 interactive channels
      expect(find.text('Direct Phone Call'), findsOneWidget);
      expect(find.text('Email Support'), findsOneWidget);
      expect(find.text('Facebook Page'), findsOneWidget);
      expect(find.text('Viber Direct Chat'), findsOneWidget);

      // Check Quick Note section
      expect(find.text('Send Us A Quick Love Note'), findsOneWidget);
      expect(find.text('Send via Email'), findsOneWidget);
    });

    testWidgets('SettingsScreen displays couple space details and Contact Us tile',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Settings & Sanctuary ✨'), findsOneWidget);
      expect(find.text('Support & Love Concierge'), findsOneWidget);
      expect(find.text('Contact Us'), findsOneWidget);
      expect(find.text('Phone, Email, Viber & Facebook Support'), findsOneWidget);
      expect(find.text('Anniversary Milestones'), findsOneWidget);
      expect(find.text('Live Location & Guard'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
    });
  });

  group('Feature 1: RomanticMarkerGenerator & PartnerMapScreen', () {
    test('RomanticMarkerGenerator generates custom BitmapDescriptor markers',
        () async {
      final partnerMarker = await RomanticMarkerGenerator.createCoupleMarker(
        label: 'Thae Thae ❤️',
        borderColor: BelieveColors.primary,
        isPartner: true,
      );

      final userMarker = await RomanticMarkerGenerator.createCoupleMarker(
        label: 'You',
        borderColor: BelieveColors.accentLavender,
        isPartner: false,
      );

      expect(partnerMarker, isNotNull);
      expect(userMarker, isNotNull);
    });

    testWidgets('PartnerMapScreen mounts with GoogleMap, overlay buttons, and Check-In button',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(const PartnerMapScreen()));
      await tester.pump();

      // Verify Screen Title
      expect(find.text('Where You Are ✨'), findsOneWidget);

      // Verify GoogleMap widget presence
      expect(find.byType(GoogleMap), findsOneWidget);

      // Verify Overlay Control Buttons
      expect(find.byTooltip('Center on Partner (Love)'), findsOneWidget);
      expect(find.byTooltip('Refresh Location & Fit Both'), findsOneWidget);
      expect(find.byTooltip('Current Location'), findsOneWidget);
      expect(find.byTooltip('Toggle Satellite / Pastel Map'), findsOneWidget);

      // Test tapping Refresh button
      await tester.tap(find.byTooltip('Refresh Location & Fit Both'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Coordinates refreshed & synced with partner! ✨'), findsOneWidget);

      // Verify Bottom Check-In Button
      expect(find.text('Send Arrival Alert & Check-In'), findsOneWidget);

      // Settle any asynchronous marker load timeout timers
      await tester.pump(const Duration(seconds: 5));
    });
  });

  group('Feature 3: Dashboard Dual Avatars', () {
    testWidgets('InterlockingDualAvatars renders user and partner avatars cleanly',
        (tester) async {
      await tester.pumpWidget(createTestApp(const Scaffold(
        body: Center(child: InterlockingDualAvatars()),
      )));
      await tester.pump();

      expect(find.byType(InterlockingDualAvatars), findsOneWidget);
      expect(find.byType(CircleAvatar), findsNWidgets(2));
    });
  });

  group('Feature 2: Dismissible Draggable Sheet in Location Detail', () {
    testWidgets('PartnerLocationDetailScreen contains DraggableScrollableSheet with full map support',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(const PartnerLocationDetailScreen()));
      await tester.pump();

      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      expect(find.text('Today\'s Arrival Log & Places'), findsOneWidget);
      expect(find.byTooltip('Full Screen Map'), findsOneWidget);
    });
  });
}
