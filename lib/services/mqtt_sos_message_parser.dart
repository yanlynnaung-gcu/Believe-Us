import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:thae_nge_lay/features/emergency/domain/models/emergency_sos_model.dart';

class MqttSosMessageParser {
  static void processUpdates({
    required List<MqttReceivedMessage<MqttMessage?>> messages,
    required String? currentUserId,
    required void Function(EmergencySOSAlert alert) onAlertReceived,
  }) {
    for (final msg in messages) {
      final pubMsg = msg.payload as MqttPublishMessage;
      final payloadString = MqttPublishPayload.bytesToStringAsString(
        pubMsg.payload.message,
      );

      debugPrint(
        '[MqttSosMessageParser] Received message on ${msg.topic} with QoS ${pubMsg.header?.qos}: $payloadString',
      );

      try {
        final Map<String, dynamic> json =
            jsonDecode(payloadString) as Map<String, dynamic>;
        final alert = EmergencySOSAlert.fromJson(json);

        if (alert.senderId == currentUserId) {
          debugPrint('[MqttSosMessageParser] Ignoring self-published alert.');
          continue;
        }

        onAlertReceived(alert);
      } catch (e) {
        debugPrint(
            '[MqttSosMessageParser] Failed to parse emergency payload: $e');
      }
    }
  }
}
