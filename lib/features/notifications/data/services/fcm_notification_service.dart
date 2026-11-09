import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:thae_nge_lay/features/notifications/domain/models/couple_notification.dart';

part 'fcm_notification_service.g.dart';

class FcmNotificationService {
  final Uuid _uuid = const Uuid();
  final StreamController<CoupleNotification> _notificationStream =
      StreamController<CoupleNotification>.broadcast();

  final List<CoupleNotification> _history = [];

  Stream<CoupleNotification> get onNotificationReceived =>
      _notificationStream.stream;
  List<CoupleNotification> get history => List.unmodifiable(_history);

  String? _fcmToken;
  String get fcmToken => _fcmToken ?? 'fcm_token_${_uuid.v4().substring(0, 12)}';

  Future<void> init() async {
    _fcmToken = 'fcm_believeus_${_uuid.v4().substring(0, 16)}';
  }

  void _dispatch(CoupleNotification notification) {
    _history.insert(0, notification);
    _notificationStream.add(notification);
  }

  // Event 1: New text message
  void triggerTextMessagePush({
    required String senderName,
    required String previewText,
  }) {
    _dispatch(
      CoupleNotification(
        id: 'notif_${_uuid.v4().substring(0, 8)}',
        title: '❤️ $senderName sent a love note',
        body: previewText,
        type: NotificationType.textMessage,
        createdAt: DateTime.now(),
      ),
    );
  }

  // Event 2: New voice message
  void triggerVoiceMessagePush({
    required String senderName,
    required int durationSeconds,
  }) {
    _dispatch(
      CoupleNotification(
        id: 'notif_${_uuid.v4().substring(0, 8)}',
        title: '🎙️ $senderName sent a voice message ($durationSeconds s)',
        body: 'Tap to listen to your partner\'s voice right now.',
        type: NotificationType.voiceMessage,
        createdAt: DateTime.now(),
      ),
    );
  }

  // Event 3: KPay / WavePay gift received
  void triggerGiftReceivedPush({
    required String senderName,
    required String provider,
    required String amount,
  }) {
    _dispatch(
      CoupleNotification(
        id: 'notif_${_uuid.v4().substring(0, 8)}',
        title: '🎉 Gift Received via $provider!',
        body: '$senderName just surprised you with $amount ❤️',
        type: NotificationType.giftReceived,
        createdAt: DateTime.now(),
      ),
    );
  }

  // Event 4: Partner location check-in / arrival alert
  void triggerLocationArrivalPush({
    required String partnerName,
    required String placeName,
  }) {
    _dispatch(
      CoupleNotification(
        id: 'notif_${_uuid.v4().substring(0, 8)}',
        title: '📍 $partnerName arrived safely at $placeName',
        body: 'Location check-in confirmed across your sacred connection.',
        type: NotificationType.locationArrival,
        createdAt: DateTime.now(),
      ),
    );
  }

  // Event 5: Upcoming anniversary reminder
  void triggerAnniversaryReminderPush({
    required String title,
    required int daysRemaining,
  }) {
    final dayLabel = daysRemaining == 0
        ? 'TODAY is the day! Celebrate your bond ❤️'
        : 'Only $daysRemaining days left to celebrate!';

    _dispatch(
      CoupleNotification(
        id: 'notif_${_uuid.v4().substring(0, 8)}',
        title: '💍 Upcoming Milestone: $title',
        body: dayLabel,
        type: NotificationType.anniversaryReminder,
        createdAt: DateTime.now(),
      ),
    );
  }

  void dispose() {
    _notificationStream.close();
  }
}

@Riverpod(keepAlive: true)
FcmNotificationService fcmNotificationService(Ref ref) {
  final service = FcmNotificationService();
  service.init();
  ref.onDispose(() => service.dispose());
  return service;
}
