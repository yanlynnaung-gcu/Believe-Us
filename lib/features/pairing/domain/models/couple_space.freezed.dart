// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'couple_space.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CoupleSpace {

 String get id; String get user1Id; String get user2Id; String get inviteCode; DateTime get pairedAt; DateTime? get anniversaryDate; bool get isActive;
/// Create a copy of CoupleSpace
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoupleSpaceCopyWith<CoupleSpace> get copyWith => _$CoupleSpaceCopyWithImpl<CoupleSpace>(this as CoupleSpace, _$identity);

  /// Serializes this CoupleSpace to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoupleSpace&&(identical(other.id, id) || other.id == id)&&(identical(other.user1Id, user1Id) || other.user1Id == user1Id)&&(identical(other.user2Id, user2Id) || other.user2Id == user2Id)&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.pairedAt, pairedAt) || other.pairedAt == pairedAt)&&(identical(other.anniversaryDate, anniversaryDate) || other.anniversaryDate == anniversaryDate)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,user1Id,user2Id,inviteCode,pairedAt,anniversaryDate,isActive);

@override
String toString() {
  return 'CoupleSpace(id: $id, user1Id: $user1Id, user2Id: $user2Id, inviteCode: $inviteCode, pairedAt: $pairedAt, anniversaryDate: $anniversaryDate, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $CoupleSpaceCopyWith<$Res>  {
  factory $CoupleSpaceCopyWith(CoupleSpace value, $Res Function(CoupleSpace) _then) = _$CoupleSpaceCopyWithImpl;
@useResult
$Res call({
 String id, String user1Id, String user2Id, String inviteCode, DateTime pairedAt, DateTime? anniversaryDate, bool isActive
});




}
/// @nodoc
class _$CoupleSpaceCopyWithImpl<$Res>
    implements $CoupleSpaceCopyWith<$Res> {
  _$CoupleSpaceCopyWithImpl(this._self, this._then);

  final CoupleSpace _self;
  final $Res Function(CoupleSpace) _then;

/// Create a copy of CoupleSpace
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? user1Id = null,Object? user2Id = null,Object? inviteCode = null,Object? pairedAt = null,Object? anniversaryDate = freezed,Object? isActive = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,user1Id: null == user1Id ? _self.user1Id : user1Id // ignore: cast_nullable_to_non_nullable
as String,user2Id: null == user2Id ? _self.user2Id : user2Id // ignore: cast_nullable_to_non_nullable
as String,inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String,pairedAt: null == pairedAt ? _self.pairedAt : pairedAt // ignore: cast_nullable_to_non_nullable
as DateTime,anniversaryDate: freezed == anniversaryDate ? _self.anniversaryDate : anniversaryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CoupleSpace].
extension CoupleSpacePatterns on CoupleSpace {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoupleSpace value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoupleSpace() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoupleSpace value)  $default,){
final _that = this;
switch (_that) {
case _CoupleSpace():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoupleSpace value)?  $default,){
final _that = this;
switch (_that) {
case _CoupleSpace() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String user1Id,  String user2Id,  String inviteCode,  DateTime pairedAt,  DateTime? anniversaryDate,  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoupleSpace() when $default != null:
return $default(_that.id,_that.user1Id,_that.user2Id,_that.inviteCode,_that.pairedAt,_that.anniversaryDate,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String user1Id,  String user2Id,  String inviteCode,  DateTime pairedAt,  DateTime? anniversaryDate,  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _CoupleSpace():
return $default(_that.id,_that.user1Id,_that.user2Id,_that.inviteCode,_that.pairedAt,_that.anniversaryDate,_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String user1Id,  String user2Id,  String inviteCode,  DateTime pairedAt,  DateTime? anniversaryDate,  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _CoupleSpace() when $default != null:
return $default(_that.id,_that.user1Id,_that.user2Id,_that.inviteCode,_that.pairedAt,_that.anniversaryDate,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CoupleSpace implements CoupleSpace {
  const _CoupleSpace({required this.id, required this.user1Id, required this.user2Id, required this.inviteCode, required this.pairedAt, this.anniversaryDate, this.isActive = true});
  factory _CoupleSpace.fromJson(Map<String, dynamic> json) => _$CoupleSpaceFromJson(json);

@override final  String id;
@override final  String user1Id;
@override final  String user2Id;
@override final  String inviteCode;
@override final  DateTime pairedAt;
@override final  DateTime? anniversaryDate;
@override@JsonKey() final  bool isActive;

/// Create a copy of CoupleSpace
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoupleSpaceCopyWith<_CoupleSpace> get copyWith => __$CoupleSpaceCopyWithImpl<_CoupleSpace>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoupleSpaceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoupleSpace&&(identical(other.id, id) || other.id == id)&&(identical(other.user1Id, user1Id) || other.user1Id == user1Id)&&(identical(other.user2Id, user2Id) || other.user2Id == user2Id)&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.pairedAt, pairedAt) || other.pairedAt == pairedAt)&&(identical(other.anniversaryDate, anniversaryDate) || other.anniversaryDate == anniversaryDate)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,user1Id,user2Id,inviteCode,pairedAt,anniversaryDate,isActive);

@override
String toString() {
  return 'CoupleSpace(id: $id, user1Id: $user1Id, user2Id: $user2Id, inviteCode: $inviteCode, pairedAt: $pairedAt, anniversaryDate: $anniversaryDate, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$CoupleSpaceCopyWith<$Res> implements $CoupleSpaceCopyWith<$Res> {
  factory _$CoupleSpaceCopyWith(_CoupleSpace value, $Res Function(_CoupleSpace) _then) = __$CoupleSpaceCopyWithImpl;
@override @useResult
$Res call({
 String id, String user1Id, String user2Id, String inviteCode, DateTime pairedAt, DateTime? anniversaryDate, bool isActive
});




}
/// @nodoc
class __$CoupleSpaceCopyWithImpl<$Res>
    implements _$CoupleSpaceCopyWith<$Res> {
  __$CoupleSpaceCopyWithImpl(this._self, this._then);

  final _CoupleSpace _self;
  final $Res Function(_CoupleSpace) _then;

/// Create a copy of CoupleSpace
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? user1Id = null,Object? user2Id = null,Object? inviteCode = null,Object? pairedAt = null,Object? anniversaryDate = freezed,Object? isActive = null,}) {
  return _then(_CoupleSpace(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,user1Id: null == user1Id ? _self.user1Id : user1Id // ignore: cast_nullable_to_non_nullable
as String,user2Id: null == user2Id ? _self.user2Id : user2Id // ignore: cast_nullable_to_non_nullable
as String,inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String,pairedAt: null == pairedAt ? _self.pairedAt : pairedAt // ignore: cast_nullable_to_non_nullable
as DateTime,anniversaryDate: freezed == anniversaryDate ? _self.anniversaryDate : anniversaryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
