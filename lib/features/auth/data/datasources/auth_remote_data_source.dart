import 'dart:io';
import 'package:thae_nge_lay/features/auth/domain/models/user_profile.dart';

export 'auth_remote_data_source_impl.dart';

abstract interface class AuthRemoteDataSource {
  Future<Map<String, dynamic>> sendEmailOtp(String email);

  Future<({UserProfile user, bool isNewUser})> verifyEmailOtp({
    required String email,
    required String otp,
  });

  Future<Map<String, dynamic>> sendForgotPasswordOtp(String email);

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
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
