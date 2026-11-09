import 'package:fpdart/fpdart.dart';
import 'package:thae_nge_lay/core/errors/failure.dart';
import 'package:thae_nge_lay/features/chat/domain/models/chat_message.dart';

abstract interface class ChatRepository {
  Future<Either<Failure, List<ChatMessage>>> getMessages(String coupleSpaceId);
  Stream<List<ChatMessage>> streamMessages(String coupleSpaceId);
  Future<Either<Failure, ChatMessage>> sendTextMessage({
    required String senderId,
    required String receiverId,
    required String coupleSpaceId,
    required String text,
  });
  Future<Either<Failure, ChatMessage>> sendVoiceMessage({
    required String senderId,
    required String receiverId,
    required String coupleSpaceId,
    required String audioPath,
    required int durationSeconds,
    required List<double> waveforms,
  });
  Future<Either<Failure, ChatMessage>> sendGiftMessage({
    required String senderId,
    required String receiverId,
    required String coupleSpaceId,
    required Map<String, dynamic> giftData,
  });
  Future<Either<Failure, int>> getUnreadCount({
    required String coupleSpaceId,
    required String receiverId,
  });
  Future<Either<Failure, int>> markMessagesAsRead({
    required String coupleSpaceId,
    required String receiverId,
  });
}
