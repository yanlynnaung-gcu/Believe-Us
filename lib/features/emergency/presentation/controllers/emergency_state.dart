import 'package:thae_nge_lay/features/emergency/domain/models/emergency_sos_model.dart';

/// State representation for emergency listening, triggers, and active alerts.
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
