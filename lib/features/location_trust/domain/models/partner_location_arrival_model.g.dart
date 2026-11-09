// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_location_arrival_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PartnerLocationArrivalModel _$PartnerLocationArrivalModelFromJson(
  Map<String, dynamic> json,
) => _PartnerLocationArrivalModel(
  id: _stringFromDynamic(json['id']),
  userId: json['userId'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  addressLine: json['addressLine'] as String,
  placeName: json['placeName'] as String,
  status:
      $enumDecodeNullable(_$MovementStatusEnumMap, json['status']) ??
      MovementStatus.stationary,
  speedKmh: (json['speedKmh'] as num?)?.toDouble() ?? 0.0,
  batteryLevel: (json['batteryLevel'] as num?)?.toInt() ?? 100,
  isCharging: json['isCharging'] as bool? ?? false,
  arrivedAt: DateTime.parse(json['arrivedAt'] as String),
  departedAt: json['departedAt'] == null
      ? null
      : DateTime.parse(json['departedAt'] as String),
  lastUpdatedAt: DateTime.parse(json['lastUpdatedAt'] as String),
);

Map<String, dynamic> _$PartnerLocationArrivalModelToJson(
  _PartnerLocationArrivalModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'addressLine': instance.addressLine,
  'placeName': instance.placeName,
  'status': _$MovementStatusEnumMap[instance.status]!,
  'speedKmh': instance.speedKmh,
  'batteryLevel': instance.batteryLevel,
  'isCharging': instance.isCharging,
  'arrivedAt': instance.arrivedAt.toIso8601String(),
  'departedAt': instance.departedAt?.toIso8601String(),
  'lastUpdatedAt': instance.lastUpdatedAt.toIso8601String(),
};

const _$MovementStatusEnumMap = {
  MovementStatus.stationary: 'STATIONARY',
  MovementStatus.moving: 'MOVING',
};
