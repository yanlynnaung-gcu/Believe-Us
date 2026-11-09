import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_location_arrival_model.freezed.dart';
part 'partner_location_arrival_model.g.dart';

String _stringFromDynamic(dynamic val) => val?.toString() ?? '';

enum MovementStatus {
  @JsonValue('STATIONARY')
  stationary,
  @JsonValue('MOVING')
  moving,
}

@freezed
abstract class PartnerLocationArrivalModel with _$PartnerLocationArrivalModel {
  const factory PartnerLocationArrivalModel({
    @JsonKey(fromJson: _stringFromDynamic) required String id,
    required String userId,
    required double latitude,
    required double longitude,
    required String addressLine,
    required String placeName,
    @Default(MovementStatus.stationary) MovementStatus status,
    @Default(0.0) double speedKmh,
    @Default(100) int batteryLevel,
    @Default(false) bool isCharging,
    required DateTime arrivedAt,
    DateTime? departedAt,
    required DateTime lastUpdatedAt,
  }) = _PartnerLocationArrivalModel;

  factory PartnerLocationArrivalModel.fromJson(Map<String, dynamic> json) =>
      _$PartnerLocationArrivalModelFromJson(json);
}
