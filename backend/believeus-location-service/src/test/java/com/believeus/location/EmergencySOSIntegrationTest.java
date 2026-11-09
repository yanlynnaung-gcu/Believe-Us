package com.believeus.location;

import com.believeus.location.controller.EmergencyController;
import com.believeus.location.entity.CoupleSpaceEntity;
import com.believeus.location.entity.UserEntity;
import com.believeus.location.model.dto.EmergencySOSRequest;
import com.believeus.location.model.dto.EmergencySOSResponse;
import com.believeus.location.repository.CoupleSpaceRepository;
import com.believeus.location.repository.UserRepository;
import com.believeus.location.security.UserPrincipal;
import com.believeus.location.service.FirebaseMessagingService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
class EmergencySOSIntegrationTest {

    @Autowired
    private EmergencyController emergencyController;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private CoupleSpaceRepository coupleSpaceRepository;

    @Autowired
    private FirebaseMessagingService firebaseMessagingService;

    private static final String SPACE_ID = "space_sos_test_001";
    private static final String USER_ID = "usr_sos_sender";
    private static final String PARTNER_ID = "usr_sos_partner";

    @BeforeEach
    void setUp() {
        coupleSpaceRepository.deleteAll();
        userRepository.deleteAll();
        firebaseMessagingService.getSentNotificationsHistory().clear();

        // Create paired couple space
        CoupleSpaceEntity space = CoupleSpaceEntity.builder()
                .id(SPACE_ID)
                .user1Id(USER_ID)
                .user2Id(PARTNER_ID)
                .inviteCode("SOS777")
                .pairedAt(LocalDateTime.now().minusDays(10))
                .anniversaryDate(LocalDateTime.now().minusDays(10))
                .isActive(true)
                .build();
        coupleSpaceRepository.save(space);

        // Create sender user
        UserEntity sender = UserEntity.builder()
                .id(USER_ID)
                .email("sender@believeus.app")
                .displayName("Ko Ko (Sender)")
                .role("BOYFRIEND")
                .coupleSpaceId(SPACE_ID)
                .partnerId(PARTNER_ID)
                .createdAt(LocalDateTime.now())
                .build();
        userRepository.save(sender);

        // Create partner user
        UserEntity partner = UserEntity.builder()
                .id(PARTNER_ID)
                .email("partner@believeus.app")
                .displayName("Thae Thae (Partner)")
                .role("GIRLFRIEND")
                .coupleSpaceId(SPACE_ID)
                .partnerId(USER_ID)
                .createdAt(LocalDateTime.now())
                .build();
        userRepository.save(partner);
    }

    private void authenticateUser(String userId, String spaceId) {
        UserPrincipal principal = new UserPrincipal(
                userId,
                "sender@believeus.app",
                "BOYFRIEND",
                spaceId
        );
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(principal, null, List.of())
        );
    }

    @Test
    @DisplayName("Authenticated user triggers Emergency SOS with precise coordinates, WebSocket broadcast & FCM alert")
    void testEmergencySOS_SuccessfulTriggerAndBroadcast() {
        authenticateUser(USER_ID, SPACE_ID);

        EmergencySOSRequest request = EmergencySOSRequest.builder()
                .latitude(16.8295)
                .longitude(96.1305)
                .timestamp(System.currentTimeMillis())
                .message("🚨 Immediate help! Physical Volume Up SOS triggered.")
                .address("Pyay Road, Kamayut, Yangon")
                .build();

        ResponseEntity<EmergencySOSResponse> response = emergencyController.triggerEmergencySOS(request);

        assertNotNull(response);
        assertEquals(200, response.getStatusCode().value());

        EmergencySOSResponse body = response.getBody();
        assertNotNull(body);
        assertTrue(body.isSuccess());
        assertNotNull(body.getAlertId());
        assertTrue(body.getAlertId().startsWith("sos_"));
        assertEquals(USER_ID, body.getSenderId());
        assertEquals("Ko Ko (Sender)", body.getSenderName());
        assertEquals(PARTNER_ID, body.getPartnerId());
        assertEquals("Thae Thae (Partner)", body.getPartnerName());
        assertEquals(SPACE_ID, body.getCoupleSpaceId());
        assertEquals(16.8295, body.getLatitude());
        assertEquals(96.1305, body.getLongitude());
        assertEquals("ACTIVE_EMERGENCY", body.getStatus());

        // Verify sender's location was updated in DB
        UserEntity updatedSender = userRepository.findById(USER_ID).orElseThrow();
        assertEquals(16.8295, updatedSender.getLastLatitude());
        assertEquals(96.1305, updatedSender.getLastLongitude());
        assertEquals("Pyay Road, Kamayut, Yangon", updatedSender.getLastAddress());

        // Verify High-Priority FCM push notification was dispatched
        List<Map<String, Object>> fcmHistory = firebaseMessagingService.getSentNotificationsHistory();
        assertFalse(fcmHistory.isEmpty());
        Map<String, Object> latestFcm = fcmHistory.get(fcmHistory.size() - 1);
        assertEquals("HIGH", latestFcm.get("priority"));
        assertTrue(latestFcm.get("title").toString().contains("EMERGENCY SOS"));

        @SuppressWarnings("unchecked")
        Map<String, String> dataPayload = (Map<String, String>) latestFcm.get("data");
        assertEquals("EMERGENCY_SOS", dataPayload.get("type"));
        assertEquals("/emergency-alarm", dataPayload.get("route"));
        assertEquals("true", dataPayload.get("alarm"));
    }

    @Test
    @DisplayName("Unpaired user attempting Emergency SOS throws AccessDeniedException")
    void testEmergencySOS_UnpairedUserThrowsAccessDenied() {
        authenticateUser("usr_unpaired", null);

        EmergencySOSRequest request = EmergencySOSRequest.builder()
                .latitude(16.8000)
                .longitude(96.1500)
                .message("SOS")
                .build();

        assertThrows(AccessDeniedException.class, () -> {
            emergencyController.triggerEmergencySOS(request);
        });
    }

    @Test
    @DisplayName("Unauthenticated request attempting Emergency SOS throws AccessDeniedException")
    void testEmergencySOS_UnauthenticatedThrowsAccessDenied() {
        SecurityContextHolder.clearContext();

        EmergencySOSRequest request = EmergencySOSRequest.builder()
                .latitude(16.8000)
                .longitude(96.1500)
                .build();

        assertThrows(AccessDeniedException.class, () -> {
            emergencyController.triggerEmergencySOS(request);
        });
    }
}
