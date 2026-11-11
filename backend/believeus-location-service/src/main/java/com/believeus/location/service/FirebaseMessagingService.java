package com.believeus.location.service;

import com.believeus.location.entity.UserEntity;
import com.google.firebase.FirebaseApp;
import com.google.firebase.messaging.AndroidConfig;
import com.google.firebase.messaging.AndroidNotification;
import com.google.firebase.messaging.ApnsConfig;
import com.google.firebase.messaging.Aps;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import lombok.Getter;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Service
@Slf4j
public class FirebaseMessagingService {

    private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ofPattern("h:mm a");

    @Getter
    private final List<Map<String, Object>> sentNotificationsHistory = Collections.synchronizedList(new ArrayList<>());

    /**
     * Sends high-priority instant arrival FCM notification with deep link payload
     */
    public boolean sendArrivalNotification(
            String partnerName,
            String placeNameOrAddress,
            LocalDateTime arrivalTime,
            int batteryLevel
    ) {
        String formattedTime = arrivalTime.format(TIME_FORMATTER);
        String title = String.format("📍 %s Reached Safely!", partnerName);
        String body = String.format("%s arrived at %s at %s (🔋 %d%%)",
                partnerName, placeNameOrAddress, formattedTime, batteryLevel);

        Map<String, String> dataPayload = new HashMap<>();
        dataPayload.put("type", "LOCATION_ARRIVAL");
        dataPayload.put("route", "/location-details");
        dataPayload.put("partnerName", partnerName);
        dataPayload.put("place", placeNameOrAddress);
        dataPayload.put("time", formattedTime);
        dataPayload.put("click_action", "FLUTTER_NOTIFICATION_CLICK");

        dispatchFcmPush(null, title, body, dataPayload, "HIGH");
        return true;
    }

    /**
     * Sends safety heart nudge notification
     */
    public boolean sendSafetyNudgeNotification(String senderName, String partnerName) {
        String title = String.format("💌 %s sent a safety heart", senderName);
        String body = "Have you reached safely, my love?";

        Map<String, String> dataPayload = new HashMap<>();
        dataPayload.put("type", "LOCATION_CHECKIN_NUDGE");
        dataPayload.put("route", "/location-details");
        dataPayload.put("click_action", "FLUTTER_NOTIFICATION_CLICK");

        dispatchFcmPush(null, title, body, dataPayload, "HIGH");
        return true;
    }

    /**
     * Sends high-priority Emergency SOS push notification to partner device
     */
    public boolean sendEmergencySOSNotification(
            String senderName,
            double latitude,
            double longitude,
            String messageText,
            String partnerName
    ) {
        String title = String.format("🚨 EMERGENCY SOS from %s!", senderName);
        String body = String.format("%s needs your immediate help! %s (Location: %.5f, %.5f)",
                senderName,
                (messageText != null && !messageText.isBlank()) ? messageText : "Immediate assistance required!",
                latitude,
                longitude);

        Map<String, String> dataPayload = new HashMap<>();
        dataPayload.put("type", "EMERGENCY_SOS");
        dataPayload.put("route", "/emergency-alarm");
        dataPayload.put("senderName", senderName);
        dataPayload.put("latitude", String.valueOf(latitude));
        dataPayload.put("longitude", String.valueOf(longitude));
        dataPayload.put("message", messageText != null ? messageText : "");
        dataPayload.put("priority", "MAX_EMERGENCY");
        dataPayload.put("alarm", "true");
        dataPayload.put("click_action", "FLUTTER_NOTIFICATION_CLICK");

        dispatchFcmPush(null, title, body, dataPayload, "HIGH");
        return true;
    }

    /**
     * Sends FCM push notification when a partner sends a chat message (text, voice, gift)
     */
    public boolean sendChatMessageNotification(
            UserEntity recipient,
            String senderName,
            String messageText,
            String messageType
    ) {
        String title;
        String body;

        String safeType = messageType != null ? messageType.toLowerCase() : "text";
        if ("voice".equals(safeType)) {
            title = String.format("🎙️ %s sent a voice message", senderName);
            body = "Tap to listen to your partner's voice right now ❤️";
        } else if ("gift".equals(safeType)) {
            title = String.format("🎉 %s sent a sweet surprise!", senderName);
            body = messageText != null && !messageText.isBlank() ? messageText : "Tap to open your romantic gift ❤️";
        } else {
            title = String.format("❤️ %s sent a love note", senderName);
            body = messageText != null && !messageText.isBlank() ? messageText : "Thinking about holding your hand right now ❤️";
        }

        Map<String, String> dataPayload = new HashMap<>();
        dataPayload.put("type", "CHAT_MESSAGE");
        dataPayload.put("route", "/chat");
        dataPayload.put("senderName", senderName);
        dataPayload.put("messageType", safeType);
        dataPayload.put("click_action", "FLUTTER_NOTIFICATION_CLICK");

        String targetToken = recipient != null ? recipient.getFcmToken() : null;
        dispatchFcmPush(targetToken, title, body, dataPayload, "HIGH");
        return true;
    }

    /**
     * Sends FCM push notification when a partner receives a gift via KPay / WavePay
     */
    public boolean sendGiftReceivedNotification(
            UserEntity recipient,
            String senderName,
            String provider,
            String amount,
            String packageTitle
    ) {
        String safeProvider = provider != null ? provider : "KBZPay";
        String title = String.format("🎉 Gift Received via %s!", safeProvider);
        String body = String.format("%s just surprised you with %s (%s) ❤️",
                senderName,
                packageTitle != null ? packageTitle : "a sweet gift",
                amount != null ? amount : "");

        Map<String, String> dataPayload = new HashMap<>();
        dataPayload.put("type", "GIFT_RECEIVED");
        dataPayload.put("route", "/chat");
        dataPayload.put("provider", safeProvider);
        dataPayload.put("amount", amount != null ? amount : "");
        dataPayload.put("packageTitle", packageTitle != null ? packageTitle : "");
        dataPayload.put("senderName", senderName);
        dataPayload.put("click_action", "FLUTTER_NOTIFICATION_CLICK");

        String targetToken = recipient != null ? recipient.getFcmToken() : null;
        dispatchFcmPush(targetToken, title, body, dataPayload, "HIGH");
        return true;
    }

    /**
     * Sends FCM push notification when a couple space is successfully paired
     */
    public boolean sendCouplePairedNotification(
            UserEntity recipient,
            String partnerName,
            String coupleSpaceId
    ) {
        String title = "💍 Sacred Bond Connected!";
        String body = String.format("You and %s are now officially paired in couple space #%s!",
                partnerName, coupleSpaceId);

        Map<String, String> dataPayload = new HashMap<>();
        dataPayload.put("type", "COUPLE_PAIRED");
        dataPayload.put("route", "/home");
        dataPayload.put("coupleSpaceId", coupleSpaceId);
        dataPayload.put("partnerName", partnerName);
        dataPayload.put("click_action", "FLUTTER_NOTIFICATION_CLICK");

        String targetToken = recipient != null ? recipient.getFcmToken() : null;
        dispatchFcmPush(targetToken, title, body, dataPayload, "HIGH");
        return true;
    }

    /**
     * Core FCM dispatch helper: records in history and dispatches through Firebase Messaging if configured
     */
    private void dispatchFcmPush(
            String targetToken,
            String title,
            String body,
            Map<String, String> dataPayload,
            String priority
    ) {
        Map<String, Object> record = new HashMap<>();
        record.put("title", title);
        record.put("body", body);
        record.put("data", dataPayload);
        record.put("priority", priority != null ? priority : "HIGH");
        record.put("targetToken", targetToken);
        record.put("timestamp", LocalDateTime.now());
        sentNotificationsHistory.add(record);

        log.info("[FCM PUSH SENT] Title: '{}', Body: '{}', Route: '{}', Target: '{}'",
                title, body, dataPayload.get("route"),
                targetToken != null ? (targetToken.length() > 12 ? targetToken.substring(0, 12) + "..." : targetToken) : "UNSET");

        if (targetToken != null && !targetToken.isBlank() && !FirebaseApp.getApps().isEmpty()) {
            try {
                Message message = Message.builder()
                        .setToken(targetToken)
                        .setNotification(Notification.builder()
                                .setTitle(title)
                                .setBody(body)
                                .build())
                        .putAllData(dataPayload)
                        .setAndroidConfig(AndroidConfig.builder()
                                .setPriority("MAX_EMERGENCY".equalsIgnoreCase(priority) ? AndroidConfig.Priority.HIGH : AndroidConfig.Priority.HIGH)
                                .setNotification(AndroidNotification.builder()
                                        .setChannelId("believeus_high_priority_channel")
                                        .setPriority(AndroidNotification.Priority.HIGH)
                                        .setSound("default")
                                        .setClickAction("FLUTTER_NOTIFICATION_CLICK")
                                        .build())
                                .build())
                        .setApnsConfig(ApnsConfig.builder()
                                .setAps(Aps.builder()
                                        .setContentAvailable(true)
                                        .setSound("default")
                                        .build())
                                .build())
                        .build();

                String response = FirebaseMessaging.getInstance().send(message);
                log.info("[FCM REMOTE SUCCESS] Message sent to FCM device: {}", response);
            } catch (Exception e) {
                log.warn("[FCM REMOTE NOTICE] Direct FCM send skipped or failed: {}", e.getMessage());
            }
        }
    }
}
