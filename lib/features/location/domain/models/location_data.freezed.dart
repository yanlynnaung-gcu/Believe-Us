// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PartnerLocationStatus {

 double get latitude; double get longitude; String get placeName; int get batteryLevel; bool get isCharging; DateTime get lastUpdated; bool get isOnline; double? get distanceKm;
/// Create a copy of PartnerLocationStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PartnerLocationStatusCopyWith<PartnerLocationStatus> get copyWith => _$PartnerLocationStatusCopyWithImpl<PartnerLocationStatus>(this as PartnerLocationStatus, _$identity);

  /// Serializes this PartnerLocationStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PartnerLocationStatus&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.placeName, placeName) || other.placeName == placeName)&&(identical(other.batteryLevel, batteryLevel) || other.batteryLevel == batteryLevel)&&(identical(other.isCharging, isCharging) || other.isCharging == isCharging)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,placeName,batteryLevel,isCharging,lastUpdated,isOnline,distanceKm);

@override
String toString() {
  return 'PartnerLocationStatus(latitude: $latitude, longitude: $longitude, placeName: $placeName, batteryLevel: $batteryLevel, isCharging: $isCharging, lastUpdated: $lastUpdated, isOnline: $isOnline, distanceKm: $distanceKm)';
}


}

/// @nodoc
abstract mixin class $PartnerLocationStatusCopyWith<$Res>  {
  factory $PartnerLocationStatusCopyWith(PartnerLocationStatus value, $Res Function(PartnerLocationStatus) _then) = _$PartnerLocationStatusCopyWithImpl;
@useResult
$Res call({
 double latitude, double longitude, String placeName, int batteryLevel, bool isCharging, DateTime lastUpdated, bool isOnline, double? distanceKm
});




}
/// @nodoc
class _$PartnerLocationStatusCopyWithImpl<$Res>
    implements $PartnerLocationStatusCopyWith<$Res> {
  _$PartnerLocationStatusCopyWithImpl(this._self, this._then);

  final PartnerLocationStatus _self;
  final $Res Function(PartnerLocationStatus) _then;

/// Create a copy of PartnerLocationStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? latitude = null,Object? longitude = null,Object? placeName = null,Object? batteryLevel = null,Object? isCharging = null,Object? lastUpdated = null,Object? isOnline = null,Object? distanceKm = freezed,}) {
  return _then(_self.copyWith(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,placeName: null == placeName ? _self.placeName : placeName // ignore: cast_nullable_to_non_nullable
as String,batteryLevel: null == batteryLevel ? _self.batteryLevel : batteryLevel // ignore: cast_nullable_to_non_nullable
as int,isCharging: null == isCharging ? _self.isCharging : isCharging // ignore: cast_nullable_to_non_nullable
as bool,lastUpdated: null == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,distanceKm: freezed == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [PartnerLocationStatus].
extension PartnerLocationStatusPatterns on PartnerLocationStatus {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PartnerLocationStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PartnerLocationStatus() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PartnerLocationStatus value)  $default,){
final _that = this;
switch (_that) {
case _PartnerLocationStatus():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PartnerLocationStatus value)?  $default,){
final _that = this;
switch (_that) {
case _PartnerLocationStatus() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double latitude,  double longitude,  String placeName,  int batteryLevel,  bool isCharging,  DateTime lastUpdated,  bool isOnline,  double? distanceKm)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PartnerLocationStatus() when $default != null:
return $default(_that.latitude,_that.longitude,_that.placeName,_that.batteryLevel,_that.isCharging,_that.lastUpdated,_that.isOnline,_that.distanceKm);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double latitude,  double longitude,  String placeName,  int batteryLevel,  bool isCharging,  DateTime lastUpdated,  bool isOnline,  double? distanceKm)  $default,) {final _that = this;
switch (_that) {
case _PartnerLocationStatus():
return $default(_that.latitude,_that.longitude,_that.placeName,_that.batteryLevel,_that.isCharging,_that.lastUpdated,_that.isOnline,_that.distanceKm);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double latitude,  double longitude,  String placeName,  int batteryLevel,  bool isCharging,  DateTime lastUpdated,  bool isOnline,  double? distanceKm)?  $default,) {final _that = this;
switch (_that) {
case _PartnerLocationStatus() when $default != null:
return $default(_that.latitude,_that.longitude,_that.placeName,_that.batteryLevel,_that.isCharging,_that.lastUpdated,_that.isOnline,_that.distanceKm);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PartnerLocationStatus implements PartnerLocationStatus {
  const _PartnerLocationStatus({required this.latitude, required this.longitude, required this.placeName, required this.batteryLevel, required this.isCharging, required this.lastUpdated, this.isOnline = true, this.distanceKm});
  factory _PartnerLocationStatus.fromJson(Map<String, dynamic> json) => _$PartnerLocationStatusFromJson(json);

@override final  double latitude;
@override final  double longitude;
@override final  String placeName;
@override final  int batteryLevel;
@override final  bool isCharging;
@override final  DateTime lastUpdated;
@override@JsonKey() final  bool isOnline;
@override final  double? distanceKm;

/// Create a copy of PartnerLocationStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PartnerLocationStatusCopyWith<_PartnerLocationStatus> get copyWith => __$PartnerLocationStatusCopyWithImpl<_PartnerLocationStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PartnerLocationStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PartnerLocationStatus&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.placeName, placeName) || other.placeName == placeName)&&(identical(other.batteryLevel, batteryLevel) || other.batteryLevel == batteryLevel)&&(identical(other.isCharging, isCharging) || other.isCharging == isCharging)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,placeName,batteryLevel,isCharging,lastUpdated,isOnline,distanceKm);

@override
String toString() {
  return 'PartnerLocationStatus(latitude: $latitude, longitude: $longitude, placeName: $placeName, batteryLevel: $batteryLevel, isCharging: $isCharging, lastUpdated: $lastUpdated, isOnline: $isOnline, distanceKm: $distanceKm)';
}


}

/// @nodoc
abstract mixin class _$PartnerLocationStatusCopyWith<$Res> implements $PartnerLocationStatusCopyWith<$Res> {
  factory _$PartnerLocationStatusCopyWith(_PartnerLocationStatus value, $Res Function(_PartnerLocationStatus) _then) = __$PartnerLocationStatusCopyWithImpl;
@override @useResult
$Res call({
 double latitude, double longitude, String placeName, int batteryLevel, bool isCharging, DateTime lastUpdated, bool isOnline, double? distanceKm
});




}
/// @nodoc
class __$PartnerLocationStatusCopyWithImpl<$Res>
    implements _$PartnerLocationStatusCopyWith<$Res> {
  __$PartnerLocationStatusCopyWithImpl(this._self, this._then);

  final _PartnerLocationStatus _self;
  final $Res Function(_PartnerLocationStatus) _then;

/// Create a copy of PartnerLocationStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? latitude = null,Object? longitude = null,Object? placeName = null,Object? batteryLevel = null,Object? isCharging = null,Object? lastUpdated = null,Object? isOnline = null,Object? distanceKm = freezed,}) {
  return _then(_PartnerLocationStatus(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,placeName: null == placeName ? _self.placeName : placeName // ignore: cast_nullable_to_non_nullable
as String,batteryLevel: null == batteryLevel ? _self.batteryLevel : batteryLevel // ignore: cast_nullable_to_non_nullable
as int,isCharging: null == isCharging ? _self.isCharging : isCharging // ignore: cast_nullable_to_non_nullable
as bool,lastUpdated: null == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,distanceKm: freezed == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
