import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thae_nge_lay/core/storage/local_storage_service.dart';
import 'package:thae_nge_lay/features/auth/domain/models/user_profile.dart';

part 'auth_state_notifier.g.dart';

@Riverpod(keepAlive: true)
class AuthStateNotifier extends _$AuthStateNotifier {
  @override
  UserProfile? build() {
    final storage = ref.watch(localStorageServiceProvider);
    final jsonStr = storage.userProfileJson;
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        return UserProfile.fromJson(map);
      } catch (_) {}
    }
    return null;
  }

  Future<void> setUser(UserProfile? user) async {
    state = user;
    final storage = ref.read(localStorageServiceProvider);
    if (user != null) {
      await storage.setActiveUserId(user.id);
      await storage.setUserProfileJson(jsonEncode(user.toJson()));
    } else {
      await storage.setActiveUserId(null);
      await storage.setUserProfileJson(null);
      await storage.setAuthToken(null);
    }
  }

  Future<void> updateProfile({
    required String displayName,
    String? photoUrl,
    String? role,
    DateTime? birthday,
    DateTime? anniversaryDate,
  }) async {
    final currentUser = state;
    if (currentUser == null) return;

    final updated = currentUser.copyWith(
      displayName: displayName,
      photoUrl: photoUrl ?? currentUser.photoUrl,
      role: role ?? currentUser.role,
      birthday: birthday ?? currentUser.birthday,
      anniversaryDate: anniversaryDate ?? currentUser.anniversaryDate,
      isProfileComplete: true,
    );
    await setUser(updated);
  }

  Future<void> pairPartner({
    required String partnerId,
    required String coupleSpaceId,
    DateTime? anniversaryDate,
  }) async {
    final currentUser = state;
    if (currentUser == null) return;

    final updated = currentUser.copyWith(
      partnerId: partnerId,
      coupleSpaceId: coupleSpaceId,
      anniversaryDate: anniversaryDate ?? currentUser.anniversaryDate,
    );
    await setUser(updated);
  }

  Future<void> unpair() async {
    final currentUser = state;
    if (currentUser == null) return;

    final updated = currentUser.copyWith(
      partnerId: null,
      coupleSpaceId: null,
    );
    await setUser(updated);
  }

  Future<void> signOut() async {
    await setUser(null);
  }

  Future<void> logout() => signOut();
}
