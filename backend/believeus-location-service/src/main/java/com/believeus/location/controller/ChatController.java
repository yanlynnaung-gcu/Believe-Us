package com.believeus.location.controller;

import com.believeus.location.model.dto.ChatMessageDto;
import com.believeus.location.security.SecurityContextUtil;
import com.believeus.location.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/chat")
@CrossOrigin(originPatterns = "*", allowCredentials = "true")
@RequiredArgsConstructor
public class ChatController {

    private final ChatService chatService;

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
