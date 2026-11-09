import 'package:freezed_annotation/freezed_annotation.dart';

part 'couple_notification.freezed.dart';
part 'couple_notification.g.dart';

enum NotificationType {
  textMessage,
  voiceMessage,
  giftReceived,
  locationArrival,
  anniversaryReminder,
}

@freezed
abstract class CoupleNotification with _$CoupleNotification {
  const factory CoupleNotification({
    required String id,
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
    required DateTime createdAt,
    @Default(false) bool isRead,
  }) = _CoupleNotification;

  factory CoupleNotification.fromJson(Map<String, dynamic> json) =>
      _$CoupleNotificationFromJson(json);
}
