package com.believeus.location.controller;

import com.believeus.location.entity.UserEntity;
import com.believeus.location.model.dto.UserProfileDto;
import com.believeus.location.repository.UserRepository;
import com.believeus.location.security.SecurityContextUtil;
import com.believeus.location.service.AuthService;
import com.believeus.location.websocket.SyncWebSocketHandler;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/users")
@CrossOrigin(originPatterns = "*", allowCredentials = "true")
@RequiredArgsConstructor
@Slf4j
public class UserController {

    private final UserRepository userRepository;
    private final AuthService authService;
    private final SyncWebSocketHandler syncWebSocketHandler;

    private static final String AVATARS_DIR = "./uploads/avatars";

    @PostMapping(value = "/{userId}/avatar", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<Map<String, Object>> uploadAvatar(
            @PathVariable String userId,
            @RequestParam("file") MultipartFile file) throws IOException {

        validateUserOwnership(userId);

        if (file.isEmpty()) {
            throw new IllegalArgumentException("Cannot upload empty profile photo.");
        }

        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));

        File dir = new File(AVATARS_DIR);
        if (!dir.exists()) {
            dir.mkdirs();
        }

        String originalFilename = file.getOriginalFilename();
        String ext = "jpg";
        if (originalFilename != null && originalFilename.contains(".")) {
            ext = originalFilename.substring(originalFilename.lastIndexOf(".") + 1).toLowerCase();
        }

        String filename = userId + "_" + System.currentTimeMillis() + "." + ext;
        Path targetPath = Paths.get(AVATARS_DIR, filename);

        Files.copy(file.getInputStream(), targetPath, StandardCopyOption.REPLACE_EXISTING);

        String relativeUrl = "/uploads/avatars/" + filename;
        user.setAvatarUrl(relativeUrl);
        userRepository.save(user);

        log.info("Saved avatar for user {}: {}", userId, relativeUrl);

        UserProfileDto dto = UserProfileDto.fromEntity(user);

        // Broadcast to partner in couple space if paired
        if (user.getCoupleSpaceId() != null) {
            syncWebSocketHandler.broadcastToCoupleTopic(user.getCoupleSpaceId(), "status", "PROFILE_UPDATED", dto);
        }

        return ResponseEntity.ok(Map.of(
                "avatarUrl", relativeUrl,
                "user", dto
        ));
    }

    @GetMapping("/{userId}")
    public ResponseEntity<UserProfileDto> getUserProfile(@PathVariable String userId) {
        return ResponseEntity.ok(authService.getUserProfile(userId));
    }

    @PutMapping("/{userId}")
    public ResponseEntity<UserProfileDto> updateProfile(
            @PathVariable String userId,
            @RequestBody Map<String, Object> updates) {
        validateUserOwnership(userId);
        return ResponseEntity.ok(authService.updateProfile(userId, updates));
    }

    @PutMapping("/{userId}/fcm-token")
    public ResponseEntity<Map<String, Object>> updateFcmToken(
            @PathVariable String userId,
            @RequestBody Map<String, String> body) {
        validateUserOwnership(userId);
        String token = body.get("fcmToken");
        if (token == null || token.isBlank()) {
            token = body.get("token");
        }
        authService.updateFcmToken(userId, token);
        return ResponseEntity.ok(Map.of(
                "status", "SUCCESS",
                "message", "FCM device registration token registered successfully",
                "userId", userId
        ));
    }

    @PostMapping("/{userId}/fcm-token")
    public ResponseEntity<Map<String, Object>> registerFcmToken(
            @PathVariable String userId,
            @RequestBody Map<String, String> body) {
        return updateFcmToken(userId, body);
    }

    private void validateUserOwnership(String userId) {
        String tokenUserId = SecurityContextUtil.getCurrentUserId();
        if (tokenUserId != null && !tokenUserId.equals(userId)) {
            throw new AccessDeniedException("User Security Isolation: Cannot modify profile of another user");
        }
    }
}
