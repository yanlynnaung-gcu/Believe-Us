// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'couple_notification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CoupleNotification {

 String get id; String get title; String get body; NotificationType get type; Map<String, dynamic>? get data; DateTime get createdAt; bool get isRead;
/// Create a copy of CoupleNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoupleNotificationCopyWith<CoupleNotification> get copyWith => _$CoupleNotificationCopyWithImpl<CoupleNotification>(this as CoupleNotification, _$identity);

  /// Serializes this CoupleNotification to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoupleNotification&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isRead, isRead) || other.isRead == isRead));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,body,type,const DeepCollectionEquality().hash(data),createdAt,isRead);

@override
String toString() {
  return 'CoupleNotification(id: $id, title: $title, body: $body, type: $type, data: $data, createdAt: $createdAt, isRead: $isRead)';
}


}

/// @nodoc
abstract mixin class $CoupleNotificationCopyWith<$Res>  {
  factory $CoupleNotificationCopyWith(CoupleNotification value, $Res Function(CoupleNotification) _then) = _$CoupleNotificationCopyWithImpl;
@useResult
$Res call({
 String id, String title, String body, NotificationType type, Map<String, dynamic>? data, DateTime createdAt, bool isRead
});




}
/// @nodoc
class _$CoupleNotificationCopyWithImpl<$Res>
    implements $CoupleNotificationCopyWith<$Res> {
  _$CoupleNotificationCopyWithImpl(this._self, this._then);

  final CoupleNotification _self;
  final $Res Function(CoupleNotification) _then;

/// Create a copy of CoupleNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? body = null,Object? type = null,Object? data = freezed,Object? createdAt = null,Object? isRead = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationType,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CoupleNotification].
extension CoupleNotificationPatterns on CoupleNotification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoupleNotification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoupleNotification() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoupleNotification value)  $default,){
final _that = this;
switch (_that) {
case _CoupleNotification():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoupleNotification value)?  $default,){
final _that = this;
switch (_that) {
case _CoupleNotification() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String body,  NotificationType type,  Map<String, dynamic>? data,  DateTime createdAt,  bool isRead)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoupleNotification() when $default != null:
return $default(_that.id,_that.title,_that.body,_that.type,_that.data,_that.createdAt,_that.isRead);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String body,  NotificationType type,  Map<String, dynamic>? data,  DateTime createdAt,  bool isRead)  $default,) {final _that = this;
switch (_that) {
case _CoupleNotification():
return $default(_that.id,_that.title,_that.body,_that.type,_that.data,_that.createdAt,_that.isRead);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String body,  NotificationType type,  Map<String, dynamic>? data,  DateTime createdAt,  bool isRead)?  $default,) {final _that = this;
switch (_that) {
case _CoupleNotification() when $default != null:
return $default(_that.id,_that.title,_that.body,_that.type,_that.data,_that.createdAt,_that.isRead);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CoupleNotification implements CoupleNotification {
  const _CoupleNotification({required this.id, required this.title, required this.body, required this.type, final  Map<String, dynamic>? data, required this.createdAt, this.isRead = false}): _data = data;
  factory _CoupleNotification.fromJson(Map<String, dynamic> json) => _$CoupleNotificationFromJson(json);

@override final  String id;
@override final  String title;
@override final  String body;
@override final  NotificationType type;
 final  Map<String, dynamic>? _data;
@override Map<String, dynamic>? get data {
  final value = _data;
  if (value == null) return null;
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime createdAt;
@override@JsonKey() final  bool isRead;

/// Create a copy of CoupleNotification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoupleNotificationCopyWith<_CoupleNotification> get copyWith => __$CoupleNotificationCopyWithImpl<_CoupleNotification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoupleNotificationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoupleNotification&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._data, _data)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isRead, isRead) || other.isRead == isRead));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,body,type,const DeepCollectionEquality().hash(_data),createdAt,isRead);

@override
String toString() {
  return 'CoupleNotification(id: $id, title: $title, body: $body, type: $type, data: $data, createdAt: $createdAt, isRead: $isRead)';
}


}

/// @nodoc
abstract mixin class _$CoupleNotificationCopyWith<$Res> implements $CoupleNotificationCopyWith<$Res> {
  factory _$CoupleNotificationCopyWith(_CoupleNotification value, $Res Function(_CoupleNotification) _then) = __$CoupleNotificationCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String body, NotificationType type, Map<String, dynamic>? data, DateTime createdAt, bool isRead
});




}
/// @nodoc
class __$CoupleNotificationCopyWithImpl<$Res>
    implements _$CoupleNotificationCopyWith<$Res> {
  __$CoupleNotificationCopyWithImpl(this._self, this._then);

  final _CoupleNotification _self;
  final $Res Function(_CoupleNotification) _then;

/// Create a copy of CoupleNotification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? body = null,Object? type = null,Object? data = freezed,Object? createdAt = null,Object? isRead = null,}) {
  return _then(_CoupleNotification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationType,data: freezed == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
