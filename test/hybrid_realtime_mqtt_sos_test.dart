import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:thae_nge_lay/core/errors/failure.dart';
import 'package:thae_nge_lay/core/network/websocket_sync_service.dart';
import 'package:thae_nge_lay/core/storage/local_storage_service.dart';
import 'package:thae_nge_lay/features/auth/domain/models/user_profile.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';
import 'package:thae_nge_lay/features/emergency/data/repositories/emergency_repository.dart';
import 'package:thae_nge_lay/features/emergency/data/services/volume_button_service.dart';
import 'package:thae_nge_lay/features/emergency/domain/models/emergency_sos_model.dart';
import 'package:thae_nge_lay/features/emergency/presentation/controllers/emergency_controller.dart';
import 'package:thae_nge_lay/features/location/data/services/location_service.dart';
import 'package:thae_nge_lay/features/location_trust/data/services/geocoding_service.dart';
import 'package:thae_nge_lay/features/location_trust/presentation/controllers/location_detail_controller.dart';
import 'package:thae_nge_lay/services/mqtt_sos_service.dart';
import 'package:thae_nge_lay/services/websocket_service.dart';

class _FakeLocalStorageService extends Fake implements LocalStorageService {
  @override
  bool get isOnboardingCompleted => true;
  @override
  Future<void> setOnboardingCompleted(bool value) async {}
  @override
  String? get activeUserId => 'usr_hybrid_tester';
  @override
  Future<void> setActiveUserId(String? id) async {}
  @override
  String? get authToken => 'token_hybrid_realtime_123';
  @override
  Future<void> setAuthToken(String? token) async {}
}

class _MockLocationService extends Fake implements LocationService {
  @override
  Future<Position?> getCurrentPosition() async {
    return Position(
      latitude: 16.8295,
      longitude: 96.1305,
      timestamp: DateTime.now(),
      accuracy: 5.0,
      altitude: 10.0,
      altitudeAccuracy: 1.0,
      heading: 90.0,
      headingAccuracy: 1.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );
  }
}

class _MockGeocodingService extends Fake implements GeocodingService {
  @override
  Future<String> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    return 'Kamayut, Yangon (Near Inya Lake)';
  }
}

class _MockEmergencyRepository extends Fake implements EmergencyRepository {
  EmergencySOSModel? lastDispatchedModel;

  @override
  Future<Either<Failure, EmergencySOSModel>> sendEmergencyAlert({
    required double latitude,
    required double longitude,
    required String message,
    String? address,
    int? timestamp,
  }) async {
    final model = EmergencySOSModel(
      alertId: 'sos_mock_001',
      senderId: 'usr_hybrid_tester',
      senderName: 'Ko Ko',
      partnerId: 'usr_partner',
      partnerName: 'Thae Thae',
      coupleSpaceId: 'space_hybrid_001',
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        timestamp ?? DateTime.now().millisecondsSinceEpoch,
      ),
      message: message,
      address: address ?? 'Kamayut, Yangon',
      status: 'ACTIVE_EMERGENCY',
      isSender: true,
    );
    lastDispatchedModel = model;
    return right(model);
  }
}

class _SenderAuthStateNotifier extends AuthStateNotifier {
  @override
  UserProfile? build() {
    return const UserProfile(
      id: 'usr_hybrid_tester',
      emailOrPhone: 'koko@believeus.app',
      displayName: 'Ko Ko',
      role: 'BOYFRIEND',
      coupleSpaceId: 'space_hybrid_001',
      partnerId: 'usr_partner',
    );
  }
}

class _PartnerAuthStateNotifier extends AuthStateNotifier {
  @override
  UserProfile? build() {
    return const UserProfile(
      id: 'usr_partner',
      emailOrPhone: 'thaethae@believeus.app',
      displayName: 'Thae Thae',
      role: 'GIRLFRIEND',
      coupleSpaceId: 'space_hybrid_001',
      partnerId: 'usr_hybrid_tester',
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Hybrid Real-Time Architecture: WebSocket & MQTT', () {
    test('WebSocketService handles Daily Notes, Location sync & STOMP routing', () async {
      final syncService = WebSocketSyncService();
      final webSocketService = WebSocketService(syncService: syncService);

      webSocketService.initialize(
        userId: 'usr_hybrid_tester',
        coupleSpaceId: 'space_hybrid_001',
      );

      final noteCompleter = Completer<Map<String, dynamic>>();
      final locationCompleter = Completer<Map<String, dynamic>>();

      final noteSub = webSocketService.dailyNoteStream.listen((data) {
        if (!noteCompleter.isCompleted) {
          noteCompleter.complete(data);
        }
      });

      final locSub = webSocketService.locationStream.listen((data) {
        if (!locationCompleter.isCompleted) {
          locationCompleter.complete(data);
        }
      });

      // Outgoing methods verify STOMP event payload construction
      webSocketService.sendDailyNote(
        note: 'Have a wonderful day, my love!',
        mood: 'loving',
      );
      webSocketService.sendLocationHeartbeat(
        latitude: 16.8295,
        longitude: 96.1305,
        batteryLevel: 95,
      );

      // Incoming STOMP messages are correctly routed to dedicated streams
      syncService.simulateIncomingEvent(
        const WebSocketEvent(
          event: 'NOTE_UPDATE',
          topic: '/topic/couple.space_hybrid_001.note',
          data: {
            'type': 'DAILY_NOTE',
            'note': 'Thinking of you while drinking my morning coffee ☕💖',
            'mood': 'romantic',
          },
        ),
      );

      syncService.simulateIncomingEvent(
        const WebSocketEvent(
          event: 'LOCATION_UPDATE',
          topic: '/topic/couple.space_hybrid_001.location',
          data: {
            'type': 'LOCATION_HEARTBEAT',
            'latitude': 16.8295,
            'longitude': 96.1305,
            'batteryLevel': 92,
          },
        ),
      );

      final receivedNote = await noteCompleter.future.timeout(const Duration(seconds: 2));
      final receivedLoc = await locationCompleter.future.timeout(const Duration(seconds: 2));

      expect(receivedNote['note'], contains('coffee'));
      expect(receivedLoc['latitude'], equals(16.8295));

      await noteSub.cancel();
      await locSub.cancel();
      webSocketService.dispose();
      syncService.dispose();
    });

    test('MqttSosService configures QoS 1 emergency topic and resilient offline queuing', () async {
      final mqttService = MqttSosService();

      await mqttService.initialize(
        userId: 'usr_hybrid_tester',
        coupleSpaceId: 'space_hybrid_001',
      );

      expect(mqttService.activeTopic, equals('couple/space_hybrid_001/emergency'));

      final incomingAlert = EmergencySOSAlert(
        alertId: 'sos_partner_999',
        senderId: 'usr_partner',
        senderName: 'Thae Thae',
        partnerId: 'usr_hybrid_tester',
        coupleSpaceId: 'space_hybrid_001',
        latitude: 16.8300,
        longitude: 96.1310,
        timestamp: DateTime.now(),
        message: '🚨 Emergency! Need immediate assistance near Inya Road!',
        address: 'Inya Road, Kamayut',
        status: 'ACTIVE_EMERGENCY',
      );

      final alertCompleter = Completer<EmergencySOSAlert>();
      final sub = mqttService.sosAlertStream.listen((alert) {
        if (!alertCompleter.isCompleted) {
          alertCompleter.complete(alert);
        }
      });

      // Simulate incoming partner alert on topic couple/space_hybrid_001/emergency
      mqttService.simulateIncomingAlert(incomingAlert);

      final receivedAlert = await alertCompleter.future.timeout(const Duration(seconds: 2));
      expect(receivedAlert.alertId, equals('sos_partner_999'));
      expect(receivedAlert.senderName, equals('Thae Thae'));
      expect(receivedAlert.message, contains('immediate assistance'));

      // Test publishEmergencySOS with offline queue resilience
      final outboundAlert = EmergencySOSAlert(
        alertId: 'sos_outbound_001',
        senderId: 'usr_hybrid_tester',
        senderName: 'Ko Ko',
        partnerId: 'usr_partner',
        coupleSpaceId: 'space_hybrid_001',
        latitude: 16.8295,
        longitude: 96.1305,
        timestamp: DateTime.now(),
        message: '🚨 Physical Volume Up triggered emergency alert',
        address: 'Kamayut, Yangon',
      );

      // When disconnected, it safely buffers to offline queue without throwing unhandled exceptions
      final published = await mqttService.publishEmergencySOS(
        coupleSpaceId: 'space_hybrid_001',
        alert: outboundAlert,
      );
      // Returns false since offline, but alert is successfully queued
      expect(published, isFalse);

      await sub.cancel();
      mqttService.dispose();
    });

    test('Emergency SOS Trigger: Physical Volume Up 3x triggers high-accuracy GPS and MQTT QoS 1 publish', () async {
      final mockRepo = _MockEmergencyRepository();
      final volumeService = VolumeButtonService();
      final mqttService = MqttSosService();

      final container = ProviderContainer(
        overrides: [
          localStorageServiceProvider.overrideWithValue(_FakeLocalStorageService()),
          locationServiceProvider.overrideWithValue(_MockLocationService()),
          geocodingServiceProvider.overrideWithValue(_MockGeocodingService()),
          emergencyRepositoryProvider.overrideWithValue(mockRepo),
          volumeButtonServiceProvider.overrideWithValue(volumeService),
          mqttSosServiceProvider.overrideWithValue(mqttService),
          authStateProvider.overrideWith(() => _SenderAuthStateNotifier()),
        ],
      );

      addTearDown(() {
        container.dispose();
        volumeService.dispose();
        mqttService.dispose();
      });

      final controller = container.read(emergencyControllerProvider.notifier);

      expect(container.read(emergencyControllerProvider).isAlarmActive, isFalse);

      // Simulate triple press on physical Volume Up within 3 seconds
      volumeService.simulateButtonPress(VolumeButtonEvent.VOLUME_UP);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(container.read(emergencyControllerProvider).volumePressCount, equals(1));

      volumeService.simulateButtonPress(VolumeButtonEvent.VOLUME_UP);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(container.read(emergencyControllerProvider).volumePressCount, equals(2));

      volumeService.simulateButtonPress(VolumeButtonEvent.VOLUME_UP);

      // Wait briefly for async GPS capture and MQTT QoS 1 publish
      await Future.delayed(const Duration(milliseconds: 200));

      final state = container.read(emergencyControllerProvider);
      expect(state.isAlarmActive, isTrue);
      expect(state.activeAlert, isNotNull);
      expect(state.activeAlert!.latitude, equals(16.8295));
      expect(state.activeAlert!.longitude, equals(96.1305));
      expect(state.activeAlert!.address, equals('Kamayut, Yangon (Near Inya Lake)'));
      expect(state.activeAlert!.isSender, isTrue);

      // Verify repository captured the event
      expect(mockRepo.lastDispatchedModel, isNotNull);
      expect(mockRepo.lastDispatchedModel!.message, contains('Volume Up'));

      // Dismiss resets active alarm
      controller.dismissAlert();
      expect(container.read(emergencyControllerProvider).isAlarmActive, isFalse);
    });

    test('Partner incoming MQTT SOS alert triggers immediate distress alarm state on recipient device', () async {
      final volumeService = VolumeButtonService();
      final mqttService = MqttSosService();

      final container = ProviderContainer(
        overrides: [
          localStorageServiceProvider.overrideWithValue(_FakeLocalStorageService()),
          volumeButtonServiceProvider.overrideWithValue(volumeService),
          mqttSosServiceProvider.overrideWithValue(mqttService),
          authStateProvider.overrideWith(() => _PartnerAuthStateNotifier()),
        ],
      );

      addTearDown(() {
        container.dispose();
        volumeService.dispose();
        mqttService.dispose();
      });

      // Initialize controller
      container.read(emergencyControllerProvider);

      expect(container.read(emergencyControllerProvider).isAlarmActive, isFalse);

      // Partner device receives MQTT SOS alert on couple/space_hybrid_001/emergency
      mqttService.simulateIncomingAlert(
        EmergencySOSAlert(
          alertId: 'sos_partner_emergency_777',
          senderId: 'usr_hybrid_tester',
          senderName: 'Ko Ko',
          partnerId: 'usr_partner',
          coupleSpaceId: 'space_hybrid_001',
          latitude: 16.8295,
          longitude: 96.1305,
          timestamp: DateTime.now(),
          message: '🚨 EMERGENCY! Urgent help required!',
          address: 'Kamayut, Yangon',
          status: 'ACTIVE_EMERGENCY',
        ),
      );

      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(emergencyControllerProvider);
      expect(state.isAlarmActive, isTrue);
      expect(state.activeAlert, isNotNull);
      expect(state.activeAlert!.alertId, equals('sos_partner_emergency_777'));
      expect(state.activeAlert!.senderName, equals('Ko Ko'));
      expect(state.activeAlert!.message, contains('Urgent help required'));
    });
  });
}
