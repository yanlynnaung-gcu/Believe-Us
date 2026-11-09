import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thae_nge_lay/core/network/api_client.dart';
import 'package:thae_nge_lay/features/emergency/domain/models/emergency_sos_model.dart';

part 'mqtt_sos_service.g.dart';

/// Mission-Critical MQTT SOS Service for Offline Resilience
/// Uses persistent sessions (cleanSession = false) and QoS 1 (At least once delivery)
/// to ensure emergency alerts are reliably delivered even if a partner is temporarily offline.
class MqttSosService {
  MqttServerClient? _client;
  String? _userId;
  String? _coupleSpaceId;
  bool _isConnecting = false;

  final StreamController<EmergencySOSAlert> _sosAlertController =
      StreamController<EmergencySOSAlert>.broadcast();

  // Offline queue for resilient emergency dispatch when network is temporarily disconnected
  final List<EmergencySOSAlert> _offlineDispatchQueue = [];
  final List<EmergencySOSAlert> _publishedAlertsForTesting = [];
  bool _mockConnectedForTesting = false;
  Timer? _connectTimeoutTimer;

  Stream<EmergencySOSAlert> get sosAlertStream => _sosAlertController.stream;

  bool get isConnected =>
      _mockConnectedForTesting ||
      _client?.connectionStatus?.state == MqttConnectionState.connected;

  String? get activeTopic =>
      _coupleSpaceId != null ? 'couple/$_coupleSpaceId/emergency' : null;

  @visibleForTesting
  List<EmergencySOSAlert> get publishedAlertsForTesting =>
      List.unmodifiable(_publishedAlertsForTesting);

  @visibleForTesting
  List<EmergencySOSAlert> get offlineDispatchQueue =>
      List.unmodifiable(_offlineDispatchQueue);

  @visibleForTesting
  void setMockConnected(bool connected) {
    _mockConnectedForTesting = connected;
    if (connected) {
      _flushOfflineQueue();
    }
  }

  /// Initializes credentials and establishes connection to the MQTT broker
  Future<void> initialize({
    required String? userId,
    required String? coupleSpaceId,
  }) async {
    final credentialsChanged =
        _userId != userId || _coupleSpaceId != coupleSpaceId;
    _userId = userId;
    _coupleSpaceId = coupleSpaceId;

    if (userId == null) {
      await disconnect();
      return;
    }

    if (credentialsChanged || !isConnected) {
      await connect();
    }
  }

  /// Establishes persistent MQTT connection with cleanSession = false and auto-reconnect
  Future<bool> connect() async {
    if (_isConnecting || isConnected) return isConnected;
    if (_userId == null) return false;

    _isConnecting = true;

    try {
      final host = ApiEndpoints.mqttBrokerHost;
      final port = ApiEndpoints.mqttPort;
      // Stable persistent client identifier per user for QoS 1 session queuing
      final clientId = 'believeus_app_${_userId ?? "anon"}';

      debugPrint(
        '[MqttSosService] Connecting to MQTT broker at $host:$port with clientId: $clientId (cleanSession=false)...',
      );

      _client = MqttServerClient.withPort(host, clientId, port);
      _client!.logging(on: false);
      _client!.keepAlivePeriod = 30;
      _client!.autoReconnect = true;
      _client!.resubscribeOnAutoReconnect = true;

      // CleanSession = false ensures the broker stores subscriptions and unacknowledged QoS 1 messages
      final connMessage = MqttConnectMessage().withClientIdentifier(clientId);
      connMessage.variableHeader?.connectFlags.cleanStart = false; // Persistent session
      _client!.connectionMessage = connMessage;

      _client!.onConnected = _onConnected;
      _client!.onDisconnected = _onDisconnected;
      _client!.onAutoReconnected = _onAutoReconnected;
      _client!.onSubscribed = _onSubscribed;

      if (_mockConnectedForTesting) {
        _isConnecting = false;
        return true;
      }

      final completer = Completer<MqttClientConnectionStatus?>();
      _connectTimeoutTimer?.cancel();
      _connectTimeoutTimer = Timer(const Duration(milliseconds: 1000), () {
        if (!completer.isCompleted) completer.complete(null);
      });

      _client!.connect().then((status) {
        if (!completer.isCompleted) completer.complete(status);
      }).catchError((_) {
        if (!completer.isCompleted) completer.complete(null);
      });

      final status = await completer.future;
      _connectTimeoutTimer?.cancel();
      _connectTimeoutTimer = null;
      _isConnecting = false;

      if (status?.state == MqttConnectionState.connected) {
        _subscribeToEmergencyTopic();
        _listenToIncomingUpdates();
        _flushOfflineQueue();
        return true;
      } else {
        debugPrint(
          '[MqttSosService] Connection status not connected: ${status?.state}',
        );
        return false;
      }
    } catch (e) {
      _isConnecting = false;
      debugPrint('[MqttSosService] Connection failed (will auto-retry): $e');
      return false;
    }
  }

  void _onConnected() {
    debugPrint('[MqttSosService] Connected to MQTT broker successfully.');
    _subscribeToEmergencyTopic();
    _flushOfflineQueue();
  }

  void _onDisconnected() {
    debugPrint('[MqttSosService] Disconnected from MQTT broker.');
  }

  void _onAutoReconnected() {
    debugPrint('[MqttSosService] Auto-reconnected to MQTT broker.');
    _subscribeToEmergencyTopic();
    _flushOfflineQueue();
  }

  void _onSubscribed(String topic) {
    debugPrint('[MqttSosService] Subscribed to topic $topic with QoS 1.');
  }

  /// Subscribes to the couple space emergency topic with QoS 1 (At least once delivery)
  void _subscribeToEmergencyTopic() {
    if (_coupleSpaceId == null || !isConnected) return;
    final topic = 'couple/$_coupleSpaceId/emergency';
    try {
      _client!.subscribe(topic, MqttQos.atLeastOnce);
      debugPrint('[MqttSosService] Subscribed to topic: $topic with QoS 1');
    } catch (e) {
      debugPrint('[MqttSosService] Subscribe error: $e');
    }
  }

  void _listenToIncomingUpdates() {
    _client?.updates?.listen(
      (List<MqttReceivedMessage<MqttMessage?>>? messages) {
        if (messages == null || messages.isEmpty) return;

        for (final msg in messages) {
          final pubMsg = msg.payload as MqttPublishMessage;
          final payloadString = MqttPublishPayload.bytesToStringAsString(
            pubMsg.payload.message,
          );

          debugPrint(
            '[MqttSosService] Received message on ${msg.topic} with QoS ${pubMsg.header?.qos}: $payloadString',
          );

          try {
            final Map<String, dynamic> json =
                jsonDecode(payloadString) as Map<String, dynamic>;
            final alert = EmergencySOSAlert.fromJson(json);

            // Ignore own broadcast
            if (alert.senderId == _userId) {
              debugPrint('[MqttSosService] Ignoring self-published SOS alert.');
              continue;
            }

            _sosAlertController.add(alert);
          } catch (e) {
            debugPrint('[MqttSosService] Failed to parse emergency payload: $e');
          }
        }
      },
      onError: (err) {
        debugPrint('[MqttSosService] Error in updates stream: $err');
      },
    );
  }

  /// Publishes Emergency SOS alert payload with QoS 1 (At least once delivery)
  Future<bool> publishEmergencySOS({
    required String coupleSpaceId,
    required EmergencySOSAlert alert,
  }) async {
    final topic = 'couple/$coupleSpaceId/emergency';
    final payloadJson = jsonEncode(alert.toJson());

    _publishedAlertsForTesting.add(alert);

    debugPrint(
      '[MqttSosService] Publishing Emergency SOS to $topic (QoS 1): $payloadJson',
    );

    if (!isConnected) {
      debugPrint(
        '[MqttSosService] Client offline; queuing SOS alert into persistent offline buffer...',
      );
      _offlineDispatchQueue.add(alert);
      // Attempt background connection
      connect();
      return false;
    }

    if (_mockConnectedForTesting && (_client == null || _client?.connectionStatus?.state != MqttConnectionState.connected)) {
      debugPrint(
        '[MqttSosService] [TEST MOCK] Published emergency alert to $topic with QoS 1',
      );
      return true;
    }

    try {
      final builder = MqttClientPayloadBuilder();
      builder.addString(payloadJson);

      _client!.publishMessage(
        topic,
        MqttQos.atLeastOnce, // QoS 1 (At least once delivery)
        builder.payload!,
        retain: false,
      );
      debugPrint(
        '[MqttSosService] Successfully published emergency alert to $topic with QoS 1',
      );
      return true;
    } catch (e) {
      debugPrint('[MqttSosService] Publish failed: $e, queuing for retry.');
      _offlineDispatchQueue.add(alert);
      return false;
    }
  }

  void _flushOfflineQueue() {
    if (_offlineDispatchQueue.isEmpty || !isConnected || _coupleSpaceId == null) {
      return;
    }

    debugPrint(
      '[MqttSosService] Flushing ${_offlineDispatchQueue.length} queued offline emergency alerts...',
    );
    final pending = List<EmergencySOSAlert>.from(_offlineDispatchQueue);
    _offlineDispatchQueue.clear();

    for (final alert in pending) {
      publishEmergencySOS(coupleSpaceId: _coupleSpaceId!, alert: alert);
    }
  }

  /// Simulation helper for testing incoming partner alerts
  @visibleForTesting
  void simulateIncomingAlert(EmergencySOSAlert alert) {
    _sosAlertController.add(alert);
  }

  Future<void> disconnect() async {
    _connectTimeoutTimer?.cancel();
    _connectTimeoutTimer = null;
    try {
      _client?.disconnect();
    } catch (_) {}
    _client = null;
  }

  void dispose() {
    disconnect();
    _sosAlertController.close();
  }
}

@Riverpod(keepAlive: true)
MqttSosService mqttSosService(Ref ref) {
  final service = MqttSosService();
  ref.onDispose(() => service.dispose());
  return service;
}
