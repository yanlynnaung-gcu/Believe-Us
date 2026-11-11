import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thae_nge_lay/core/errors/failure.dart';
import 'package:thae_nge_lay/core/network/api_client.dart';
import 'package:thae_nge_lay/core/storage/local_storage_service.dart';
import 'package:thae_nge_lay/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:thae_nge_lay/features/auth/domain/models/user_profile.dart';
import 'package:thae_nge_lay/features/auth/domain/repositories/auth_repository.dart';

part 'auth_repository_impl.g.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, Map<String, dynamic>>> sendEmailOtp(String email) async {
    try {
      final res = await _remoteDataSource.sendEmailOtp(email);
      return Right(res);
    } catch (e) {
      return Left(Failure.auth(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, ({UserProfile user, bool isNewUser})>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final res = await _remoteDataSource.verifyEmailOtp(email: email, otp: otp);
      return Right(res);
    } catch (e) {
      return Left(Failure.auth(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> sendForgotPasswordOtp(String email) async {
    try {
      final res = await _remoteDataSource.sendForgotPasswordOtp(email);
      return Right(res);
    } catch (e) {
      return Left(Failure.auth(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      return const Right(null);
    } catch (e) {
      return Left(Failure.auth(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> register({
    required String email,
    required String password,
    required String displayName,
    required String role,
    DateTime? birthday,
    File? avatarFile,
  }) async {
    try {
      final user = await _remoteDataSource.register(
        email: email,
        password: password,
        displayName: displayName,
        role: role,
        birthday: birthday,
        avatarFile: avatarFile,
      );
      return Right(user);
    } on DioException catch (e) {
      final errorMsg = _extractErrorMessage(e) ?? 'Registration failed. Please check inputs.';
      return Left(Failure.auth(errorMsg));
    } catch (e) {
      return Left(Failure.auth(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> login({
    required String email,
    required String password,
    String? deviceId,
    String? deviceName,
  }) async {
    try {
      final user = await _remoteDataSource.login(
        email: email,
        password: password,
        deviceId: deviceId,
        deviceName: deviceName,
      );
      return Right(user);
    } on DioException catch (e) {
      final errorMsg = _extractErrorMessage(e) ?? 'Invalid email or password.';
      return Left(Failure.auth(errorMsg));
    } catch (e) {
      return Left(Failure.auth(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> signInWithGoogle({
    String? role,
    DateTime? birthday,
  }) async {
    try {
      final user = await _remoteDataSource.signInWithGoogle(
        role: role,
        birthday: birthday,
      );
      return Right(user);
    } on DioException catch (e) {
      final errorMsg = _extractErrorMessage(e) ?? 'Google Sign-In failed.';
      return Left(Failure.auth(errorMsg));
    } catch (e) {
      return Left(Failure.auth(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar({
    required String userId,
    required File avatarFile,
  }) async {
    try {
      final url = await _remoteDataSource.uploadAvatar(
        userId: userId,
        avatarFile: avatarFile,
      );
      return Right(url);
    } catch (e) {
      return Left(Failure.server(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, String>> uploadCoverPhoto({
    required String coupleSpaceId,
    required File coverFile,
  }) async {
    try {
      final url = await _remoteDataSource.uploadCoverPhoto(
        coupleSpaceId: coupleSpaceId,
        coverFile: coverFile,
      );
      return Right(url);
    } catch (e) {
      return Left(Failure.server(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateProfile({
    required String userId,
    required String displayName,
    String? role,
    DateTime? birthday,
    String? avatarUrl,
  }) async {
    try {
      final user = await _remoteDataSource.updateProfile(
        userId: userId,
        displayName: displayName,
        role: role,
        birthday: birthday,
        avatarUrl: avatarUrl,
      );
      return Right(user);
    } catch (e) {
      return Left(Failure.server(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(Failure.unexpected(e.toString()));
    }
  }

  String? _extractErrorMessage(DioException e) {
    if (e.response?.data is Map) {
      final data = e.response!.data as Map;
      if (data['message'] != null) {
        return data['message'].toString();
      }
      if (data['error'] != null) {
        return data['error'].toString();
      }
    }
    return e.message;
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final dio = ref.watch(dioClientProvider);
  final storage = ref.watch(localStorageServiceProvider);
  return AuthRepositoryImpl(
    remoteDataSource: AuthRemoteDataSourceImpl(
      dio: dio,
      storage: storage,
    ),
  );
}
