import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:thae_nge_lay/core/network/websocket_sync_service.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';
import 'package:thae_nge_lay/features/gifting/data/repositories/gifting_repository_impl.dart';

class UnseenGiftsNotifier extends Notifier<int> {
  StreamSubscription? _giftReceivedSub;
  StreamSubscription? _giftSeenSub;

  @override
  int build() {
    final user = ref.watch(authStateProvider);
    final ws = ref.watch(webSocketSyncServiceProvider);
    final repo = ref.watch(giftingRepositoryProvider);

    _giftReceivedSub?.cancel();
    _giftSeenSub?.cancel();

    ref.onDispose(() {
      _giftReceivedSub?.cancel();
      _giftSeenSub?.cancel();
    });

    if (user != null && user.coupleSpaceId != null && user.coupleSpaceId!.isNotEmpty) {
      final spaceId = user.coupleSpaceId!;
      final userId = user.id;

      // 1. Initial count from backend
      Future.microtask(() async {
        final result = await repo.getUnseenGiftsCount(
          coupleSpaceId: spaceId,
          receiverId: userId,
        );
        result.fold(
          (_) {},
          (count) {
            state = count;
          },
        );
      });

      // 2. Listen for incoming GIFT_RECEIVED WebSocket events
      _giftReceivedSub = ws.onEvent('GIFT_RECEIVED').listen((e) {
        final receiverId = e.data['receiverId'];
        final status = (e.data['status'] ?? '').toString().toUpperCase();
        if ((receiverId == null || receiverId == userId) &&
            (status == 'PAID' || status == 'SUCCESS' || status == 'COMPLETED')) {
          state = state + 1;
        }
      });

      // 3. Listen for GIFT_SEEN WebSocket events
      _giftSeenSub = ws.onEvent('GIFT_SEEN').listen((e) {
        final receiverId = e.data['receiverId'];
        if (receiverId == null || receiverId == userId) {
          state = 0;
        }
      });
    }

    return 0;
  }

  Future<void> markGiftsAsSeen() async {
    state = 0;
    final user = ref.read(authStateProvider);
    if (user == null || user.coupleSpaceId == null) return;

    final repo = ref.read(giftingRepositoryProvider);
    await repo.markGiftsAsSeen(
      coupleSpaceId: user.coupleSpaceId!,
      receiverId: user.id,
    );
  }

  void increment() {
    state = state + 1;
  }

  void reset() {
    state = 0;
  }
}

final unseenGiftsProvider =
    NotifierProvider<UnseenGiftsNotifier, int>(UnseenGiftsNotifier.new);
