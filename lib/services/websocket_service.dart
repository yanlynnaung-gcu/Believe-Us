import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thae_nge_lay/core/network/websocket_sync_service.dart';

part 'websocket_service.g.dart';

/// Standard Real-Time Active Synchronization Service (STOMP / WebSocket)
/// Handles Daily Notes, Live map location sync, and active couple chats.
class WebSocketService {
  final WebSocketSyncService _syncService;

  WebSocketService({WebSocketSyncService? syncService})
      : _syncService = syncService ?? WebSocketSyncService();

  String? _userId;
  String? _coupleSpaceId;

  // Streams for specific domain events
  final StreamController<Map<String, dynamic>> _dailyNoteController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _locationController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _chatController =
      StreamController<Map<String, dynamic>>.broadcast();

  StreamSubscription<WebSocketEvent>? _eventSub;

  Stream<Map<String, dynamic>> get dailyNoteStream => _dailyNoteController.stream;
  Stream<Map<String, dynamic>> get locationStream => _locationController.stream;
  Stream<Map<String, dynamic>> get chatStream => _chatController.stream;
  Stream<WebSocketEvent> get rawEventStream => _syncService.eventStream;

  bool get isConnected => _syncService.isConnected;

  void initialize({required String? userId, required String? coupleSpaceId}) {
    _userId = userId;
    _coupleSpaceId = coupleSpaceId;

    _eventSub?.cancel();
    _eventSub = _syncService.eventStream.listen(_routeEvent);

    _syncService.updateCredentials(userId: userId, coupleSpaceId: coupleSpaceId);
  }

  void _routeEvent(WebSocketEvent event) {
    final topic = event.topic ?? '';
    final eventName = event.event.toUpperCase();

    // Route Daily Notes
    if (topic.endsWith('.note') ||
        eventName == 'NOTE_UPDATE' ||
        eventName == 'DAILY_NOTE') {
      _dailyNoteController.add(event.data);
    }

    // Route Live Location Updates
    if (topic.endsWith('.location') ||
        eventName == 'LOCATION_UPDATE' ||
        eventName == 'HEARTBEAT') {
      _locationController.add(event.data);
    }

    // Route Active Chat
    if (topic.endsWith('.chat') ||
        eventName == 'CHAT_MESSAGE' ||
        eventName == 'MESSAGE') {
      _chatController.add(event.data);
    }
  }

  /// Sends a Daily Note synchronization event to the partner over STOMP/WebSocket
  void sendDailyNote({
    required String note,
    String? mood,
    Map<String, dynamic>? additionalData,
  }) {
    if (_coupleSpaceId == null) return;
    final topic = '/topic/couple.$_coupleSpaceId.note';
    final payload = <String, dynamic>{
      'type': 'DAILY_NOTE',
      'note': note,
      'mood': mood ?? 'happy',
      'senderId': _userId ?? '',
      'coupleSpaceId': _coupleSpaceId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      if (additionalData != null) ...additionalData,
    };

    _syncService.sendEvent(
      event: 'NOTE_UPDATE',
      topic: topic,
      data: payload,
    );
    debugPrint('[WebSocketService] Dispatched Daily Note to $topic: $note');
  }

  /// Sends live GPS map location heartbeat to the partner over STOMP/WebSocket
  void sendLocationHeartbeat({
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
    int? batteryLevel,
    bool isCharging = false,
  }) {
    if (_coupleSpaceId == null) return;
    final topic = '/topic/couple.$_coupleSpaceId.location';
    final payload = <String, dynamic>{
      'type': 'LOCATION_HEARTBEAT',
      'senderId': _userId ?? '',
      'coupleSpaceId': _coupleSpaceId,
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed ?? 0.0,
      'heading': heading ?? 0.0,
      'batteryLevel': batteryLevel ?? 100,
      'isCharging': isCharging,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    _syncService.sendEvent(
      event: 'LOCATION_UPDATE',
      topic: topic,
      data: payload,
    );
    debugPrint('[WebSocketService] Dispatched Location Heartbeat ($latitude, $longitude) to $topic');
  }

  /// Sends active couple chat message
  void sendChatMessage(Map<String, dynamic> messageData) {
    if (_coupleSpaceId == null) return;
    final topic = '/topic/couple.$_coupleSpaceId.chat';

    _syncService.sendEvent(
      event: 'CHAT_MESSAGE',
      topic: topic,
      data: messageData,
    );
  }

  void connect() => _syncService.connect();

  void dispose() {
    _eventSub?.cancel();
    _dailyNoteController.close();
    _locationController.close();
    _chatController.close();
  }
}

@Riverpod(keepAlive: true)
WebSocketService webSocketService(Ref ref) {
  final syncService = ref.watch(webSocketSyncServiceProvider);
  final service = WebSocketService(syncService: syncService);
  ref.onDispose(() => service.dispose());
  return service;
}
