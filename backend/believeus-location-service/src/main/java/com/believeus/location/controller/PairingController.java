package com.believeus.location.controller;

import com.believeus.location.model.dto.CoupleSpaceResponse;
import com.believeus.location.model.dto.PairRequest;
import com.believeus.location.security.SecurityContextUtil;
import com.believeus.location.service.PairingService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/pairing")
@CrossOrigin(originPatterns = "*", allowCredentials = "true")
@RequiredArgsConstructor
public class PairingController {

    private final PairingService pairingService;

    @GetMapping("/code/{userId}")
    public ResponseEntity<Map<String, String>> getOrCreateInviteCode(@PathVariable String userId) {
        String tokenUserId = SecurityContextUtil.getCurrentUserId();
        String effectiveUserId = tokenUserId != null ? tokenUserId : userId;
        String code = pairingService.getOrCreateInviteCode(effectiveUserId);
        return ResponseEntity.ok(Map.of("inviteCode", code));
    }

    @PostMapping("/generate")
    public ResponseEntity<Map<String, String>> generateInviteCode(@RequestBody Map<String, Object> payload) {
        String tokenUserId = SecurityContextUtil.getCurrentUserId();
        String effectiveUserId = tokenUserId != null ? tokenUserId : (String) payload.get("userId");
        if (effectiveUserId == null || effectiveUserId.isBlank()) {
            throw new IllegalArgumentException("User ID is required to generate invite code.");
        }
        boolean forceNew = Boolean.TRUE.equals(payload.get("forceNew"));
        String code = forceNew
                ? pairingService.forceGenerateNewCode(effectiveUserId)
                : pairingService.getOrCreateInviteCode(effectiveUserId);
        return ResponseEntity.ok(Map.of("inviteCode", code));
    }

    @PostMapping("/pair")
    public ResponseEntity<CoupleSpaceResponse> pairWithCode(@Valid @RequestBody PairRequest request) {
        String tokenUserId = SecurityContextUtil.getCurrentUserId();
        String effectiveUserId = tokenUserId != null ? tokenUserId : request.getCurrentUserId();
        CoupleSpaceResponse response = pairingService.pairWithCode(effectiveUserId, request.getInviteCode());
        return ResponseEntity.ok(response);
    }

    @GetMapping("/status/{userId}")
    public ResponseEntity<Map<String, Object>> getPairingStatus(@PathVariable String userId) {
        String tokenUserId = SecurityContextUtil.getCurrentUserId();
        String effectiveUserId = tokenUserId != null ? tokenUserId : userId;
        return ResponseEntity.ok(pairingService.getPairingStatus(effectiveUserId));
    }

    @PostMapping("/unpair")
    public ResponseEntity<Map<String, Boolean>> unpair(@RequestBody Map<String, String> payload) {
        String tokenSpaceId = SecurityContextUtil.getCurrentCoupleSpaceId();
        String coupleSpaceId = tokenSpaceId != null ? tokenSpaceId : payload.get("coupleSpaceId");
        if (coupleSpaceId != null) {
            SecurityContextUtil.validateCoupleSpaceAccess(coupleSpaceId);
            pairingService.unpair(coupleSpaceId);
        }
        return ResponseEntity.ok(Map.of("success", true));
    }
}
