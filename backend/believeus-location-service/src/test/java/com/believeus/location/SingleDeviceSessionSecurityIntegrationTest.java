package com.believeus.location;

import com.believeus.location.model.dto.*;
import com.believeus.location.repository.UserRepository;
import com.believeus.location.service.AuthService;
import com.believeus.location.websocket.SyncWebSocketHandler;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;

import java.time.LocalDate;

import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("dev")
class SingleDeviceSessionSecurityIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private AuthService authService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private SyncWebSocketHandler syncWebSocketHandler;

    @Autowired
    private ObjectMapper objectMapper;

    @BeforeEach
    void setUp() {
        userRepository.deleteAll();
    }

    @Test
    @DisplayName("Single-device session security intercepts login from secondary device when primary device is active")
    void testSingleDeviceLoginInterceptionAndApprovalFlow() throws Exception {
        // 1. Register a user
        RegisterRequest registerReq = RegisterRequest.builder()
                .email("device.test@believeus.app")
                .password("securePassword123")
                .displayName("Ko Ko")
                .role("BOYFRIEND")
                .birthday(LocalDate.of(1998, 1, 1))
                .deviceId("device_primary_001")
                .deviceName("Primary Pixel 8")
                .build();

        AuthResponse regAuth = authService.register(registerReq);
        assertNotNull(regAuth.getToken());
        String userId = regAuth.getUser().getId();
        String primaryToken = regAuth.getToken();

        // 2. Simulate primary device opening a WebSocket connection
        WebSocketSession mockSession = Mockito.mock(WebSocketSession.class);
        Mockito.when(mockSession.getId()).thenReturn("ws_session_primary");
        Mockito.when(mockSession.isOpen()).thenReturn(true);
        syncWebSocketHandler.afterConnectionEstablished(mockSession);

        String subscribePayload = objectMapper.writeValueAsString(java.util.Map.of(
                "action", "SUBSCRIBE",
                "userId", userId
        ));
        syncWebSocketHandler.handleMessage(mockSession, new TextMessage(subscribePayload));
        assertTrue(syncWebSocketHandler.isUserOnline(userId), "User must be online on primary device");

        // 3. Secondary device attempts login with the same credentials
        LoginRequest secondaryLoginReq = LoginRequest.builder()
                .email("device.test@believeus.app")
                .password("securePassword123")
                .deviceId("device_secondary_002")
                .deviceName("iPad Pro 13")
                .build();

        String loginResponseContent = mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(secondaryLoginReq)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.requiresApproval").value(true))
                .andExpect(jsonPath("$.loginTicketId").isNotEmpty())
                .andReturn().getResponse().getContentAsString();

        AuthResponse interceptedAuth = objectMapper.readValue(loginResponseContent, AuthResponse.class);
        String ticketId = interceptedAuth.getLoginTicketId();
        assertNotNull(ticketId);

        // 4. Secondary device polls ticket status -> status is PENDING
        mockMvc.perform(get("/api/v1/auth/login-ticket/" + ticketId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("PENDING"))
                .andExpect(jsonPath("$.requiresApproval").value(true));

        // 5. Primary device resolves ticket -> APPROVE
        ResolveLoginTicketRequest approveReq = ResolveLoginTicketRequest.builder()
                .approved(true)
                .build();

        mockMvc.perform(post("/api/v1/auth/login-ticket/" + ticketId + "/resolve")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + primaryToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(approveReq)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("APPROVED"));

        // 6. Secondary device polls again -> APPROVED with new JWT token
        mockMvc.perform(get("/api/v1/auth/login-ticket/" + ticketId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("APPROVED"))
                .andExpect(jsonPath("$.requiresApproval").value(false))
                .andExpect(jsonPath("$.token").isNotEmpty())
                .andExpect(jsonPath("$.user.id").value(userId));
    }

    @Test
    @DisplayName("Primary device can deny secondary device login attempt")
    void testSingleDeviceLoginDenialFlow() throws Exception {
        RegisterRequest registerReq = RegisterRequest.builder()
                .email("deny.test@believeus.app")
                .password("securePassword123")
                .displayName("Thae Thae")
                .role("GIRLFRIEND")
                .birthday(LocalDate.of(2000, 2, 2))
                .deviceId("device_primary_100")
                .deviceName("Primary iPhone 15")
                .build();

        AuthResponse regAuth = authService.register(registerReq);
        String userId = regAuth.getUser().getId();
        String primaryToken = regAuth.getToken();

        // Connect WS
        WebSocketSession mockSession = Mockito.mock(WebSocketSession.class);
        Mockito.when(mockSession.getId()).thenReturn("ws_session_deny");
        Mockito.when(mockSession.isOpen()).thenReturn(true);
        syncWebSocketHandler.afterConnectionEstablished(mockSession);
        syncWebSocketHandler.handleMessage(mockSession, new TextMessage(objectMapper.writeValueAsString(java.util.Map.of(
                "action", "SUBSCRIBE",
                "userId", userId
        ))));

        // Secondary login
        LoginRequest secondaryLogin = LoginRequest.builder()
                .email("deny.test@believeus.app")
                .password("securePassword123")
                .deviceId("device_unauthorized_200")
                .deviceName("Stranger Device")
                .build();

        String res = mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(secondaryLogin)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.requiresApproval").value(true))
                .andReturn().getResponse().getContentAsString();

        AuthResponse authRes = objectMapper.readValue(res, AuthResponse.class);

        // Deny ticket
        ResolveLoginTicketRequest denyReq = ResolveLoginTicketRequest.builder()
                .approved(false)
                .build();

        mockMvc.perform(post("/api/v1/auth/login-ticket/" + authRes.getLoginTicketId() + "/resolve")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + primaryToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(denyReq)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("REJECTED"));

        // Poll -> REJECTED
        mockMvc.perform(get("/api/v1/auth/login-ticket/" + authRes.getLoginTicketId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("REJECTED"))
                .andExpect(jsonPath("$.token").doesNotExist());
    }

    @Test
    @DisplayName("Forgot password endpoint returns 405 Method Not Allowed when called with GET")
    void testForgotPasswordMethodNotAllowed() throws Exception {
        mockMvc.perform(get("/api/v1/auth/forgot-password/send-otp"))
                .andExpect(status().isMethodNotAllowed())
                .andExpect(jsonPath("$.status").value(405))
                .andExpect(jsonPath("$.error").value("Method Not Allowed"));
    }
}
