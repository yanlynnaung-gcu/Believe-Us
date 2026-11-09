// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PartnerLocationStatus _$PartnerLocationStatusFromJson(
  Map<String, dynamic> json,
) => _PartnerLocationStatus(
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  placeName: json['placeName'] as String,
  batteryLevel: (json['batteryLevel'] as num).toInt(),
  isCharging: json['isCharging'] as bool,
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  isOnline: json['isOnline'] as bool? ?? true,
  distanceKm: (json['distanceKm'] as num?)?.toDouble(),
);

Map<String, dynamic> _$PartnerLocationStatusToJson(
  _PartnerLocationStatus instance,
) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'placeName': instance.placeName,
  'batteryLevel': instance.batteryLevel,
  'isCharging': instance.isCharging,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
  'isOnline': instance.isOnline,
  'distanceKm': instance.distanceKm,
};
