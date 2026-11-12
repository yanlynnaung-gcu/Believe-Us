import 'dart:async';
import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thae_nge_lay/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/account_auth_operations.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_ui_state.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/profile_operations_helper.dart';

export 'auth_ui_state.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  AuthUIState build() {
    return const AuthUIState();
  }

  Future<bool> sendEmailOtp(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final success = await AccountAuthOperations.sendEmailOtp(
      ref: ref,
      email: email,
      onError: (err) => state = state.copyWith(errorMessage: err),
      onSuccess: (msg) => state = state.copyWith(successMessage: msg),
    );
    state = state.copyWith(isLoading: false);
    return success;
  }

  Future<({bool success, bool isNewUser})> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final res = await AccountAuthOperations.verifyEmailOtp(
      ref: ref,
      email: email,
      otp: otp,
      onError: (err) => state = state.copyWith(errorMessage: err),
    );
    state = state.copyWith(isLoading: false);
    return res;
  }

  Future<bool> sendForgotPasswordOtp(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final success = await AccountAuthOperations.sendForgotPasswordOtp(
      ref: ref,
      email: email,
      onError: (err) => state = state.copyWith(errorMessage: err),
      onSuccess: (msg) => state = state.copyWith(successMessage: msg),
    );
    state = state.copyWith(isLoading: false);
    return success;
  }

  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final success = await AccountAuthOperations.resetPassword(
      ref: ref,
      email: email,
      otp: otp,
      newPassword: newPassword,
      onError: (err) => state = state.copyWith(errorMessage: err),
      onSuccess: (msg) => state = state.copyWith(successMessage: msg),
    );
    state = state.copyWith(isLoading: false);
    return success;
  }

  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
    required String role,
    DateTime? birthday,
    File? avatarFile,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.register(
      email: email,
      password: password,
      displayName: displayName,
      role: role,
      birthday: birthday,
      avatarFile: avatarFile,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message ?? 'Registration failed.',
        );
        return false;
      },
      (user) async {
        await ref.read(authStateProvider.notifier).setUser(user);
        state = state.copyWith(
            isLoading: false, successMessage: 'Account created!');
        return true;
      },
    );
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.login(
      email: email,
      password: password,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message ?? 'Invalid email or password.',
        );
        return false;
      },
      (user) async {
        await ref.read(authStateProvider.notifier).setUser(user);
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }

  Future<bool> signInWithGoogle({
    String? role,
    DateTime? birthday,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.signInWithGoogle(
      role: role,
      birthday: birthday,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message ?? 'Google Sign-In failed.',
        );
        return false;
      },
      (user) async {
        await ref.read(authStateProvider.notifier).setUser(user);
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }

  Future<String?> uploadAvatar(File file) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final url = await ProfileOperationsHelper.uploadAvatar(
      ref: ref,
      file: file,
      onError: (err) => state = state.copyWith(errorMessage: err),
    );
    state = state.copyWith(isLoading: false);
    return url;
  }

  Future<String?> uploadCoverPhoto(File file) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final url = await ProfileOperationsHelper.uploadCoverPhoto(
      ref: ref,
      file: file,
      onError: (err) => state = state.copyWith(errorMessage: err),
    );
    state = state.copyWith(isLoading: false);
    return url;
  }

  Future<bool> completeProfile({
    required String displayName,
    required String photoUrl,
    DateTime? anniversaryDate,
    DateTime? birthday,
    String? role,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final success = await ProfileOperationsHelper.completeProfile(
      ref: ref,
      displayName: displayName,
      photoUrl: photoUrl,
      anniversaryDate: anniversaryDate,
      birthday: birthday,
      role: role,
      onError: (err) => state = state.copyWith(errorMessage: err),
    );
    state = state.copyWith(isLoading: false);
    return success;
  }

  Future<bool> updateProfile({
    required String displayName,
    String? role,
    DateTime? birthday,
    String? photoUrl,
    DateTime? anniversaryDate,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final success = await ProfileOperationsHelper.updateProfile(
      ref: ref,
      displayName: displayName,
      role: role,
      birthday: birthday,
      photoUrl: photoUrl,
      anniversaryDate: anniversaryDate,
      onError: (err) => state = state.copyWith(errorMessage: err),
    );
    state = state.copyWith(isLoading: false);
    return success;
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
