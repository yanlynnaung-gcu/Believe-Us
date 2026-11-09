// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gift_transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GiftTransaction {

 String get id; String get senderId; String get receiverId; String get coupleSpaceId; String get packageTitle; int get amountMmK; PaymentProvider get provider; String get note; TransactionStatus get status; String get transactionRef; DateTime get createdAt;
/// Create a copy of GiftTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GiftTransactionCopyWith<GiftTransaction> get copyWith => _$GiftTransactionCopyWithImpl<GiftTransaction>(this as GiftTransaction, _$identity);

  /// Serializes this GiftTransaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GiftTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.receiverId, receiverId) || other.receiverId == receiverId)&&(identical(other.coupleSpaceId, coupleSpaceId) || other.coupleSpaceId == coupleSpaceId)&&(identical(other.packageTitle, packageTitle) || other.packageTitle == packageTitle)&&(identical(other.amountMmK, amountMmK) || other.amountMmK == amountMmK)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.note, note) || other.note == note)&&(identical(other.status, status) || other.status == status)&&(identical(other.transactionRef, transactionRef) || other.transactionRef == transactionRef)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,senderId,receiverId,coupleSpaceId,packageTitle,amountMmK,provider,note,status,transactionRef,createdAt);

@override
String toString() {
  return 'GiftTransaction(id: $id, senderId: $senderId, receiverId: $receiverId, coupleSpaceId: $coupleSpaceId, packageTitle: $packageTitle, amountMmK: $amountMmK, provider: $provider, note: $note, status: $status, transactionRef: $transactionRef, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $GiftTransactionCopyWith<$Res>  {
  factory $GiftTransactionCopyWith(GiftTransaction value, $Res Function(GiftTransaction) _then) = _$GiftTransactionCopyWithImpl;
@useResult
$Res call({
 String id, String senderId, String receiverId, String coupleSpaceId, String packageTitle, int amountMmK, PaymentProvider provider, String note, TransactionStatus status, String transactionRef, DateTime createdAt
});




}
/// @nodoc
class _$GiftTransactionCopyWithImpl<$Res>
    implements $GiftTransactionCopyWith<$Res> {
  _$GiftTransactionCopyWithImpl(this._self, this._then);

  final GiftTransaction _self;
  final $Res Function(GiftTransaction) _then;

/// Create a copy of GiftTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? senderId = null,Object? receiverId = null,Object? coupleSpaceId = null,Object? packageTitle = null,Object? amountMmK = null,Object? provider = null,Object? note = null,Object? status = null,Object? transactionRef = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,receiverId: null == receiverId ? _self.receiverId : receiverId // ignore: cast_nullable_to_non_nullable
as String,coupleSpaceId: null == coupleSpaceId ? _self.coupleSpaceId : coupleSpaceId // ignore: cast_nullable_to_non_nullable
as String,packageTitle: null == packageTitle ? _self.packageTitle : packageTitle // ignore: cast_nullable_to_non_nullable
as String,amountMmK: null == amountMmK ? _self.amountMmK : amountMmK // ignore: cast_nullable_to_non_nullable
as int,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as PaymentProvider,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransactionStatus,transactionRef: null == transactionRef ? _self.transactionRef : transactionRef // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [GiftTransaction].
extension GiftTransactionPatterns on GiftTransaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GiftTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GiftTransaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GiftTransaction value)  $default,){
final _that = this;
switch (_that) {
case _GiftTransaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GiftTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _GiftTransaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String senderId,  String receiverId,  String coupleSpaceId,  String packageTitle,  int amountMmK,  PaymentProvider provider,  String note,  TransactionStatus status,  String transactionRef,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GiftTransaction() when $default != null:
return $default(_that.id,_that.senderId,_that.receiverId,_that.coupleSpaceId,_that.packageTitle,_that.amountMmK,_that.provider,_that.note,_that.status,_that.transactionRef,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String senderId,  String receiverId,  String coupleSpaceId,  String packageTitle,  int amountMmK,  PaymentProvider provider,  String note,  TransactionStatus status,  String transactionRef,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _GiftTransaction():
return $default(_that.id,_that.senderId,_that.receiverId,_that.coupleSpaceId,_that.packageTitle,_that.amountMmK,_that.provider,_that.note,_that.status,_that.transactionRef,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String senderId,  String receiverId,  String coupleSpaceId,  String packageTitle,  int amountMmK,  PaymentProvider provider,  String note,  TransactionStatus status,  String transactionRef,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _GiftTransaction() when $default != null:
return $default(_that.id,_that.senderId,_that.receiverId,_that.coupleSpaceId,_that.packageTitle,_that.amountMmK,_that.provider,_that.note,_that.status,_that.transactionRef,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GiftTransaction implements GiftTransaction {
  const _GiftTransaction({required this.id, required this.senderId, required this.receiverId, required this.coupleSpaceId, required this.packageTitle, required this.amountMmK, required this.provider, required this.note, required this.status, required this.transactionRef, required this.createdAt});
  factory _GiftTransaction.fromJson(Map<String, dynamic> json) => _$GiftTransactionFromJson(json);

@override final  String id;
@override final  String senderId;
@override final  String receiverId;
@override final  String coupleSpaceId;
@override final  String packageTitle;
@override final  int amountMmK;
@override final  PaymentProvider provider;
@override final  String note;
@override final  TransactionStatus status;
@override final  String transactionRef;
@override final  DateTime createdAt;

/// Create a copy of GiftTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GiftTransactionCopyWith<_GiftTransaction> get copyWith => __$GiftTransactionCopyWithImpl<_GiftTransaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GiftTransactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GiftTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.receiverId, receiverId) || other.receiverId == receiverId)&&(identical(other.coupleSpaceId, coupleSpaceId) || other.coupleSpaceId == coupleSpaceId)&&(identical(other.packageTitle, packageTitle) || other.packageTitle == packageTitle)&&(identical(other.amountMmK, amountMmK) || other.amountMmK == amountMmK)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.note, note) || other.note == note)&&(identical(other.status, status) || other.status == status)&&(identical(other.transactionRef, transactionRef) || other.transactionRef == transactionRef)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,senderId,receiverId,coupleSpaceId,packageTitle,amountMmK,provider,note,status,transactionRef,createdAt);

@override
String toString() {
  return 'GiftTransaction(id: $id, senderId: $senderId, receiverId: $receiverId, coupleSpaceId: $coupleSpaceId, packageTitle: $packageTitle, amountMmK: $amountMmK, provider: $provider, note: $note, status: $status, transactionRef: $transactionRef, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$GiftTransactionCopyWith<$Res> implements $GiftTransactionCopyWith<$Res> {
  factory _$GiftTransactionCopyWith(_GiftTransaction value, $Res Function(_GiftTransaction) _then) = __$GiftTransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, String senderId, String receiverId, String coupleSpaceId, String packageTitle, int amountMmK, PaymentProvider provider, String note, TransactionStatus status, String transactionRef, DateTime createdAt
});




}
/// @nodoc
class __$GiftTransactionCopyWithImpl<$Res>
    implements _$GiftTransactionCopyWith<$Res> {
  __$GiftTransactionCopyWithImpl(this._self, this._then);

  final _GiftTransaction _self;
  final $Res Function(_GiftTransaction) _then;

/// Create a copy of GiftTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? senderId = null,Object? receiverId = null,Object? coupleSpaceId = null,Object? packageTitle = null,Object? amountMmK = null,Object? provider = null,Object? note = null,Object? status = null,Object? transactionRef = null,Object? createdAt = null,}) {
  return _then(_GiftTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,receiverId: null == receiverId ? _self.receiverId : receiverId // ignore: cast_nullable_to_non_nullable
as String,coupleSpaceId: null == coupleSpaceId ? _self.coupleSpaceId : coupleSpaceId // ignore: cast_nullable_to_non_nullable
as String,packageTitle: null == packageTitle ? _self.packageTitle : packageTitle // ignore: cast_nullable_to_non_nullable
as String,amountMmK: null == amountMmK ? _self.amountMmK : amountMmK // ignore: cast_nullable_to_non_nullable
as int,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as PaymentProvider,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransactionStatus,transactionRef: null == transactionRef ? _self.transactionRef : transactionRef // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
