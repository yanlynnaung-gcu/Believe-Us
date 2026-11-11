/// Represents an incoming or outgoing WebSocket event message.
class WebSocketEvent {
  final String event;
  final Map<String, dynamic> data;
  final String? topic;
  final String? coupleSpaceId;

  const WebSocketEvent({
    required this.event,
    required this.data,
    this.topic,
    this.coupleSpaceId,
  });

  /// Builds standard topic subscription paths for a couple space.
  static List<String> buildTopics(String? space) {
    if (space == null || space.isEmpty) return const [];
    return [
      '/topic/couple.$space.*',
      '/topic/couple.$space.chat',
      '/topic/couple.$space.location',
      '/topic/couple.$space.gifts',
      '/topic/couple.$space.status',
      '/topic/couple.$space.milestones',
    ];
  }
}
