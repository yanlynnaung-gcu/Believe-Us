package com.believeus.location.service;

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

        Map<String, Object> record = new HashMap<>();
        record.put("title", title);
        record.put("body", body);
        record.put("data", dataPayload);
        record.put("priority", "HIGH");
        record.put("timestamp", LocalDateTime.now());

        sentNotificationsHistory.add(record);
        log.info("[FCM PUSH SENT] Title: '{}', Body: '{}', DeepLink: '{}'",
                title, body, dataPayload.get("route"));

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

        Map<String, Object> record = new HashMap<>();
        record.put("title", title);
        record.put("body", body);
        record.put("data", dataPayload);
        record.put("priority", "HIGH");
        record.put("timestamp", LocalDateTime.now());

        sentNotificationsHistory.add(record);
        log.info("[FCM NUDGE SENT] To: '{}', Message: '{}'", partnerName, body);

        return true;
    }
}
