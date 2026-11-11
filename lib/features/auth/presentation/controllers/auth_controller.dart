import 'dart:async';
import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thae_nge_lay/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';

part 'auth_controller.g.dart';

class AuthUIState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const AuthUIState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  AuthUIState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AuthUIState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

@riverpod
class AuthController extends _$AuthController {
  @override
  AuthUIState build() {
    return const AuthUIState();
  }

  Future<bool> sendEmailOtp(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.sendEmailOtp(email);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message ?? 'Failed to send verification code.',
        );
        return false;
      },
      (data) {
        state = state.copyWith(
          isLoading: false,
          successMessage: data['message'] as String? ?? 'Code sent to $email',
        );
        return true;
      },
    );
  }

  Future<({bool success, bool isNewUser})> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.verifyEmailOtp(email: email, otp: otp);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message ?? 'Invalid or expired verification code.',
        );
        return (success: false, isNewUser: false);
      },
      (res) async {
        await ref.read(authStateProvider.notifier).setUser(res.user);
        state = state.copyWith(isLoading: false);
        return (success: true, isNewUser: res.isNewUser);
      },
    );
  }

  Future<bool> sendForgotPasswordOtp(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.sendForgotPasswordOtp(email);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message ?? 'Failed to send verification code.',
        );
        return false;
      },
      (data) {
        state = state.copyWith(
          isLoading: false,
          successMessage: data['message'] as String? ?? 'Code sent to $email',
        );
        return true;
      },
    );
  }

  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.resetPassword(
      email: email,
      otp: otp,
      newPassword: newPassword,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message ?? 'Failed to reset password.',
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Password reset successfully! Please sign in with your new password.',
        );
        return true;
      },
    );
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
        state = state.copyWith(isLoading: false, successMessage: 'Account created!');
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
    final user = ref.read(authStateProvider);
    if (user == null) return null;

    state = state.copyWith(isLoading: true, clearError: true);
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.uploadAvatar(
      userId: user.id,
      avatarFile: file,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message ?? 'Failed to upload profile photo.',
        );
        return null;
      },
      (url) async {
        await ref.read(authStateProvider.notifier).updateProfile(
              displayName: user.displayName,
              photoUrl: url,
            );
        state = state.copyWith(isLoading: false);
        return url;
      },
    );
  }

  Future<String?> uploadCoverPhoto(File file) async {
    final user = ref.read(authStateProvider);
    final coupleSpaceId = user?.coupleSpaceId;
    if (coupleSpaceId == null) return null;

    state = state.copyWith(isLoading: true, clearError: true);
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.uploadCoverPhoto(
      coupleSpaceId: coupleSpaceId,
      coverFile: file,
    );

    state = state.copyWith(isLoading: false);
    return result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message ?? 'Failed to upload couple photo.',
        );
        return null;
      },
      (url) => url,
    );
  }

  Future<bool> completeProfile({
    required String displayName,
    required String photoUrl,
    DateTime? anniversaryDate,
    DateTime? birthday,
    String? role,
  }) async {
    final user = ref.read(authStateProvider);
    if (user == null) return false;

    state = state.copyWith(isLoading: true, clearError: true);
    final repo = ref.read(authRepositoryProvider);

    String? finalPhotoUrl = photoUrl;
    if (photoUrl.isNotEmpty && File(photoUrl).existsSync()) {
      final uploadRes = await repo.uploadAvatar(
        userId: user.id,
        avatarFile: File(photoUrl),
      );
      uploadRes.fold(
        (_) => null,
        (uploadedUrl) => finalPhotoUrl = uploadedUrl,
      );
    }

    final result = await repo.updateProfile(
      userId: user.id,
      displayName: displayName,
      role: role ?? user.role,
      birthday: birthday ?? user.birthday,
      avatarUrl: finalPhotoUrl,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message ?? 'Failed to complete profile.',
        );
        return false;
      },
      (updated) async {
        final withAnniversary = updated.copyWith(
          anniversaryDate: anniversaryDate ?? updated.anniversaryDate,
          isProfileComplete: true,
        );
        await ref.read(authStateProvider.notifier).setUser(withAnniversary);
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }

  Future<bool> updateProfile({
    required String displayName,
    String? role,
    DateTime? birthday,
    String? photoUrl,
  }) async {
    final user = ref.read(authStateProvider);
    if (user == null) return false;

    state = state.copyWith(isLoading: true, clearError: true);
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.updateProfile(
      userId: user.id,
      displayName: displayName,
      role: role,
      birthday: birthday,
      avatarUrl: photoUrl,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message ?? 'Failed to update profile.',
        );
        return false;
      },
      (updated) async {
        await ref.read(authStateProvider.notifier).setUser(updated);
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
