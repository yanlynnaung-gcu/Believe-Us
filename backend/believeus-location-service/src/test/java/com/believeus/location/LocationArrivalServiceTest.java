package com.believeus.location;

import com.believeus.location.entity.LocationArrivalLog;
import com.believeus.location.entity.TrustedPlace;
import com.believeus.location.model.MovementStatus;
import com.believeus.location.model.dto.AddTrustedPlaceRequest;
import com.believeus.location.model.dto.LocationHeartbeatRequest;
import com.believeus.location.model.dto.SendSafetyNudgeRequest;
import com.believeus.location.repository.LocationArrivalLogRepository;
import com.believeus.location.repository.TrustedPlaceRepository;
import com.believeus.location.service.FirebaseMessagingService;
import com.believeus.location.service.LocationArrivalService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@ActiveProfiles("dev")
class LocationArrivalServiceTest {

    @Autowired
    private LocationArrivalService locationArrivalService;

    @Autowired
    private LocationArrivalLogRepository arrivalLogRepository;

    @Autowired
    private TrustedPlaceRepository trustedPlaceRepository;

    @Autowired
    private FirebaseMessagingService firebaseMessagingService;

    private static final String PARTNER_ID = "partner_thae_nge_lay";
    private static final String PARTNER_NAME = "Thae Nge Lay";

    @BeforeEach
    void setUp() {
        arrivalLogRepository.deleteAll();
        trustedPlaceRepository.deleteAll();
        firebaseMessagingService.getSentNotificationsHistory().clear();

        // Seed default trusted place: Sweet Home at Kamayut (16.8295, 96.1305)
        locationArrivalService.addTrustedPlace(AddTrustedPlaceRequest.builder()
                .userId(PARTNER_ID)
                .name("Sweet Home")
                .iconName("home")
                .latitude(16.8295)
                .longitude(96.1305)
                .radiusMeters(150.0)
                .notifyArrival(true)
                .notifyDeparture(true)
                .build());
    }

    @Test
    @DisplayName("Haversine formula calculates distance accurately")
    void testHaversineDistance() {
        // Distance between Kamayut (16.8295, 96.1305) and Sule Square (16.7795, 96.1603)
        double distance = locationArrivalService.calculateDistanceMeters(
                16.8295, 96.1305,
                16.7795, 96.1603
        );
        assertTrue(distance > 5000 && distance < 8000, "Distance should be ~6.4km");
    }

    @Test
    @DisplayName("Entering within 150m of Trusted Place triggers Arrival Log and high-priority FCM push")
    void testTrustedPlaceArrivalTrigger() {
        LocationHeartbeatRequest heartbeat = LocationHeartbeatRequest.builder()
                .partnerId(PARTNER_ID)
                .partnerName(PARTNER_NAME)
                .latitude(16.8295)
                .longitude(96.1305)
                .speedKmh(0.0)
                .batteryLevel(85)
                .isCharging(true)
                .build();

        LocationArrivalLog arrival = locationArrivalService.processHeartbeat(heartbeat);

        assertNotNull(arrival);
        assertEquals(PARTNER_ID, arrival.getUserId());
        assertEquals("Sweet Home", arrival.getPlaceName());
        assertEquals(MovementStatus.STATIONARY, arrival.getStatus());
        assertEquals(85, arrival.getBatteryLevel());
        assertTrue(arrival.getIsCharging());
        assertNull(arrival.getDepartedAt());

        // Verify FCM push notification triggered with deep link
        List<Map<String, Object>> fcmHistory = firebaseMessagingService.getSentNotificationsHistory();
        assertFalse(fcmHistory.isEmpty(), "FCM notification must be recorded");

        Map<String, Object> latest = fcmHistory.get(fcmHistory.size() - 1);
        assertTrue(latest.get("title").toString().contains(PARTNER_NAME));
        assertTrue(latest.get("title").toString().contains("Reached Safely!"));
        assertTrue(latest.get("body").toString().contains("Sweet Home"));

        @SuppressWarnings("unchecked")
        Map<String, String> data = (Map<String, String>) latest.get("data");
        assertEquals("LOCATION_ARRIVAL", data.get("type"));
        assertEquals("/location-details", data.get("route"));
    }

    @Test
    @DisplayName("Subsequent heartbeats at the same place update lastUpdatedAt without duplicating logs")
    void testSubsequentHeartbeatUpdatesExistingLog() {
        LocationHeartbeatRequest heartbeat1 = LocationHeartbeatRequest.builder()
                .partnerId(PARTNER_ID)
                .partnerName(PARTNER_NAME)
                .latitude(16.8295)
                .longitude(96.1305)
                .speedKmh(0.0)
                .batteryLevel(85)
                .isCharging(true)
                .build();

        locationArrivalService.processHeartbeat(heartbeat1);

        LocationHeartbeatRequest heartbeat2 = LocationHeartbeatRequest.builder()
                .partnerId(PARTNER_ID)
                .partnerName(PARTNER_NAME)
                .latitude(16.8296)
                .longitude(96.1306)
                .speedKmh(0.0)
                .batteryLevel(84)
                .isCharging(true)
                .build();

        LocationArrivalLog updated = locationArrivalService.processHeartbeat(heartbeat2);

        List<LocationArrivalLog> logs = locationArrivalService.getTodayArrivalLogs(PARTNER_ID);
        assertEquals(1, logs.size(), "Should maintain a single active arrival log");
        assertEquals(84, updated.getBatteryLevel());
    }

    @Test
    @DisplayName("Moving > 200m away stamps departedAt and marks status as MOVING")
    void testDepartureDetection() {
        // First arrive at Sweet Home
        LocationHeartbeatRequest arrive = LocationHeartbeatRequest.builder()
                .partnerId(PARTNER_ID)
                .partnerName(PARTNER_NAME)
                .latitude(16.8295)
                .longitude(96.1305)
                .speedKmh(0.0)
                .batteryLevel(90)
                .build();
        locationArrivalService.processHeartbeat(arrive);

        // Move > 200m away (~1km away toward Hledan at 30 km/h)
        LocationHeartbeatRequest depart = LocationHeartbeatRequest.builder()
                .partnerId(PARTNER_ID)
                .partnerName(PARTNER_NAME)
                .latitude(16.8400)
                .longitude(96.1400)
                .speedKmh(30.0)
                .batteryLevel(89)
                .build();
        locationArrivalService.processHeartbeat(depart);

        List<LocationArrivalLog> logs = locationArrivalService.getTodayArrivalLogs(PARTNER_ID);
        assertEquals(1, logs.size());
        LocationArrivalLog departedLog = logs.get(0);

        assertNotNull(departedLog.getDepartedAt(), "departedAt must be stamped");
        assertEquals(MovementStatus.MOVING, departedLog.getStatus());
    }

    @Test
    @DisplayName("Safety Heart Nudge sends sweet check-in notification via FCM")
    void testSendSafetyNudge() {
        boolean sent = locationArrivalService.sendSafetyNudge(SendSafetyNudgeRequest.builder()
                .senderId("usr_alice")
                .partnerId(PARTNER_ID)
                .partnerName(PARTNER_NAME)
                .build());

        assertTrue(sent);
        List<Map<String, Object>> fcmHistory = firebaseMessagingService.getSentNotificationsHistory();
        assertFalse(fcmHistory.isEmpty());

        Map<String, Object> latest = fcmHistory.get(fcmHistory.size() - 1);
        assertTrue(latest.get("body").toString().contains("Have you reached safely"));

        @SuppressWarnings("unchecked")
        Map<String, String> data = (Map<String, String>) latest.get("data");
        assertEquals("LOCATION_CHECKIN_NUDGE", data.get("type"));
        assertEquals("/location-details", data.get("route"));
    }

    @Test
    @DisplayName("Consecutive location pings calculate distance delta and trigger MOVING status if > 20m in < 2 mins")
    void testConsecutivePingMovementDetection() {
        // First ping: Stationary at custom coordinates outside trusted places
        LocationHeartbeatRequest firstPing = LocationHeartbeatRequest.builder()
                .partnerId("moving_user_1")
                .partnerName("Ko Ko")
                .latitude(16.8000)
                .longitude(96.1500)
                .speedKmh(0.0)
                .batteryLevel(95)
                .build();
        LocationArrivalLog log1 = locationArrivalService.processHeartbeat(firstPing);
        assertEquals(MovementStatus.STATIONARY, log1.getStatus());

        // Second ping: moved > 50 meters (16.8005, 96.1505) within consecutive heartbeat
        LocationHeartbeatRequest secondPing = LocationHeartbeatRequest.builder()
                .partnerId("moving_user_1")
                .partnerName("Ko Ko")
                .latitude(16.8006)
                .longitude(96.1506)
                .speedKmh(0.0) // Device reported speed 0, but distance delta is > 20m!
                .batteryLevel(94)
                .build();
        LocationArrivalLog log2 = locationArrivalService.processHeartbeat(secondPing);
        assertEquals(MovementStatus.MOVING, log2.getStatus(), "Distance delta > 20m within 2 minutes must trigger MOVING status");
    }
}
