package com.believeus.location.controller;

import com.believeus.location.model.dto.MilestoneDto;
import com.believeus.location.security.SecurityContextUtil;
import com.believeus.location.service.MilestoneService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/milestones")
@CrossOrigin(originPatterns = "*", allowCredentials = "true")
@RequiredArgsConstructor
@Slf4j
public class MilestoneController {

    private final MilestoneService milestoneService;

    @GetMapping
    public ResponseEntity<List<MilestoneDto>> getMilestones(
            @RequestParam(value = "coupleSpaceId", required = false) String paramSpaceId
    ) {
        String coupleSpaceId = resolveCoupleSpaceId(paramSpaceId);
        return ResponseEntity.ok(milestoneService.getMilestones(coupleSpaceId));
    }

    @PostMapping
    public ResponseEntity<MilestoneDto> addMilestone(
            @RequestParam(value = "coupleSpaceId", required = false) String paramSpaceId,
            @Valid @RequestBody MilestoneDto request
    ) {
        String coupleSpaceId = resolveCoupleSpaceId(paramSpaceId != null ? paramSpaceId : request.getCoupleSpaceId());
        return ResponseEntity.ok(milestoneService.addMilestone(coupleSpaceId, request));
    }

    @DeleteMapping("/{milestoneId}")
    public ResponseEntity<Map<String, Object>> deleteMilestone(
            @PathVariable String milestoneId,
            @RequestParam(value = "coupleSpaceId", required = false) String paramSpaceId
    ) {
        String coupleSpaceId = resolveCoupleSpaceId(paramSpaceId);
        milestoneService.deleteMilestone(coupleSpaceId, milestoneId);
        return ResponseEntity.ok(Map.of("success", true, "milestoneId", milestoneId));
    }

    private String resolveCoupleSpaceId(String explicitSpaceId) {
        String tokenSpaceId = SecurityContextUtil.getCurrentCoupleSpaceId();
        if (tokenSpaceId != null && !tokenSpaceId.isBlank()) {
            if (explicitSpaceId != null && !explicitSpaceId.isBlank() && !tokenSpaceId.equals(explicitSpaceId)) {
                SecurityContextUtil.validateCoupleSpaceAccess(explicitSpaceId);
            }
            return tokenSpaceId;
        }
        if (explicitSpaceId != null && !explicitSpaceId.isBlank()) {
            return explicitSpaceId;
        }
        throw new IllegalArgumentException("CoupleSpace ID is required but was not provided in token or parameters.");
    }
}
