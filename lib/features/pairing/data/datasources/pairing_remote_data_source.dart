import 'package:dio/dio.dart';
import 'package:thae_nge_lay/core/network/api_client.dart';
import 'package:thae_nge_lay/features/pairing/domain/models/couple_space.dart';
import 'package:thae_nge_lay/features/pairing/domain/models/couple_summary.dart';

abstract interface class PairingRemoteDataSource {
  Future<String> getOrCreateInviteCode(String userId);
  Future<String> generateNewInviteCode(String userId);
  Future<CoupleSpace> pairWithCode({
    required String currentUserId,
    required String inviteCode,
  });
  Future<CoupleSpace?> getCoupleSpace(String coupleSpaceId);
  Future<Map<String, dynamic>> checkPairingStatus(String userId);
  Future<CoupleSummary> getCoupleSummary({
    required String coupleSpaceId,
    String? userId,
  });
  Future<void> unpair(String coupleSpaceId);
}

class PairingRemoteDataSourceImpl implements PairingRemoteDataSource {
  final Dio _dio;

  PairingRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? Dio();

  @override
  Future<String> getOrCreateInviteCode(String userId) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.pairingGeneratePath,
        data: {
          'userId': userId,
          'forceNew': false,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        final code = response.data['inviteCode'] as String?;
        if (code != null && code.isNotEmpty) return code;
      }
    } on DioException catch (e) {
      // Fallback check to GET endpoint if POST returned 404/405
      if (e.response?.statusCode == 404 || e.response?.statusCode == 405) {
        try {
          final getResp = await _dio.get('${ApiEndpoints.pairingCodePath}/$userId');
          if (getResp.statusCode == 200 && getResp.data != null) {
            final code = getResp.data['inviteCode'] as String?;
            if (code != null && code.isNotEmpty) return code;
          }
        } catch (_) {}
      }
      final msg = _extractErrorMessage(e);
      throw Exception(msg);
    } catch (e) {
      throw Exception('Failed to obtain invite code from server: $e');
    }

    throw Exception('Failed to obtain invite code: Unexpected response from backend.');
  }

  @override
  Future<String> generateNewInviteCode(String userId) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.pairingGeneratePath,
        data: {
          'userId': userId,
          'forceNew': true,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        final code = response.data['inviteCode'] as String?;
        if (code != null && code.isNotEmpty) return code;
      }
    } on DioException catch (e) {
      final msg = _extractErrorMessage(e);
      throw Exception(msg);
    } catch (e) {
      throw Exception('Failed to regenerate invite code: $e');
    }

    throw Exception('Failed to regenerate invite code: Unexpected response from backend.');
  }

  @override
  Future<CoupleSpace> pairWithCode({
    required String currentUserId,
    required String inviteCode,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.pairPath,
        data: {
          'currentUserId': currentUserId,
          'inviteCode': inviteCode.trim().toUpperCase(),
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        return CoupleSpace.fromJson(Map<String, dynamic>.from(response.data as Map));
      }
    } on DioException catch (e) {
      final msg = _extractErrorMessage(e);
      throw Exception(msg);
    } catch (e) {
      rethrow;
    }

    throw Exception('Pairing failed: Unexpected response from server.');
  }

  @override
  Future<Map<String, dynamic>> checkPairingStatus(String userId) async {
    try {
      final response = await _dio.get('${ApiEndpoints.pairingStatusPath}/$userId');
      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
    } catch (_) {}
    return {'isPaired': false};
  }

  @override
  Future<CoupleSpace?> getCoupleSpace(String coupleSpaceId) async {
    try {
      final response = await _dio.get('${ApiEndpoints.baseUrl}/api/v1/pairing/space/$coupleSpaceId');
      if (response.statusCode == 200 && response.data != null) {
        return CoupleSpace.fromJson(Map<String, dynamic>.from(response.data as Map));
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<CoupleSummary> getCoupleSummary({
    required String coupleSpaceId,
    String? userId,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.couplesPath}/$coupleSpaceId/summary',
        queryParameters: userId != null ? {'userId': userId} : null,
      );
      if (response.statusCode == 200 && response.data != null) {
        return CoupleSummary.fromJson(Map<String, dynamic>.from(response.data as Map));
      }
    } on DioException catch (e) {
      final msg = _extractErrorMessage(e);
      throw Exception(msg);
    } catch (e) {
      throw Exception('Failed to load couple summary: $e');
    }

    throw Exception('Failed to load couple summary: Unexpected response from backend.');
  }

  @override
  Future<void> unpair(String coupleSpaceId) async {
    try {
      await _dio.post(
        ApiEndpoints.unpairPath,
        data: {'coupleSpaceId': coupleSpaceId},
      );
    } catch (_) {}
  }

  String _extractErrorMessage(DioException e) {
    if (e.response != null && e.response!.data != null) {
      final data = e.response!.data;
      if (data is Map) {
        final msg = data['message'] ?? data['error'];
        if (msg != null && msg.toString().trim().isNotEmpty) {
          return msg.toString().trim();
        }
      } else if (data is String && data.trim().isNotEmpty) {
        return data.trim();
      }
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Unable to connect to Thae Thae backend at ${ApiEndpoints.baseUrl}. Please check Wi-Fi connection.';
    }

    return e.message ?? 'Network connection error';
  }
}
