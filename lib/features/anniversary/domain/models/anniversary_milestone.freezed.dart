// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'anniversary_milestone.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AnniversaryMilestone {

 String get id; String get title; DateTime get targetDate; bool get isRecurringAnnual; String get iconEmoji; String? get note; String get category;
/// Create a copy of AnniversaryMilestone
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnniversaryMilestoneCopyWith<AnniversaryMilestone> get copyWith => _$AnniversaryMilestoneCopyWithImpl<AnniversaryMilestone>(this as AnniversaryMilestone, _$identity);

  /// Serializes this AnniversaryMilestone to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnniversaryMilestone&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.isRecurringAnnual, isRecurringAnnual) || other.isRecurringAnnual == isRecurringAnnual)&&(identical(other.iconEmoji, iconEmoji) || other.iconEmoji == iconEmoji)&&(identical(other.note, note) || other.note == note)&&(identical(other.category, category) || other.category == category));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,targetDate,isRecurringAnnual,iconEmoji,note,category);

@override
String toString() {
  return 'AnniversaryMilestone(id: $id, title: $title, targetDate: $targetDate, isRecurringAnnual: $isRecurringAnnual, iconEmoji: $iconEmoji, note: $note, category: $category)';
}


}

/// @nodoc
abstract mixin class $AnniversaryMilestoneCopyWith<$Res>  {
  factory $AnniversaryMilestoneCopyWith(AnniversaryMilestone value, $Res Function(AnniversaryMilestone) _then) = _$AnniversaryMilestoneCopyWithImpl;
@useResult
$Res call({
 String id, String title, DateTime targetDate, bool isRecurringAnnual, String iconEmoji, String? note, String category
});




}
/// @nodoc
class _$AnniversaryMilestoneCopyWithImpl<$Res>
    implements $AnniversaryMilestoneCopyWith<$Res> {
  _$AnniversaryMilestoneCopyWithImpl(this._self, this._then);

  final AnniversaryMilestone _self;
  final $Res Function(AnniversaryMilestone) _then;

/// Create a copy of AnniversaryMilestone
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? targetDate = null,Object? isRecurringAnnual = null,Object? iconEmoji = null,Object? note = freezed,Object? category = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,targetDate: null == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as DateTime,isRecurringAnnual: null == isRecurringAnnual ? _self.isRecurringAnnual : isRecurringAnnual // ignore: cast_nullable_to_non_nullable
as bool,iconEmoji: null == iconEmoji ? _self.iconEmoji : iconEmoji // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AnniversaryMilestone].
extension AnniversaryMilestonePatterns on AnniversaryMilestone {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnniversaryMilestone value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnniversaryMilestone() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnniversaryMilestone value)  $default,){
final _that = this;
switch (_that) {
case _AnniversaryMilestone():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnniversaryMilestone value)?  $default,){
final _that = this;
switch (_that) {
case _AnniversaryMilestone() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  DateTime targetDate,  bool isRecurringAnnual,  String iconEmoji,  String? note,  String category)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnniversaryMilestone() when $default != null:
return $default(_that.id,_that.title,_that.targetDate,_that.isRecurringAnnual,_that.iconEmoji,_that.note,_that.category);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  DateTime targetDate,  bool isRecurringAnnual,  String iconEmoji,  String? note,  String category)  $default,) {final _that = this;
switch (_that) {
case _AnniversaryMilestone():
return $default(_that.id,_that.title,_that.targetDate,_that.isRecurringAnnual,_that.iconEmoji,_that.note,_that.category);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  DateTime targetDate,  bool isRecurringAnnual,  String iconEmoji,  String? note,  String category)?  $default,) {final _that = this;
switch (_that) {
case _AnniversaryMilestone() when $default != null:
return $default(_that.id,_that.title,_that.targetDate,_that.isRecurringAnnual,_that.iconEmoji,_that.note,_that.category);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnniversaryMilestone implements AnniversaryMilestone {
  const _AnniversaryMilestone({required this.id, required this.title, required this.targetDate, this.isRecurringAnnual = true, this.iconEmoji = '❤️', this.note, this.category = 'Anniversary'});
  factory _AnniversaryMilestone.fromJson(Map<String, dynamic> json) => _$AnniversaryMilestoneFromJson(json);

@override final  String id;
@override final  String title;
@override final  DateTime targetDate;
@override@JsonKey() final  bool isRecurringAnnual;
@override@JsonKey() final  String iconEmoji;
@override final  String? note;
@override@JsonKey() final  String category;

/// Create a copy of AnniversaryMilestone
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnniversaryMilestoneCopyWith<_AnniversaryMilestone> get copyWith => __$AnniversaryMilestoneCopyWithImpl<_AnniversaryMilestone>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnniversaryMilestoneToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnniversaryMilestone&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.isRecurringAnnual, isRecurringAnnual) || other.isRecurringAnnual == isRecurringAnnual)&&(identical(other.iconEmoji, iconEmoji) || other.iconEmoji == iconEmoji)&&(identical(other.note, note) || other.note == note)&&(identical(other.category, category) || other.category == category));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,targetDate,isRecurringAnnual,iconEmoji,note,category);

@override
String toString() {
  return 'AnniversaryMilestone(id: $id, title: $title, targetDate: $targetDate, isRecurringAnnual: $isRecurringAnnual, iconEmoji: $iconEmoji, note: $note, category: $category)';
}


}

/// @nodoc
abstract mixin class _$AnniversaryMilestoneCopyWith<$Res> implements $AnniversaryMilestoneCopyWith<$Res> {
  factory _$AnniversaryMilestoneCopyWith(_AnniversaryMilestone value, $Res Function(_AnniversaryMilestone) _then) = __$AnniversaryMilestoneCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, DateTime targetDate, bool isRecurringAnnual, String iconEmoji, String? note, String category
});




}
/// @nodoc
class __$AnniversaryMilestoneCopyWithImpl<$Res>
    implements _$AnniversaryMilestoneCopyWith<$Res> {
  __$AnniversaryMilestoneCopyWithImpl(this._self, this._then);

  final _AnniversaryMilestone _self;
  final $Res Function(_AnniversaryMilestone) _then;

/// Create a copy of AnniversaryMilestone
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? targetDate = null,Object? isRecurringAnnual = null,Object? iconEmoji = null,Object? note = freezed,Object? category = null,}) {
  return _then(_AnniversaryMilestone(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,targetDate: null == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as DateTime,isRecurringAnnual: null == isRecurringAnnual ? _self.isRecurringAnnual : isRecurringAnnual // ignore: cast_nullable_to_non_nullable
as bool,iconEmoji: null == iconEmoji ? _self.iconEmoji : iconEmoji // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
