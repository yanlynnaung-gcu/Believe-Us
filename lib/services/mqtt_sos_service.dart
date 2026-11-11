import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thae_nge_lay/core/network/api_client.dart';
import 'package:thae_nge_lay/features/emergency/domain/models/emergency_sos_model.dart';
import 'package:thae_nge_lay/services/mqtt_connection_manager.dart';
import 'package:thae_nge_lay/services/mqtt_sos_message_parser.dart';

part 'mqtt_sos_service.g.dart';

class MqttSosService {
  MqttServerClient? _client;
  String? _userId;
  String? _coupleSpaceId;
  bool _isConnecting = false;

  final StreamController<EmergencySOSAlert> _sosAlertController =
      StreamController<EmergencySOSAlert>.broadcast();

  final List<EmergencySOSAlert> _offlineDispatchQueue = [];
  final List<EmergencySOSAlert> _publishedAlertsForTesting = [];
  bool _mockConnectedForTesting = false;
  Timer? _connectTimeoutTimer;
  DateTime? _lastConnectFailure;

  Stream<EmergencySOSAlert> get sosAlertStream => _sosAlertController.stream;

  bool get isConnected =>
      _mockConnectedForTesting ||
      _client?.connectionStatus?.state == MqttConnectionState.connected;

  String? get activeTopic =>
      _coupleSpaceId != null ? 'couple/$_coupleSpaceId/emergency' : null;

  @visibleForTesting
  List<EmergencySOSAlert> get publishedAlertsForTesting => List.unmodifiable(_publishedAlertsForTesting);

  @visibleForTesting
  List<EmergencySOSAlert> get offlineDispatchQueue => List.unmodifiable(_offlineDispatchQueue);

  @visibleForTesting
  void setMockConnected(bool connected) {
    _mockConnectedForTesting = connected;
    if (connected) _flushOfflineQueue();
  }

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

  Future<bool> connect() async {
    if (_isConnecting || isConnected) return isConnected;
    if (_userId == null) return false;

    if (_lastConnectFailure != null &&
        DateTime.now().difference(_lastConnectFailure!).inSeconds < 10) {
      return false;
    }

    _isConnecting = true;
    _cleanupClient();

    try {
      final host = ApiEndpoints.mqttBrokerHost;
      final port = ApiEndpoints.mqttPort;
      final clientId = 'believeus_app_${_userId ?? "anon"}';

      _client = MqttConnectionManager.createClient(
        host: host,
        port: port,
        clientId: clientId,
        onConnected: _onConnected,
        onDisconnected: () => debugPrint('[MqttSosService] Disconnected.'),
        onAutoReconnected: _onConnected,
        onSubscribed: (t) => debugPrint('[MqttSosService] Subscribed: $t'),
      );

      if (_mockConnectedForTesting) {
        _isConnecting = false;
        return true;
      }

      final completer = Completer<MqttClientConnectionStatus?>();
      _connectTimeoutTimer?.cancel();
      _connectTimeoutTimer = Timer(const Duration(milliseconds: 1500), () {
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
        _lastConnectFailure = null;
        _subscribeToEmergencyTopic();
        _listenToIncomingUpdates();
        _flushOfflineQueue();
        return true;
      } else {
        _lastConnectFailure = DateTime.now();
        _cleanupClient();
        return false;
      }
    } catch (e) {
      _isConnecting = false;
      _lastConnectFailure = DateTime.now();
      _cleanupClient();
      return false;
    }
  }

  void _cleanupClient() {
    if (_client != null) {
      try {
        _client!.disconnect();
      } catch (_) {}
      _client = null;
    }
  }

  void _onConnected() {
    debugPrint('[MqttSosService] Connected to MQTT broker successfully.');
    _subscribeToEmergencyTopic();
    _flushOfflineQueue();
  }

  void _subscribeToEmergencyTopic() {
    if (_coupleSpaceId == null || !isConnected) return;
    final topic = 'couple/$_coupleSpaceId/emergency';
    try {
      _client!.subscribe(topic, MqttQos.atLeastOnce);
    } catch (e) {
      debugPrint('[MqttSosService] Subscribe error: $e');
    }
  }

  void _listenToIncomingUpdates() {
    _client?.updates?.listen(
      (messages) {
        if (messages.isNotEmpty) {
          MqttSosMessageParser.processUpdates(
            messages: messages,
            currentUserId: _userId,
            onAlertReceived: _sosAlertController.add,
          );
        }
      },
      onError: (err) => debugPrint('[MqttSosService] Updates error: $err'),
    );
  }

  Future<bool> publishEmergencySOS({
    required String coupleSpaceId,
    required EmergencySOSAlert alert,
  }) async {
    final topic = 'couple/$coupleSpaceId/emergency';
    final payloadJson = jsonEncode(alert.toJson());
    _publishedAlertsForTesting.add(alert);

    if (!isConnected) {
      _offlineDispatchQueue.add(alert);
      connect();
      return false;
    }

    if (_mockConnectedForTesting &&
        (_client == null ||
            _client?.connectionStatus?.state != MqttConnectionState.connected)) {
      return true;
    }

    try {
      final builder = MqttClientPayloadBuilder();
      builder.addString(payloadJson);
      _client!.publishMessage(
        topic,
        MqttQos.atLeastOnce,
        builder.payload!,
        retain: false,
      );
      return true;
    } catch (e) {
      _offlineDispatchQueue.add(alert);
      return false;
    }
  }

  void _flushOfflineQueue() {
    if (_offlineDispatchQueue.isEmpty || !isConnected || _coupleSpaceId == null) {
      return;
    }
    final pending = List<EmergencySOSAlert>.from(_offlineDispatchQueue);
    _offlineDispatchQueue.clear();

    for (final alert in pending) {
      publishEmergencySOS(coupleSpaceId: _coupleSpaceId!, alert: alert);
    }
  }

  @visibleForTesting
  void simulateIncomingAlert(EmergencySOSAlert alert) {
    _sosAlertController.add(alert);
  }

  Future<void> disconnect() async {
    _connectTimeoutTimer?.cancel();
    _connectTimeoutTimer = null;
    _cleanupClient();
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
