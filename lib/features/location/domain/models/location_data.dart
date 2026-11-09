import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_data.freezed.dart';
part 'location_data.g.dart';

@freezed
abstract class PartnerLocationStatus with _$PartnerLocationStatus {
  const factory PartnerLocationStatus({
    required double latitude,
    required double longitude,
    required String placeName,
    required int batteryLevel,
    required bool isCharging,
    required DateTime lastUpdated,
    @Default(true) bool isOnline,
    double? distanceKm,
  }) = _PartnerLocationStatus;

  factory PartnerLocationStatus.fromJson(Map<String, dynamic> json) =>
      _$PartnerLocationStatusFromJson(json);
}
