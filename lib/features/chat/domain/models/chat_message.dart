import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

enum MessageType {
  text,
  voice,
  gift,
}

@freezed
abstract class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String senderId,
    required String receiverId,
    required String coupleSpaceId,
    required MessageType type,
    String? text,
    String? audioPath,
    int? audioDurationSeconds,
    List<double>? waveformSamples,
    Map<String, dynamic>? giftData,
    required DateTime createdAt,
    @Default(false) bool isRead,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}
