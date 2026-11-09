package com.believeus.location.controller;

import com.believeus.location.entity.CoupleSpaceEntity;
import com.believeus.location.entity.UserEntity;
import com.believeus.location.model.dto.EmergencySOSRequest;
import com.believeus.location.model.dto.EmergencySOSResponse;
import com.believeus.location.mqtt.MqttEmergencyConnector;
import com.believeus.location.repository.CoupleSpaceRepository;
import com.believeus.location.repository.UserRepository;
import com.believeus.location.security.SecurityContextUtil;
import com.believeus.location.service.FirebaseMessagingService;
import com.believeus.location.websocket.SyncWebSocketHandler;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@RestController
@CrossOrigin(originPatterns = "*", allowCredentials = "true")
@RequiredArgsConstructor
@Slf4j
public class EmergencyController {

    private final UserRepository userRepository;
    private final CoupleSpaceRepository coupleSpaceRepository;
    private final SyncWebSocketHandler syncWebSocketHandler;
    private final FirebaseMessagingService firebaseMessagingService;
    private final MqttEmergencyConnector mqttEmergencyConnector;

    @PostMapping({"/api/v1/couple/emergency", "/api/v1/couples/emergency"})
    public ResponseEntity<EmergencySOSResponse> triggerEmergencySOS(
            @RequestBody(required = false) EmergencySOSRequest request) {

        String currentUserId = SecurityContextUtil.requireCurrentUserId();
        String coupleSpaceId = SecurityContextUtil.requireCurrentCoupleSpaceId();

        EmergencySOSRequest safeRequest = request != null ? request : new EmergencySOSRequest();
        double lat = safeRequest.getLatitude() != null ? safeRequest.getLatitude() : 0.0;
        double lng = safeRequest.getLongitude() != null ? safeRequest.getLongitude() : 0.0;
        long timestamp = safeRequest.getTimestamp() != null ? safeRequest.getTimestamp() : System.currentTimeMillis();
        String message = (safeRequest.getMessage() != null && !safeRequest.getMessage().isBlank())
                ? safeRequest.getMessage()
                : "🚨 EMERGENCY SOS: Immediate assistance required!";
        String address = safeRequest.getAddress() != null ? safeRequest.getAddress() : "";

        // 1. Fetch sender info
        Optional<UserEntity> senderOpt = userRepository.findById(currentUserId);
        String senderName = senderOpt.map(UserEntity::getDisplayName).orElse("Partner");
        String partnerId = senderOpt.map(UserEntity::getPartnerId).orElse(null);

        // If partnerId is null on user, resolve from active couple space
        if (partnerId == null || partnerId.isBlank()) {
            Optional<CoupleSpaceEntity> spaceOpt = coupleSpaceRepository.findById(coupleSpaceId);
            if (spaceOpt.isPresent()) {
                CoupleSpaceEntity space = spaceOpt.get();
                partnerId = space.getUser1Id().equals(currentUserId) ? space.getUser2Id() : space.getUser1Id();
            }
        }

        String partnerName = "Partner";
        if (partnerId != null) {
            partnerName = userRepository.findById(partnerId)
                    .map(UserEntity::getDisplayName)
                    .orElse("Partner");
        }

        // 2. Update sender's latest GPS coordinate
        senderOpt.ifPresent(u -> {
            u.setLastLatitude(lat);
            u.setLastLongitude(lng);
            if (!address.isBlank()) {
                u.setLastAddress(address);
            }
            userRepository.save(u);
        });

        String alertId = "sos_" + UUID.randomUUID().toString().substring(0, 8);

        // 3. Build emergency broadcast payload
        Map<String, Object> payload = new HashMap<>();
        payload.put("alertId", alertId);
        payload.put("type", "EMERGENCY_SOS");
        payload.put("senderId", currentUserId);
        payload.put("senderName", senderName);
        payload.put("partnerId", partnerId);
        payload.put("coupleSpaceId", coupleSpaceId);
        payload.put("latitude", lat);
        payload.put("longitude", lng);
        payload.put("address", address);
        payload.put("timestamp", timestamp);
        payload.put("message", message);
        payload.put("status", "ACTIVE_EMERGENCY");

        // 4. Instantly broadcast to couple space dedicated room: /topic/couple.{coupleSpaceId}.emergency
        syncWebSocketHandler.broadcastToCoupleTopic(coupleSpaceId, "emergency", "EMERGENCY_ALERT", payload);

        // 5. Send High-Priority FCM Push Notification to partner
        firebaseMessagingService.sendEmergencySOSNotification(senderName, lat, lng, message, partnerName);

        // 6. Publish via MQTT with QoS 1 for offline resilience
        mqttEmergencyConnector.publishEmergencyAlert(
                coupleSpaceId, safeRequest, alertId, currentUserId, senderName, partnerId);

        log.warn("[EMERGENCY SOS TRIGGERED] Space: {}, Sender: {} ({}), Loc: ({}, {})",
                coupleSpaceId, senderName, currentUserId, lat, lng);

        EmergencySOSResponse response = EmergencySOSResponse.builder()
                .success(true)
                .alertId(alertId)
                .senderId(currentUserId)
                .senderName(senderName)
                .partnerId(partnerId)
                .partnerName(partnerName)
                .coupleSpaceId(coupleSpaceId)
                .latitude(lat)
                .longitude(lng)
                .timestamp(timestamp)
                .message(message)
                .address(address)
                .status("ACTIVE_EMERGENCY")
                .build();

        return ResponseEntity.ok(response);
    }
}
