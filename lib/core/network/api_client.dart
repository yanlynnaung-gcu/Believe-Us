import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thae_nge_lay/core/storage/local_storage_service.dart';

part 'api_client.g.dart';

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
  static const String authRegisterPath = '/api/v1/auth/register';
  static const String authLoginPath = '/api/v1/auth/login';
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
  static const String chatUnreadPath = '/api/v1/chat/unread';
  static const String chatReadPath = '/api/v1/chat/read';

  // Myanmar Gifting endpoints
  static const String giftingPackagesPath = '/api/v1/gifting/packages';
  static const String giftingPayPath = '/api/v1/gifting/pay';
  static const String giftingUnseenPath = '/api/v1/gifting/unseen';
  static const String giftingMarkSeenPath = '/api/v1/gifting/mark-seen';

  // Shared Couple Milestones endpoint
  static const String milestonesPath = '/api/v1/milestones';
}

/// JWT Bearer Token Injection Interceptor
class JwtAuthInterceptor extends Interceptor {
  final LocalStorageService _storage;

  JwtAuthInterceptor(this._storage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      final token = _storage.authToken;
      if (token != null && token.trim().isNotEmpty) {
        options.headers['Authorization'] = 'Bearer ${token.trim()}';
      }
    } catch (_) {
      // Ignore if local storage is not yet initialized
    }
    handler.next(options);
  }
}

/// Robust Exponential Backoff Retry Interceptor for Dio
class DioExponentialBackoffRetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration initialDelay;
  final Duration maxDelay;
  final Random _random = Random();

  DioExponentialBackoffRetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 8),
  });

  bool _isRetryable(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }

    if (err.response != null) {
      final code = err.response!.statusCode;
      if (code != null &&
          (code == 500 || code == 502 || code == 503 || code == 504)) {
        return true;
      }
    }

    return false;
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    var currentErr = err;
    int currentRetry =
        (currentErr.requestOptions.extra['retry_count'] as int? ?? 0);

    while (currentRetry < maxRetries && _isRetryable(currentErr)) {
      currentRetry++;
      final jitterMs = _random.nextInt(150);
      final delayMs =
          (initialDelay.inMilliseconds * pow(2, currentRetry - 1))
              .clamp(0, maxDelay.inMilliseconds)
              .toInt() +
          jitterMs;

      debugPrint(
        '[DioRetry] Transient error on ${currentErr.requestOptions.path} (${currentErr.type}). '
        'Retrying ($currentRetry/$maxRetries) in ${delayMs}ms...',
      );

      await Future.delayed(Duration(milliseconds: delayMs));

      try {
        final requestOptions = currentErr.requestOptions;
        final response = await dio.fetch<dynamic>(
          requestOptions.copyWith(
            extra: {...requestOptions.extra, 'retry_count': currentRetry},
          ),
        );

        return handler.resolve(response);
      } on DioException catch (retryErr) {
        currentErr = retryErr;
      } catch (e) {
        return handler.next(currentErr);
      }
    }

    return handler.next(currentErr);
  }
}

@Riverpod(keepAlive: true)
Dio dioClient(Ref ref) {
  final options = BaseOptions(
    baseUrl: ApiEndpoints.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    sendTimeout: const Duration(seconds: 10),
    headers: const {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );

  final dio = Dio(options);

  try {
    final storage = ref.watch(localStorageServiceProvider);
    dio.interceptors.add(JwtAuthInterceptor(storage));
  } catch (_) {}

  dio.interceptors.add(DioExponentialBackoffRetryInterceptor(dio: dio));

  if (kDebugMode) {
    const bool verboseDioLogs = bool.fromEnvironment(
      'VERBOSE_DIO_LOGS',
      defaultValue: false,
    );
    dio.interceptors.add(
      LogInterceptor(
        request: verboseDioLogs,
        requestHeader: verboseDioLogs,
        requestBody: verboseDioLogs,
        responseHeader: verboseDioLogs,
        responseBody: verboseDioLogs,
        error: true,
        logPrint: (obj) => debugPrint('[Dio] $obj'),
      ),
    );
  }

  return dio;
}
