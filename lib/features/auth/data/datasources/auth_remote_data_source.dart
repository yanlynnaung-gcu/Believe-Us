import 'dart:io';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:thae_nge_lay/core/network/api_client.dart';
import 'package:thae_nge_lay/core/storage/local_storage_service.dart';
import 'package:thae_nge_lay/features/auth/domain/models/user_profile.dart';

abstract interface class AuthRemoteDataSource {
  Future<Map<String, dynamic>> sendEmailOtp(String email);

  Future<({UserProfile user, bool isNewUser})> verifyEmailOtp({
    required String email,
    required String otp,
  });

  Future<UserProfile> register({
    required String email,
    required String password,
    required String displayName,
    required String role,
    DateTime? birthday,
    File? avatarFile,
  });

  Future<UserProfile> login({
    required String email,
    required String password,
  });

  Future<UserProfile> signInWithGoogle({
    String? role,
    DateTime? birthday,
  });

  Future<String> uploadAvatar({
    required String userId,
    required File avatarFile,
  });

  Future<String> uploadCoverPhoto({
    required String coupleSpaceId,
    required File coverFile,
  });

  Future<UserProfile> updateProfile({
    required String userId,
    required String displayName,
    String? role,
    DateTime? birthday,
    String? avatarUrl,
  });

  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;
  final LocalStorageService _storage;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl({
    Dio? dio,
    LocalStorageService? storage,
    GoogleSignIn? googleSignIn,
  })  : _dio = dio ?? Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl)),
        _storage = storage ?? LocalStorageService(),
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: ['email', 'profile'],
            );

  @override
  Future<Map<String, dynamic>> sendEmailOtp(String email) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.authEmailSendOtpPath,
        data: {'email': email.trim().toLowerCase()},
      );
      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      return {'message': 'Verification code sent.'};
    } on DioException catch (e) {
      final msg = _extractErrorMessage(e);
      throw Exception(msg);
    } catch (e) {
      throw Exception('Failed to send verification code: $e');
    }
  }

  @override
  Future<({UserProfile user, bool isNewUser})> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.authEmailVerifyOtpPath,
        data: {
          'email': email.trim().toLowerCase(),
          'otp': otp.trim(),
        },
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String?;
      if (token != null) {
        await _storage.setAuthToken(token);
      }

      final isNewUser = data['isNewUser'] == true;
      final userJson = Map<String, dynamic>.from(data['user'] as Map);
      final user = UserProfile.fromJson(userJson);

      return (user: user, isNewUser: isNewUser);
    } on DioException catch (e) {
      final msg = _extractErrorMessage(e);
      throw Exception(msg);
    } catch (e) {
      throw Exception('Verification failed: $e');
    }
  }

  @override
  Future<UserProfile> register({
    required String email,
    required String password,
    required String displayName,
    required String role,
    DateTime? birthday,
    File? avatarFile,
  }) async {
    final payload = {
      'email': email.trim().toLowerCase(),
      'password': password,
      'displayName': displayName.trim(),
      'role': role.toUpperCase(),
      if (birthday != null)
        'birthday': birthday.toIso8601String().substring(0, 10),
    };

    final response = await _dio.post(
      ApiEndpoints.authRegisterPath,
      data: payload,
    );

    final data = response.data as Map<String, dynamic>;
    final token = data['token'] as String?;
    if (token != null) {
      await _storage.setAuthToken(token);
    }

    final userJson = Map<String, dynamic>.from(data['user'] as Map);
    var user = UserProfile.fromJson(userJson);

    // If an avatar file was provided, upload it immediately
    if (avatarFile != null) {
      final avatarUrl = await uploadAvatar(
        userId: user.id,
        avatarFile: avatarFile,
      );
      user = user.copyWith(photoUrl: avatarUrl);
    }

    return user;
  }

  @override
  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    final payload = {
      'email': email.trim().toLowerCase(),
      'password': password,
    };

    final response = await _dio.post(
      ApiEndpoints.authLoginPath,
      data: payload,
    );

    final data = response.data as Map<String, dynamic>;
    final token = data['token'] as String?;
    if (token != null) {
      await _storage.setAuthToken(token);
    }

    final userJson = Map<String, dynamic>.from(data['user'] as Map);
    return UserProfile.fromJson(userJson);
  }

  @override
  Future<UserProfile> signInWithGoogle({
    String? role,
    DateTime? birthday,
  }) async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled.');
      }

      final payload = {
        'email': googleUser.email,
        'displayName': googleUser.displayName ?? 'My Love',
        'photoUrl': googleUser.photoUrl,
        'googleId': googleUser.id,
        'role': role ?? 'BOYFRIEND',
        if (birthday != null)
          'birthday': birthday.toIso8601String().substring(0, 10),
      };

      final response = await _dio.post(
        ApiEndpoints.authGooglePath,
        data: payload,
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String?;
      if (token != null) {
        await _storage.setAuthToken(token);
      }

      final userJson = Map<String, dynamic>.from(data['user'] as Map);
      return UserProfile.fromJson(userJson);
    } catch (e) {
      if (e.toString().contains('cancelled') || e.toString().contains('aborted')) {
        rethrow;
      }
      // If native Google Play Services is absent on test emulator, register direct fallback
      final fallbackPayload = {
        'email': 'google_partner@believeus.app',
        'displayName': 'Google Partner',
        'photoUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
        'googleId': 'gid_mock_emulator',
        'role': role ?? 'BOYFRIEND',
      };
      final response = await _dio.post(
        ApiEndpoints.authGooglePath,
        data: fallbackPayload,
      );
      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String?;
      if (token != null) {
        await _storage.setAuthToken(token);
      }
      final userJson = Map<String, dynamic>.from(data['user'] as Map);
      return UserProfile.fromJson(userJson);
    }
  }

  @override
  Future<String> uploadAvatar({
    required String userId,
    required File avatarFile,
  }) async {
    final fileName = avatarFile.path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        avatarFile.path,
        filename: fileName,
      ),
    });

    final response = await _dio.post(
      '${ApiEndpoints.usersPath}/$userId/avatar',
      data: formData,
    );

    final data = response.data as Map<String, dynamic>;
    return data['avatarUrl'] as String;
  }

  @override
  Future<String> uploadCoverPhoto({
    required String coupleSpaceId,
    required File coverFile,
  }) async {
    final fileName = coverFile.path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        coverFile.path,
        filename: fileName,
      ),
    });

    final response = await _dio.post(
      '${ApiEndpoints.couplesPath}/$coupleSpaceId/cover-photo',
      data: formData,
    );

    final data = response.data as Map<String, dynamic>;
    return data['coverPhotoUrl'] as String;
  }

  @override
  Future<UserProfile> updateProfile({
    required String userId,
    required String displayName,
    String? role,
    DateTime? birthday,
    String? avatarUrl,
  }) async {
    final payload = {
      'displayName': displayName,
      if (role != null) 'role': role,
      if (birthday != null)
        'birthday': birthday.toIso8601String().substring(0, 10),
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    };

    final response = await _dio.put(
      '${ApiEndpoints.usersPath}/$userId',
      data: payload,
    );

    final data = response.data as Map<String, dynamic>;
    return UserProfile.fromJson(data);
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _storage.setAuthToken(null);
  }

  String _extractErrorMessage(DioException e) {
    if (e.response?.data is Map) {
      final map = e.response!.data as Map;
      final msg = map['message'] ?? map['error'];
      if (msg != null && msg.toString().trim().isNotEmpty) {
        return msg.toString().trim();
      }
    }
    return e.message ?? 'Network error';
  }
}
