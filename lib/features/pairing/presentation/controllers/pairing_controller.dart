import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thae_nge_lay/core/network/websocket_sync_service.dart';
import 'package:thae_nge_lay/core/storage/local_storage_service.dart';
import 'package:thae_nge_lay/features/anniversary/presentation/controllers/anniversary_notifier.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';
import 'package:thae_nge_lay/features/home/presentation/controllers/couple_media_controller.dart';
import 'package:thae_nge_lay/features/pairing/data/repositories/pairing_repository_impl.dart';

part 'pairing_controller.g.dart';

class PairingUIState {
  final bool isLoading;
  final bool isGeneratingCode;
  final String? inviteCode;
  final String? errorMessage;
  final bool isPaired;

  const PairingUIState({
    this.isLoading = false,
    this.isGeneratingCode = false,
    this.inviteCode,
    this.errorMessage,
    this.isPaired = false,
  });

  PairingUIState copyWith({
    bool? isLoading,
    bool? isGeneratingCode,
    String? inviteCode,
    String? errorMessage,
    bool? isPaired,
    bool clearError = false,
  }) {
    return PairingUIState(
      isLoading: isLoading ?? this.isLoading,
      isGeneratingCode: isGeneratingCode ?? this.isGeneratingCode,
      inviteCode: inviteCode ?? this.inviteCode,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isPaired: isPaired ?? this.isPaired,
    );
  }
}

@riverpod
class PairingController extends _$PairingController {
  Timer? _pollTimer;
  StreamSubscription? _wsSub;
  bool _isCheckingStatus = false;

  @override
  PairingUIState build() {
    ref.onDispose(() {
      _pollTimer?.cancel();
      _pollTimer = null;
      _wsSub?.cancel();
    });

    _initRealtimeListener();
    Future.microtask(() => _loadInviteCode());
    return const PairingUIState();
  }

  void _initRealtimeListener() {
    final user = ref.read(authStateProvider);
    if (user == null) return;

    final ws = ref.read(webSocketSyncServiceProvider);
    ws.updateCredentials(userId: user.id, coupleSpaceId: null);

    // 1. Instant WebSocket event when partner submits our code
    _wsSub?.cancel();
    _wsSub = ws.onEvent('COUPLE_PAIRED').listen((e) async {
      final data = e.data;
      final user1 = data['user1Id']?.toString();
      final user2 = data['user2Id']?.toString();
      final spaceId = data['id']?.toString();
      final partnerId = user1 == user.id ? user2 : user1;
      final dateStr = data['anniversaryDate']?.toString() ??
          data['startDate']?.toString() ??
          data['pairedAt']?.toString() ??
          data['createdAt']?.toString();
      final anniversaryDate = dateStr != null ? DateTime.tryParse(dateStr)?.toUtc() : null;

      if (partnerId != null && spaceId != null) {
        _pollTimer?.cancel();
        _pollTimer = null;
        await ref.read(authStateProvider.notifier).pairPartner(
              partnerId: partnerId,
              coupleSpaceId: spaceId,
              anniversaryDate: anniversaryDate,
            );
        if (anniversaryDate != null) {
          await ref.read(localStorageServiceProvider).setAnniversaryDate(anniversaryDate);
        }
        ref.invalidate(anniversaryProvider);
        await ref.read(coupleMediaProvider.notifier).syncCoupleSummary();
        state = state.copyWith(isPaired: true);
      }
    });

    // 2. Throttled 10s polling fallback to prevent request storms during Railway cold starts
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _checkPairingStatus();
    });
  }

  Future<void> _checkPairingStatus() async {
    final user = ref.read(authStateProvider);
    if (user == null || state.isPaired || _isCheckingStatus) return;

    _isCheckingStatus = true;
    try {
      final repo = ref.read(pairingRepositoryProvider);
      final result = await repo.checkPairingStatus(user.id);

      result.fold(
        (_) => null,
        (data) async {
          final isPaired = data['isPaired'] == true;
          if (isPaired && data.containsKey('coupleSpace') && data['coupleSpace'] is Map) {
            final spaceMap = data['coupleSpace'] as Map;
            final partnerId = data['partnerId']?.toString() ??
                (spaceMap['user1Id'] == user.id ? spaceMap['user2Id'] : spaceMap['user1Id']);
            final spaceId = spaceMap['id']?.toString();
            final dateStr = spaceMap['anniversaryDate']?.toString() ??
                spaceMap['startDate']?.toString() ??
                spaceMap['pairedAt']?.toString() ??
                spaceMap['createdAt']?.toString();
            final anniversaryDate = dateStr != null ? DateTime.tryParse(dateStr)?.toUtc() : null;

            if (partnerId != null && spaceId != null) {
              _pollTimer?.cancel();
              _pollTimer = null;
              await ref.read(authStateProvider.notifier).pairPartner(
                    partnerId: partnerId,
                    coupleSpaceId: spaceId,
                    anniversaryDate: anniversaryDate,
                  );
              if (anniversaryDate != null) {
                await ref.read(localStorageServiceProvider).setAnniversaryDate(anniversaryDate);
              }
              ref.invalidate(anniversaryProvider);
              await ref.read(coupleMediaProvider.notifier).syncCoupleSummary();
              state = state.copyWith(isPaired: true);
            }
          }
        },
      );
    } finally {
      _isCheckingStatus = false;
    }
  }

  Future<void> _loadInviteCode() async {
    final user = ref.read(authStateProvider);
    if (user == null) return;

    state = state.copyWith(isGeneratingCode: true, clearError: true);
    final repo = ref.read(pairingRepositoryProvider);
    final result = await repo.getOrCreateInviteCode(user.id);

    result.fold(
      (failure) => state = state.copyWith(
        isGeneratingCode: false,
        errorMessage: failure.message,
      ),
      (code) => state = state.copyWith(
        isGeneratingCode: false,
        inviteCode: code,
        clearError: true,
      ),
    );
  }

  Future<void> retryLoadCode() async {
    await _loadInviteCode();
  }

  Future<void> generateNewInviteCode() async {
    final user = ref.read(authStateProvider);
    if (user == null) return;

    state = state.copyWith(isGeneratingCode: true, clearError: true);
    final repo = ref.read(pairingRepositoryProvider);
    final result = await repo.generateNewInviteCode(user.id);

    result.fold(
      (failure) => state = state.copyWith(
        isGeneratingCode: false,
        errorMessage: failure.message,
      ),
      (code) => state = state.copyWith(
        isGeneratingCode: false,
        inviteCode: code,
        clearError: true,
      ),
    );
  }

  Future<bool> pairWithCode(String code) async {
    final user = ref.read(authStateProvider);
    if (user == null) return false;

    // Strict regex extraction for pure 6-digit code
    final match = RegExp(r'\d{6}').firstMatch(code);
    if (match == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Invalid couple code. Please enter a valid 6-digit numeric code.',
      );
      return false;
    }

    final sanitizedCode = match.group(0)!;

    state = state.copyWith(isLoading: true, clearError: true);
    final repo = ref.read(pairingRepositoryProvider);
    final result = await repo.pairWithCode(
      currentUserId: user.id,
      inviteCode: sanitizedCode,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message ?? 'Pairing failed.',
        );
        return false;
      },
      (space) async {
        final partnerId =
            space.user1Id == user.id ? space.user2Id : space.user1Id;
        _pollTimer?.cancel();
        final annDate = space.anniversaryDate ?? space.pairedAt;
        await ref.read(authStateProvider.notifier).pairPartner(
              partnerId: partnerId,
              coupleSpaceId: space.id,
              anniversaryDate: annDate,
            );
        await ref.read(localStorageServiceProvider).setAnniversaryDate(annDate);
        ref.invalidate(anniversaryProvider);
        await ref.read(coupleMediaProvider.notifier).syncCoupleSummary();
        state = state.copyWith(isLoading: false, isPaired: true);
        return true;
      },
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
