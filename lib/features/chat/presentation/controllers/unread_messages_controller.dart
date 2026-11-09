import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:thae_nge_lay/core/network/websocket_sync_service.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';
import 'package:thae_nge_lay/features/chat/data/repositories/chat_repository_impl.dart';

class UnreadMessagesNotifier extends Notifier<int> {
  StreamSubscription? _unreadSub;
  StreamSubscription? _msgSub;
  StreamSubscription? _readSub;

  @override
  int build() {
    final user = ref.watch(authStateProvider);
    final ws = ref.watch(webSocketSyncServiceProvider);
    final chatRepo = ref.watch(chatRepositoryProvider);

    _unreadSub?.cancel();
    _msgSub?.cancel();
    _readSub?.cancel();

    ref.onDispose(() {
      _unreadSub?.cancel();
      _msgSub?.cancel();
      _readSub?.cancel();
    });

    if (user != null) {
      final spaceId = user.coupleSpaceId ?? 'space_demo';
      final userId = user.id;

      // 1. Initial count from backend / repository
      Future.microtask(() async {
        final result = await chatRepo.getUnreadCount(
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

      // 2. Listen for real-time CHAT_UNREAD_COUNT events
      _unreadSub = ws.onEvent('CHAT_UNREAD_COUNT').listen((e) {
        final rawCount = e.data['unreadCount'];
        final targetReceiver = e.data['receiverId'];
        if (targetReceiver == null || targetReceiver == userId) {
          if (rawCount is num) {
            state = rawCount.toInt();
          }
        }
      });

      // 3. Listen for incoming CHAT_MESSAGE events
      _msgSub = ws.onEvent('CHAT_MESSAGE').listen((e) {
        final receiverId = e.data['receiverId'];
        final isRead = e.data['isRead'] == true;
        if (receiverId == userId && !isRead) {
          state = state + 1;
        }
      });

      // 4. Listen for MESSAGES_READ events
      _readSub = ws.onEvent('MESSAGES_READ').listen((e) {
        final readBy = e.data['readBy'];
        if (readBy == userId) {
          state = 0;
        }
      });
    }

    return 0;
  }

  Future<void> markAsRead() async {
    state = 0;
    final user = ref.read(authStateProvider);
    if (user == null) return;

    final chatRepo = ref.read(chatRepositoryProvider);
    await chatRepo.markMessagesAsRead(
      coupleSpaceId: user.coupleSpaceId ?? 'space_demo',
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

final unreadMessagesProvider =
    NotifierProvider<UnreadMessagesNotifier, int>(UnreadMessagesNotifier.new);
