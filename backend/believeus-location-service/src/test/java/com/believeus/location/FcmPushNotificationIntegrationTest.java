package com.believeus.location;

import com.believeus.location.entity.UserEntity;
import com.believeus.location.model.dto.ChatMessageDto;
import com.believeus.location.model.dto.GiftingRequest;
import com.believeus.location.model.dto.GiftingResponse;
import com.believeus.location.model.dto.RegisterRequest;
import com.believeus.location.repository.ChatMessageRepository;
import com.believeus.location.repository.CoupleSpaceRepository;
import com.believeus.location.repository.GiftTransactionRepository;
import com.believeus.location.repository.UserRepository;
import com.believeus.location.service.AuthService;
import com.believeus.location.service.ChatService;
import com.believeus.location.service.FirebaseMessagingService;
import com.believeus.location.service.GiftingService;
import com.believeus.location.service.PairingService;
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
class FcmPushNotificationIntegrationTest {

    @Autowired
    private AuthService authService;

    @Autowired
    private PairingService pairingService;

    @Autowired
    private ChatService chatService;

    @Autowired
    private GiftingService giftingService;

    @Autowired
    private FirebaseMessagingService firebaseMessagingService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private CoupleSpaceRepository coupleSpaceRepository;

    @Autowired
    private ChatMessageRepository chatMessageRepository;

    @Autowired
    private GiftTransactionRepository giftTransactionRepository;

    @BeforeEach
    void setUp() {
        firebaseMessagingService.getSentNotificationsHistory().clear();
        chatMessageRepository.deleteAll();
        giftTransactionRepository.deleteAll();
        coupleSpaceRepository.deleteAll();
        userRepository.deleteAll();
    }

    @Test
    @DisplayName("FCM Push Notifications: Token Management, Chat, Gifting & Pairing Dispatches")
    void testFcmTokenRegistrationAndEventTriggers() {
        // 1. Register Boyfriend and Girlfriend
        var bfResp = authService.register(RegisterRequest.builder()
                .email("mgmg@believeus.app")
                .password("Password123!")
                .displayName("Mg Mg")
                .role("BOYFRIEND")
                .build());
        String bfId = bfResp.getUser().getId();

        var gfResp = authService.register(RegisterRequest.builder()
                .email("thae@believeus.app")
                .password("Password123!")
                .displayName("Thae Thae")
                .role("GIRLFRIEND")
                .build());
        String gfId = gfResp.getUser().getId();

        // 2. Register FCM Device Tokens for both users
        String bfFcmToken = "fcm_token_mgmg_device_alpha_12345";
        String gfFcmToken = "fcm_token_thae_device_beta_67890";

        authService.updateFcmToken(bfId, bfFcmToken);
        authService.updateFcmToken(gfId, gfFcmToken);

        UserEntity bf = userRepository.findById(bfId).orElseThrow();
        UserEntity gf = userRepository.findById(gfId).orElseThrow();
        assertEquals(bfFcmToken, bf.getFcmToken());
        assertEquals(gfFcmToken, gf.getFcmToken());

        // 3. Pair them via 6-digit invite code and verify FCM Pair Notification
        String code = pairingService.getOrCreateInviteCode(bfId);
        pairingService.pairWithCode(gfId, code);

        List<Map<String, Object>> historyAfterPairing = firebaseMessagingService.getSentNotificationsHistory();
        assertFalse(historyAfterPairing.isEmpty());

        boolean foundPairNotif = historyAfterPairing.stream().anyMatch(record -> {
            @SuppressWarnings("unchecked")
            Map<String, String> data = (Map<String, String>) record.get("data");
            return "COUPLE_PAIRED".equals(data.get("type")) && "/home".equals(data.get("route"));
        });
        assertTrue(foundPairNotif, "Should have dispatched COUPLE_PAIRED FCM notification");

        // 4. Send Chat Love Note and verify FCM Push to partner device
        firebaseMessagingService.getSentNotificationsHistory().clear();

        ChatMessageDto chatDto = ChatMessageDto.builder()
                .senderId(bfId)
                .receiverId(gfId)
                .coupleSpaceId(bf.getCoupleSpaceId() != null ? bf.getCoupleSpaceId() : userRepository.findById(bfId).get().getCoupleSpaceId())
                .type("text")
                .text("I love you more than all the stars tonight ✨❤️")
                .build();
        chatService.sendMessage(chatDto);

        List<Map<String, Object>> historyAfterChat = firebaseMessagingService.getSentNotificationsHistory();
        assertFalse(historyAfterChat.isEmpty());
        Map<String, Object> latestChatNotif = historyAfterChat.get(historyAfterChat.size() - 1);
        assertEquals(gfFcmToken, latestChatNotif.get("targetToken"));
        assertTrue(latestChatNotif.get("title").toString().contains("Mg Mg sent a love note"));
        assertEquals("I love you more than all the stars tonight ✨❤️", latestChatNotif.get("body"));

        @SuppressWarnings("unchecked")
        Map<String, String> chatData = (Map<String, String>) latestChatNotif.get("data");
        assertEquals("CHAT_MESSAGE", chatData.get("type"));
        assertEquals("/chat", chatData.get("route"));

        // 5. Send KPay Gift and verify detailed FCM Gift Push
        firebaseMessagingService.getSentNotificationsHistory().clear();

        String spaceId = userRepository.findById(bfId).get().getCoupleSpaceId();
        GiftingResponse giftResp = giftingService.processPayment(GiftingRequest.builder()
                .senderId(bfId)
                .receiverId(gfId)
                .coupleSpaceId(spaceId)
                .amountMmK(25000)
                .provider("KBZPay")
                .packageTitle("Pink Rose Bouquet 💐")
                .note("For my sweetest flower 🌸")
                .build());

        assertNotNull(giftResp);
        List<Map<String, Object>> historyAfterGift = firebaseMessagingService.getSentNotificationsHistory();
        assertFalse(historyAfterGift.isEmpty());

        boolean foundGiftNotif = historyAfterGift.stream().anyMatch(record -> {
            @SuppressWarnings("unchecked")
            Map<String, String> data = (Map<String, String>) record.get("data");
            return "GIFT_RECEIVED".equals(data.get("type")) && "KBZPay".equals(data.get("provider"));
        });
        assertTrue(foundGiftNotif, "Should have dispatched GIFT_RECEIVED FCM notification with KBZPay details");
    }
}
