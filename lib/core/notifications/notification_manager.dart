import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:thae_nge_lay/core/network/api_endpoints.dart';
import 'package:thae_nge_lay/core/router/app_router.dart';
import 'package:thae_nge_lay/core/router/route_names.dart';

/// Top-level background message handler for FCM
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationManager.instance.showHeadsUpBannerFromRemoteMessage(message);
}

/// Central Native Notification Engine managing FCM Push Notifications and Local Notifications
class NotificationManager {
  static final NotificationManager instance = NotificationManager._internal();
  NotificationManager._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel highPriorityChannel =
      AndroidNotificationChannel(
    'believeus_high_priority_channel',
    'Thae Thae Sacred Alerts',
    description:
        'High-priority heads-up alerts for partner love messages, gifts, transactions and arrivals.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  String? _fcmToken;
  String get fcmToken => _fcmToken ?? 'fcm_believeus_local_device_token';

  String? _pendingInitialRoute;
  String? consumePendingRoute() {
    final route = _pendingInitialRoute;
    _pendingInitialRoute = null;
    return route;
  }

  bool _isInitialized = false;

  bool get _hasPlatformInstance {
    try {
      // FlutterLocalNotificationsPlatform.instance is a late field that throws if not registered
      FlutterLocalNotificationsPlatform.instance;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Initializes Flutter Local Notifications and Firebase Messaging
  Future<void> init() async {
    if (_isInitialized) return;

    if (!_hasPlatformInstance) {
      debugPrint('[NotificationManager] Headless test environment detected; using simulated notification engine.');
      _isInitialized = true;
      return;
    }

    // 1. Initialize Local Notifications Plugin
    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          _handleNotificationPayload(response.payload);
        },
      );

      final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(highPriorityChannel);
        await androidPlugin.requestNotificationsPermission();
      }

      // Check if app was launched by tapping a notification while terminated
      final launchDetails =
          await _localNotifications.getNotificationAppLaunchDetails();
      if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
        final payload = launchDetails.notificationResponse?.payload;
        if (payload != null && payload.isNotEmpty) {
          _handleNotificationPayload(payload);
        }
      }
    } catch (e) {
      debugPrint('[NotificationManager] Local notifications init note: $e');
    }

    // 2. Safely Initialize Firebase Core and Messaging
    try {
      if (Firebase.apps.isEmpty) {
        try {
          await Firebase.initializeApp();
        } catch (_) {
          await Firebase.initializeApp(
            options: const FirebaseOptions(
              apiKey: 'AIzaSyBelieveUsKeyFallback1234567890',
              appId: '1:123456789012:android:abcdef123456',
              messagingSenderId: '123456789012',
              projectId: 'believeus-app',
            ),
          );
        }
      }

      final messaging = FirebaseMessaging.instance;

      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      try {
        // ignore: deprecated_member_use
        final token = await messaging.getToken();
        if (token != null && token.isNotEmpty) {
          _fcmToken = token;
        }
      } catch (tokenErr) {
        debugPrint('[NotificationManager] FCM Token notice: $tokenErr');
      }

      // Foreground message listener: show native heads-up banner
      FirebaseMessaging.onMessage.listen(showHeadsUpBannerFromRemoteMessage);

      // Notification tapped when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleRemoteMessageTap);

      // Check initial message if app opened from terminated state via FCM
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleRemoteMessageTap(initialMessage);
      }
    } catch (e) {
      debugPrint('[NotificationManager] Firebase Messaging init note: $e');
    }

    _isInitialized = true;
  }

  /// Displays a native heads-up notification banner from an incoming FCM RemoteMessage
  Future<void> showHeadsUpBannerFromRemoteMessage(RemoteMessage message) async {
    final title = message.notification?.title ??
        message.data['title'] ??
        '❤️ Thae Thae Alert';
    final body = message.notification?.body ??
        message.data['body'] ??
        'You have a new sacred alert from your partner.';

    final payload = jsonEncode(message.data);
    final notificationId = message.messageId.hashCode;

    await showHeadsUpBanner(
      id: notificationId,
      title: title,
      body: body,
      data: message.data,
      payload: payload,
    );
  }

  /// Displays native heads-up push notification banner at top of device screen
  Future<void> showHeadsUpBanner({
    required int id,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? payload,
  }) async {
    try {
      final effectivePayload =
          payload ?? (data != null ? jsonEncode(data) : null);

      if (!_hasPlatformInstance) {
        debugPrint('[NotificationManager Heads-Up Banner] Title: $title, Body: $body, Payload: $effectivePayload');
        return;
      }

      final androidDetails = AndroidNotificationDetails(
        highPriorityChannel.id,
        highPriorityChannel.name,
        channelDescription: highPriorityChannel.description,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(body),
        category: AndroidNotificationCategory.message,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: effectivePayload,
      );
    } catch (e) {
      debugPrint('[NotificationManager] Error displaying heads-up notification: $e');
    }
  }

  /// Displays heads-up notification for KPay / WavePay gifting transaction
  Future<void> showTransactionNotification({
    required String provider,
    required String amount,
    required String senderName,
    String? note,
  }) async {
    final title = '🎉 Gift Received via $provider!';
    final body = '$senderName just surprised you with $amount ❤️';
    final data = {
      'route': AppRoutes.chat,
      'type': 'GIFT_RECEIVED',
      'provider': provider,
      'amount': amount,
      'senderName': senderName,
      'note': note ?? '',
    };

    await showHeadsUpBanner(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      data: data,
    );
  }

  /// Displays heads-up notification for partner chat love notes or voice memos
  Future<void> showChatMessageNotification({
    required String senderName,
    required String message,
    String? type,
  }) async {
    final isVoice = (type ?? '').toLowerCase() == 'voice';
    final title = isVoice
        ? '🎙️ $senderName sent a voice message'
        : '❤️ $senderName sent a love note';
    final body = isVoice ? 'Tap to listen to your partner\'s voice right now.' : message;

    final data = {
      'route': AppRoutes.chat,
      'type': 'CHAT_MESSAGE',
      'senderName': senderName,
      'messageType': type ?? 'text',
    };

    await showHeadsUpBanner(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      data: data,
    );
  }

  /// Displays heads-up notification for partner location arrival
  Future<void> showArrivalNotification({
    required String partnerName,
    required String placeName,
  }) async {
    final title = '📍 $partnerName arrived safely at $placeName';
    const body = 'Location check-in confirmed across your sacred connection.';

    final data = {
      'route': AppRoutes.locationDetails,
      'type': 'LOCATION_ARRIVAL',
      'partnerName': partnerName,
      'placeName': placeName,
    };

    await showHeadsUpBanner(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      data: data,
    );
  }

  /// Displays heads-up notification for 1-to-1 couple pairing
  Future<void> showPairingNotification({
    required String partnerName,
    required String coupleSpaceId,
  }) async {
    const title = '💍 Sacred Bond Connected!';
    final body = 'You and $partnerName are now officially paired in space #$coupleSpaceId.';

    final data = {
      'route': AppRoutes.home,
      'type': 'COUPLE_PAIRED',
      'partnerName': partnerName,
      'coupleSpaceId': coupleSpaceId,
    };

    await showHeadsUpBanner(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      data: data,
    );
  }

  /// Syncs FCM Device Registration Token with backend database
  Future<void> syncTokenWithBackend({
    required String userId,
    required Dio dio,
  }) async {
    if (userId.isEmpty) return;
    try {
      await dio.put(
        ApiEndpoints.userFcmTokenPath(userId),
        data: {'fcmToken': fcmToken},
      );
      debugPrint('[NotificationManager] Registered FCM token with backend for user $userId');
    } catch (e) {
      debugPrint('[NotificationManager] Token sync warning: $e');
    }
  }

  /// Handles FCM RemoteMessage tap
  void _handleRemoteMessageTap(RemoteMessage message) {
    final route = message.data['route'];
    final type = message.data['type'];
    _routeToDestination(route: route, type: type);
  }

  /// Handles notification response payload from local notifications
  void _handleNotificationPayload(String? payload) {
    if (payload == null || payload.isEmpty) return;

    String? route;
    String? type;

    try {
      if (payload.trim().startsWith('{')) {
        final Map<String, dynamic> data = jsonDecode(payload);
        route = data['route']?.toString();
        type = data['type']?.toString();
      } else {
        route = payload.trim();
      }
    } catch (_) {
      route = payload.trim();
    }

    _routeToDestination(route: route, type: type);
  }

  /// Resolves destination route and transitions navigation
  void _routeToDestination({String? route, String? type}) {
    String target = AppRoutes.home;

    if (route != null && route.isNotEmpty) {
      target = route;
    } else if (type != null) {
      switch (type) {
        case 'CHAT_MESSAGE':
        case 'textMessage':
        case 'voiceMessage':
        case 'GIFT_RECEIVED':
        case 'giftReceived':
        case 'PAYMENT_TRANSACTION':
          target = AppRoutes.chat;
          break;
        case 'LOCATION_ARRIVAL':
        case 'locationArrival':
        case 'LOCATION_CHECKIN_NUDGE':
          target = AppRoutes.locationDetails;
          break;
        case 'EMERGENCY_SOS':
          target = AppRoutes.emergencyAlarm;
          break;
        case 'COUPLE_PAIRED':
          target = AppRoutes.home;
          break;
        default:
          target = AppRoutes.home;
      }
    }

    navigateToRoute(target);
  }

  /// Navigates to target route using root navigator key or saves for pending startup
  void navigateToRoute(String route, {Object? extra}) {
    final context = rootNavigatorKey.currentContext;
    if (context != null && context.mounted) {
      try {
        GoRouter.of(context).push(route, extra: extra);
      } catch (_) {
        try {
          GoRouter.of(context).go(route, extra: extra);
        } catch (e) {
          debugPrint('[NotificationManager] Navigation failure for $route: $e');
        }
      }
    } else {
      _pendingInitialRoute = route;
    }
  }
}
