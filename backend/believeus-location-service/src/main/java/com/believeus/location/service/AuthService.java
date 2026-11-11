package com.believeus.location.service;

import com.believeus.location.entity.EmailOtpEntity;
import com.believeus.location.entity.UserEntity;
import com.believeus.location.model.LoginTicket;
import com.believeus.location.model.dto.*;
import com.believeus.location.repository.EmailOtpRepository;
import com.believeus.location.repository.UserRepository;
import com.believeus.location.websocket.SyncWebSocketHandler;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {

    private final UserRepository userRepository;
    private final EmailOtpRepository emailOtpRepository;
    private final EmailService emailService;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenService jwtTokenService;
    private final SyncWebSocketHandler syncWebSocketHandler;
    private final LoginTicketService loginTicketService;

    @Transactional
    public Map<String, Object> sendEmailOtp(SendEmailOtpRequest request) {
        String email = request.getEmail().trim().toLowerCase();
        emailService.generateAndSendOtp(email);
        return Map.of(
                "message", "A 6-digit verification code has been sent to " + email,
                "expiresInSeconds", 300
        );
    }

    @Transactional
    public Map<String, Object> sendForgotPasswordOtp(SendEmailOtpRequest request) {
        String email = request.getEmail().trim().toLowerCase();
        if (!userRepository.existsByEmailIgnoreCase(email)) {
            throw new IllegalArgumentException("No account found with this email: " + email + ". Please check your email or sign up.");
        }
        emailService.generateAndSendOtp(email);
        return Map.of(
                "message", "A 6-digit verification code has been sent to " + email,
                "expiresInSeconds", 300
        );
    }

    @Transactional
    public Map<String, Object> resetPassword(ResetPasswordRequest request) {
        String normalizedEmail = request.getEmail().trim().toLowerCase();
        String code = request.getOtp().trim();

        UserEntity user = userRepository.findByEmailIgnoreCase(normalizedEmail)
                .orElseThrow(() -> new IllegalArgumentException("No account found with this email: " + normalizedEmail));

        EmailOtpEntity otp = emailOtpRepository
                .findTopByEmailIgnoreCaseAndVerifiedFalseOrderByCreatedAtDesc(normalizedEmail)
                .orElseThrow(() -> new IllegalArgumentException("No active verification code found for " + normalizedEmail + ". Please request a new code."));

        if (otp.getExpiresAt().isBefore(LocalDateTime.now())) {
            throw new IllegalArgumentException("Verification code has expired. Please request a new code.");
        }

        if (!otp.getOtpCode().equals(code)) {
            throw new IllegalArgumentException("Invalid 6-digit verification code. Please check your email.");
        }

        otp.setVerified(true);
        emailOtpRepository.save(otp);

        user.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        user.setUpdatedAt(LocalDateTime.now());
        userRepository.save(user);

        log.info("Password successfully reset for user: {} ({})", user.getDisplayName(), user.getEmail());

        return Map.of(
                "success", true,
                "message", "Password reset successfully! Please sign in with your new password."
        );
    }

    @Transactional
    public AuthResponse verifyEmailOtp(VerifyEmailOtpRequest request) {
        String normalizedEmail = request.getEmail().trim().toLowerCase();
        String code = request.getOtp().trim();

        EmailOtpEntity otp = emailOtpRepository
                .findTopByEmailIgnoreCaseAndVerifiedFalseOrderByCreatedAtDesc(normalizedEmail)
                .orElseThrow(() -> new IllegalArgumentException("No active verification code found for " + normalizedEmail + ". Please request a new code."));

        if (otp.getExpiresAt().isBefore(LocalDateTime.now())) {
            throw new IllegalArgumentException("Verification code has expired. Please request a new code.");
        }

        if (!otp.getOtpCode().equals(code)) {
            throw new IllegalArgumentException("Invalid 6-digit verification code. Please check your email.");
        }

        otp.setVerified(true);
        emailOtpRepository.save(otp);

        UserEntity user = userRepository.findByEmailIgnoreCase(normalizedEmail).orElse(null);
        boolean isNew = false;

        if (user == null) {
            isNew = true;
            String userId = "usr_" + UUID.randomUUID().toString().substring(0, 10);
            user = UserEntity.builder()
                    .id(userId)
                    .email(normalizedEmail)
                    .displayName("My Love")
                    .role("BOYFRIEND")
                    .batteryLevel(100)
                    .isOnline(true)
                    .createdAt(LocalDateTime.now())
                    .updatedAt(LocalDateTime.now())
                    .build();
            user = userRepository.save(user);
            log.info("Created new user via Email OTP: {} ({})", user.getId(), user.getEmail());
        } else {
            user.setIsOnline(true);
            userRepository.save(user);
            log.info("Existing user verified via Email OTP: {} ({})", user.getId(), user.getEmail());
        }

        String token = jwtTokenService.generateToken(user.getId(), user.getEmail(), user.getRole(), user.getCoupleSpaceId());

        return AuthResponse.builder()
                .token(token)
                .user(UserProfileDto.fromEntity(user))
                .isNewUser(isNew)
                .message(isNew ? "Email verified! Please complete your couple profile." : "Welcome back, " + user.getDisplayName() + "!")
                .build();
    }

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        String normalizedEmail = request.getEmail().trim().toLowerCase();
        if (userRepository.existsByEmailIgnoreCase(normalizedEmail)) {
            throw new IllegalArgumentException("An account with this email already exists. Please log in.");
        }

        String role = request.getRole() != null ? request.getRole().trim().toUpperCase() : "BOYFRIEND";
        if (!"BOYFRIEND".equals(role) && !"GIRLFRIEND".equals(role)) {
            role = "BOYFRIEND";
        }

        String userId = "usr_" + UUID.randomUUID().toString().substring(0, 10);
        String encodedPassword = passwordEncoder.encode(request.getPassword());

        UserEntity user = UserEntity.builder()
                .id(userId)
                .email(normalizedEmail)
                .passwordHash(encodedPassword)
                .displayName(request.getDisplayName().trim())
                .role(role)
                .birthday(request.getBirthday())
                .avatarUrl(request.getAvatarUrl())
                .batteryLevel(100)
                .isOnline(true)
                .currentDeviceId(request.getDeviceId())
                .currentDeviceName(request.getDeviceName() != null ? request.getDeviceName() : "Mobile App")
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();

        UserEntity saved = userRepository.save(user);
        String token = jwtTokenService.generateToken(saved.getId(), saved.getEmail(), saved.getRole(), saved.getCoupleSpaceId());

        log.info("Registered new user: {} ({}), role: {}", saved.getDisplayName(), saved.getEmail(), saved.getRole());

        return AuthResponse.builder()
                .token(token)
                .user(UserProfileDto.fromEntity(saved))
                .message("Account created successfully!")
                .build();
    }

    @Transactional
    public AuthResponse login(LoginRequest request) {
        String normalizedEmail = request.getEmail().trim().toLowerCase();
        UserEntity user = userRepository.findByEmailIgnoreCase(normalizedEmail)
                .orElseThrow(() -> new IllegalArgumentException("No account found with this email. Please sign up."));

        if (user.getPasswordHash() == null || !passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new IllegalArgumentException("Incorrect password. Please try again.");
        }

        // Strict Single-Device Session Security:
        // If an active session exists on another device, intercept and require primary device approval.
        boolean isOnline = syncWebSocketHandler.isUserOnline(user.getId());
        boolean isDifferentDevice = user.getCurrentDeviceId() != null
                && !user.getCurrentDeviceId().isBlank()
                && request.getDeviceId() != null
                && !request.getDeviceId().isBlank()
                && !user.getCurrentDeviceId().equals(request.getDeviceId());

        if (isOnline && isDifferentDevice) {
            LoginTicket ticket = loginTicketService.createTicket(
                    user.getId(),
                    request.getDeviceId(),
                    request.getDeviceName()
            );

            // Broadcast real-time WebSocket alert event to active primary device
            syncWebSocketHandler.sendToUser(user.getId(), "DEVICE_LOGIN_ATTEMPT", Map.of(
                    "ticketId", ticket.getTicketId(),
                    "deviceId", request.getDeviceId(),
                    "deviceName", ticket.getTargetDeviceName(),
                    "attemptedAt", System.currentTimeMillis()
            ));

            log.info("[Single-Device Security] Intercepted login attempt for user '{}' from device '{}' ({}). Approval requested from primary device '{}'.",
                    user.getId(), request.getDeviceId(), ticket.getTargetDeviceName(), user.getCurrentDeviceId());

            return AuthResponse.builder()
                    .requiresApproval(true)
                    .loginTicketId(ticket.getTicketId())
                    .message("Login attempt detected from a new device. Approval requested from your active primary device.")
                    .build();
        }

        if (request.getDeviceId() != null && !request.getDeviceId().isBlank()) {
            user.setCurrentDeviceId(request.getDeviceId());
            user.setCurrentDeviceName(request.getDeviceName() != null ? request.getDeviceName() : "Mobile App");
        }
        user.setIsOnline(true);
        userRepository.save(user);

        String token = jwtTokenService.generateToken(user.getId(), user.getEmail(), user.getRole(), user.getCoupleSpaceId());
        log.info("User logged in: {} ({})", user.getDisplayName(), user.getEmail());

        return AuthResponse.builder()
                .token(token)
                .user(UserProfileDto.fromEntity(user))
                .requiresApproval(false)
                .message("Welcome back, " + user.getDisplayName() + "!")
                .build();
    }

    @Transactional(readOnly = true)
    public LoginTicketStatusResponse getLoginTicketStatus(String ticketId) {
        LoginTicket ticket = loginTicketService.getTicket(ticketId);
        if (ticket == null) {
            throw new IllegalArgumentException("Login ticket not found or expired: " + ticketId);
        }

        return LoginTicketStatusResponse.builder()
                .ticketId(ticket.getTicketId())
                .status(ticket.getStatus().name())
                .requiresApproval(ticket.getStatus() == LoginTicket.TicketStatus.PENDING)
                .token(ticket.getToken())
                .user(ticket.getUserProfile())
                .message(ticket.getStatus() == LoginTicket.TicketStatus.APPROVED
                        ? "Login approved!"
                        : ticket.getStatus() == LoginTicket.TicketStatus.REJECTED
                        ? "Login request was denied by your active device."
                        : ticket.getStatus() == LoginTicket.TicketStatus.EXPIRED
                        ? "Login request timed out."
                        : "Awaiting approval from your active device.")
                .build();
    }

    @Transactional
    public Map<String, Object> resolveLoginTicket(String ticketId, String currentUserId, boolean approved) {
        LoginTicket ticket = loginTicketService.getTicket(ticketId);
        if (ticket == null) {
            throw new IllegalArgumentException("Login ticket not found or expired: " + ticketId);
        }
        if (!ticket.getUserId().equals(currentUserId)) {
            throw new IllegalArgumentException("Unauthorized to resolve this login ticket.");
        }
        if (ticket.getStatus() != LoginTicket.TicketStatus.PENDING) {
            throw new IllegalStateException("Ticket already resolved with status: " + ticket.getStatus());
        }

        if (approved) {
            UserEntity user = userRepository.findById(currentUserId)
                    .orElseThrow(() -> new IllegalArgumentException("User not found: " + currentUserId));

            user.setCurrentDeviceId(ticket.getTargetDeviceId());
            user.setCurrentDeviceName(ticket.getTargetDeviceName());
            userRepository.save(user);

            String token = jwtTokenService.generateToken(user.getId(), user.getEmail(), user.getRole(), user.getCoupleSpaceId());
            UserProfileDto profile = UserProfileDto.fromEntity(user);

            loginTicketService.resolveTicket(ticketId, true, token, profile);

            // Notify active primary device that this session is terminated due to takeover
            syncWebSocketHandler.sendToUser(currentUserId, "SESSION_TERMINATED", Map.of(
                    "reason", "LOGIN_ON_ANOTHER_DEVICE",
                    "deviceName", ticket.getTargetDeviceName(),
                    "message", "Your account was logged in from " + ticket.getTargetDeviceName() + "."
            ));

            log.info("[Single-Device Security] Login ticket '{}' APPROVED for user '{}' on new device '{}'.",
                    ticketId, currentUserId, ticket.getTargetDeviceName());

            return Map.of("success", true, "status", "APPROVED", "message", "New device login approved.");
        } else {
            loginTicketService.resolveTicket(ticketId, false, null, null);
            log.info("[Single-Device Security] Login ticket '{}' REJECTED for user '{}'.", ticketId, currentUserId);
            return Map.of("success", true, "status", "REJECTED", "message", "New device login rejected.");
        }
    }

    @Transactional
    public AuthResponse googleAuth(GoogleAuthRequest request) {
        String normalizedEmail = request.getEmail().trim().toLowerCase();
        UserEntity user = userRepository.findByEmailIgnoreCase(normalizedEmail).orElse(null);

        if (user == null) {
            String role = request.getRole() != null ? request.getRole().trim().toUpperCase() : "BOYFRIEND";
            if (!"BOYFRIEND".equals(role) && !"GIRLFRIEND".equals(role)) {
                role = "BOYFRIEND";
            }

            String userId = "usr_" + UUID.randomUUID().toString().substring(0, 10);
            user = UserEntity.builder()
                    .id(userId)
                    .email(normalizedEmail)
                    .displayName(request.getDisplayName().trim())
                    .role(role)
                    .avatarUrl(request.getPhotoUrl())
                    .birthday(request.getBirthday())
                    .batteryLevel(100)
                    .isOnline(true)
                    .createdAt(LocalDateTime.now())
                    .updatedAt(LocalDateTime.now())
                    .build();
        } else {
            user.setIsOnline(true);
            if (request.getPhotoUrl() != null && user.getAvatarUrl() == null) {
                user.setAvatarUrl(request.getPhotoUrl());
            }
        }

        UserEntity saved = userRepository.save(user);
        String token = jwtTokenService.generateToken(saved.getId(), saved.getEmail(), saved.getRole(), saved.getCoupleSpaceId());
        log.info("Google sign-in for user: {} ({})", saved.getDisplayName(), saved.getEmail());

        return AuthResponse.builder()
                .token(token)
                .user(UserProfileDto.fromEntity(saved))
                .message("Google authentication successful!")
                .build();
    }

    @Transactional(readOnly = true)
    public UserProfileDto getUserProfile(String userId) {
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));
        return UserProfileDto.fromEntity(user);
    }

    @Transactional
    public UserProfileDto updateProfile(String userId, Map<String, Object> updates) {
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));

        if (updates.containsKey("displayName")) {
            String name = (String) updates.get("displayName");
            if (name != null && !name.isBlank()) {
                user.setDisplayName(name.trim());
            }
        }

        if (updates.containsKey("role")) {
            String role = (String) updates.get("role");
            if (role != null && ("BOYFRIEND".equalsIgnoreCase(role) || "GIRLFRIEND".equalsIgnoreCase(role))) {
                user.setRole(role.toUpperCase());
            }
        }

        if (updates.containsKey("birthday")) {
            Object bday = updates.get("birthday");
            if (bday instanceof String str && !str.isBlank()) {
                try {
                    user.setBirthday(LocalDate.parse(str.substring(0, 10)));
                } catch (Exception ignored) {}
            }
        }

        if (updates.containsKey("avatarUrl")) {
            user.setAvatarUrl((String) updates.get("avatarUrl"));
        }

        UserEntity saved = userRepository.save(user);
        UserProfileDto dto = UserProfileDto.fromEntity(saved);

        // Broadcast to couple space if paired
        if (saved.getCoupleSpaceId() != null) {
            syncWebSocketHandler.broadcastToCoupleSpace(saved.getCoupleSpaceId(), "PROFILE_UPDATED", dto);
        }

        return dto;
    }
}
