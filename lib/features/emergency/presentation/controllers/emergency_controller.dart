import 'dart:async';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thae_nge_lay/core/network/websocket_sync_service.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';
import 'package:thae_nge_lay/features/emergency/data/repositories/emergency_repository.dart';
import 'package:thae_nge_lay/features/emergency/data/services/volume_button_service.dart';
import 'package:thae_nge_lay/features/emergency/domain/models/emergency_sos_model.dart';
import 'package:thae_nge_lay/features/location/data/services/location_service.dart';
import 'package:thae_nge_lay/features/location_trust/presentation/controllers/location_detail_controller.dart';
import 'package:thae_nge_lay/services/mqtt_sos_service.dart';

part 'emergency_controller.g.dart';

class EmergencyState {
  final bool isListening;
  final bool isTriggering;
  final int volumePressCount;
  final EmergencySOSModel? activeAlert;
  final String? errorMessage;
  final bool isAlarmActive;

  const EmergencyState({
    this.isListening = true,
    this.isTriggering = false,
    this.volumePressCount = 0,
    this.activeAlert,
    this.errorMessage,
    this.isAlarmActive = false,
  });

  EmergencyState copyWith({
    bool? isListening,
    bool? isTriggering,
    int? volumePressCount,
    EmergencySOSModel? activeAlert,
    String? errorMessage,
    bool? isAlarmActive,
  }) {
    return EmergencyState(
      isListening: isListening ?? this.isListening,
      isTriggering: isTriggering ?? this.isTriggering,
      volumePressCount: volumePressCount ?? this.volumePressCount,
      activeAlert: activeAlert ?? this.activeAlert,
      errorMessage: errorMessage,
      isAlarmActive: isAlarmActive ?? this.isAlarmActive,
    );
  }
}

@Riverpod(keepAlive: true)
class EmergencyController extends _$EmergencyController {
  StreamSubscription? _volumeSub;
  StreamSubscription? _wsAlertSub;
  StreamSubscription? _mqttAlertSub;
  final List<DateTime> _pressTimestamps = [];
  Timer? _pressResetTimer;

  @override
  EmergencyState build() {
    ref.onDispose(() {
      _volumeSub?.cancel();
      _wsAlertSub?.cancel();
      _mqttAlertSub?.cancel();
      _pressResetTimer?.cancel();
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

  /// Triple-press consecutive detection logic:
  /// Requires 3 presses within a 3.0 second window.
  void handleVolumeUpPress() {
    final now = DateTime.now();

    // 1. Purge any presses that occurred more than 3000ms ago
    _pressTimestamps.removeWhere(
      (t) => now.difference(t).inMilliseconds > 3000,
    );
    _pressTimestamps.add(now);

    final currentCount = _pressTimestamps.length;
    state = state.copyWith(volumePressCount: currentCount);

    // Haptic tick feedback on physical button press
    HapticFeedback.selectionClick();

    // Cancel any previous trailing reset timer
    _pressResetTimer?.cancel();
    _pressResetTimer = Timer(const Duration(milliseconds: 3100), () {
      _pressTimestamps.clear();
      state = state.copyWith(volumePressCount: 0);
    });

    // 2. Trigger instant emergency action upon confirmed triple press
    if (currentCount >= 3) {
      _pressTimestamps.clear();
      _pressResetTimer?.cancel();
      state = state.copyWith(volumePressCount: 0);
      triggerEmergencySOS(
        message: '🚨 EMERGENCY SOS! Physical Volume Up pressed 3 times!',
      );
    }
  }

  /// High-accuracy GPS capture, emergency API dispatch, and local alarm activation
  Future<EmergencySOSModel?> triggerEmergencySOS({String? message}) async {
    state = state.copyWith(isTriggering: true, errorMessage: null);

    // Heavy urgent haptic feedback pulses (SOS pattern)
    HapticFeedback.heavyImpact();
    Future.delayed(
      const Duration(milliseconds: 160),
      () => HapticFeedback.heavyImpact(),
    );
    Future.delayed(
      const Duration(milliseconds: 320),
      () => HapticFeedback.heavyImpact(),
    );

    final locationSvc = ref.read(locationServiceProvider);
    double latitude = 16.8295;
    double longitude = 96.1305;
    String address = 'Live GPS Location';

    try {
      final pos = await locationSvc.getCurrentPosition();
      if (pos != null) {
        latitude = pos.latitude;
        longitude = pos.longitude;
      }
    } catch (_) {}

    try {
      final geocoding = ref.read(geocodingServiceProvider);
      final resolved = await geocoding.reverseGeocode(
        latitude: latitude,
        longitude: longitude,
      );
      if (resolved.isNotEmpty) {
        address = resolved;
      }
    } catch (_) {}

    final distressMsg = (message != null && message.trim().isNotEmpty)
        ? message.trim()
        : '🚨 EMERGENCY SOS: Immediate assistance required!';

    final repo = ref.read(emergencyRepositoryProvider);
    final result = await repo.sendEmergencyAlert(
      latitude: latitude,
      longitude: longitude,
      message: distressMsg,
      address: address,
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
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
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
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
      message: distressMsg,
      address: address,
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
        // Even if offline/server is restarting, maintain active local emergency state
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
