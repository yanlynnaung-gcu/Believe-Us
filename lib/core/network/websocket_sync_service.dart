import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:thae_nge_lay/core/network/api_client.dart';
import 'package:thae_nge_lay/core/network/websocket_event.dart';
import 'package:thae_nge_lay/core/network/websocket_reconnect_tracker.dart';

export 'websocket_event.dart';

part 'websocket_sync_service.g.dart';

class WebSocketSyncService {
  static const bool _kVerboseWsLogs =
      bool.fromEnvironment('VERBOSE_WS_LOGS', defaultValue: false);

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  Timer? _pingTimer;

  String? _currentUserId;
  String? _currentCoupleSpaceId;
  bool _isConnecting = false;

  final WebSocketReconnectTracker _tracker = WebSocketReconnectTracker();

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

  // High-frequency events silenced in logs to prevent CPU & console saturation
  static const Set<String> _highFrequencyEvents = {
    'PONG',
    'PING',
    'HEARTBEAT',
    'LOCATION_UPDATE',
    'LOCATION_HEARTBEAT',
  };

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
        if (kDebugMode && _kVerboseWsLogs && !_highFrequencyEvents.contains(event.toUpperCase())) {
          debugPrint('[WebSocket] Sent event $event: $payload');
        }
      } catch (e) {
        if (kDebugMode && _kVerboseWsLogs) {
          debugPrint('[WebSocket] Send event error: $e');
        }
      }
    }
  }

  void updateCredentials({required String? userId, required String? coupleSpaceId}) {
    final changed = _currentUserId != userId || _currentCoupleSpaceId != coupleSpaceId;
    _currentUserId = userId;
    _currentCoupleSpaceId = coupleSpaceId;

    if (changed) {
      if (_channel != null && isConnected) {
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
      if (kDebugMode && _kVerboseWsLogs) {
        debugPrint('[WebSocket] Connecting to $uri (Attempt ${_tracker.attempts}) ...');
      }

      _channel = WebSocketChannel.connect(uri);

      _channel?.ready.then((_) {
        _isConnecting = false;
        _tracker.reset();
        if (kDebugMode && _kVerboseWsLogs) {
          debugPrint('[WebSocket] Handshake succeeded.');
        }
        _subscribe();
        _startPing();
      }).catchError((error) {
        if (kDebugMode && _kVerboseWsLogs) {
          debugPrint('[WebSocket] Handshake Error: $error');
        }
        _scheduleExponentialReconnect();
      });

      _subscription = _channel!.stream.listen(
        (data) {
          _isConnecting = false;
          _tracker.reset();
          _handleMessage(data);
        },
        onError: (error) {
          if (kDebugMode && _kVerboseWsLogs) {
            debugPrint('[WebSocket] Connection Error: $error');
          }
          _scheduleExponentialReconnect();
        },
        onDone: () {
          if (kDebugMode && _kVerboseWsLogs) {
            debugPrint('[WebSocket] Connection closed by server.');
          }
          _scheduleExponentialReconnect();
        },
        cancelOnError: true,
      );
    } catch (e) {
      if (kDebugMode && _kVerboseWsLogs) {
        debugPrint('[WebSocket] Connect exception: $e');
      }
      _scheduleExponentialReconnect();
    }
  }

  void _subscribe() {
    if (_channel == null || _currentUserId == null) return;
    try {
      final topics = WebSocketEvent.buildTopics(_currentCoupleSpaceId);
      final payload = jsonEncode({
        'action': 'SUBSCRIBE',
        'userId': _currentUserId,
        'coupleSpaceId': _currentCoupleSpaceId ?? '',
        'topics': topics,
      });
      _channel!.sink.add(payload);
      if (kDebugMode && _kVerboseWsLogs) {
        debugPrint(
          '[WebSocket] Subscribed User $_currentUserId to Space $_currentCoupleSpaceId '
          '(${topics.length} topics)',
        );
      }
    } catch (e) {
      if (kDebugMode && _kVerboseWsLogs) {
        debugPrint('[WebSocket] Subscribe error: $e');
      }
    }
  }

  void _startPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 35), (_) {
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

      if (kDebugMode && _kVerboseWsLogs && !_highFrequencyEvents.contains(event.toUpperCase())) {
        debugPrint('[WebSocket Event Received] $event: $json');
      }

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
      if (kDebugMode && _kVerboseWsLogs) {
        debugPrint('[WebSocket] Parse error: $e');
      }
    }
  }

  void _scheduleExponentialReconnect() {
    _isConnecting = false;
    _cleanup();

    if (_currentUserId == null) return;
    if (_reconnectTimer != null && _reconnectTimer!.isActive) {
      return;
    }

    final delayMs = _tracker.getNextDelayMs();
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
