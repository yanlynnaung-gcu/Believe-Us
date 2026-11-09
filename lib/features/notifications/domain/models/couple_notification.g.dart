// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'couple_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CoupleNotification _$CoupleNotificationFromJson(Map<String, dynamic> json) =>
    _CoupleNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      data: json['data'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
    );

Map<String, dynamic> _$CoupleNotificationToJson(_CoupleNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'data': instance.data,
      'createdAt': instance.createdAt.toIso8601String(),
      'isRead': instance.isRead,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.textMessage: 'textMessage',
  NotificationType.voiceMessage: 'voiceMessage',
  NotificationType.giftReceived: 'giftReceived',
  NotificationType.locationArrival: 'locationArrival',
  NotificationType.anniversaryReminder: 'anniversaryReminder',
};
