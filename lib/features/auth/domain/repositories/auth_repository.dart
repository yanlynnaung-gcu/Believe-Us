import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:thae_nge_lay/core/errors/failure.dart';
import 'package:thae_nge_lay/features/auth/domain/models/user_profile.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, Map<String, dynamic>>> sendEmailOtp(String email);

  Future<Either<Failure, ({UserProfile user, bool isNewUser})>> verifyEmailOtp({
    required String email,
    required String otp,
  });

  Future<Either<Failure, Map<String, dynamic>>> sendForgotPasswordOtp(String email);

  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });

  Future<Either<Failure, UserProfile>> register({
    required String email,
    required String password,
    required String displayName,
    required String role,
    DateTime? birthday,
    File? avatarFile,
  });

  Future<Either<Failure, UserProfile>> login({
    required String email,
    required String password,
    String? deviceId,
    String? deviceName,
  });

  Future<Either<Failure, UserProfile>> signInWithGoogle({
    String? role,
    DateTime? birthday,
  });

  Future<Either<Failure, String>> uploadAvatar({
    required String userId,
    required File avatarFile,
  });

  Future<Either<Failure, String>> uploadCoverPhoto({
    required String coupleSpaceId,
    required File coverFile,
  });

  Future<Either<Failure, UserProfile>> updateProfile({
    required String userId,
    required String displayName,
    String? role,
    DateTime? birthday,
    String? avatarUrl,
    DateTime? anniversaryDate,
  });

  Future<Either<Failure, void>> signOut();
}
