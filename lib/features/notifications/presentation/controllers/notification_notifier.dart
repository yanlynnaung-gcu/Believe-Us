import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thae_nge_lay/features/notifications/data/services/fcm_notification_service.dart';
import 'package:thae_nge_lay/features/notifications/domain/models/couple_notification.dart';

part 'notification_notifier.g.dart';

@riverpod
class NotificationNotifier extends _$NotificationNotifier {
  @override
  Stream<CoupleNotification> build() {
    final service = ref.watch(fcmNotificationServiceProvider);
    return service.onNotificationReceived;
  }
}
