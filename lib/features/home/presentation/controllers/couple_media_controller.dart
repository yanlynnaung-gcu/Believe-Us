import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thae_nge_lay/core/network/websocket_sync_service.dart';
import 'package:thae_nge_lay/core/storage/local_storage_service.dart';
import 'package:thae_nge_lay/core/utils/image_provider_helper.dart';
import 'package:thae_nge_lay/features/anniversary/presentation/controllers/anniversary_notifier.dart';
import 'package:thae_nge_lay/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';
import 'package:thae_nge_lay/features/pairing/data/repositories/pairing_repository_impl.dart';
import 'package:thae_nge_lay/features/pairing/domain/models/couple_summary.dart';

part 'couple_media_controller.g.dart';

class CoupleMediaState {
  final String coverPhotoPath;
  final String userAvatarPath;
  final String partnerAvatarPath;
  final String partnerName;
  final DateTime partnerBirthday;
  final bool isSyncing;

  const CoupleMediaState({
    required this.coverPhotoPath,
    required this.userAvatarPath,
    required this.partnerAvatarPath,
    required this.partnerName,
    required this.partnerBirthday,
    this.isSyncing = false,
  });

  CoupleMediaState copyWith({
    String? coverPhotoPath,
    String? userAvatarPath,
    String? partnerAvatarPath,
    String? partnerName,
    DateTime? partnerBirthday,
    bool? isSyncing,
  }) {
    return CoupleMediaState(
      coverPhotoPath: coverPhotoPath ?? this.coverPhotoPath,
      userAvatarPath: userAvatarPath ?? this.userAvatarPath,
      partnerAvatarPath: partnerAvatarPath ?? this.partnerAvatarPath,
      partnerName: partnerName ?? this.partnerName,
      partnerBirthday: partnerBirthday ?? this.partnerBirthday,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}

@Riverpod(keepAlive: true)
class CoupleMediaController extends _$CoupleMediaController {
  StreamSubscription? _wsProfileSub;
  StreamSubscription? _wsCoverSub;
  StreamSubscription? _wsAnniversarySub;
  StreamSubscription? _wsPairedSub;

  @override
  CoupleMediaState build() {
    ref.onDispose(() {
      _wsProfileSub?.cancel();
      _wsCoverSub?.cancel();
      _wsAnniversarySub?.cancel();
      _wsPairedSub?.cancel();
    });

    final storage = ref.watch(localStorageServiceProvider);
    final user = ref.watch(authStateProvider);

    final defaultPartnerRole =
        (user?.role.toUpperCase() == 'GIRLFRIEND') ? 'BOYFRIEND' : 'GIRLFRIEND';
    final fallbackPartnerAvatar = defaultPartnerRole == 'BOYFRIEND'
        ? kDefaultAvatarBoyfriendUrl
        : kDefaultAvatarGirlfriendUrl;
    final fallbackUserAvatar = (user?.role.toUpperCase() == 'GIRLFRIEND')
        ? kDefaultAvatarGirlfriendUrl
        : kDefaultAvatarBoyfriendUrl;

    // 1. Initial User Avatar (user profile > storage cache > fallback)
    final initialUserAvatar = (user?.photoUrl != null && user!.photoUrl!.isNotEmpty)
        ? user.photoUrl!
        : fallbackUserAvatar;

    // 2. Cover Photo (storage cache > fallback)
    final cachedCover = storage.coverPhotoPath;
    final initialCover = (cachedCover != null && cachedCover.isNotEmpty)
        ? cachedCover
        : kDefaultFallbackImageUrl;

    // 3. Partner Avatar (storage cache > fallback)
    final cachedPartnerAvatar = storage.partnerAvatarPath;
    final initialPartnerAvatar = (cachedPartnerAvatar != null && cachedPartnerAvatar.isNotEmpty)
        ? cachedPartnerAvatar
        : fallbackPartnerAvatar;

    // 4. Partner Name & Birthday
    final cachedPartnerName = storage.partnerName;
    final defaultPartnerName = (user?.role.toUpperCase() == 'GIRLFRIEND')
        ? 'Ko Ko'
        : 'Thae Thae';
    final initialPartnerName = (cachedPartnerName != null && cachedPartnerName.isNotEmpty)
        ? cachedPartnerName
        : defaultPartnerName;

    final cachedPartnerBday = storage.partnerBirthday;
    final initialPartnerBday =
        cachedPartnerBday ?? DateTime.now().add(const Duration(days: 14));

    _setupWebSocketListeners();
    Future.microtask(() => syncCoupleSummary());

    return CoupleMediaState(
      coverPhotoPath: initialCover,
      userAvatarPath: initialUserAvatar,
      partnerAvatarPath: initialPartnerAvatar,
      partnerName: initialPartnerName,
      partnerBirthday: initialPartnerBday,
    );
  }

  void _setupWebSocketListeners() {
    _wsProfileSub?.cancel();
    _wsCoverSub?.cancel();
    _wsAnniversarySub?.cancel();
    _wsPairedSub?.cancel();

    final ws = ref.read(webSocketSyncServiceProvider);
    final storage = ref.read(localStorageServiceProvider);

    _wsProfileSub = ws.onEvent('PROFILE_UPDATED').listen((e) async {
      final data = e.data;
      final currentUser = ref.read(authStateProvider);
      if (currentUser == null) return;

      final eventUserId = data['id']?.toString();
      final partnerId = currentUser.partnerId;

      if (eventUserId != null && eventUserId == partnerId) {
        final displayName = data['displayName']?.toString();
        final avatarUrl =
            data['avatarUrl']?.toString() ?? data['photoUrl']?.toString();
        final birthdayStr = data['birthday']?.toString();
        DateTime? birthday;
        if (birthdayStr != null) {
          birthday = DateTime.tryParse(birthdayStr);
        }

        if (displayName != null && displayName.isNotEmpty) {
          await storage.setPartnerName(displayName);
        }
        if (avatarUrl != null && avatarUrl.isNotEmpty) {
          await storage.setPartnerAvatarPath(avatarUrl);
        }
        if (birthday != null) {
          await storage.setPartnerBirthday(birthday);
        }

        state = state.copyWith(
          partnerName: (displayName != null && displayName.isNotEmpty)
              ? displayName
              : state.partnerName,
          partnerAvatarPath: (avatarUrl != null && avatarUrl.isNotEmpty)
              ? avatarUrl
              : state.partnerAvatarPath,
          partnerBirthday: birthday ?? state.partnerBirthday,
        );
      } else if (eventUserId != null && eventUserId == currentUser.id) {
        final avatarUrl =
            data['avatarUrl']?.toString() ?? data['photoUrl']?.toString();
        if (avatarUrl != null && avatarUrl.isNotEmpty) {
          state = state.copyWith(userAvatarPath: avatarUrl);
          await ref.read(authStateProvider.notifier).updateProfile(
                displayName: currentUser.displayName,
                photoUrl: avatarUrl,
              );
        }
      }

      final coverPhotoUrl = data['coverPhotoUrl']?.toString();
      if (coverPhotoUrl != null && coverPhotoUrl.isNotEmpty) {
        await storage.setCoverPhotoPath(coverPhotoUrl);
        state = state.copyWith(coverPhotoPath: coverPhotoUrl);
      }
    });

    _wsCoverSub = ws.onEvent('COVER_PHOTO_UPDATED').listen((e) async {
      final coverPhotoUrl = e.data['coverPhotoUrl']?.toString();
      if (coverPhotoUrl != null && coverPhotoUrl.isNotEmpty) {
        await storage.setCoverPhotoPath(coverPhotoUrl);
        state = state.copyWith(coverPhotoPath: coverPhotoUrl);
      }
    });

    _wsAnniversarySub = ws.onEvent('ANNIVERSARY_UPDATED').listen((e) {
      ref.invalidate(anniversaryProvider);
    });

    _wsPairedSub = ws.onEvent('COUPLE_PAIRED').listen((e) {
      syncCoupleSummary();
      ref.invalidate(anniversaryProvider);
    });
  }

  Future<void> syncCoupleSummary() async {
    final user = ref.read(authStateProvider);
    if (user == null || user.coupleSpaceId == null) return;

    state = state.copyWith(isSyncing: true);

    final pairingRepo = ref.read(pairingRepositoryProvider);
    final result = await pairingRepo.getCoupleSummary(
      coupleSpaceId: user.coupleSpaceId!,
      userId: user.id,
    );

    result.fold(
      (failure) {
        debugPrint('[CoupleMediaController] Failed to sync couple summary: ${failure.message}');
        state = state.copyWith(isSyncing: false);
      },
      (summary) {
        initFromCoupleSummary(summary);
      },
    );
  }

  void initFromCoupleSummary(CoupleSummary summary) {
    final storage = ref.read(localStorageServiceProvider);
    var newState = state.copyWith(isSyncing: false);

    if (summary.coverPhotoUrl != null && summary.coverPhotoUrl!.isNotEmpty) {
      storage.setCoverPhotoPath(summary.coverPhotoUrl!);
      newState = newState.copyWith(coverPhotoPath: summary.coverPhotoUrl!);
    }

    if (summary.myProfile?.photoUrl != null &&
        summary.myProfile!.photoUrl!.isNotEmpty) {
      newState = newState.copyWith(userAvatarPath: summary.myProfile!.photoUrl!);
    }

    if (summary.partnerProfile != null) {
      final p = summary.partnerProfile!;
      if (p.displayName.isNotEmpty) {
        storage.setPartnerName(p.displayName);
        newState = newState.copyWith(partnerName: p.displayName);
      }
      if (p.photoUrl != null && p.photoUrl!.isNotEmpty) {
        storage.setPartnerAvatarPath(p.photoUrl!);
        newState = newState.copyWith(partnerAvatarPath: p.photoUrl!);
      }
      if (p.birthday != null) {
        storage.setPartnerBirthday(p.birthday!);
        newState = newState.copyWith(partnerBirthday: p.birthday!);
      }
    }

    // Sync official start date and days together across client
    final officialStart = summary.officialStartDate;
    if (officialStart != null) {
      storage.setAnniversaryDate(officialStart);
      storage.setDaysTogether(summary.daysTogether);

      final currentUser = ref.read(authStateProvider);
      if (currentUser != null && currentUser.anniversaryDate != officialStart) {
        ref.read(authStateProvider.notifier).setUser(
              currentUser.copyWith(anniversaryDate: officialStart),
            );
      }
      ref.read(anniversaryProvider.notifier).syncFromSummary(summary);
    }

    state = newState;
  }

  Future<void> updateCoverPhoto(String path) async {
    final storage = ref.read(localStorageServiceProvider);
    state = state.copyWith(coverPhotoPath: path);
    await storage.setCoverPhotoPath(path);

    final user = ref.read(authStateProvider);
    if (user?.coupleSpaceId != null && File(path).existsSync()) {
      try {
        final authRepo = ref.read(authRepositoryProvider);
        final result = await authRepo.uploadCoverPhoto(
          coupleSpaceId: user!.coupleSpaceId!,
          coverFile: File(path),
        );
        result.fold(
          (err) => debugPrint('[CoupleMediaController] Cover upload failed: $err'),
          (uploadedUrl) async {
            await storage.setCoverPhotoPath(uploadedUrl);
            state = state.copyWith(coverPhotoPath: uploadedUrl);
          },
        );
      } catch (e) {
        debugPrint('[CoupleMediaController] Exception uploading cover: $e');
      }
    }
  }

  Future<void> updateUserAvatar(String path) async {
    state = state.copyWith(userAvatarPath: path);

    final user = ref.read(authStateProvider);
    if (user != null && File(path).existsSync()) {
      try {
        final authRepo = ref.read(authRepositoryProvider);
        final result = await authRepo.uploadAvatar(
          userId: user.id,
          avatarFile: File(path),
        );
        result.fold(
          (err) => debugPrint('[CoupleMediaController] Avatar upload failed: $err'),
          (uploadedUrl) async {
            state = state.copyWith(userAvatarPath: uploadedUrl);
            await ref.read(authStateProvider.notifier).updateProfile(
                  displayName: user.displayName,
                  photoUrl: uploadedUrl,
                );
          },
        );
      } catch (e) {
        debugPrint('[CoupleMediaController] Exception uploading avatar: $e');
      }
    }
  }

  Future<void> updatePartnerAvatar(String path) async {
    final storage = ref.read(localStorageServiceProvider);
    state = state.copyWith(partnerAvatarPath: path);
    await storage.setPartnerAvatarPath(path);
  }

  Future<void> updatePartnerBirthday(DateTime birthday) async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.setPartnerBirthday(birthday);
    state = state.copyWith(partnerBirthday: birthday);
  }

  Future<void> updatePartnerName(String name) async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.setPartnerName(name);
    state = state.copyWith(partnerName: name);
  }
}

/// Alias for concise access across redesign widgets
final coupleMediaProvider = coupleMediaControllerProvider;
