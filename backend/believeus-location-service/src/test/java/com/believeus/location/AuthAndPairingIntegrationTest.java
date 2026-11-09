package com.believeus.location;

import com.believeus.location.model.dto.*;
import com.believeus.location.repository.CoupleSpaceRepository;
import com.believeus.location.repository.UserRepository;
import com.believeus.location.service.AuthService;
import com.believeus.location.service.PairingService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
class AuthAndPairingIntegrationTest {

    @Autowired
    private AuthService authService;

    @Autowired
    private PairingService pairingService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private CoupleSpaceRepository coupleSpaceRepository;

    @Autowired
    private com.believeus.location.repository.EmailOtpRepository emailOtpRepository;

    @Autowired
    private com.believeus.location.service.ChatService chatService;

    @Autowired
    private com.believeus.location.service.GiftingService giftingService;

    @Autowired
    private com.believeus.location.repository.ChatMessageRepository chatMessageRepository;

    @Autowired
    private com.believeus.location.repository.GiftTransactionRepository giftTransactionRepository;

    @BeforeEach
    void setUp() {
        chatMessageRepository.deleteAll();
        giftTransactionRepository.deleteAll();
        coupleSpaceRepository.deleteAll();
        userRepository.deleteAll();
        emailOtpRepository.deleteAll();
    }

    @Test
    @DisplayName("Boyfriend and Girlfriend register with real accounts and pair successfully")
    void testRealUserRegistrationAndPairing() {
        // 1. Boyfriend registers
        RegisterRequest bfRequest = RegisterRequest.builder()
                .email("koko@believeus.app")
                .password("lovepass123")
                .displayName("Ko Ko")
                .role("BOYFRIEND")
                .birthday(LocalDate.of(1998, 5, 15))
                .build();

        AuthResponse bfAuth = authService.register(bfRequest);
        assertNotNull(bfAuth.getToken());
        assertNotNull(bfAuth.getUser());
        assertEquals("Ko Ko", bfAuth.getUser().getDisplayName());
        assertEquals("BOYFRIEND", bfAuth.getUser().getRole());
        String bfUserId = bfAuth.getUser().getId();

        // 2. Girlfriend registers
        RegisterRequest gfRequest = RegisterRequest.builder()
                .email("thaengelay@believeus.app")
                .password("mylove456")
                .displayName("Thae Nge Lay")
                .role("GIRLFRIEND")
                .birthday(LocalDate.of(2000, 8, 20))
                .build();

        AuthResponse gfAuth = authService.register(gfRequest);
        assertNotNull(gfAuth.getToken());
        assertNotNull(gfAuth.getUser());
        assertEquals("Thae Nge Lay", gfAuth.getUser().getDisplayName());
        assertEquals("GIRLFRIEND", gfAuth.getUser().getRole());
        String gfUserId = gfAuth.getUser().getId();

        // 3. Boyfriend generates invite code (strict 6-digit numeric)
        String inviteCode = pairingService.getOrCreateInviteCode(bfUserId);
        assertNotNull(inviteCode);
        assertEquals(6, inviteCode.length());
        assertTrue(inviteCode.matches("^\\d{6}$"), "Invite code must be pure 6-digit numeric string");

        // Non-6-digit codes are rejected
        assertThrows(IllegalArgumentException.class, () -> {
            pairingService.pairWithCode(gfUserId, "12345");
        });
        assertThrows(IllegalArgumentException.class, () -> {
            pairingService.pairWithCode(gfUserId, "ABCDEF");
        });
        assertThrows(IllegalArgumentException.class, () -> {
            pairingService.pairWithCode(gfUserId, "1234567");
        });

        // 4. Girlfriend pairs using Boyfriend's invite code
        CoupleSpaceResponse pairedSpace = pairingService.pairWithCode(gfUserId, inviteCode);
        assertNotNull(pairedSpace);
        assertNotNull(pairedSpace.getId());

        // 5. Verify Couple Summary returns both real database profiles
        CoupleSummaryResponse summary = pairingService.getCoupleSummary(pairedSpace.getId(), gfUserId);
        assertNotNull(summary);
        assertEquals(pairedSpace.getId(), summary.getCoupleSpaceId());
        assertEquals("Thae Nge Lay", summary.getMyProfile().getDisplayName());
        assertEquals("GIRLFRIEND", summary.getMyProfile().getRole());
        assertEquals("Ko Ko", summary.getPartnerProfile().getDisplayName());
        assertEquals("BOYFRIEND", summary.getPartnerProfile().getRole());
    }

    @Test
    @DisplayName("Login with valid password succeeds and invalid password fails")
    void testLoginFlow() {
        authService.register(RegisterRequest.builder()
                .email("login_test@believeus.app")
                .password("secret123")
                .displayName("Romeo")
                .role("BOYFRIEND")
                .build());

        AuthResponse loginSuccess = authService.login(LoginRequest.builder()
                .email("login_test@believeus.app")
                .password("secret123")
                .build());
        assertNotNull(loginSuccess.getToken());
        assertEquals("Romeo", loginSuccess.getUser().getDisplayName());

        assertThrows(IllegalArgumentException.class, () -> {
            authService.login(LoginRequest.builder()
                    .email("login_test@believeus.app")
                    .password("wrongpassword")
                    .build());
        });
    }

    @Test
    @DisplayName("100% Free Email OTP: Send OTP, verify with 6-digit code, and log in")
    void testEmailOtpFlow() {
        String testEmail = "honey@believeus.app";

        // 1. Send OTP
        var sendResp = authService.sendEmailOtp(SendEmailOtpRequest.builder().email(testEmail).build());
        assertNotNull(sendResp);
        assertTrue(sendResp.containsKey("message"));

        // 2. Fetch the generated OTP from DB
        var otpEntity = emailOtpRepository.findTopByEmailIgnoreCaseAndVerifiedFalseOrderByCreatedAtDesc(testEmail)
                .orElseThrow(() -> new AssertionError("OTP was not saved in repository"));
        assertNotNull(otpEntity.getOtpCode());
        assertEquals(6, otpEntity.getOtpCode().length());

        // 3. Verify with incorrect OTP fails
        assertThrows(IllegalArgumentException.class, () -> {
            authService.verifyEmailOtp(VerifyEmailOtpRequest.builder()
                    .email(testEmail)
                    .otp("000000")
                    .build());
        });

        // 4. Verify with correct 6-digit code succeeds (Brand New User)
        AuthResponse verifyResp = authService.verifyEmailOtp(VerifyEmailOtpRequest.builder()
                .email(testEmail)
                .otp(otpEntity.getOtpCode())
                .build());
        assertNotNull(verifyResp.getToken());
        assertNotNull(verifyResp.getUser());
        assertEquals(testEmail, verifyResp.getUser().getEmail());
        assertTrue(verifyResp.getIsNewUser());

        // 5. Subsequent OTP verification for existing user returns isNewUser = false
        authService.sendEmailOtp(SendEmailOtpRequest.builder().email(testEmail).build());
        var secondOtp = emailOtpRepository.findTopByEmailIgnoreCaseAndVerifiedFalseOrderByCreatedAtDesc(testEmail).orElseThrow();
        AuthResponse secondVerify = authService.verifyEmailOtp(VerifyEmailOtpRequest.builder()
                .email(testEmail)
                .otp(secondOtp.getOtpCode())
                .build());
        assertNotNull(secondVerify.getToken());
        assertFalse(secondVerify.getIsNewUser());
    }

    @Test
    @DisplayName("Real-Time Chat Unread Badge: Sending text & voice messages updates unread count and mark-read resets it")
    void testChatUnreadTracking() {
        String spaceId = "space_chat_test";
        String senderId = "usr_koko";
        String receiverId = "usr_thaethae";

        // 1. Initial unread count should be 0
        assertEquals(0, chatService.getUnreadCount(spaceId, receiverId));

        // 2. Send first message (TEXT)
        chatService.sendMessage(ChatMessageDto.builder()
                .senderId(senderId)
                .receiverId(receiverId)
                .coupleSpaceId(spaceId)
                .type("text")
                .text("Good evening darling ❤️")
                .build());

        assertEquals(1, chatService.getUnreadCount(spaceId, receiverId));

        // 3. Send second message (VOICE)
        chatService.sendMessage(ChatMessageDto.builder()
                .senderId(senderId)
                .receiverId(receiverId)
                .coupleSpaceId(spaceId)
                .type("voice")
                .audioDurationSeconds(5)
                .build());

        assertEquals(2, chatService.getUnreadCount(spaceId, receiverId));

        // 4. Mark messages as read -> unread count resets to 0
        long marked = chatService.markMessagesAsRead(spaceId, receiverId);
        assertEquals(2, marked);
        assertEquals(0, chatService.getUnreadCount(spaceId, receiverId));
    }

    @Test
    @DisplayName("Unseen Gift Box Badge: Gifting persists transaction as PAID and unseen count is cleared on seen")
    void testGiftingUnseenTracking() {
        String spaceId = "space_gift_test";
        String senderId = "usr_koko";
        String receiverId = "usr_thaethae";

        // 1. Initial unseen count should be 0
        assertEquals(0, giftingService.getUnseenGiftsCount(spaceId, receiverId));

        // 2. Send gift
        GiftingResponse response = giftingService.processPayment(GiftingRequest.builder()
                .senderId(senderId)
                .receiverId(receiverId)
                .coupleSpaceId(spaceId)
                .packageTitle("Pink Rose Bouquet 💐")
                .amountMmK(25000)
                .provider("KBZPay")
                .note("Forever yours ❤️")
                .build());

        assertNotNull(response.getId());
        assertEquals("PAID", response.getStatus());

        // Verify unseen gift count
        assertEquals(1, giftingService.getUnseenGiftsCount(spaceId, receiverId));

        // 3. Mark gifts as seen
        long seenCount = giftingService.markGiftsAsSeen(spaceId, receiverId);
        assertEquals(1, seenCount);
        assertEquals(0, giftingService.getUnseenGiftsCount(spaceId, receiverId));
    }
}
