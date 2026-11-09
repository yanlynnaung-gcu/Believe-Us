// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'partner_location_arrival_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PartnerLocationArrivalModel {

@JsonKey(fromJson: _stringFromDynamic) String get id; String get userId; double get latitude; double get longitude; String get addressLine; String get placeName; MovementStatus get status; double get speedKmh; int get batteryLevel; bool get isCharging; DateTime get arrivedAt; DateTime? get departedAt; DateTime get lastUpdatedAt;
/// Create a copy of PartnerLocationArrivalModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PartnerLocationArrivalModelCopyWith<PartnerLocationArrivalModel> get copyWith => _$PartnerLocationArrivalModelCopyWithImpl<PartnerLocationArrivalModel>(this as PartnerLocationArrivalModel, _$identity);

  /// Serializes this PartnerLocationArrivalModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PartnerLocationArrivalModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.addressLine, addressLine) || other.addressLine == addressLine)&&(identical(other.placeName, placeName) || other.placeName == placeName)&&(identical(other.status, status) || other.status == status)&&(identical(other.speedKmh, speedKmh) || other.speedKmh == speedKmh)&&(identical(other.batteryLevel, batteryLevel) || other.batteryLevel == batteryLevel)&&(identical(other.isCharging, isCharging) || other.isCharging == isCharging)&&(identical(other.arrivedAt, arrivedAt) || other.arrivedAt == arrivedAt)&&(identical(other.departedAt, departedAt) || other.departedAt == departedAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,latitude,longitude,addressLine,placeName,status,speedKmh,batteryLevel,isCharging,arrivedAt,departedAt,lastUpdatedAt);

@override
String toString() {
  return 'PartnerLocationArrivalModel(id: $id, userId: $userId, latitude: $latitude, longitude: $longitude, addressLine: $addressLine, placeName: $placeName, status: $status, speedKmh: $speedKmh, batteryLevel: $batteryLevel, isCharging: $isCharging, arrivedAt: $arrivedAt, departedAt: $departedAt, lastUpdatedAt: $lastUpdatedAt)';
}


}

/// @nodoc
abstract mixin class $PartnerLocationArrivalModelCopyWith<$Res>  {
  factory $PartnerLocationArrivalModelCopyWith(PartnerLocationArrivalModel value, $Res Function(PartnerLocationArrivalModel) _then) = _$PartnerLocationArrivalModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _stringFromDynamic) String id, String userId, double latitude, double longitude, String addressLine, String placeName, MovementStatus status, double speedKmh, int batteryLevel, bool isCharging, DateTime arrivedAt, DateTime? departedAt, DateTime lastUpdatedAt
});




}
/// @nodoc
class _$PartnerLocationArrivalModelCopyWithImpl<$Res>
    implements $PartnerLocationArrivalModelCopyWith<$Res> {
  _$PartnerLocationArrivalModelCopyWithImpl(this._self, this._then);

  final PartnerLocationArrivalModel _self;
  final $Res Function(PartnerLocationArrivalModel) _then;

/// Create a copy of PartnerLocationArrivalModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? latitude = null,Object? longitude = null,Object? addressLine = null,Object? placeName = null,Object? status = null,Object? speedKmh = null,Object? batteryLevel = null,Object? isCharging = null,Object? arrivedAt = null,Object? departedAt = freezed,Object? lastUpdatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,addressLine: null == addressLine ? _self.addressLine : addressLine // ignore: cast_nullable_to_non_nullable
as String,placeName: null == placeName ? _self.placeName : placeName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MovementStatus,speedKmh: null == speedKmh ? _self.speedKmh : speedKmh // ignore: cast_nullable_to_non_nullable
as double,batteryLevel: null == batteryLevel ? _self.batteryLevel : batteryLevel // ignore: cast_nullable_to_non_nullable
as int,isCharging: null == isCharging ? _self.isCharging : isCharging // ignore: cast_nullable_to_non_nullable
as bool,arrivedAt: null == arrivedAt ? _self.arrivedAt : arrivedAt // ignore: cast_nullable_to_non_nullable
as DateTime,departedAt: freezed == departedAt ? _self.departedAt : departedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PartnerLocationArrivalModel].
extension PartnerLocationArrivalModelPatterns on PartnerLocationArrivalModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PartnerLocationArrivalModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PartnerLocationArrivalModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PartnerLocationArrivalModel value)  $default,){
final _that = this;
switch (_that) {
case _PartnerLocationArrivalModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PartnerLocationArrivalModel value)?  $default,){
final _that = this;
switch (_that) {
case _PartnerLocationArrivalModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _stringFromDynamic)  String id,  String userId,  double latitude,  double longitude,  String addressLine,  String placeName,  MovementStatus status,  double speedKmh,  int batteryLevel,  bool isCharging,  DateTime arrivedAt,  DateTime? departedAt,  DateTime lastUpdatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PartnerLocationArrivalModel() when $default != null:
return $default(_that.id,_that.userId,_that.latitude,_that.longitude,_that.addressLine,_that.placeName,_that.status,_that.speedKmh,_that.batteryLevel,_that.isCharging,_that.arrivedAt,_that.departedAt,_that.lastUpdatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _stringFromDynamic)  String id,  String userId,  double latitude,  double longitude,  String addressLine,  String placeName,  MovementStatus status,  double speedKmh,  int batteryLevel,  bool isCharging,  DateTime arrivedAt,  DateTime? departedAt,  DateTime lastUpdatedAt)  $default,) {final _that = this;
switch (_that) {
case _PartnerLocationArrivalModel():
return $default(_that.id,_that.userId,_that.latitude,_that.longitude,_that.addressLine,_that.placeName,_that.status,_that.speedKmh,_that.batteryLevel,_that.isCharging,_that.arrivedAt,_that.departedAt,_that.lastUpdatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _stringFromDynamic)  String id,  String userId,  double latitude,  double longitude,  String addressLine,  String placeName,  MovementStatus status,  double speedKmh,  int batteryLevel,  bool isCharging,  DateTime arrivedAt,  DateTime? departedAt,  DateTime lastUpdatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PartnerLocationArrivalModel() when $default != null:
return $default(_that.id,_that.userId,_that.latitude,_that.longitude,_that.addressLine,_that.placeName,_that.status,_that.speedKmh,_that.batteryLevel,_that.isCharging,_that.arrivedAt,_that.departedAt,_that.lastUpdatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PartnerLocationArrivalModel implements PartnerLocationArrivalModel {
  const _PartnerLocationArrivalModel({@JsonKey(fromJson: _stringFromDynamic) required this.id, required this.userId, required this.latitude, required this.longitude, required this.addressLine, required this.placeName, this.status = MovementStatus.stationary, this.speedKmh = 0.0, this.batteryLevel = 100, this.isCharging = false, required this.arrivedAt, this.departedAt, required this.lastUpdatedAt});
  factory _PartnerLocationArrivalModel.fromJson(Map<String, dynamic> json) => _$PartnerLocationArrivalModelFromJson(json);

@override@JsonKey(fromJson: _stringFromDynamic) final  String id;
@override final  String userId;
@override final  double latitude;
@override final  double longitude;
@override final  String addressLine;
@override final  String placeName;
@override@JsonKey() final  MovementStatus status;
@override@JsonKey() final  double speedKmh;
@override@JsonKey() final  int batteryLevel;
@override@JsonKey() final  bool isCharging;
@override final  DateTime arrivedAt;
@override final  DateTime? departedAt;
@override final  DateTime lastUpdatedAt;

/// Create a copy of PartnerLocationArrivalModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PartnerLocationArrivalModelCopyWith<_PartnerLocationArrivalModel> get copyWith => __$PartnerLocationArrivalModelCopyWithImpl<_PartnerLocationArrivalModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PartnerLocationArrivalModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PartnerLocationArrivalModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.addressLine, addressLine) || other.addressLine == addressLine)&&(identical(other.placeName, placeName) || other.placeName == placeName)&&(identical(other.status, status) || other.status == status)&&(identical(other.speedKmh, speedKmh) || other.speedKmh == speedKmh)&&(identical(other.batteryLevel, batteryLevel) || other.batteryLevel == batteryLevel)&&(identical(other.isCharging, isCharging) || other.isCharging == isCharging)&&(identical(other.arrivedAt, arrivedAt) || other.arrivedAt == arrivedAt)&&(identical(other.departedAt, departedAt) || other.departedAt == departedAt)&&(identical(other.lastUpdatedAt, lastUpdatedAt) || other.lastUpdatedAt == lastUpdatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,latitude,longitude,addressLine,placeName,status,speedKmh,batteryLevel,isCharging,arrivedAt,departedAt,lastUpdatedAt);

@override
String toString() {
  return 'PartnerLocationArrivalModel(id: $id, userId: $userId, latitude: $latitude, longitude: $longitude, addressLine: $addressLine, placeName: $placeName, status: $status, speedKmh: $speedKmh, batteryLevel: $batteryLevel, isCharging: $isCharging, arrivedAt: $arrivedAt, departedAt: $departedAt, lastUpdatedAt: $lastUpdatedAt)';
}


}

/// @nodoc
abstract mixin class _$PartnerLocationArrivalModelCopyWith<$Res> implements $PartnerLocationArrivalModelCopyWith<$Res> {
  factory _$PartnerLocationArrivalModelCopyWith(_PartnerLocationArrivalModel value, $Res Function(_PartnerLocationArrivalModel) _then) = __$PartnerLocationArrivalModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _stringFromDynamic) String id, String userId, double latitude, double longitude, String addressLine, String placeName, MovementStatus status, double speedKmh, int batteryLevel, bool isCharging, DateTime arrivedAt, DateTime? departedAt, DateTime lastUpdatedAt
});




}
/// @nodoc
class __$PartnerLocationArrivalModelCopyWithImpl<$Res>
    implements _$PartnerLocationArrivalModelCopyWith<$Res> {
  __$PartnerLocationArrivalModelCopyWithImpl(this._self, this._then);

  final _PartnerLocationArrivalModel _self;
  final $Res Function(_PartnerLocationArrivalModel) _then;

/// Create a copy of PartnerLocationArrivalModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? latitude = null,Object? longitude = null,Object? addressLine = null,Object? placeName = null,Object? status = null,Object? speedKmh = null,Object? batteryLevel = null,Object? isCharging = null,Object? arrivedAt = null,Object? departedAt = freezed,Object? lastUpdatedAt = null,}) {
  return _then(_PartnerLocationArrivalModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,addressLine: null == addressLine ? _self.addressLine : addressLine // ignore: cast_nullable_to_non_nullable
as String,placeName: null == placeName ? _self.placeName : placeName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MovementStatus,speedKmh: null == speedKmh ? _self.speedKmh : speedKmh // ignore: cast_nullable_to_non_nullable
as double,batteryLevel: null == batteryLevel ? _self.batteryLevel : batteryLevel // ignore: cast_nullable_to_non_nullable
as int,isCharging: null == isCharging ? _self.isCharging : isCharging // ignore: cast_nullable_to_non_nullable
as bool,arrivedAt: null == arrivedAt ? _self.arrivedAt : arrivedAt // ignore: cast_nullable_to_non_nullable
as DateTime,departedAt: freezed == departedAt ? _self.departedAt : departedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastUpdatedAt: null == lastUpdatedAt ? _self.lastUpdatedAt : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
