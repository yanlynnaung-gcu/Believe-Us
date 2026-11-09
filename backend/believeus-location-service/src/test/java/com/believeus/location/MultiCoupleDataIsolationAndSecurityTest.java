package com.believeus.location;

import com.believeus.location.entity.ChatMessageEntity;
import com.believeus.location.entity.GiftTransactionEntity;
import com.believeus.location.entity.LocationArrivalLog;
import com.believeus.location.entity.MilestoneEntity;
import com.believeus.location.model.dto.ChatMessageDto;
import com.believeus.location.model.dto.GiftingRequest;
import com.believeus.location.model.dto.LocationHeartbeatRequest;
import com.believeus.location.model.dto.MilestoneDto;
import com.believeus.location.repository.ChatMessageRepository;
import com.believeus.location.repository.GiftTransactionRepository;
import com.believeus.location.repository.LocationArrivalLogRepository;
import com.believeus.location.repository.MilestoneRepository;
import com.believeus.location.security.SecurityContextUtil;
import com.believeus.location.security.UserPrincipal;
import com.believeus.location.service.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;

import java.time.LocalDateTime;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
class MultiCoupleDataIsolationAndSecurityTest {

    @Autowired
    private ChatService chatService;

    @Autowired
    private GiftingService giftingService;

    @Autowired
    private LocationArrivalService locationArrivalService;

    @Autowired
    private MilestoneService milestoneService;

    @Autowired
    private JwtTokenService jwtTokenService;

    @Autowired
    private ChatMessageRepository chatMessageRepository;

    @Autowired
    private GiftTransactionRepository giftTransactionRepository;

    @Autowired
    private LocationArrivalLogRepository arrivalLogRepository;

    @Autowired
    private MilestoneRepository milestoneRepository;

    private static final String SPACE_1 = "space_couple_alpha";
    private static final String USER_1A = "usr_romeo";
    private static final String USER_1B = "usr_juliet";

    private static final String SPACE_2 = "space_couple_beta";
    private static final String USER_2A = "usr_koko";
    private static final String USER_2B = "usr_thaethae";

    @BeforeEach
    void setUp() {
        chatMessageRepository.deleteAll();
        giftTransactionRepository.deleteAll();
        arrivalLogRepository.deleteAll();
        milestoneRepository.deleteAll();
        SecurityContextHolder.clearContext();
    }

    private void authenticateAs(String userId, String email, String role, String coupleSpaceId) {
        UserPrincipal principal = UserPrincipal.builder()
                .userId(userId)
                .email(email)
                .role(role)
                .coupleSpaceId(coupleSpaceId)
                .build();
        UsernamePasswordAuthenticationToken auth =
                new UsernamePasswordAuthenticationToken(principal, null, principal.getAuthorities());
        SecurityContextHolder.getContext().setAuthentication(auth);
    }

    @Test
    @DisplayName("JWT Generation embeds userId, email, role, and coupleSpaceId claims")
    void testJwtClaims() {
        String token = jwtTokenService.generateToken(USER_1A, "romeo@believeus.app", "BOYFRIEND", SPACE_1);
        assertNotNull(token);

        assertEquals(USER_1A, jwtTokenService.extractUserId(token));
        assertEquals(SPACE_1, jwtTokenService.extractCoupleSpaceId(token));
        assertEquals("BOYFRIEND", jwtTokenService.extractRole(token));
        assertEquals("romeo@believeus.app", jwtTokenService.extractEmail(token));
        assertTrue(jwtTokenService.validateToken(token));
    }

    @Test
    @DisplayName("Strict Couple Isolation: Chat messages between Couple 1 and Couple 2 never leak")
    void testChatMessageIsolation() {
        // Couple 1 sends message
        chatService.sendMessage(ChatMessageDto.builder()
                .senderId(USER_1A)
                .receiverId(USER_1B)
                .coupleSpaceId(SPACE_1)
                .type("text")
                .text("Secret letter for Juliet ❤️")
                .build());

        // Couple 2 sends message
        chatService.sendMessage(ChatMessageDto.builder()
                .senderId(USER_2A)
                .receiverId(USER_2B)
                .coupleSpaceId(SPACE_2)
                .type("text")
                .text("Secret letter for Thae Thae 💖")
                .build());

        List<ChatMessageDto> space1Msgs = chatService.getMessages(SPACE_1);
        List<ChatMessageDto> space2Msgs = chatService.getMessages(SPACE_2);

        assertEquals(1, space1Msgs.size());
        assertEquals("Secret letter for Juliet ❤️", space1Msgs.get(0).getText());
        assertEquals(SPACE_1, space1Msgs.get(0).getCoupleSpaceId());

        assertEquals(1, space2Msgs.size());
        assertEquals("Secret letter for Thae Thae 💖", space2Msgs.get(0).getText());
        assertEquals(SPACE_2, space2Msgs.get(0).getCoupleSpaceId());
    }

    @Test
    @DisplayName("Strict Couple Isolation: Gift transactions between Couple 1 and Couple 2 are strictly partitioned")
    void testGiftTransactionIsolation() {
        giftingService.processPayment(GiftingRequest.builder()
                .senderId(USER_1A)
                .receiverId(USER_1B)
                .coupleSpaceId(SPACE_1)
                .packageTitle("Roses for Juliet 🌹")
                .amountMmK(30000)
                .provider("KBZPay")
                .build());

        giftingService.processPayment(GiftingRequest.builder()
                .senderId(USER_2A)
                .receiverId(USER_2B)
                .coupleSpaceId(SPACE_2)
                .packageTitle("Strawberries for Thae Thae 🍓")
                .amountMmK(15000)
                .provider("WavePay")
                .build());

        assertEquals(1, giftingService.getUnseenGiftsCount(SPACE_1, USER_1B));
        assertEquals(0, giftingService.getUnseenGiftsCount(SPACE_1, USER_2B));

        assertEquals(1, giftingService.getUnseenGiftsCount(SPACE_2, USER_2B));
        assertEquals(0, giftingService.getUnseenGiftsCount(SPACE_2, USER_1B));
    }

    @Test
    @DisplayName("Strict Couple Isolation: Milestones are isolated per CoupleSpace")
    void testMilestoneIsolation() {
        milestoneService.addMilestone(SPACE_1, MilestoneDto.builder()
                .title("Romeo & Juliet 100 Days")
                .targetDate(LocalDateTime.now().plusDays(50))
                .iconEmoji("💍")
                .category("Anniversary")
                .build());

        milestoneService.addMilestone(SPACE_2, MilestoneDto.builder()
                .title("Ko Ko & Thae Thae Trip to Bagan")
                .targetDate(LocalDateTime.now().plusDays(20))
                .iconEmoji("✈️")
                .category("Trip Countdown")
                .build());

        List<MilestoneDto> space1Milestones = milestoneService.getMilestones(SPACE_1);
        List<MilestoneDto> space2Milestones = milestoneService.getMilestones(SPACE_2);

        assertEquals(1, space1Milestones.size());
        assertEquals("Romeo & Juliet 100 Days", space1Milestones.get(0).getTitle());
        assertEquals(SPACE_1, space1Milestones.get(0).getCoupleSpaceId());

        assertEquals(1, space2Milestones.size());
        assertEquals("Ko Ko & Thae Thae Trip to Bagan", space2Milestones.get(0).getTitle());
        assertEquals(SPACE_2, space2Milestones.get(0).getCoupleSpaceId());
    }

    @Test
    @DisplayName("Strict Couple Isolation: Location Heartbeat persists coupleSpaceId and isolates logs")
    void testLocationHeartbeatIsolation() {
        LocationHeartbeatRequest hb1 = LocationHeartbeatRequest.builder()
                .partnerId(USER_1A)
                .partnerName("Romeo")
                .coupleSpaceId(SPACE_1)
                .latitude(16.8000)
                .longitude(96.1500)
                .batteryLevel(95)
                .build();
        locationArrivalService.processHeartbeat(hb1);

        LocationHeartbeatRequest hb2 = LocationHeartbeatRequest.builder()
                .partnerId(USER_2A)
                .partnerName("Ko Ko")
                .coupleSpaceId(SPACE_2)
                .latitude(16.8500)
                .longitude(96.1200)
                .batteryLevel(90)
                .build();
        locationArrivalService.processHeartbeat(hb2);

        List<LocationArrivalLog> space1Logs = locationArrivalService.getTodayArrivalLogs(SPACE_1, USER_1A);
        List<LocationArrivalLog> space2Logs = locationArrivalService.getTodayArrivalLogs(SPACE_2, USER_2A);

        assertEquals(1, space1Logs.size());
        assertEquals(SPACE_1, space1Logs.get(0).getCoupleSpaceId());
        assertEquals(USER_1A, space1Logs.get(0).getUserId());

        assertEquals(1, space2Logs.size());
        assertEquals(SPACE_2, space2Logs.get(0).getCoupleSpaceId());
        assertEquals(USER_2A, space2Logs.get(0).getUserId());
    }

    @Test
    @DisplayName("SecurityContext: User authenticated in Couple 1 is denied access to Couple 2 space")
    void testCrossCoupleAccessDenied() {
        authenticateAs(USER_1A, "romeo@believeus.app", "BOYFRIEND", SPACE_1);

        assertEquals(USER_1A, SecurityContextUtil.getCurrentUserId());
        assertEquals(SPACE_1, SecurityContextUtil.getCurrentCoupleSpaceId());

        // Validating own space succeeds
        assertDoesNotThrow(() -> SecurityContextUtil.validateCoupleSpaceAccess(SPACE_1));

        // Validating another couple's space throws AccessDeniedException
        assertThrows(AccessDeniedException.class, () -> SecurityContextUtil.validateCoupleSpaceAccess(SPACE_2));
    }
}
