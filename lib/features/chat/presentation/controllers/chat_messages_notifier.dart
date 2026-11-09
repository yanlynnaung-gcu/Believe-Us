import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';
import 'package:thae_nge_lay/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:thae_nge_lay/features/chat/domain/models/chat_message.dart';

part 'chat_messages_notifier.g.dart';

@riverpod
class ChatMessagesNotifier extends _$ChatMessagesNotifier {
  @override
  Stream<List<ChatMessage>> build() {
    final user = ref.watch(authStateProvider);
    final spaceId = user?.coupleSpaceId ?? 'space_demo';
    final repo = ref.watch(chatRepositoryProvider);
    return repo.streamMessages(spaceId);
  }

  Future<bool> sendTextMessage(String text) async {
    final user = ref.read(authStateProvider);
    if (user == null || text.trim().isEmpty) return false;

    final repo = ref.read(chatRepositoryProvider);
    final result = await repo.sendTextMessage(
      senderId: user.id,
      receiverId: user.partnerId ?? 'usr_partner_demo',
      coupleSpaceId: user.coupleSpaceId ?? 'space_demo',
      text: text,
    );
    return result.isRight();
  }

  Future<bool> sendVoiceMessage({
    required String audioPath,
    required int durationSeconds,
    required List<double> waveforms,
  }) async {
    final user = ref.read(authStateProvider);
    if (user == null) return false;

    final repo = ref.read(chatRepositoryProvider);
    final result = await repo.sendVoiceMessage(
      senderId: user.id,
      receiverId: user.partnerId ?? 'usr_partner_demo',
      coupleSpaceId: user.coupleSpaceId ?? 'space_demo',
      audioPath: audioPath,
      durationSeconds: durationSeconds,
      waveforms: waveforms,
    );
    return result.isRight();
  }
}
