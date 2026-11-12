import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/errors/failure.dart';
import 'package:thae_nge_lay/core/storage/local_storage_service.dart';
import 'package:thae_nge_lay/features/auth/domain/models/user_profile.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';
import 'package:thae_nge_lay/features/emergency/data/repositories/emergency_repository.dart';
import 'package:thae_nge_lay/features/emergency/data/services/volume_button_service.dart';
import 'package:thae_nge_lay/features/emergency/domain/models/emergency_sos_model.dart';
import 'package:thae_nge_lay/features/emergency/presentation/controllers/emergency_controller.dart';
import 'package:thae_nge_lay/features/emergency/presentation/screens/emergency_alarm_screen.dart';
import 'package:thae_nge_lay/features/location/data/services/location_service.dart';
import 'package:thae_nge_lay/features/location_trust/data/repositories/location_arrival_repository.dart';
import 'package:thae_nge_lay/features/location_trust/domain/models/partner_location_arrival_model.dart';
import 'package:thae_nge_lay/features/location_trust/domain/models/trusted_place_model.dart';
import 'package:thae_nge_lay/features/location_trust/presentation/controllers/location_detail_controller.dart';
import 'package:thae_nge_lay/features/pairing/data/repositories/pairing_repository_impl.dart';
import 'package:thae_nge_lay/features/pairing/domain/models/couple_summary.dart';
import 'package:thae_nge_lay/features/pairing/domain/repositories/pairing_repository.dart';
import 'package:thae_nge_lay/services/mqtt_sos_service.dart';

class _FakeLocalStorageService extends Fake implements LocalStorageService {
  @override
  bool get isOnboardingCompleted => true;
  @override
  Future<void> setOnboardingCompleted(bool value) async {}
  @override
  String? get activeUserId => 'usr_boyfriend';
  @override
  Future<void> setActiveUserId(String? id) async {}
  @override
  String? get authToken => 'token_sos_123';
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

class _FakeLocationService extends Fake implements LocationService {
  @override
  Future<Position?> getCurrentPosition() async {
    return Position(
      longitude: 96.1305,
      latitude: 16.8295,
      timestamp: DateTime.now(),
      accuracy: 3.5,
      altitude: 12.0,
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
    return 2.5;
  }

  @override
  Future<int> getBatteryLevel() async => 92;

  @override
  Future<bool> isCharging() async => false;

  @override
  Stream<Position> getPositionStream() => const Stream.empty();
}

class _FakeEmergencyRepository extends Fake implements EmergencyRepository {
  EmergencySOSModel? lastSentModel;
  int callCount = 0;

  @override
  Future<Either<Failure, EmergencySOSModel>> sendEmergencyAlert({
    required double latitude,
    required double longitude,
    required String message,
    String? address,
    int? timestamp,
  }) async {
    callCount++;
    lastSentModel = EmergencySOSModel(
      alertId: 'sos_mock_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'usr_boyfriend',
      senderName: 'Ko Ko',
      partnerId: 'usr_girlfriend',
      partnerName: 'Thae Thae',
      coupleSpaceId: 'space_couple_sos_123',
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        timestamp ?? DateTime.now().millisecondsSinceEpoch,
      ),
      message: message,
      address: address ?? 'Pyay Road, Kamayut, Yangon',
      status: 'ACTIVE_EMERGENCY',
      isSender: true,
    );
    return right(lastSentModel!);
  }
}

class _FakePairingRepository extends Fake implements PairingRepository {
  @override
  Future<Either<Failure, CoupleSummary>> getCoupleSummary({
    required String coupleSpaceId,
    String? userId,
  }) async {
    return Right(CoupleSummary(
      coupleSpaceId: coupleSpaceId,
      coverPhotoUrl: '/uploads/covers/space.jpg',
      daysTogether: 100,
      myProfile: const UserProfile(
        id: 'usr_boyfriend',
        displayName: 'Ko Ko',
        emailOrPhone: 'koko@believeus.app',
        role: 'BOYFRIEND',
      ),
      partnerProfile: UserProfile(
        id: 'usr_girlfriend',
        displayName: 'Thae Thae',
        emailOrPhone: 'thae@believeus.app',
        role: 'GIRLFRIEND',
        birthday: DateTime(2000, 8, 20),
      ),
    ));
  }
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

class _MockAuthStateNotifier extends AuthStateNotifier {
  @override
  UserProfile? build() {
    return const UserProfile(
      id: 'usr_boyfriend',
      emailOrPhone: 'koko@believeus.app',
      displayName: 'Ko Ko',
      role: 'BOYFRIEND',
      partnerId: 'usr_girlfriend',
      coupleSpaceId: 'space_couple_sos_123',
    );
  }
}

class _FakeMqttSosService extends Fake implements MqttSosService {
  final StreamController<EmergencySOSAlert> _controller =
      StreamController<EmergencySOSAlert>.broadcast();
  @override
  Stream<EmergencySOSAlert> get sosAlertStream => _controller.stream;
  @override
  bool get isConnected => true;
  @override
  Future<void> initialize(
      {required String? userId, required String? coupleSpaceId}) async {}
  @override
  Future<bool> publishEmergencySOS(
          {required String coupleSpaceId, required EmergencySOSAlert alert}) async =>
      true;
  @override
  void dispose() {
    _controller.close();
  }
}

Widget createTestApp(
  Widget child, {
  VolumeButtonService? volumeService,
  EmergencyRepository? emergencyRepo,
}) {
  return ProviderScope(
    overrides: [
      localStorageServiceProvider
          .overrideWithValue(_FakeLocalStorageService()),
      locationServiceProvider
          .overrideWithValue(_FakeLocationService()),
      locationArrivalRepositoryProvider
          .overrideWithValue(_FakeLocationArrivalRepository()),
      pairingRepositoryProvider
          .overrideWithValue(_FakePairingRepository()),
      authStateProvider.overrideWith(() => _MockAuthStateNotifier()),
      mqttSosServiceProvider.overrideWithValue(_FakeMqttSosService()),
      if (volumeService != null)
        volumeButtonServiceProvider.overrideWithValue(volumeService),
      if (emergencyRepo != null)
        emergencyRepositoryProvider.overrideWithValue(emergencyRepo),
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

  group('Feature: Physical Volume Up Emergency SOS Alert', () {
    test('Triple-Press consecutive Volume Up detection triggers emergency action within 3 seconds',
        () async {
      final fakeVolumeSvc = VolumeButtonService(
        testController: StreamController<VolumeButtonEvent>.broadcast(),
      );
      final fakeEmergencyRepo = _FakeEmergencyRepository();

      final container = ProviderContainer(
        overrides: [
          localStorageServiceProvider
              .overrideWithValue(_FakeLocalStorageService()),
          locationServiceProvider
              .overrideWithValue(_FakeLocationService()),
          emergencyRepositoryProvider
              .overrideWithValue(fakeEmergencyRepo),
          volumeButtonServiceProvider
              .overrideWithValue(fakeVolumeSvc),
          authStateProvider.overrideWith(() => _MockAuthStateNotifier()),
          mqttSosServiceProvider.overrideWithValue(_FakeMqttSosService()),
        ],
      );

      final controller = container.read(emergencyControllerProvider.notifier);

      // Verify initial state
      expect(container.read(emergencyControllerProvider).volumePressCount, 0);
      expect(container.read(emergencyControllerProvider).isAlarmActive, false);
      expect(fakeEmergencyRepo.callCount, 0);

      // First Press
      controller.handleVolumeUpPress();
      expect(container.read(emergencyControllerProvider).volumePressCount, 1);
      expect(fakeEmergencyRepo.callCount, 0);

      // Second Press (within 3 seconds)
      controller.handleVolumeUpPress();
      expect(container.read(emergencyControllerProvider).volumePressCount, 2);
      expect(fakeEmergencyRepo.callCount, 0);

      // Third Press (within 3 seconds) -> TRIGGERS EMERGENCY SOS!
      controller.handleVolumeUpPress();
      expect(container.read(emergencyControllerProvider).volumePressCount, 0);

      // Await async GPS capture & API dispatch
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final state = container.read(emergencyControllerProvider);
      expect(state.isAlarmActive, true);
      expect(state.activeAlert, isNotNull);
      expect(state.activeAlert?.isSender, true);
      expect(state.activeAlert?.latitude, 16.8295);
      expect(state.activeAlert?.longitude, 96.1305);
      expect(fakeEmergencyRepo.callCount, 1);
      expect(fakeEmergencyRepo.lastSentModel?.message, contains('EMERGENCY SOS'));

      container.dispose();
      fakeVolumeSvc.dispose();
    });

    test('Volume Up presses separated by more than 3 seconds do not trigger emergency action (accidental prevention)',
        () async {
      final fakeVolumeSvc = VolumeButtonService(
        testController: StreamController<VolumeButtonEvent>.broadcast(),
      );
      final fakeEmergencyRepo = _FakeEmergencyRepository();

      final container = ProviderContainer(
        overrides: [
          localStorageServiceProvider
              .overrideWithValue(_FakeLocalStorageService()),
          locationServiceProvider
              .overrideWithValue(_FakeLocationService()),
          emergencyRepositoryProvider
              .overrideWithValue(fakeEmergencyRepo),
          volumeButtonServiceProvider
              .overrideWithValue(fakeVolumeSvc),
          authStateProvider.overrideWith(() => _MockAuthStateNotifier()),
          mqttSosServiceProvider.overrideWithValue(_FakeMqttSosService()),
        ],
      );

      final controller = container.read(emergencyControllerProvider.notifier);

      // Press 1
      controller.handleVolumeUpPress();
      expect(container.read(emergencyControllerProvider).volumePressCount, 1);

      // Press 2
      controller.handleVolumeUpPress();
      expect(container.read(emergencyControllerProvider).volumePressCount, 2);

      // Simulate a gap exceeding 3.1 seconds
      await Future<void>.delayed(const Duration(milliseconds: 3150));
      expect(container.read(emergencyControllerProvider).volumePressCount, 0);

      // A late 3rd press counts only as press 1 of a new sequence
      controller.handleVolumeUpPress();
      expect(container.read(emergencyControllerProvider).volumePressCount, 1);
      expect(fakeEmergencyRepo.callCount, 0);
      expect(container.read(emergencyControllerProvider).isAlarmActive, false);

      container.dispose();
      fakeVolumeSvc.dispose();
    });

    testWidgets('EmergencyAlarmScreen renders pulsing SOS siren beacon, GPS coordinates & distress actions',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      final testAlert = EmergencySOSModel(
        alertId: 'sos_test_456',
        senderId: 'usr_boyfriend',
        senderName: 'Ko Ko',
        partnerId: 'usr_girlfriend',
        partnerName: 'Thae Thae',
        coupleSpaceId: 'space_couple_sos_123',
        latitude: 16.82950,
        longitude: 96.13050,
        timestamp: DateTime.now(),
        message: '🚨 EMERGENCY SOS! Physical Volume Up pressed 3 times!',
        address: 'No. 42, Pyay Road, Kamayut Township, Yangon',
        status: 'ACTIVE_EMERGENCY',
        isSender: true,
      );

      await tester.pumpWidget(createTestApp(
        EmergencyAlarmScreen(alert: testAlert),
      ));
      await tester.pump();

      // Verify SOS Status Banner & Siren
      expect(find.text('SOS DISTRESS BEACON ACTIVE'), findsOneWidget);
      expect(find.byIcon(LucideIcons.siren), findsOneWidget);
      expect(find.text('Emergency Alert Sent!'), findsOneWidget);

      // Verify Distress Message
      expect(find.textContaining('Physical Volume Up pressed 3 times!'), findsOneWidget);

      // Verify High Accuracy GPS location & Address
      expect(find.text('16.82950° N, 96.13050° E'), findsOneWidget);
      expect(find.text('No. 42, Pyay Road, Kamayut Township, Yangon'), findsOneWidget);
      expect(find.text('High Accuracy GPS'), findsOneWidget);

      // Verify Action Buttons
      expect(find.text('Direct Call Partner'), findsOneWidget);
      expect(find.text('Call 199 (Police)'), findsOneWidget);
      expect(find.text('View on Map'), findsOneWidget);
      expect(find.text('I\'m Safe Now • Resolve Alert'), findsOneWidget);

      // Settle any animation frame safely
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('Partner receiving emergency SOS renders distress alert and immediate partner contact button',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      final partnerAlert = EmergencySOSModel(
        alertId: 'sos_partner_789',
        senderId: 'usr_girlfriend',
        senderName: 'Thae Thae',
        partnerId: 'usr_boyfriend',
        partnerName: 'Ko Ko',
        coupleSpaceId: 'space_couple_sos_123',
        latitude: 16.82710,
        longitude: 96.12840,
        timestamp: DateTime.now(),
        message: '🚨 SOS! I need immediate help! My live location is attached.',
        address: 'Kamayut, Yangon',
        status: 'ACTIVE_EMERGENCY',
        isSender: false,
      );

      await tester.pumpWidget(createTestApp(
        EmergencyAlarmScreen(alert: partnerAlert),
      ));
      await tester.pump();

      // Verify Partner Distress Banner
      expect(find.text('DISTRESS ALERT RECEIVED'), findsOneWidget);
      expect(find.text('🚨 Thae Thae Needs Immediate Help!'), findsOneWidget);
      expect(find.text('Call Thae Thae Immediately'), findsOneWidget);

      // Verify Coordinates
      expect(find.text('16.82710° N, 96.12840° E'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));
    });
  });
}
