import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:thae_nge_lay/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';

class AccountAuthOperations {
  static Future<bool> sendEmailOtp({
    required Ref ref,
    required String email,
    required void Function(String error) onError,
    required void Function(String success) onSuccess,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.sendEmailOtp(email);

    return result.fold(
      (failure) {
        onError(failure.message ?? 'Failed to send verification code.');
        return false;
      },
      (data) {
        onSuccess(data['message'] as String? ?? 'Code sent to $email');
        return true;
      },
    );
  }

  static Future<({bool success, bool isNewUser})> verifyEmailOtp({
    required Ref ref,
    required String email,
    required String otp,
    required void Function(String error) onError,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.verifyEmailOtp(email: email, otp: otp);

    return result.fold(
      (failure) {
        onError(failure.message ?? 'Invalid or expired verification code.');
        return (success: false, isNewUser: false);
      },
      (res) async {
        await ref.read(authStateProvider.notifier).setUser(res.user);
        return (success: true, isNewUser: res.isNewUser);
      },
    );
  }

  static Future<bool> sendForgotPasswordOtp({
    required Ref ref,
    required String email,
    required void Function(String error) onError,
    required void Function(String success) onSuccess,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.sendForgotPasswordOtp(email);

    return result.fold(
      (failure) {
        onError(failure.message ?? 'Failed to send verification code.');
        return false;
      },
      (data) {
        onSuccess(data['message'] as String? ?? 'Code sent to $email');
        return true;
      },
    );
  }

  static Future<bool> resetPassword({
    required Ref ref,
    required String email,
    required String otp,
    required String newPassword,
    required void Function(String error) onError,
    required void Function(String success) onSuccess,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.resetPassword(
      email: email,
      otp: otp,
      newPassword: newPassword,
    );

    return result.fold(
      (failure) {
        onError(failure.message ?? 'Failed to reset password.');
        return false;
      },
      (_) {
        onSuccess(
            'Password reset successfully! Please sign in with your new password.');
        return true;
      },
    );
  }
}
