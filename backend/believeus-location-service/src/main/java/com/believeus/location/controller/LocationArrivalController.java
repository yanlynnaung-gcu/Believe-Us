package com.believeus.location.controller;

import com.believeus.location.entity.LocationArrivalLog;
import com.believeus.location.entity.TrustedPlace;
import com.believeus.location.model.dto.AddTrustedPlaceRequest;
import com.believeus.location.model.dto.ArrivalLogResponse;
import com.believeus.location.model.dto.LocationHeartbeatRequest;
import com.believeus.location.model.dto.SendSafetyNudgeRequest;
import com.believeus.location.security.SecurityContextUtil;
import com.believeus.location.service.LocationArrivalService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping({"/api/v1/location", "/api/v1/locations"})
@CrossOrigin(originPatterns = "*", allowCredentials = "true")
@RequiredArgsConstructor
public class LocationArrivalController {

    private final LocationArrivalService locationArrivalService;

    @PostMapping("/heartbeat")
    public ResponseEntity<ArrivalLogResponse> processLocationHeartbeat(
            @Valid @RequestBody LocationHeartbeatRequest request
    ) {
        String currentUserId = SecurityContextUtil.getCurrentUserId();
        String currentSpaceId = SecurityContextUtil.getCurrentCoupleSpaceId();

        // Enforce telemetry identity directly from verified security context
        if (currentUserId != null && !currentUserId.isBlank()) {
            request.setPartnerId(currentUserId);
        }
        if (currentSpaceId != null && !currentSpaceId.isBlank()) {
            request.setCoupleSpaceId(currentSpaceId);
        }

        LocationArrivalLog log = locationArrivalService.processHeartbeat(request);
        return ResponseEntity.ok(ArrivalLogResponse.fromEntity(log));
    }

    @GetMapping("/arrivals/{userId}")
    public ResponseEntity<List<ArrivalLogResponse>> getTodayArrivalLogs(
            @PathVariable String userId
    ) {
        String tokenSpaceId = SecurityContextUtil.getCurrentCoupleSpaceId();
        List<LocationArrivalLog> logs = tokenSpaceId != null
                ? locationArrivalService.getTodayArrivalLogs(tokenSpaceId, userId)
                : locationArrivalService.getTodayArrivalLogs(userId);

        List<ArrivalLogResponse> responses = logs.stream()
                .map(ArrivalLogResponse::fromEntity)
                .toList();
        return ResponseEntity.ok(responses);
    }

    @GetMapping("/latest/{userId}")
    public ResponseEntity<ArrivalLogResponse> getLatestLocation(
            @PathVariable String userId
    ) {
        return locationArrivalService.getLatestLocation(userId)
                .map(ArrivalLogResponse::fromEntity)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.noContent().build());
    }

    @GetMapping("/places/{userId}")
    public ResponseEntity<List<TrustedPlace>> getTrustedPlaces(
            @PathVariable String userId
    ) {
        String tokenSpaceId = SecurityContextUtil.getCurrentCoupleSpaceId();
        if (tokenSpaceId != null) {
            List<TrustedPlace> spacePlaces = locationArrivalService.getTrustedPlacesBySpace(tokenSpaceId);
            if (!spacePlaces.isEmpty()) {
                return ResponseEntity.ok(spacePlaces);
            }
        }
        return ResponseEntity.ok(locationArrivalService.getTrustedPlaces(userId));
    }

    @PostMapping("/places")
    public ResponseEntity<TrustedPlace> addTrustedPlace(
            @Valid @RequestBody AddTrustedPlaceRequest request
    ) {
        String currentUserId = SecurityContextUtil.getCurrentUserId();
        if (currentUserId != null && !currentUserId.isBlank()) {
            request.setUserId(currentUserId);
        }
        return ResponseEntity.ok(locationArrivalService.addTrustedPlace(request));
    }

    @PostMapping("/nudge")
    public ResponseEntity<Map<String, Object>> sendSafetyNudge(
            @Valid @RequestBody SendSafetyNudgeRequest request
    ) {
        String currentUserId = SecurityContextUtil.getCurrentUserId();
        if (currentUserId != null && !currentUserId.isBlank()) {
            request.setSenderId(currentUserId);
        }
        boolean sent = locationArrivalService.sendSafetyNudge(request);
        return ResponseEntity.ok(Map.of(
                "success", sent,
                "message", "Safety heart nudge dispatched via FCM"
        ));
    }
}
