import 'dart:async';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thae_nge_lay/core/network/websocket_sync_service.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';
import 'package:thae_nge_lay/features/emergency/data/repositories/emergency_repository.dart';
import 'package:thae_nge_lay/features/emergency/data/services/volume_button_service.dart';
import 'package:thae_nge_lay/features/emergency/domain/models/emergency_sos_model.dart';
import 'package:thae_nge_lay/features/emergency/presentation/controllers/emergency_state.dart';
import 'package:thae_nge_lay/features/emergency/presentation/controllers/volume_triple_press_detector.dart';
import 'package:thae_nge_lay/features/location/data/services/location_service.dart';
import 'package:thae_nge_lay/features/location_trust/presentation/controllers/location_detail_controller.dart';
import 'package:thae_nge_lay/services/mqtt_sos_service.dart';

export 'emergency_state.dart';

part 'emergency_controller.g.dart';

@Riverpod(keepAlive: true)
class EmergencyController extends _$EmergencyController {
  StreamSubscription? _volumeSub;
  StreamSubscription? _wsAlertSub;
  StreamSubscription? _mqttAlertSub;
  VolumeTriplePressDetector? _pressDetector;

  @override
  EmergencyState build() {
    _pressDetector = VolumeTriplePressDetector(
      onCountChanged: (count) {
        state = state.copyWith(volumePressCount: count);
      },
      onTriplePress: () {
        triggerEmergencySOS(
          message: '🚨 EMERGENCY SOS! Physical Volume Up pressed 3 times!',
        );
      },
    );

    ref.onDispose(() {
      _volumeSub?.cancel();
      _wsAlertSub?.cancel();
      _mqttAlertSub?.cancel();
      _pressDetector?.dispose();
    });

    final auth = ref.watch(authStateProvider);
    ref.read(mqttSosServiceProvider).initialize(
      userId: auth?.id,
      coupleSpaceId: auth?.coupleSpaceId,
    );

    _initSubscriptions();
    return const EmergencyState();
  }

  void _initSubscriptions() {
    final volumeSvc = ref.watch(volumeButtonServiceProvider);
    _volumeSub?.cancel();
    _volumeSub = volumeSvc.volumeButtonEvents.listen((event) {
      if (event == VolumeButtonEvent.VOLUME_UP) {
        handleVolumeUpPress();
      }
    });

    final ws = ref.watch(webSocketSyncServiceProvider);
    _wsAlertSub?.cancel();
    _wsAlertSub = ws.onEvent('EMERGENCY_ALERT').listen((event) {
      _handleIncomingEmergencyAlert(event.data);
    });

    final mqtt = ref.watch(mqttSosServiceProvider);
    _mqttAlertSub?.cancel();
    _mqttAlertSub = mqtt.sosAlertStream.listen((alert) {
      _handleIncomingMqttAlert(alert);
    });
  }

  void handleVolumeUpPress() {
    _pressDetector?.handlePress();
  }

  /// High-accuracy GPS capture, emergency API dispatch, and local alarm activation
  Future<EmergencySOSModel?> triggerEmergencySOS({String? message}) async {
    state = state.copyWith(isTriggering: true, errorMessage: null);

    for (final ms in [0, 160, 320]) {
      Future.delayed(Duration(milliseconds: ms), HapticFeedback.heavyImpact);
    }

    final loc = await _resolveLocation();
    final distressMsg = (message != null && message.trim().isNotEmpty)
        ? message.trim()
        : '🚨 EMERGENCY SOS: Immediate assistance required!';

    final repo = ref.read(emergencyRepositoryProvider);
    final result = await repo.sendEmergencyAlert(
      latitude: loc.lat,
      longitude: loc.lng,
      message: distressMsg,
      address: loc.address,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    final auth = ref.read(authStateProvider);
    final coupleSpaceId = auth?.coupleSpaceId ?? '';
    final senderName = auth?.displayName ?? 'You';

    // Broadcast via WebSocket to /topic/couple.{coupleSpaceId}.emergency
    ref.read(webSocketSyncServiceProvider).sendEvent(
      event: 'EMERGENCY_ALERT',
      topic: '/topic/couple.$coupleSpaceId.emergency',
      data: {
        'alertId': 'sos_${DateTime.now().millisecondsSinceEpoch}',
        'type': 'EMERGENCY_SOS',
        'senderId': auth?.id ?? '',
        'senderName': senderName,
        'coupleSpaceId': coupleSpaceId,
        'latitude': loc.lat,
        'longitude': loc.lng,
        'address': loc.address,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'message': distressMsg,
        'status': 'ACTIVE_EMERGENCY',
      },
    );

    EmergencySOSModel activeModel = EmergencySOSModel(
      alertId: 'sos_${DateTime.now().millisecondsSinceEpoch}',
      senderId: auth?.id ?? 'me',
      senderName: senderName,
      partnerId: auth?.partnerId,
      coupleSpaceId: coupleSpaceId,
      latitude: loc.lat,
      longitude: loc.lng,
      timestamp: DateTime.now(),
      message: distressMsg,
      address: loc.address,
      status: 'ACTIVE_EMERGENCY',
      isSender: true,
    );

    // Mission-Critical MQTT Publish with QoS 1 (At least once delivery) for offline resilience
    if (coupleSpaceId.isNotEmpty) {
      ref.read(mqttSosServiceProvider).publishEmergencySOS(
        coupleSpaceId: coupleSpaceId,
        alert: activeModel,
      );
    }

    result.fold(
      (failure) {
        state = state.copyWith(
          isTriggering: false,
          isAlarmActive: true,
          activeAlert: activeModel,
          errorMessage: failure.message,
        );
      },
      (sosModel) {
        activeModel = sosModel;
        state = state.copyWith(
          isTriggering: false,
          isAlarmActive: true,
          activeAlert: sosModel,
          errorMessage: null,
        );
      },
    );

    return activeModel;
  }

  Future<({double lat, double lng, String address})> _resolveLocation() async {
    double lat = 16.8295, lng = 96.1305;
    String addr = 'Live GPS Location';
    try {
      final pos = await ref.read(locationServiceProvider).getCurrentPosition();
      if (pos != null) {
        lat = pos.latitude;
        lng = pos.longitude;
      }
    } catch (_) {}
    try {
      final resolved = await ref.read(geocodingServiceProvider).reverseGeocode(
        latitude: lat,
        longitude: lng,
      );
      if (resolved.isNotEmpty) addr = resolved;
    } catch (_) {}
    return (lat: lat, lng: lng, address: addr);
  }

  void _handleIncomingMqttAlert(EmergencySOSAlert alert) {
    state = state.copyWith(
      activeAlert: alert,
      isAlarmActive: true,
    );
    HapticFeedback.heavyImpact();
  }

  void _handleIncomingEmergencyAlert(dynamic rawData) {
    if (rawData is Map) {
      final map = Map<String, dynamic>.from(rawData);
      final model = EmergencySOSModel.fromJson(map, isSender: false);
      state = state.copyWith(
        activeAlert: model,
        isAlarmActive: true,
      );
      HapticFeedback.heavyImpact();
    }
  }

  void dismissAlert() {
    final alert = state.activeAlert;
    if (alert != null) {
      final auth = ref.read(authStateProvider);
      final coupleSpaceId = auth?.coupleSpaceId ?? alert.coupleSpaceId;
      ref.read(webSocketSyncServiceProvider).sendEvent(
        event: 'EMERGENCY_RESOLVED',
        topic: '/topic/couple.$coupleSpaceId.emergency',
        data: {
          'alertId': alert.alertId,
          'status': 'RESOLVED',
          'resolvedBy': auth?.displayName ?? 'You',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
    }

    state = state.copyWith(
      activeAlert: null,
      isAlarmActive: false,
      volumePressCount: 0,
      errorMessage: null,
    );
  }
}
