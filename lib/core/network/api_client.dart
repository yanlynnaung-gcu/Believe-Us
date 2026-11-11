import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thae_nge_lay/core/network/api_endpoints.dart';
import 'package:thae_nge_lay/core/network/dio_retry_interceptor.dart';
import 'package:thae_nge_lay/core/storage/local_storage_service.dart';

export 'api_endpoints.dart';
export 'dio_retry_interceptor.dart';

part 'api_client.g.dart';

@Riverpod(keepAlive: true)
Dio dioClient(Ref ref) {
  final options = BaseOptions(
    baseUrl: ApiEndpoints.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
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
