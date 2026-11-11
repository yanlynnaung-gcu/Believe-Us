package com.believeus.location.controller;

import com.believeus.location.model.dto.*;
import com.believeus.location.service.AuthService;
import com.believeus.location.service.JwtTokenService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/auth")
@CrossOrigin(originPatterns = "*", allowCredentials = "true")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final JwtTokenService jwtTokenService;

    @PostMapping({"/email/send-otp", "/email/send-otp/"})
    public ResponseEntity<Map<String, Object>> sendEmailOtp(@Valid @RequestBody SendEmailOtpRequest request) {
        return ResponseEntity.ok(authService.sendEmailOtp(request));
    }

    @PostMapping({"/forgot-password/send-otp", "/forgot-password/send-otp/"})
    public ResponseEntity<Map<String, Object>> sendForgotPasswordOtp(@Valid @RequestBody SendEmailOtpRequest request) {
        return ResponseEntity.ok(authService.sendForgotPasswordOtp(request));
    }

    @PostMapping({"/reset-password", "/reset-password/"})
    public ResponseEntity<Map<String, Object>> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        return ResponseEntity.ok(authService.resetPassword(request));
    }

    @PostMapping({"/email/verify-otp", "/email/verify-otp/"})
    public ResponseEntity<AuthResponse> verifyEmailOtp(@Valid @RequestBody VerifyEmailOtpRequest request) {
        return ResponseEntity.ok(authService.verifyEmailOtp(request));
    }

    @PostMapping({"/register", "/register/"})
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.ok(authService.register(request));
    }

    @PostMapping({"/login", "/login/"})
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }

    @GetMapping({"/login-ticket/{ticketId}", "/login-ticket/{ticketId}/"})
    public ResponseEntity<LoginTicketStatusResponse> getLoginTicketStatus(@PathVariable String ticketId) {
        return ResponseEntity.ok(authService.getLoginTicketStatus(ticketId));
    }

    @PostMapping({"/login-ticket/{ticketId}/resolve", "/login-ticket/{ticketId}/resolve/"})
    public ResponseEntity<Map<String, Object>> resolveLoginTicket(
            @PathVariable String ticketId,
            @RequestHeader(value = "Authorization", required = false) String authHeader,
            @Valid @RequestBody ResolveLoginTicketRequest request) {
        String userId = jwtTokenService.extractUserId(authHeader);
        if (userId == null) {
            return ResponseEntity.status(401).build();
        }
        return ResponseEntity.ok(authService.resolveLoginTicket(ticketId, userId, request.getApproved()));
    }

    @PostMapping({"/google", "/google/"})
    public ResponseEntity<AuthResponse> googleAuth(@Valid @RequestBody GoogleAuthRequest request) {
        return ResponseEntity.ok(authService.googleAuth(request));
    }

    @GetMapping("/me")
    public ResponseEntity<UserProfileDto> getMe(@RequestHeader(value = "Authorization", required = false) String authHeader) {
        String userId = jwtTokenService.extractUserId(authHeader);
        if (userId == null) {
            return ResponseEntity.status(401).build();
        }
        return ResponseEntity.ok(authService.getUserProfile(userId));
    }
}
