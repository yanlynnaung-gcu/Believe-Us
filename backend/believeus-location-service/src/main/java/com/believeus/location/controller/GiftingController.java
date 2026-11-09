package com.believeus.location.controller;

import com.believeus.location.model.dto.GiftingRequest;
import com.believeus.location.model.dto.GiftingResponse;
import com.believeus.location.security.SecurityContextUtil;
import com.believeus.location.service.GiftingService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/gifting")
@CrossOrigin(originPatterns = "*", allowCredentials = "true")
@RequiredArgsConstructor
public class GiftingController {

    private final GiftingService giftingService;

    @GetMapping("/packages")
    public ResponseEntity<List<Map<String, Object>>> getAvailablePackages() {
        return ResponseEntity.ok(giftingService.getAvailablePackages());
    }

    @PostMapping("/pay")
    public ResponseEntity<GiftingResponse> processPayment(@RequestBody GiftingRequest request) {
        String currentUserId = SecurityContextUtil.getCurrentUserId();
        String currentSpaceId = SecurityContextUtil.getCurrentCoupleSpaceId();

        if (currentUserId != null && !currentUserId.isBlank()) {
            request.setSenderId(currentUserId);
        }
        if (currentSpaceId != null && !currentSpaceId.isBlank()) {
            request.setCoupleSpaceId(currentSpaceId);
        }

        return ResponseEntity.ok(giftingService.processPayment(request));
    }

    @GetMapping("/unseen/{coupleSpaceId}")
    public ResponseEntity<Map<String, Object>> getUnseenCount(
            @PathVariable String coupleSpaceId,
            @RequestParam(required = false) String receiverId
    ) {
        SecurityContextUtil.validateCoupleSpaceAccess(coupleSpaceId);
        String currentUserId = SecurityContextUtil.getCurrentUserId();
        String effectiveReceiver = currentUserId != null ? currentUserId : receiverId;

        long count = giftingService.getUnseenGiftsCount(coupleSpaceId, effectiveReceiver);
        return ResponseEntity.ok(Map.of(
                "coupleSpaceId", coupleSpaceId,
                "receiverId", effectiveReceiver != null ? effectiveReceiver : "",
                "unseenCount", count
        ));
    }

    @PostMapping("/mark-seen/{coupleSpaceId}")
    public ResponseEntity<Map<String, Object>> markGiftsAsSeen(
            @PathVariable String coupleSpaceId,
            @RequestParam(required = false) String receiverId
    ) {
        SecurityContextUtil.validateCoupleSpaceAccess(coupleSpaceId);
        String currentUserId = SecurityContextUtil.getCurrentUserId();
        String effectiveReceiver = currentUserId != null ? currentUserId : receiverId;

        long count = giftingService.markGiftsAsSeen(coupleSpaceId, effectiveReceiver);
        return ResponseEntity.ok(Map.of(
                "status", "SUCCESS",
                "markedSeenCount", count
        ));
    }
}
