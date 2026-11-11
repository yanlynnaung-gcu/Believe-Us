package com.believeus.location;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpHeaders;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.options;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("dev")
class CorsConfigurationIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    @DisplayName("Preflight OPTIONS request to /api/v1/auth/login returns allowCredentials and matching origin")
    void testAuthPreflightCors() throws Exception {
        mockMvc.perform(options("/api/v1/auth/login")
                        .header(HttpHeaders.ORIGIN, "http://localhost:3000")
                        .header(HttpHeaders.ACCESS_CONTROL_REQUEST_METHOD, "POST")
                        .header(HttpHeaders.ACCESS_CONTROL_REQUEST_HEADERS, "Authorization,Content-Type"))
                .andExpect(status().isOk())
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_ORIGIN, "http://localhost:3000"))
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_CREDENTIALS, "true"));
    }

    @Test
    @DisplayName("Preflight OPTIONS request from Android emulator origin (10.0.2.2) succeeds")
    void testAndroidEmulatorCors() throws Exception {
        mockMvc.perform(options("/api/v1/auth/email/send-otp")
                        .header(HttpHeaders.ORIGIN, "http://10.0.2.2:8080")
                        .header(HttpHeaders.ACCESS_CONTROL_REQUEST_METHOD, "POST")
                        .header(HttpHeaders.ACCESS_CONTROL_REQUEST_HEADERS, "Authorization,Content-Type"))
                .andExpect(status().isOk())
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_ORIGIN, "http://10.0.2.2:8080"))
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_CREDENTIALS, "true"));
    }

    @Test
    @DisplayName("Preflight OPTIONS request from local LAN Wi-Fi origin succeeds")
    void testLocalLanWifiCors() throws Exception {
        mockMvc.perform(options("/api/v1/chat/messages/space_couple_test")
                        .header(HttpHeaders.ORIGIN, "http://192.168.1.6:8080")
                        .header(HttpHeaders.ACCESS_CONTROL_REQUEST_METHOD, "GET")
                        .header(HttpHeaders.ACCESS_CONTROL_REQUEST_HEADERS, "Authorization"))
                .andExpect(status().isOk())
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_ORIGIN, "http://192.168.1.6:8080"))
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_CREDENTIALS, "true"));
    }

    @Test
    @DisplayName("Direct POST with Origin header does not throw 400 Bad Request for allowCredentials with wildcard pattern")
    void testDirectPostWithOriginHeader() throws Exception {
        mockMvc.perform(post("/api/v1/auth/login")
                        .header(HttpHeaders.ORIGIN, "http://localhost:5173")
                        .contentType("application/json")
                        .content("{\"email\":\"invalid@test.com\",\"password\":\"wrong\"}"))
                // Expect 401 Unauthorized or 400 for bad credentials/validation, NOT a CORS 400 IllegalArgumentException
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_ORIGIN, "http://localhost:5173"))
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_CREDENTIALS, "true"));
    }

    @Test
    @DisplayName("POST /api/v1/auth/forgot-password/send-otp is properly mapped and reachable")
    void testForgotPasswordSendOtpEndpointMapping() throws Exception {
        // Preflight check
        mockMvc.perform(options("/api/v1/auth/forgot-password/send-otp")
                        .header(HttpHeaders.ORIGIN, "http://localhost:3000")
                        .header(HttpHeaders.ACCESS_CONTROL_REQUEST_METHOD, "POST")
                        .header(HttpHeaders.ACCESS_CONTROL_REQUEST_HEADERS, "Content-Type"))
                .andExpect(status().isOk())
                .andExpect(header().string(HttpHeaders.ACCESS_CONTROL_ALLOW_ORIGIN, "http://localhost:3000"));

        // POST check: invalid format yields 400 (NOT 404 Not Found)
        mockMvc.perform(post("/api/v1/auth/forgot-password/send-otp")
                        .contentType("application/json")
                        .content("{\"email\":\"\"}"))
                .andExpect(status().isBadRequest());

        // POST check with trailing slash also works
        mockMvc.perform(post("/api/v1/auth/forgot-password/send-otp/")
                        .contentType("application/json")
                        .content("{\"email\":\"\"}"))
                .andExpect(status().isBadRequest());
    }
}
