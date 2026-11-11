import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:thae_nge_lay/core/storage/local_storage_service.dart';

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
    this.maxRetries = 2,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 10),
  });

  bool _isRetryable(DioException err) {
    if (err.type == DioExceptionType.cancel) {
      return false;
    }

    // Explicit opt-out for background polling / heartbeats
    if (err.requestOptions.extra['disable_retry'] == true ||
        err.requestOptions.extra['no_retry'] == true) {
      return false;
    }

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }

    if (err.response != null) {
      final code = err.response!.statusCode;
      if (code != null &&
          (code == 408 ||
              code == 429 ||
              code == 500 ||
              code == 502 ||
              code == 503 ||
              code == 504)) {
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
    final retryCount =
        (err.requestOptions.extra['retry_count'] as int? ?? 0);

    // Stop if retries exceeded or error not retryable
    if (retryCount >= maxRetries || !_isRetryable(err)) {
      return handler.next(err);
    }

    final nextRetry = retryCount + 1;
    final jitterMs = _random.nextInt(250);
    final delayMs =
        (initialDelay.inMilliseconds * pow(2, retryCount))
            .clamp(0, maxDelay.inMilliseconds)
            .toInt() +
        jitterMs;

    if (const bool.fromEnvironment('VERBOSE_DIO_LOGS', defaultValue: false)) {
      debugPrint(
        '[DioRetry] Transient error on ${err.requestOptions.path} (${err.type}). '
        'Retrying ($nextRetry/$maxRetries) in ${delayMs}ms...',
      );
    }

    await Future.delayed(Duration(milliseconds: delayMs));

    try {
      final requestOptions = err.requestOptions.copyWith(
        extra: {
          ...err.requestOptions.extra,
          'retry_count': nextRetry,
        },
      );

      final response = await dio.fetch<dynamic>(requestOptions);
      return handler.resolve(response);
    } on DioException catch (retryErr) {
      return handler.next(retryErr);
    } catch (e) {
      return handler.next(err);
    }
  }
}
