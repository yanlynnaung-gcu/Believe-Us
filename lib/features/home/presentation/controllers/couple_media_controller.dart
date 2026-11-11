import 'dart:async';
import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thae_nge_lay/core/network/websocket_sync_service.dart';
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

  @override
  CoupleMediaState build() {
    ref.onDispose(() {
      _wsProfileSub?.cancel();
      _wsCoverSub?.cancel();
    });

    final now = DateTime.now();
    final defaultBirthday = now.add(const Duration(days: 14));

    final user = ref.watch(authStateProvider);

    final initialUserAvatar = (user?.photoUrl != null && user!.photoUrl!.isNotEmpty)
        ? user.photoUrl!
        : 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300';

    final defaultPartnerName = (user?.role.toUpperCase() == 'GIRLFRIEND')
        ? 'Ko Ko'
        : 'Thae Thae';

    ref.onDispose(() {
      _wsProfileSub?.cancel();
      _wsCoverSub?.cancel();
    });

    _setupWebSocketListeners();
    Future.microtask(() => syncCoupleSummary());

    return CoupleMediaState(
      coverPhotoPath:
          'https://images.unsplash.com/photo-1518199266791-5375a83190b7?w=1200',
      userAvatarPath: initialUserAvatar,
      partnerAvatarPath:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300',
      partnerName: defaultPartnerName,
      partnerBirthday: defaultBirthday,
    );
  }

  void _setupWebSocketListeners() {
    _wsProfileSub?.cancel();
    _wsCoverSub?.cancel();

    final ws = ref.read(webSocketSyncServiceProvider);

    _wsProfileSub = ws.onEvent('PROFILE_UPDATED').listen((e) {
      final data = e.data;
      final currentUser = ref.read(authStateProvider);
      if (currentUser == null) return;

      final eventUserId = data['id']?.toString();
      final partnerId = currentUser.partnerId;

      if (eventUserId != null && eventUserId == partnerId) {
        final displayName = data['displayName']?.toString();
        final avatarUrl = data['avatarUrl']?.toString() ?? data['photoUrl']?.toString();
        final birthdayStr = data['birthday']?.toString();
        DateTime? birthday;
        if (birthdayStr != null) {
          birthday = DateTime.tryParse(birthdayStr);
        }

        state = state.copyWith(
          partnerName: (displayName != null && displayName.isNotEmpty) ? displayName : state.partnerName,
          partnerAvatarPath: (avatarUrl != null && avatarUrl.isNotEmpty) ? avatarUrl : state.partnerAvatarPath,
          partnerBirthday: birthday ?? state.partnerBirthday,
        );
      } else if (eventUserId != null && eventUserId == currentUser.id) {
        final avatarUrl = data['avatarUrl']?.toString() ?? data['photoUrl']?.toString();
        if (avatarUrl != null && avatarUrl.isNotEmpty) {
          state = state.copyWith(userAvatarPath: avatarUrl);
        }
      }

      final coverPhotoUrl = data['coverPhotoUrl']?.toString();
      if (coverPhotoUrl != null && coverPhotoUrl.isNotEmpty) {
        state = state.copyWith(coverPhotoPath: coverPhotoUrl);
      }
    });

    _wsCoverSub = ws.onEvent('COVER_PHOTO_UPDATED').listen((e) {
      final coverPhotoUrl = e.data['coverPhotoUrl']?.toString();
      if (coverPhotoUrl != null && coverPhotoUrl.isNotEmpty) {
        state = state.copyWith(coverPhotoPath: coverPhotoUrl);
      }
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
      (_) => state = state.copyWith(isSyncing: false),
      (summary) {
        initFromCoupleSummary(summary);
      },
    );
  }

  void initFromCoupleSummary(CoupleSummary summary) {
    var newState = state.copyWith(isSyncing: false);

    if (summary.coverPhotoUrl != null && summary.coverPhotoUrl!.isNotEmpty) {
      newState = newState.copyWith(coverPhotoPath: summary.coverPhotoUrl!);
    }

    if (summary.myProfile?.photoUrl != null && summary.myProfile!.photoUrl!.isNotEmpty) {
      newState = newState.copyWith(userAvatarPath: summary.myProfile!.photoUrl!);
    }

    if (summary.partnerProfile != null) {
      final p = summary.partnerProfile!;
      if (p.displayName.isNotEmpty) {
        newState = newState.copyWith(partnerName: p.displayName);
      }
      if (p.photoUrl != null && p.photoUrl!.isNotEmpty) {
        newState = newState.copyWith(partnerAvatarPath: p.photoUrl!);
      }
      if (p.birthday != null) {
        newState = newState.copyWith(partnerBirthday: p.birthday!);
      }
    }

    state = newState;
  }

  Future<void> updateCoverPhoto(String path) async {
    state = state.copyWith(coverPhotoPath: path);

    final user = ref.read(authStateProvider);
    if (user?.coupleSpaceId != null && File(path).existsSync()) {
      try {
        final authRepo = ref.read(authRepositoryProvider);
        final result = await authRepo.uploadCoverPhoto(
          coupleSpaceId: user!.coupleSpaceId!,
          coverFile: File(path),
        );
        result.fold(
          (_) => null,
          (uploadedUrl) => state = state.copyWith(coverPhotoPath: uploadedUrl),
        );
      } catch (_) {}
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
          (_) => null,
          (uploadedUrl) async {
            state = state.copyWith(userAvatarPath: uploadedUrl);
            await ref.read(authStateProvider.notifier).updateProfile(
                  displayName: user.displayName,
                  photoUrl: uploadedUrl,
                );
          },
        );
      } catch (_) {}
    }
  }

  void updatePartnerAvatar(String path) {
    state = state.copyWith(partnerAvatarPath: path);
  }

  void updatePartnerBirthday(DateTime birthday) {
    state = state.copyWith(partnerBirthday: birthday);
  }

  void updatePartnerName(String name) {
    state = state.copyWith(partnerName: name);
  }
}

/// Alias for concise access across redesign widgets
final coupleMediaProvider = coupleMediaControllerProvider;
