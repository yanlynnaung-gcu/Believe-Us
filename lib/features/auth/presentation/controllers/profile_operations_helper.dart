import 'dart:io';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:thae_nge_lay/core/storage/local_storage_service.dart';
import 'package:thae_nge_lay/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';

class ProfileOperationsHelper {
  static Future<String?> uploadAvatar({
    required Ref ref,
    required File file,
    required void Function(String error) onError,
  }) async {
    final user = ref.read(authStateProvider);
    if (user == null) return null;

    final repo = ref.read(authRepositoryProvider);
    final result = await repo.uploadAvatar(
      userId: user.id,
      avatarFile: file,
    );

    return result.fold(
      (failure) {
        onError(failure.message ?? 'Failed to upload profile photo.');
        return null;
      },
      (url) async {
        await ref.read(authStateProvider.notifier).updateProfile(
              displayName: user.displayName,
              photoUrl: url,
            );
        return url;
      },
    );
  }

  static Future<String?> uploadCoverPhoto({
    required Ref ref,
    required File file,
    required void Function(String error) onError,
  }) async {
    final user = ref.read(authStateProvider);
    final coupleSpaceId = user?.coupleSpaceId;
    if (coupleSpaceId == null) return null;

    final repo = ref.read(authRepositoryProvider);
    final result = await repo.uploadCoverPhoto(
      coupleSpaceId: coupleSpaceId,
      coverFile: file,
    );

    return result.fold(
      (failure) {
        onError(failure.message ?? 'Failed to upload couple photo.');
        return null;
      },
      (url) => url,
    );
  }

  static Future<bool> completeProfile({
    required Ref ref,
    required String displayName,
    required String photoUrl,
    DateTime? anniversaryDate,
    DateTime? birthday,
    String? role,
    required void Function(String error) onError,
  }) async {
    final user = ref.read(authStateProvider);
    if (user == null) return false;

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
      anniversaryDate: anniversaryDate,
    );

    return result.fold(
      (failure) {
        onError(failure.message ?? 'Failed to complete profile.');
        return false;
      },
      (updated) async {
        final withAnniversary = updated.copyWith(
          anniversaryDate: anniversaryDate ?? updated.anniversaryDate,
          isProfileComplete: true,
        );
        if (withAnniversary.anniversaryDate != null) {
          await ref.read(localStorageServiceProvider).setAnniversaryDate(withAnniversary.anniversaryDate);
        }
        await ref.read(authStateProvider.notifier).setUser(withAnniversary);
        return true;
      },
    );
  }

  static Future<bool> updateProfile({
    required Ref ref,
    required String displayName,
    String? role,
    DateTime? birthday,
    String? photoUrl,
    DateTime? anniversaryDate,
    required void Function(String error) onError,
  }) async {
    final user = ref.read(authStateProvider);
    if (user == null) return false;

    final repo = ref.read(authRepositoryProvider);
    final result = await repo.updateProfile(
      userId: user.id,
      displayName: displayName,
      role: role,
      birthday: birthday,
      avatarUrl: photoUrl,
      anniversaryDate: anniversaryDate,
    );

    return result.fold(
      (failure) {
        onError(failure.message ?? 'Failed to update profile.');
        return false;
      },
      (updated) async {
        final withAnniversary = updated.copyWith(
          anniversaryDate: anniversaryDate ?? updated.anniversaryDate,
        );
        if (withAnniversary.anniversaryDate != null) {
          await ref.read(localStorageServiceProvider).setAnniversaryDate(withAnniversary.anniversaryDate);
        }
        await ref.read(authStateProvider.notifier).setUser(withAnniversary);
        return true;
      },
    );
  }
}
