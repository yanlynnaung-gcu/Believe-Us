// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserProfile {

 String get id; String get displayName;@JsonKey(readValue: _readEmail) String get emailOrPhone; String get role; DateTime? get birthday;@JsonKey(readValue: _readPhoto) String? get photoUrl; String? get partnerId; String? get coupleSpaceId; DateTime? get anniversaryDate; bool get isPhoneAuth; bool get isProfileComplete; DateTime? get createdAt;
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileCopyWith<UserProfile> get copyWith => _$UserProfileCopyWithImpl<UserProfile>(this as UserProfile, _$identity);

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.emailOrPhone, emailOrPhone) || other.emailOrPhone == emailOrPhone)&&(identical(other.role, role) || other.role == role)&&(identical(other.birthday, birthday) || other.birthday == birthday)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.partnerId, partnerId) || other.partnerId == partnerId)&&(identical(other.coupleSpaceId, coupleSpaceId) || other.coupleSpaceId == coupleSpaceId)&&(identical(other.anniversaryDate, anniversaryDate) || other.anniversaryDate == anniversaryDate)&&(identical(other.isPhoneAuth, isPhoneAuth) || other.isPhoneAuth == isPhoneAuth)&&(identical(other.isProfileComplete, isProfileComplete) || other.isProfileComplete == isProfileComplete)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,displayName,emailOrPhone,role,birthday,photoUrl,partnerId,coupleSpaceId,anniversaryDate,isPhoneAuth,isProfileComplete,createdAt);

@override
String toString() {
  return 'UserProfile(id: $id, displayName: $displayName, emailOrPhone: $emailOrPhone, role: $role, birthday: $birthday, photoUrl: $photoUrl, partnerId: $partnerId, coupleSpaceId: $coupleSpaceId, anniversaryDate: $anniversaryDate, isPhoneAuth: $isPhoneAuth, isProfileComplete: $isProfileComplete, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $UserProfileCopyWith<$Res>  {
  factory $UserProfileCopyWith(UserProfile value, $Res Function(UserProfile) _then) = _$UserProfileCopyWithImpl;
@useResult
$Res call({
 String id, String displayName,@JsonKey(readValue: _readEmail) String emailOrPhone, String role, DateTime? birthday,@JsonKey(readValue: _readPhoto) String? photoUrl, String? partnerId, String? coupleSpaceId, DateTime? anniversaryDate, bool isPhoneAuth, bool isProfileComplete, DateTime? createdAt
});




}
/// @nodoc
class _$UserProfileCopyWithImpl<$Res>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._self, this._then);

  final UserProfile _self;
  final $Res Function(UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? displayName = null,Object? emailOrPhone = null,Object? role = null,Object? birthday = freezed,Object? photoUrl = freezed,Object? partnerId = freezed,Object? coupleSpaceId = freezed,Object? anniversaryDate = freezed,Object? isPhoneAuth = null,Object? isProfileComplete = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,emailOrPhone: null == emailOrPhone ? _self.emailOrPhone : emailOrPhone // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,birthday: freezed == birthday ? _self.birthday : birthday // ignore: cast_nullable_to_non_nullable
as DateTime?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,partnerId: freezed == partnerId ? _self.partnerId : partnerId // ignore: cast_nullable_to_non_nullable
as String?,coupleSpaceId: freezed == coupleSpaceId ? _self.coupleSpaceId : coupleSpaceId // ignore: cast_nullable_to_non_nullable
as String?,anniversaryDate: freezed == anniversaryDate ? _self.anniversaryDate : anniversaryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,isPhoneAuth: null == isPhoneAuth ? _self.isPhoneAuth : isPhoneAuth // ignore: cast_nullable_to_non_nullable
as bool,isProfileComplete: null == isProfileComplete ? _self.isProfileComplete : isProfileComplete // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfile].
extension UserProfilePatterns on UserProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfile value)  $default,){
final _that = this;
switch (_that) {
case _UserProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String displayName, @JsonKey(readValue: _readEmail)  String emailOrPhone,  String role,  DateTime? birthday, @JsonKey(readValue: _readPhoto)  String? photoUrl,  String? partnerId,  String? coupleSpaceId,  DateTime? anniversaryDate,  bool isPhoneAuth,  bool isProfileComplete,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.id,_that.displayName,_that.emailOrPhone,_that.role,_that.birthday,_that.photoUrl,_that.partnerId,_that.coupleSpaceId,_that.anniversaryDate,_that.isPhoneAuth,_that.isProfileComplete,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String displayName, @JsonKey(readValue: _readEmail)  String emailOrPhone,  String role,  DateTime? birthday, @JsonKey(readValue: _readPhoto)  String? photoUrl,  String? partnerId,  String? coupleSpaceId,  DateTime? anniversaryDate,  bool isPhoneAuth,  bool isProfileComplete,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that.id,_that.displayName,_that.emailOrPhone,_that.role,_that.birthday,_that.photoUrl,_that.partnerId,_that.coupleSpaceId,_that.anniversaryDate,_that.isPhoneAuth,_that.isProfileComplete,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String displayName, @JsonKey(readValue: _readEmail)  String emailOrPhone,  String role,  DateTime? birthday, @JsonKey(readValue: _readPhoto)  String? photoUrl,  String? partnerId,  String? coupleSpaceId,  DateTime? anniversaryDate,  bool isPhoneAuth,  bool isProfileComplete,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.id,_that.displayName,_that.emailOrPhone,_that.role,_that.birthday,_that.photoUrl,_that.partnerId,_that.coupleSpaceId,_that.anniversaryDate,_that.isPhoneAuth,_that.isProfileComplete,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfile implements UserProfile {
  const _UserProfile({required this.id, required this.displayName, @JsonKey(readValue: _readEmail) this.emailOrPhone = '', this.role = 'BOYFRIEND', this.birthday, @JsonKey(readValue: _readPhoto) this.photoUrl, this.partnerId, this.coupleSpaceId, this.anniversaryDate, this.isPhoneAuth = false, this.isProfileComplete = true, this.createdAt});
  factory _UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

@override final  String id;
@override final  String displayName;
@override@JsonKey(readValue: _readEmail) final  String emailOrPhone;
@override@JsonKey() final  String role;
@override final  DateTime? birthday;
@override@JsonKey(readValue: _readPhoto) final  String? photoUrl;
@override final  String? partnerId;
@override final  String? coupleSpaceId;
@override final  DateTime? anniversaryDate;
@override@JsonKey() final  bool isPhoneAuth;
@override@JsonKey() final  bool isProfileComplete;
@override final  DateTime? createdAt;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileCopyWith<_UserProfile> get copyWith => __$UserProfileCopyWithImpl<_UserProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.emailOrPhone, emailOrPhone) || other.emailOrPhone == emailOrPhone)&&(identical(other.role, role) || other.role == role)&&(identical(other.birthday, birthday) || other.birthday == birthday)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.partnerId, partnerId) || other.partnerId == partnerId)&&(identical(other.coupleSpaceId, coupleSpaceId) || other.coupleSpaceId == coupleSpaceId)&&(identical(other.anniversaryDate, anniversaryDate) || other.anniversaryDate == anniversaryDate)&&(identical(other.isPhoneAuth, isPhoneAuth) || other.isPhoneAuth == isPhoneAuth)&&(identical(other.isProfileComplete, isProfileComplete) || other.isProfileComplete == isProfileComplete)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,displayName,emailOrPhone,role,birthday,photoUrl,partnerId,coupleSpaceId,anniversaryDate,isPhoneAuth,isProfileComplete,createdAt);

@override
String toString() {
  return 'UserProfile(id: $id, displayName: $displayName, emailOrPhone: $emailOrPhone, role: $role, birthday: $birthday, photoUrl: $photoUrl, partnerId: $partnerId, coupleSpaceId: $coupleSpaceId, anniversaryDate: $anniversaryDate, isPhoneAuth: $isPhoneAuth, isProfileComplete: $isProfileComplete, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$UserProfileCopyWith<$Res> implements $UserProfileCopyWith<$Res> {
  factory _$UserProfileCopyWith(_UserProfile value, $Res Function(_UserProfile) _then) = __$UserProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String displayName,@JsonKey(readValue: _readEmail) String emailOrPhone, String role, DateTime? birthday,@JsonKey(readValue: _readPhoto) String? photoUrl, String? partnerId, String? coupleSpaceId, DateTime? anniversaryDate, bool isPhoneAuth, bool isProfileComplete, DateTime? createdAt
});




}
/// @nodoc
class __$UserProfileCopyWithImpl<$Res>
    implements _$UserProfileCopyWith<$Res> {
  __$UserProfileCopyWithImpl(this._self, this._then);

  final _UserProfile _self;
  final $Res Function(_UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? displayName = null,Object? emailOrPhone = null,Object? role = null,Object? birthday = freezed,Object? photoUrl = freezed,Object? partnerId = freezed,Object? coupleSpaceId = freezed,Object? anniversaryDate = freezed,Object? isPhoneAuth = null,Object? isProfileComplete = null,Object? createdAt = freezed,}) {
  return _then(_UserProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,emailOrPhone: null == emailOrPhone ? _self.emailOrPhone : emailOrPhone // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,birthday: freezed == birthday ? _self.birthday : birthday // ignore: cast_nullable_to_non_nullable
as DateTime?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,partnerId: freezed == partnerId ? _self.partnerId : partnerId // ignore: cast_nullable_to_non_nullable
as String?,coupleSpaceId: freezed == coupleSpaceId ? _self.coupleSpaceId : coupleSpaceId // ignore: cast_nullable_to_non_nullable
as String?,anniversaryDate: freezed == anniversaryDate ? _self.anniversaryDate : anniversaryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,isPhoneAuth: null == isPhoneAuth ? _self.isPhoneAuth : isPhoneAuth // ignore: cast_nullable_to_non_nullable
as bool,isProfileComplete: null == isProfileComplete ? _self.isProfileComplete : isProfileComplete // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
