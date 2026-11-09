// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => _ChatMessage(
  id: json['id'] as String,
  senderId: json['senderId'] as String,
  receiverId: json['receiverId'] as String,
  coupleSpaceId: json['coupleSpaceId'] as String,
  type: $enumDecode(_$MessageTypeEnumMap, json['type']),
  text: json['text'] as String?,
  audioPath: json['audioPath'] as String?,
  audioDurationSeconds: (json['audioDurationSeconds'] as num?)?.toInt(),
  waveformSamples: (json['waveformSamples'] as List<dynamic>?)
      ?.map((e) => (e as num).toDouble())
      .toList(),
  giftData: json['giftData'] as Map<String, dynamic>?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  isRead: json['isRead'] as bool? ?? false,
);

Map<String, dynamic> _$ChatMessageToJson(_ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderId': instance.senderId,
      'receiverId': instance.receiverId,
      'coupleSpaceId': instance.coupleSpaceId,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'text': instance.text,
      'audioPath': instance.audioPath,
      'audioDurationSeconds': instance.audioDurationSeconds,
      'waveformSamples': instance.waveformSamples,
      'giftData': instance.giftData,
      'createdAt': instance.createdAt.toIso8601String(),
      'isRead': instance.isRead,
    };

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.voice: 'voice',
  MessageType.gift: 'gift',
};
