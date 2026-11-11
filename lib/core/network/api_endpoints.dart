/// Configuration & Base URL resolution for Thae Thae Real-Time Multi-Device Sync
class ApiEndpoints {
  /// Railway Production Base URL (Default အဖြစ် အမြဲသုံးရန်)
  static const String defaultProductionUrl =
      'https://believe-us-production.up.railway.app';

  /// Local Testing IP (Fallback when explicitly targeted)
  static const String defaultLanIp = '192.168.1.6';
  static const int defaultPort = 8080;
  static const int defaultMqttPort = 1883;

  /// Resolves the host for API & WebSocket:
  static String get host {
    const customHost = String.fromEnvironment('API_HOST');
    if (customHost.isNotEmpty) {
      return customHost;
    }
    return defaultLanIp;
  }

  static int get port {
    const customPort = String.fromEnvironment('API_PORT');
    if (customPort.isNotEmpty) {
      return int.tryParse(customPort) ?? defaultPort;
    }
    return defaultPort;
  }

  static int get mqttPort {
    const customMqttPort = String.fromEnvironment('MQTT_PORT');
    if (customMqttPort.isNotEmpty) {
      return int.tryParse(customMqttPort) ?? defaultMqttPort;
    }
    return defaultMqttPort;
  }

  static String get mqttBrokerHost {
    const customMqttHost = String.fromEnvironment('MQTT_HOST');
    if (customMqttHost.isNotEmpty) {
      return customMqttHost;
    }
    return host;
  }

  static String get baseUrl {
    const customBaseUrl = String.fromEnvironment('API_BASE_URL');
    if (customBaseUrl.isNotEmpty) {
      return customBaseUrl;
    }
    // Default အနေဖြင့် Railway Production URL ကို အမြဲသုံးမည်
    return defaultProductionUrl;
  }

  static String get wsUrl {
    const customWsUrl = String.fromEnvironment('WS_BASE_URL');
    if (customWsUrl.isNotEmpty) {
      return customWsUrl;
    }

    if (baseUrl.contains('up.railway.app') || baseUrl.startsWith('https://')) {
      final uri = Uri.parse(baseUrl);
      return 'wss://${uri.host}/ws';
    }

    return 'ws://$host:$port/ws';
  }

  // Authentication & Users endpoints
  static const String authEmailSendOtpPath = '/api/v1/auth/email/send-otp';
  static const String authEmailVerifyOtpPath = '/api/v1/auth/email/verify-otp';
  static const String authForgotPasswordSendOtpPath = '/api/v1/auth/forgot-password/send-otp';
  static const String authResetPasswordPath = '/api/v1/auth/reset-password';
  static const String authRegisterPath = '/api/v1/auth/register';
  static const String authLoginPath = '/api/v1/auth/login';
  static String authLoginTicketPath(String ticketId) => '/api/v1/auth/login-ticket/$ticketId';
  static String authLoginTicketResolvePath(String ticketId) => '/api/v1/auth/login-ticket/$ticketId/resolve';
  static const String authGooglePath = '/api/v1/auth/google';
  static const String usersPath = '/api/v1/users';
  static const String couplesPath = '/api/v1/couples';

  // Location endpoints
  static const String arrivalsPath = '/api/v1/location/arrivals';
  static const String placesPath = '/api/v1/location/places';
  static const String heartbeatPath = '/api/v1/location/heartbeat';
  static const String nudgePath = '/api/v1/location/nudge';
  static const String latestLocationPath = '/api/v1/location/latest';
  static const String emergencyPath = '/api/v1/couple/emergency';

  // 1-to-1 Couple Pairing endpoints
  static const String pairingCodePath = '/api/v1/pairing/code';
  static const String pairingGeneratePath = '/api/v1/pairing/generate';
  static const String pairPath = '/api/v1/pairing/pair';
  static const String pairingStatusPath = '/api/v1/pairing/status';
  static const String unpairPath = '/api/v1/pairing/unpair';

  // Chat & Messaging endpoints
  static const String chatMessagesPath = '/api/v1/chat/messages';
  static const String chatVoiceUploadPath = '/api/v1/chat/voice';
  static const String chatUnreadPath = '/api/v1/chat/unread';
  static const String chatReadPath = '/api/v1/chat/read';

  // Myanmar Gifting endpoints
  static const String giftingPackagesPath = '/api/v1/gifting/packages';
  static const String giftingPayPath = '/api/v1/gifting/pay';
  static const String giftingUnseenPath = '/api/v1/gifting/unseen';
  static const String giftingMarkSeenPath = '/api/v1/gifting/mark-seen';

  // Shared Couple Milestones endpoint
  static const String milestonesPath = '/api/v1/milestones';

  // FCM Device Token Registration endpoint
  static String userFcmTokenPath(String userId) => '/api/v1/users/$userId/fcm-token';
}
