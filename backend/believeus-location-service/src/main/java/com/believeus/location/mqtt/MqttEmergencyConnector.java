package com.believeus.location.mqtt;

import com.believeus.location.config.MqttProperties;
import com.believeus.location.entity.CoupleSpaceEntity;
import com.believeus.location.entity.UserEntity;
import com.believeus.location.model.dto.EmergencySOSRequest;
import com.believeus.location.repository.CoupleSpaceRepository;
import com.believeus.location.repository.UserRepository;
import com.believeus.location.service.FirebaseMessagingService;
import com.believeus.location.websocket.SyncWebSocketHandler;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.eclipse.paho.client.mqttv3.*;
import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;
import org.springframework.context.SmartLifecycle;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
@RequiredArgsConstructor
@Slf4j
public class MqttEmergencyConnector implements SmartLifecycle, MqttCallbackExtended {

    private final MqttProperties mqttProperties;
    private final UserRepository userRepository;
    private final CoupleSpaceRepository coupleSpaceRepository;
    private final SyncWebSocketHandler syncWebSocketHandler;
    private final FirebaseMessagingService firebaseMessagingService;
    private final ObjectMapper objectMapper = new ObjectMapper();

    private MqttAsyncClient mqttClient;
    private boolean running = false;
    private static final String EMERGENCY_SUBSCRIPTION_TOPIC = "couple/+/emergency";
    private static final Pattern TOPIC_PATTERN = Pattern.compile("^couple/([^/]+)/emergency$");

    @Override
    public void start() {
        if (!mqttProperties.isEnabled()) {
            log.info("[MQTT Connector] MQTT integration is disabled.");
            return;
        }

        try {
            String brokerUrl = mqttProperties.getBrokerUrl();
            String clientId = mqttProperties.getClientId() + "-" + UUID.randomUUID().toString().substring(0, 5);

            mqttClient = new MqttAsyncClient(brokerUrl, clientId, new MemoryPersistence());
            mqttClient.setCallback(this);

            MqttConnectOptions options = new MqttConnectOptions();
            options.setCleanSession(mqttProperties.isCleanSession()); // QoS 1 persistent session
            options.setAutomaticReconnect(true);
            options.setKeepAliveInterval(mqttProperties.getKeepAliveSeconds());
            options.setConnectionTimeout(5);

            log.info("[MQTT Connector] Connecting to broker {} with clientId: {} (cleanSession={})...",
                    brokerUrl, clientId, mqttProperties.isCleanSession());

            IMqttToken token = mqttClient.connect(options);
            token.waitForCompletion(6000);
            running = true;
            log.info("[MQTT Connector] Connected to MQTT broker successfully.");
        } catch (Throwable t) {
            log.warn("[MQTT Connector] Could not immediately connect to MQTT broker ({}) - automatic retry will follow: {}",
                    mqttProperties.getBrokerUrl(), t.getMessage());
            running = true; // Still marked running so reconnect callbacks or publish resilience works
        }
    }

    @Override
    public void connectComplete(boolean reconnect, String serverURI) {
        log.info("[MQTT Connector] Connection established with {} (reconnect: {}). Subscribing to: {} (QoS 1)...",
                serverURI, reconnect, EMERGENCY_SUBSCRIPTION_TOPIC);
        try {
            if (mqttClient != null && mqttClient.isConnected()) {
                mqttClient.subscribe(EMERGENCY_SUBSCRIPTION_TOPIC, 1);
                log.info("[MQTT Connector] Successfully subscribed to topic {} with QoS 1.", EMERGENCY_SUBSCRIPTION_TOPIC);
            }
        } catch (MqttException e) {
            log.error("[MQTT Connector] Failed to subscribe to topic {}: {}", EMERGENCY_SUBSCRIPTION_TOPIC, e.getMessage());
        }
    }

    @Override
    public void connectionLost(Throwable cause) {
        log.warn("[MQTT Connector] MQTT Connection lost: {}. Automatic reconnect in progress...",
                cause != null ? cause.getMessage() : "unknown");
    }

    @Override
    public void messageArrived(String topic, MqttMessage message) {
        String payloadStr = new String(message.getPayload(), StandardCharsets.UTF_8);
        log.warn("[MQTT EMERGENCY MESSAGE ARRIVED] Topic: '{}', QoS: {}, Payload: {}", topic, message.getQos(), payloadStr);

        try {
            Matcher matcher = TOPIC_PATTERN.matcher(topic);
            if (!matcher.matches()) {
                log.debug("[MQTT Connector] Ignoring message from non-emergency topic: {}", topic);
                return;
            }
            String coupleSpaceId = matcher.group(1);

            @SuppressWarnings("unchecked")
            Map<String, Object> data = objectMapper.readValue(payloadStr, Map.class);

            String senderId = (String) data.get("senderId");
            String senderName = (String) data.getOrDefault("senderName", "Partner");
            String partnerId = (String) data.get("partnerId");
            Number latNum = (Number) data.getOrDefault("latitude", 0.0);
            Number lngNum = (Number) data.getOrDefault("longitude", 0.0);
            double lat = latNum != null ? latNum.doubleValue() : 0.0;
            double lng = lngNum != null ? lngNum.doubleValue() : 0.0;
            String distressMsg = (String) data.getOrDefault("message", "🚨 EMERGENCY SOS: Immediate assistance required!");
            String address = (String) data.getOrDefault("address", "");

            // 1. Update user coordinate in DB if senderId is known
            if (senderId != null) {
                userRepository.findById(senderId).ifPresent(u -> {
                    u.setLastLatitude(lat);
                    u.setLastLongitude(lng);
                    if (!address.isBlank()) {
                        u.setLastAddress(address);
                    }
                    userRepository.save(u);
                });
            }

            // 2. Resolve partner info
            if (partnerId == null || partnerId.isBlank()) {
                Optional<CoupleSpaceEntity> spaceOpt = coupleSpaceRepository.findById(coupleSpaceId);
                if (spaceOpt.isPresent()) {
                    CoupleSpaceEntity space = spaceOpt.get();
                    partnerId = space.getUser1Id().equals(senderId) ? space.getUser2Id() : space.getUser1Id();
                }
            }

            String partnerName = "Partner";
            if (partnerId != null) {
                partnerName = userRepository.findById(partnerId)
                        .map(UserEntity::getDisplayName)
                        .orElse("Partner");
            }

            // 3. Simultaneously dispatch FCM Push to partner
            firebaseMessagingService.sendEmergencySOSNotification(senderName, lat, lng, distressMsg, partnerName);

            // 4. Bridge to WebSocket topic room: /topic/couple.{coupleSpaceId}.emergency
            syncWebSocketHandler.broadcastToCoupleTopic(coupleSpaceId, "emergency", "EMERGENCY_ALERT", data);

        } catch (Exception e) {
            log.error("[MQTT Connector] Error processing emergency message on topic {}: {}", topic, e.getMessage(), e);
        }
    }

    @Override
    public void deliveryComplete(IMqttDeliveryToken token) {
        log.debug("[MQTT Connector] Delivery ACK received for message ID: {}", token.getMessageId());
    }

    /**
     * Publishes an emergency SOS payload to topic couple/{coupleSpaceId}/emergency with QoS 1
     */
    public boolean publishEmergencyAlert(String coupleSpaceId,
                                         EmergencySOSRequest request,
                                         String alertId,
                                         String senderId,
                                         String senderName,
                                         String partnerId) {
        String topic = "couple/" + coupleSpaceId + "/emergency";
        try {
            Map<String, Object> payload = new HashMap<>();
            payload.put("alertId", alertId);
            payload.put("type", "EMERGENCY_SOS");
            payload.put("senderId", senderId);
            payload.put("senderName", senderName);
            payload.put("partnerId", partnerId);
            payload.put("coupleSpaceId", coupleSpaceId);
            payload.put("latitude", request != null && request.getLatitude() != null ? request.getLatitude() : 0.0);
            payload.put("longitude", request != null && request.getLongitude() != null ? request.getLongitude() : 0.0);
            payload.put("address", request != null && request.getAddress() != null ? request.getAddress() : "");
            payload.put("timestamp", request != null && request.getTimestamp() != null ? request.getTimestamp() : System.currentTimeMillis());
            payload.put("message", request != null && request.getMessage() != null ? request.getMessage() : "🚨 EMERGENCY SOS: Immediate assistance required!");
            payload.put("status", "ACTIVE_EMERGENCY");

            byte[] jsonBytes = objectMapper.writeValueAsBytes(payload);
            MqttMessage mqttMessage = new MqttMessage(jsonBytes);
            mqttMessage.setQos(1); // QoS 1 (At least once delivery)
            mqttMessage.setRetained(false);

            if (mqttClient != null && mqttClient.isConnected()) {
                mqttClient.publish(topic, mqttMessage);
                log.info("[MQTT Connector] Published Emergency SOS to topic '{}' with QoS 1 (Alert: {})", topic, alertId);
                return true;
            } else {
                log.warn("[MQTT Connector] Client not currently connected to broker. Attempting reconnect / buffer...");
                if (mqttClient != null) {
                    try {
                        mqttClient.reconnect();
                        mqttClient.publish(topic, mqttMessage);
                        return true;
                    } catch (Exception e) {
                        log.warn("[MQTT Connector] Reconnect on publish failed: {}", e.getMessage());
                    }
                }
            }
        } catch (Exception e) {
            log.error("[MQTT Connector] Failed to publish emergency alert to topic {}: {}", topic, e.getMessage(), e);
        }
        return false;
    }

    public boolean isConnected() {
        return mqttClient != null && mqttClient.isConnected();
    }

    @Override
    public void stop() {
        if (mqttClient != null) {
            try {
                if (mqttClient.isConnected()) {
                    mqttClient.disconnectForcibly(1000);
                }
                mqttClient.close();
                log.info("[MQTT Connector] Disconnected from MQTT broker.");
            } catch (Exception e) {
                log.warn("[MQTT Connector] Error closing MQTT client: {}", e.getMessage());
            } finally {
                running = false;
                mqttClient = null;
            }
        }
    }

    @Override
    public boolean isRunning() {
        return running;
    }

    @Override
    public int getPhase() {
        // Starts after the embedded broker starts
        return Integer.MIN_VALUE + 200;
    }
}
