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

    @PostMapping("/email/send-otp")
    public ResponseEntity<Map<String, Object>> sendEmailOtp(@Valid @RequestBody SendEmailOtpRequest request) {
        return ResponseEntity.ok(authService.sendEmailOtp(request));
    }

    @PostMapping("/email/verify-otp")
    public ResponseEntity<AuthResponse> verifyEmailOtp(@Valid @RequestBody VerifyEmailOtpRequest request) {
        return ResponseEntity.ok(authService.verifyEmailOtp(request));
    }

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.ok(authService.register(request));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }

    @PostMapping("/google")
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
