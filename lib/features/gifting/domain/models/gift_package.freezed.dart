// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gift_package.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GiftPackage {

 String get id; String get title; String get description; int get amountMmK; String get iconEmoji; bool get isCustomMonetary; String? get categoryTag;
/// Create a copy of GiftPackage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GiftPackageCopyWith<GiftPackage> get copyWith => _$GiftPackageCopyWithImpl<GiftPackage>(this as GiftPackage, _$identity);

  /// Serializes this GiftPackage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GiftPackage&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.amountMmK, amountMmK) || other.amountMmK == amountMmK)&&(identical(other.iconEmoji, iconEmoji) || other.iconEmoji == iconEmoji)&&(identical(other.isCustomMonetary, isCustomMonetary) || other.isCustomMonetary == isCustomMonetary)&&(identical(other.categoryTag, categoryTag) || other.categoryTag == categoryTag));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,amountMmK,iconEmoji,isCustomMonetary,categoryTag);

@override
String toString() {
  return 'GiftPackage(id: $id, title: $title, description: $description, amountMmK: $amountMmK, iconEmoji: $iconEmoji, isCustomMonetary: $isCustomMonetary, categoryTag: $categoryTag)';
}


}

/// @nodoc
abstract mixin class $GiftPackageCopyWith<$Res>  {
  factory $GiftPackageCopyWith(GiftPackage value, $Res Function(GiftPackage) _then) = _$GiftPackageCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, int amountMmK, String iconEmoji, bool isCustomMonetary, String? categoryTag
});




}
/// @nodoc
class _$GiftPackageCopyWithImpl<$Res>
    implements $GiftPackageCopyWith<$Res> {
  _$GiftPackageCopyWithImpl(this._self, this._then);

  final GiftPackage _self;
  final $Res Function(GiftPackage) _then;

/// Create a copy of GiftPackage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? amountMmK = null,Object? iconEmoji = null,Object? isCustomMonetary = null,Object? categoryTag = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,amountMmK: null == amountMmK ? _self.amountMmK : amountMmK // ignore: cast_nullable_to_non_nullable
as int,iconEmoji: null == iconEmoji ? _self.iconEmoji : iconEmoji // ignore: cast_nullable_to_non_nullable
as String,isCustomMonetary: null == isCustomMonetary ? _self.isCustomMonetary : isCustomMonetary // ignore: cast_nullable_to_non_nullable
as bool,categoryTag: freezed == categoryTag ? _self.categoryTag : categoryTag // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [GiftPackage].
extension GiftPackagePatterns on GiftPackage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GiftPackage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GiftPackage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GiftPackage value)  $default,){
final _that = this;
switch (_that) {
case _GiftPackage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GiftPackage value)?  $default,){
final _that = this;
switch (_that) {
case _GiftPackage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  int amountMmK,  String iconEmoji,  bool isCustomMonetary,  String? categoryTag)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GiftPackage() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.amountMmK,_that.iconEmoji,_that.isCustomMonetary,_that.categoryTag);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  int amountMmK,  String iconEmoji,  bool isCustomMonetary,  String? categoryTag)  $default,) {final _that = this;
switch (_that) {
case _GiftPackage():
return $default(_that.id,_that.title,_that.description,_that.amountMmK,_that.iconEmoji,_that.isCustomMonetary,_that.categoryTag);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  int amountMmK,  String iconEmoji,  bool isCustomMonetary,  String? categoryTag)?  $default,) {final _that = this;
switch (_that) {
case _GiftPackage() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.amountMmK,_that.iconEmoji,_that.isCustomMonetary,_that.categoryTag);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GiftPackage implements GiftPackage {
  const _GiftPackage({required this.id, required this.title, required this.description, required this.amountMmK, required this.iconEmoji, this.isCustomMonetary = false, this.categoryTag});
  factory _GiftPackage.fromJson(Map<String, dynamic> json) => _$GiftPackageFromJson(json);

@override final  String id;
@override final  String title;
@override final  String description;
@override final  int amountMmK;
@override final  String iconEmoji;
@override@JsonKey() final  bool isCustomMonetary;
@override final  String? categoryTag;

/// Create a copy of GiftPackage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GiftPackageCopyWith<_GiftPackage> get copyWith => __$GiftPackageCopyWithImpl<_GiftPackage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GiftPackageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GiftPackage&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.amountMmK, amountMmK) || other.amountMmK == amountMmK)&&(identical(other.iconEmoji, iconEmoji) || other.iconEmoji == iconEmoji)&&(identical(other.isCustomMonetary, isCustomMonetary) || other.isCustomMonetary == isCustomMonetary)&&(identical(other.categoryTag, categoryTag) || other.categoryTag == categoryTag));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,amountMmK,iconEmoji,isCustomMonetary,categoryTag);

@override
String toString() {
  return 'GiftPackage(id: $id, title: $title, description: $description, amountMmK: $amountMmK, iconEmoji: $iconEmoji, isCustomMonetary: $isCustomMonetary, categoryTag: $categoryTag)';
}


}

/// @nodoc
abstract mixin class _$GiftPackageCopyWith<$Res> implements $GiftPackageCopyWith<$Res> {
  factory _$GiftPackageCopyWith(_GiftPackage value, $Res Function(_GiftPackage) _then) = __$GiftPackageCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, int amountMmK, String iconEmoji, bool isCustomMonetary, String? categoryTag
});




}
/// @nodoc
class __$GiftPackageCopyWithImpl<$Res>
    implements _$GiftPackageCopyWith<$Res> {
  __$GiftPackageCopyWithImpl(this._self, this._then);

  final _GiftPackage _self;
  final $Res Function(_GiftPackage) _then;

/// Create a copy of GiftPackage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? amountMmK = null,Object? iconEmoji = null,Object? isCustomMonetary = null,Object? categoryTag = freezed,}) {
  return _then(_GiftPackage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,amountMmK: null == amountMmK ? _self.amountMmK : amountMmK // ignore: cast_nullable_to_non_nullable
as int,iconEmoji: null == iconEmoji ? _self.iconEmoji : iconEmoji // ignore: cast_nullable_to_non_nullable
as String,isCustomMonetary: null == isCustomMonetary ? _self.isCustomMonetary : isCustomMonetary // ignore: cast_nullable_to_non_nullable
as bool,categoryTag: freezed == categoryTag ? _self.categoryTag : categoryTag // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
