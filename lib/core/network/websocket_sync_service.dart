import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:thae_nge_lay/core/network/api_client.dart';

part 'websocket_sync_service.g.dart';

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
}

class WebSocketSyncService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  Timer? _pingTimer;

  String? _currentUserId;
  String? _currentCoupleSpaceId;
  bool _isConnecting = false;

  // Exponential Backoff Auto-Reconnection Configuration
  int _reconnectAttempts = 0;
  static const int _initialRetryDelayMs = 1000; // 1 second
  static const int _maxRetryDelayMs = 30000;    // 30 seconds
  static const double _backoffMultiplier = 1.5;
  final Random _random = Random();

  final StreamController<WebSocketEvent> _eventController =
      StreamController<WebSocketEvent>.broadcast();

  Stream<WebSocketEvent> get eventStream => _eventController.stream;

  bool get isConnected => _channel != null && !_isConnecting;

  Stream<WebSocketEvent> onEvent(String eventType) {
    return _eventController.stream.where((e) => e.event == eventType);
  }

  /// Simulation hook for testing incoming WebSocket/STOMP events
  @visibleForTesting
  void simulateIncomingEvent(WebSocketEvent event) {
    _eventController.add(event);
  }

  void sendEvent({
    required String event,
    required Map<String, dynamic> data,
    String? topic,
  }) {
    if (_channel != null) {
      try {
        final payload = jsonEncode({
          'action': 'EVENT',
          'event': event,
          'coupleSpaceId': _currentCoupleSpaceId ?? '',
          'senderId': _currentUserId ?? '',
          'topic': topic ?? '/topic/couple.${_currentCoupleSpaceId ?? ""}.status',
          'data': data,
        });
        _channel!.sink.add(payload);
        debugPrint('[WebSocket] Sent event $event: $payload');
      } catch (e) {
        debugPrint('[WebSocket] Send event error: $e');
      }
    }
  }

  void updateCredentials({required String? userId, required String? coupleSpaceId}) {
    final changed = _currentUserId != userId || _currentCoupleSpaceId != coupleSpaceId;
    _currentUserId = userId;
    _currentCoupleSpaceId = coupleSpaceId;

    if (changed) {
      if (_channel != null) {
        _subscribe();
      } else if (userId != null) {
        connect();
      }
    }
  }

  void connect() {
    if (_isConnecting || _channel != null) return;
    _isConnecting = true;

    try {
      final uri = Uri.parse(ApiEndpoints.wsUrl);
      debugPrint('[WebSocket] Connecting to $uri (Attempt $_reconnectAttempts) ...');

      _channel = WebSocketChannel.connect(uri);
      _channel?.ready.catchError((error) {
        debugPrint('[WebSocket] Handshake Error: $error');
      });

      _subscription = _channel!.stream.listen(
        (data) {
          _isConnecting = false;
          _reconnectAttempts = 0; // Reset backoff counter on successful traffic
          _handleMessage(data);
        },
        onError: (error) {
          debugPrint('[WebSocket] Connection Error: $error');
          _scheduleExponentialReconnect();
        },
        onDone: () {
          debugPrint('[WebSocket] Connection closed by server.');
          _scheduleExponentialReconnect();
        },
        cancelOnError: true,
      );

      _subscribe();
      _startPing();
    } catch (e) {
      debugPrint('[WebSocket] Connect exception: $e');
      _scheduleExponentialReconnect();
    }
  }

  void _subscribe() {
    if (_channel != null && _currentUserId != null) {
      final topics = <String>[];
      if (_currentCoupleSpaceId != null && _currentCoupleSpaceId!.isNotEmpty) {
        final space = _currentCoupleSpaceId!;
        topics.addAll([
          '/topic/couple.$space.*',
          '/topic/couple.$space.chat',
          '/topic/couple.$space.location',
          '/topic/couple.$space.gifts',
          '/topic/couple.$space.status',
          '/topic/couple.$space.milestones',
        ]);
      }

      final payload = jsonEncode({
        'action': 'SUBSCRIBE',
        'userId': _currentUserId,
        'coupleSpaceId': _currentCoupleSpaceId ?? '',
        'topics': topics,
      });

      try {
        _channel!.sink.add(payload);
        debugPrint(
          '[WebSocket] Subscribed User $_currentUserId to Space room $_currentCoupleSpaceId '
          'with ${topics.length} isolated dynamic topics',
        );
      } catch (e) {
        debugPrint('[WebSocket] Subscribe error: $e');
      }
    }
  }

  void _startPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      if (_channel != null) {
        try {
          _channel!.sink.add(jsonEncode({'action': 'PING'}));
        } catch (_) {}
      }
    });
  }

  void _handleMessage(dynamic raw) {
    try {
      final Map<String, dynamic> json = jsonDecode(raw.toString()) as Map<String, dynamic>;
      final event = json['event'] as String? ?? 'UNKNOWN';
      final topic = json['topic'] as String?;
      final spaceId = json['coupleSpaceId'] as String?;

      debugPrint('[WebSocket Event Received] $event: $json');

      final eventData = json.containsKey('data') && json['data'] is Map<String, dynamic>
          ? json['data'] as Map<String, dynamic>
          : json;

      _eventController.add(
        WebSocketEvent(
          event: event,
          data: eventData,
          topic: topic,
          coupleSpaceId: spaceId,
        ),
      );
    } catch (e) {
      debugPrint('[WebSocket] Parse error: $e');
    }
  }

  void _scheduleExponentialReconnect() {
    _isConnecting = false;
    _cleanup();
    _reconnectTimer?.cancel();

    if (_currentUserId == null) return;

    // Calculate delay with exponential backoff and randomized jitter
    final jitterMs = _random.nextInt(500);
    final delayMs = (_initialRetryDelayMs * pow(_backoffMultiplier, _reconnectAttempts))
        .clamp(0, _maxRetryDelayMs)
        .toInt() + jitterMs;

    _reconnectAttempts++;

    debugPrint(
      '[WebSocket Backoff] Reconnecting in ${delayMs}ms (Attempt #$_reconnectAttempts, max capped at ${_maxRetryDelayMs}ms)...',
    );

    _reconnectTimer = Timer(Duration(milliseconds: delayMs), () {
      if (_currentUserId != null) {
        connect();
      }
    });
  }

  void _cleanup() {
    _pingTimer?.cancel();
    _subscription?.cancel();
    _subscription = null;
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }

  void dispose() {
    _reconnectTimer?.cancel();
    _cleanup();
    _eventController.close();
  }
}

@Riverpod(keepAlive: true)
WebSocketSyncService webSocketSyncService(Ref ref) {
  final service = WebSocketSyncService();
  ref.onDispose(() => service.dispose());
  return service;
}
