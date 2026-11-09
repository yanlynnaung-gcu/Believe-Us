// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trusted_place_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrustedPlaceModel _$TrustedPlaceModelFromJson(Map<String, dynamic> json) =>
    _TrustedPlaceModel(
      id: _stringFromDynamic(json['id']),
      name: json['name'] as String,
      iconName: json['iconName'] as String? ?? 'home',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radiusMeters: (json['radiusMeters'] as num?)?.toDouble() ?? 150.0,
      notifyArrival: json['notifyArrival'] as bool? ?? true,
      notifyDeparture: json['notifyDeparture'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$TrustedPlaceModelToJson(_TrustedPlaceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'iconName': instance.iconName,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'radiusMeters': instance.radiusMeters,
      'notifyArrival': instance.notifyArrival,
      'notifyDeparture': instance.notifyDeparture,
      'createdAt': instance.createdAt.toIso8601String(),
    };
