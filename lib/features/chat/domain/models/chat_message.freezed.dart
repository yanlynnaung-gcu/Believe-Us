// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatMessage {

 String get id; String get senderId; String get receiverId; String get coupleSpaceId; MessageType get type; String? get text; String? get audioPath; int? get audioDurationSeconds; List<double>? get waveformSamples; Map<String, dynamic>? get giftData; DateTime get createdAt; bool get isRead;
/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessageCopyWith<ChatMessage> get copyWith => _$ChatMessageCopyWithImpl<ChatMessage>(this as ChatMessage, _$identity);

  /// Serializes this ChatMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.receiverId, receiverId) || other.receiverId == receiverId)&&(identical(other.coupleSpaceId, coupleSpaceId) || other.coupleSpaceId == coupleSpaceId)&&(identical(other.type, type) || other.type == type)&&(identical(other.text, text) || other.text == text)&&(identical(other.audioPath, audioPath) || other.audioPath == audioPath)&&(identical(other.audioDurationSeconds, audioDurationSeconds) || other.audioDurationSeconds == audioDurationSeconds)&&const DeepCollectionEquality().equals(other.waveformSamples, waveformSamples)&&const DeepCollectionEquality().equals(other.giftData, giftData)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isRead, isRead) || other.isRead == isRead));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,senderId,receiverId,coupleSpaceId,type,text,audioPath,audioDurationSeconds,const DeepCollectionEquality().hash(waveformSamples),const DeepCollectionEquality().hash(giftData),createdAt,isRead);

@override
String toString() {
  return 'ChatMessage(id: $id, senderId: $senderId, receiverId: $receiverId, coupleSpaceId: $coupleSpaceId, type: $type, text: $text, audioPath: $audioPath, audioDurationSeconds: $audioDurationSeconds, waveformSamples: $waveformSamples, giftData: $giftData, createdAt: $createdAt, isRead: $isRead)';
}


}

/// @nodoc
abstract mixin class $ChatMessageCopyWith<$Res>  {
  factory $ChatMessageCopyWith(ChatMessage value, $Res Function(ChatMessage) _then) = _$ChatMessageCopyWithImpl;
@useResult
$Res call({
 String id, String senderId, String receiverId, String coupleSpaceId, MessageType type, String? text, String? audioPath, int? audioDurationSeconds, List<double>? waveformSamples, Map<String, dynamic>? giftData, DateTime createdAt, bool isRead
});




}
/// @nodoc
class _$ChatMessageCopyWithImpl<$Res>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._self, this._then);

  final ChatMessage _self;
  final $Res Function(ChatMessage) _then;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? senderId = null,Object? receiverId = null,Object? coupleSpaceId = null,Object? type = null,Object? text = freezed,Object? audioPath = freezed,Object? audioDurationSeconds = freezed,Object? waveformSamples = freezed,Object? giftData = freezed,Object? createdAt = null,Object? isRead = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,receiverId: null == receiverId ? _self.receiverId : receiverId // ignore: cast_nullable_to_non_nullable
as String,coupleSpaceId: null == coupleSpaceId ? _self.coupleSpaceId : coupleSpaceId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MessageType,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,audioPath: freezed == audioPath ? _self.audioPath : audioPath // ignore: cast_nullable_to_non_nullable
as String?,audioDurationSeconds: freezed == audioDurationSeconds ? _self.audioDurationSeconds : audioDurationSeconds // ignore: cast_nullable_to_non_nullable
as int?,waveformSamples: freezed == waveformSamples ? _self.waveformSamples : waveformSamples // ignore: cast_nullable_to_non_nullable
as List<double>?,giftData: freezed == giftData ? _self.giftData : giftData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatMessage].
extension ChatMessagePatterns on ChatMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMessage value)  $default,){
final _that = this;
switch (_that) {
case _ChatMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMessage value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String senderId,  String receiverId,  String coupleSpaceId,  MessageType type,  String? text,  String? audioPath,  int? audioDurationSeconds,  List<double>? waveformSamples,  Map<String, dynamic>? giftData,  DateTime createdAt,  bool isRead)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that.id,_that.senderId,_that.receiverId,_that.coupleSpaceId,_that.type,_that.text,_that.audioPath,_that.audioDurationSeconds,_that.waveformSamples,_that.giftData,_that.createdAt,_that.isRead);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String senderId,  String receiverId,  String coupleSpaceId,  MessageType type,  String? text,  String? audioPath,  int? audioDurationSeconds,  List<double>? waveformSamples,  Map<String, dynamic>? giftData,  DateTime createdAt,  bool isRead)  $default,) {final _that = this;
switch (_that) {
case _ChatMessage():
return $default(_that.id,_that.senderId,_that.receiverId,_that.coupleSpaceId,_that.type,_that.text,_that.audioPath,_that.audioDurationSeconds,_that.waveformSamples,_that.giftData,_that.createdAt,_that.isRead);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String senderId,  String receiverId,  String coupleSpaceId,  MessageType type,  String? text,  String? audioPath,  int? audioDurationSeconds,  List<double>? waveformSamples,  Map<String, dynamic>? giftData,  DateTime createdAt,  bool isRead)?  $default,) {final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that.id,_that.senderId,_that.receiverId,_that.coupleSpaceId,_that.type,_that.text,_that.audioPath,_that.audioDurationSeconds,_that.waveformSamples,_that.giftData,_that.createdAt,_that.isRead);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatMessage implements ChatMessage {
  const _ChatMessage({required this.id, required this.senderId, required this.receiverId, required this.coupleSpaceId, required this.type, this.text, this.audioPath, this.audioDurationSeconds, final  List<double>? waveformSamples, final  Map<String, dynamic>? giftData, required this.createdAt, this.isRead = false}): _waveformSamples = waveformSamples,_giftData = giftData;
  factory _ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);

@override final  String id;
@override final  String senderId;
@override final  String receiverId;
@override final  String coupleSpaceId;
@override final  MessageType type;
@override final  String? text;
@override final  String? audioPath;
@override final  int? audioDurationSeconds;
 final  List<double>? _waveformSamples;
@override List<double>? get waveformSamples {
  final value = _waveformSamples;
  if (value == null) return null;
  if (_waveformSamples is EqualUnmodifiableListView) return _waveformSamples;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  Map<String, dynamic>? _giftData;
@override Map<String, dynamic>? get giftData {
  final value = _giftData;
  if (value == null) return null;
  if (_giftData is EqualUnmodifiableMapView) return _giftData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime createdAt;
@override@JsonKey() final  bool isRead;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMessageCopyWith<_ChatMessage> get copyWith => __$ChatMessageCopyWithImpl<_ChatMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.receiverId, receiverId) || other.receiverId == receiverId)&&(identical(other.coupleSpaceId, coupleSpaceId) || other.coupleSpaceId == coupleSpaceId)&&(identical(other.type, type) || other.type == type)&&(identical(other.text, text) || other.text == text)&&(identical(other.audioPath, audioPath) || other.audioPath == audioPath)&&(identical(other.audioDurationSeconds, audioDurationSeconds) || other.audioDurationSeconds == audioDurationSeconds)&&const DeepCollectionEquality().equals(other._waveformSamples, _waveformSamples)&&const DeepCollectionEquality().equals(other._giftData, _giftData)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isRead, isRead) || other.isRead == isRead));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,senderId,receiverId,coupleSpaceId,type,text,audioPath,audioDurationSeconds,const DeepCollectionEquality().hash(_waveformSamples),const DeepCollectionEquality().hash(_giftData),createdAt,isRead);

@override
String toString() {
  return 'ChatMessage(id: $id, senderId: $senderId, receiverId: $receiverId, coupleSpaceId: $coupleSpaceId, type: $type, text: $text, audioPath: $audioPath, audioDurationSeconds: $audioDurationSeconds, waveformSamples: $waveformSamples, giftData: $giftData, createdAt: $createdAt, isRead: $isRead)';
}


}

/// @nodoc
abstract mixin class _$ChatMessageCopyWith<$Res> implements $ChatMessageCopyWith<$Res> {
  factory _$ChatMessageCopyWith(_ChatMessage value, $Res Function(_ChatMessage) _then) = __$ChatMessageCopyWithImpl;
@override @useResult
$Res call({
 String id, String senderId, String receiverId, String coupleSpaceId, MessageType type, String? text, String? audioPath, int? audioDurationSeconds, List<double>? waveformSamples, Map<String, dynamic>? giftData, DateTime createdAt, bool isRead
});




}
/// @nodoc
class __$ChatMessageCopyWithImpl<$Res>
    implements _$ChatMessageCopyWith<$Res> {
  __$ChatMessageCopyWithImpl(this._self, this._then);

  final _ChatMessage _self;
  final $Res Function(_ChatMessage) _then;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? senderId = null,Object? receiverId = null,Object? coupleSpaceId = null,Object? type = null,Object? text = freezed,Object? audioPath = freezed,Object? audioDurationSeconds = freezed,Object? waveformSamples = freezed,Object? giftData = freezed,Object? createdAt = null,Object? isRead = null,}) {
  return _then(_ChatMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,receiverId: null == receiverId ? _self.receiverId : receiverId // ignore: cast_nullable_to_non_nullable
as String,coupleSpaceId: null == coupleSpaceId ? _self.coupleSpaceId : coupleSpaceId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MessageType,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,audioPath: freezed == audioPath ? _self.audioPath : audioPath // ignore: cast_nullable_to_non_nullable
as String?,audioDurationSeconds: freezed == audioDurationSeconds ? _self.audioDurationSeconds : audioDurationSeconds // ignore: cast_nullable_to_non_nullable
as int?,waveformSamples: freezed == waveformSamples ? _self._waveformSamples : waveformSamples // ignore: cast_nullable_to_non_nullable
as List<double>?,giftData: freezed == giftData ? _self._giftData : giftData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
