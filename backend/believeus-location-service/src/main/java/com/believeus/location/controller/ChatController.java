package com.believeus.location.controller;

import com.believeus.location.model.dto.ChatMessageDto;
import com.believeus.location.security.SecurityContextUtil;
import com.believeus.location.service.ChatService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/chat")
@CrossOrigin(originPatterns = "*", allowCredentials = "true")
@RequiredArgsConstructor
@Slf4j
public class ChatController {

    private final ChatService chatService;

    private static final String AUDIO_DIR = "./uploads/audio";

    @PostMapping(value = {"/voice", "/upload-audio", "/audio"}, consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<Map<String, Object>> uploadVoiceMessage(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "coupleSpaceId", required = false) String coupleSpaceId
    ) throws IOException {
        String tokenSpaceId = SecurityContextUtil.getCurrentCoupleSpaceId();
        String effectiveSpaceId = tokenSpaceId != null ? tokenSpaceId : coupleSpaceId;
        if (effectiveSpaceId != null && !effectiveSpaceId.isBlank()) {
            SecurityContextUtil.validateCoupleSpaceAccess(effectiveSpaceId);
        }

        if (file.isEmpty()) {
            throw new IllegalArgumentException("Cannot upload empty voice memo.");
        }

        File dir = new File(AUDIO_DIR);
        if (!dir.exists()) {
            dir.mkdirs();
        }

        String originalFilename = file.getOriginalFilename();
        String ext = "m4a";
        if (originalFilename != null && originalFilename.contains(".")) {
            ext = originalFilename.substring(originalFilename.lastIndexOf(".") + 1).toLowerCase();
        }

        String filename = "voice_" + UUID.randomUUID().toString().substring(0, 8) + "_" + System.currentTimeMillis() + "." + ext;
        Path targetPath = Paths.get(AUDIO_DIR, filename);

        Files.copy(file.getInputStream(), targetPath, StandardCopyOption.REPLACE_EXISTING);

        String relativeUrl = "/uploads/audio/" + filename;
        log.info("Saved voice audio file: {}", relativeUrl);

        return ResponseEntity.ok(Map.of(
                "audioUrl", relativeUrl,
                "audioPath", relativeUrl,
                "filename", filename
        ));
    }

    @GetMapping("/messages/{coupleSpaceId}")
    public ResponseEntity<List<ChatMessageDto>> getMessages(@PathVariable String coupleSpaceId) {
        String tokenSpaceId = SecurityContextUtil.getCurrentCoupleSpaceId();
        String effectiveSpaceId = tokenSpaceId != null ? tokenSpaceId : coupleSpaceId;
        SecurityContextUtil.validateCoupleSpaceAccess(coupleSpaceId);
        return ResponseEntity.ok(chatService.getMessages(effectiveSpaceId));
    }

    @PostMapping("/messages")
    public ResponseEntity<ChatMessageDto> sendMessage(@RequestBody ChatMessageDto dto) {
        String currentUserId = SecurityContextUtil.getCurrentUserId();
        String currentSpaceId = SecurityContextUtil.getCurrentCoupleSpaceId();

        // Enforce sender identity and couple space isolation from verified token context
        if (currentUserId != null && !currentUserId.isBlank()) {
            dto.setSenderId(currentUserId);
        }
        if (currentSpaceId != null && !currentSpaceId.isBlank()) {
            dto.setCoupleSpaceId(currentSpaceId);
        }

        return ResponseEntity.ok(chatService.sendMessage(dto));
    }

    @GetMapping("/unread/{coupleSpaceId}")
    public ResponseEntity<Map<String, Object>> getUnreadCount(
            @PathVariable String coupleSpaceId,
            @RequestParam(required = false) String receiverId
    ) {
        SecurityContextUtil.validateCoupleSpaceAccess(coupleSpaceId);
        String currentUserId = SecurityContextUtil.getCurrentUserId();
        String effectiveReceiver = currentUserId != null ? currentUserId : receiverId;

        long count = chatService.getUnreadCount(coupleSpaceId, effectiveReceiver);
        return ResponseEntity.ok(Map.of(
                "coupleSpaceId", coupleSpaceId,
                "receiverId", effectiveReceiver != null ? effectiveReceiver : "",
                "unreadCount", count
        ));
    }

    @PostMapping("/read/{coupleSpaceId}")
    public ResponseEntity<Map<String, Object>> markMessagesAsRead(
            @PathVariable String coupleSpaceId,
            @RequestParam(required = false) String receiverId
    ) {
        SecurityContextUtil.validateCoupleSpaceAccess(coupleSpaceId);
        String currentUserId = SecurityContextUtil.getCurrentUserId();
        String effectiveReceiver = currentUserId != null ? currentUserId : receiverId;

        long marked = chatService.markMessagesAsRead(coupleSpaceId, effectiveReceiver);
        return ResponseEntity.ok(Map.of(
                "status", "SUCCESS",
                "markedReadCount", marked
        ));
    }
}
