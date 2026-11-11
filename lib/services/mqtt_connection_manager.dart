import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttConnectionManager {
  static MqttServerClient createClient({
    required String host,
    required int port,
    required String clientId,
    required void Function() onConnected,
    required void Function() onDisconnected,
    required void Function() onAutoReconnected,
    required void Function(String topic) onSubscribed,
  }) {
    debugPrint(
      '[MqttConnectionManager] Configuring MQTT client for $host:$port ($clientId)...',
    );
    final client = MqttServerClient.withPort(host, clientId, port);
    client.logging(on: false);
    client.keepAlivePeriod = 30;
    client.autoReconnect = true;
    client.resubscribeOnAutoReconnect = true;

    final connMessage = MqttConnectMessage().withClientIdentifier(clientId);
    connMessage.variableHeader?.connectFlags.cleanStart = false;
    client.connectionMessage = connMessage;

    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onAutoReconnected = onAutoReconnected;
    client.onSubscribed = onSubscribed;
    return client;
  }
}
