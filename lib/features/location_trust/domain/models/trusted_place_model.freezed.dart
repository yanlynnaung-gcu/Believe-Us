// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trusted_place_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrustedPlaceModel {

@JsonKey(fromJson: _stringFromDynamic) String get id; String get name; String get iconName; double get latitude; double get longitude; double get radiusMeters; bool get notifyArrival; bool get notifyDeparture; DateTime get createdAt;
/// Create a copy of TrustedPlaceModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrustedPlaceModelCopyWith<TrustedPlaceModel> get copyWith => _$TrustedPlaceModelCopyWithImpl<TrustedPlaceModel>(this as TrustedPlaceModel, _$identity);

  /// Serializes this TrustedPlaceModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrustedPlaceModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.radiusMeters, radiusMeters) || other.radiusMeters == radiusMeters)&&(identical(other.notifyArrival, notifyArrival) || other.notifyArrival == notifyArrival)&&(identical(other.notifyDeparture, notifyDeparture) || other.notifyDeparture == notifyDeparture)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,iconName,latitude,longitude,radiusMeters,notifyArrival,notifyDeparture,createdAt);

@override
String toString() {
  return 'TrustedPlaceModel(id: $id, name: $name, iconName: $iconName, latitude: $latitude, longitude: $longitude, radiusMeters: $radiusMeters, notifyArrival: $notifyArrival, notifyDeparture: $notifyDeparture, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $TrustedPlaceModelCopyWith<$Res>  {
  factory $TrustedPlaceModelCopyWith(TrustedPlaceModel value, $Res Function(TrustedPlaceModel) _then) = _$TrustedPlaceModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _stringFromDynamic) String id, String name, String iconName, double latitude, double longitude, double radiusMeters, bool notifyArrival, bool notifyDeparture, DateTime createdAt
});




}
/// @nodoc
class _$TrustedPlaceModelCopyWithImpl<$Res>
    implements $TrustedPlaceModelCopyWith<$Res> {
  _$TrustedPlaceModelCopyWithImpl(this._self, this._then);

  final TrustedPlaceModel _self;
  final $Res Function(TrustedPlaceModel) _then;

/// Create a copy of TrustedPlaceModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? iconName = null,Object? latitude = null,Object? longitude = null,Object? radiusMeters = null,Object? notifyArrival = null,Object? notifyDeparture = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,iconName: null == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,radiusMeters: null == radiusMeters ? _self.radiusMeters : radiusMeters // ignore: cast_nullable_to_non_nullable
as double,notifyArrival: null == notifyArrival ? _self.notifyArrival : notifyArrival // ignore: cast_nullable_to_non_nullable
as bool,notifyDeparture: null == notifyDeparture ? _self.notifyDeparture : notifyDeparture // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TrustedPlaceModel].
extension TrustedPlaceModelPatterns on TrustedPlaceModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrustedPlaceModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrustedPlaceModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrustedPlaceModel value)  $default,){
final _that = this;
switch (_that) {
case _TrustedPlaceModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrustedPlaceModel value)?  $default,){
final _that = this;
switch (_that) {
case _TrustedPlaceModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _stringFromDynamic)  String id,  String name,  String iconName,  double latitude,  double longitude,  double radiusMeters,  bool notifyArrival,  bool notifyDeparture,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrustedPlaceModel() when $default != null:
return $default(_that.id,_that.name,_that.iconName,_that.latitude,_that.longitude,_that.radiusMeters,_that.notifyArrival,_that.notifyDeparture,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _stringFromDynamic)  String id,  String name,  String iconName,  double latitude,  double longitude,  double radiusMeters,  bool notifyArrival,  bool notifyDeparture,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _TrustedPlaceModel():
return $default(_that.id,_that.name,_that.iconName,_that.latitude,_that.longitude,_that.radiusMeters,_that.notifyArrival,_that.notifyDeparture,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _stringFromDynamic)  String id,  String name,  String iconName,  double latitude,  double longitude,  double radiusMeters,  bool notifyArrival,  bool notifyDeparture,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _TrustedPlaceModel() when $default != null:
return $default(_that.id,_that.name,_that.iconName,_that.latitude,_that.longitude,_that.radiusMeters,_that.notifyArrival,_that.notifyDeparture,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrustedPlaceModel implements TrustedPlaceModel {
  const _TrustedPlaceModel({@JsonKey(fromJson: _stringFromDynamic) required this.id, required this.name, this.iconName = 'home', required this.latitude, required this.longitude, this.radiusMeters = 150.0, this.notifyArrival = true, this.notifyDeparture = true, required this.createdAt});
  factory _TrustedPlaceModel.fromJson(Map<String, dynamic> json) => _$TrustedPlaceModelFromJson(json);

@override@JsonKey(fromJson: _stringFromDynamic) final  String id;
@override final  String name;
@override@JsonKey() final  String iconName;
@override final  double latitude;
@override final  double longitude;
@override@JsonKey() final  double radiusMeters;
@override@JsonKey() final  bool notifyArrival;
@override@JsonKey() final  bool notifyDeparture;
@override final  DateTime createdAt;

/// Create a copy of TrustedPlaceModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrustedPlaceModelCopyWith<_TrustedPlaceModel> get copyWith => __$TrustedPlaceModelCopyWithImpl<_TrustedPlaceModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrustedPlaceModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrustedPlaceModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.radiusMeters, radiusMeters) || other.radiusMeters == radiusMeters)&&(identical(other.notifyArrival, notifyArrival) || other.notifyArrival == notifyArrival)&&(identical(other.notifyDeparture, notifyDeparture) || other.notifyDeparture == notifyDeparture)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,iconName,latitude,longitude,radiusMeters,notifyArrival,notifyDeparture,createdAt);

@override
String toString() {
  return 'TrustedPlaceModel(id: $id, name: $name, iconName: $iconName, latitude: $latitude, longitude: $longitude, radiusMeters: $radiusMeters, notifyArrival: $notifyArrival, notifyDeparture: $notifyDeparture, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TrustedPlaceModelCopyWith<$Res> implements $TrustedPlaceModelCopyWith<$Res> {
  factory _$TrustedPlaceModelCopyWith(_TrustedPlaceModel value, $Res Function(_TrustedPlaceModel) _then) = __$TrustedPlaceModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _stringFromDynamic) String id, String name, String iconName, double latitude, double longitude, double radiusMeters, bool notifyArrival, bool notifyDeparture, DateTime createdAt
});




}
/// @nodoc
class __$TrustedPlaceModelCopyWithImpl<$Res>
    implements _$TrustedPlaceModelCopyWith<$Res> {
  __$TrustedPlaceModelCopyWithImpl(this._self, this._then);

  final _TrustedPlaceModel _self;
  final $Res Function(_TrustedPlaceModel) _then;

/// Create a copy of TrustedPlaceModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? iconName = null,Object? latitude = null,Object? longitude = null,Object? radiusMeters = null,Object? notifyArrival = null,Object? notifyDeparture = null,Object? createdAt = null,}) {
  return _then(_TrustedPlaceModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,iconName: null == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,radiusMeters: null == radiusMeters ? _self.radiusMeters : radiusMeters // ignore: cast_nullable_to_non_nullable
as double,notifyArrival: null == notifyArrival ? _self.notifyArrival : notifyArrival // ignore: cast_nullable_to_non_nullable
as bool,notifyDeparture: null == notifyDeparture ? _self.notifyDeparture : notifyDeparture // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
