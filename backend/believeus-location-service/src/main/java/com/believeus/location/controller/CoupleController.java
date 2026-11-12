package com.believeus.location.controller;

import com.believeus.location.model.dto.CoupleSummaryResponse;
import com.believeus.location.security.SecurityContextUtil;
import com.believeus.location.service.PairingService;
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
import java.time.LocalDateTime;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/couples")
@CrossOrigin(originPatterns = "*", allowCredentials = "true")
@RequiredArgsConstructor
@Slf4j
public class CoupleController {

    private final PairingService pairingService;

    private static final String COVERS_DIR = "./uploads/covers";

    @PostMapping(value = "/{coupleSpaceId}/cover-photo", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<Map<String, String>> uploadCoverPhoto(
            @PathVariable String coupleSpaceId,
            @RequestParam("file") MultipartFile file) throws IOException {

        SecurityContextUtil.validateCoupleSpaceAccess(coupleSpaceId);

        if (file.isEmpty()) {
            throw new IllegalArgumentException("Cannot upload empty couple cover photo.");
        }

        File dir = new File(COVERS_DIR);
        if (!dir.exists()) {
            dir.mkdirs();
        }

        String originalFilename = file.getOriginalFilename();
        String ext = "jpg";
        if (originalFilename != null && originalFilename.contains(".")) {
            ext = originalFilename.substring(originalFilename.lastIndexOf(".") + 1).toLowerCase();
        }

        String filename = coupleSpaceId + "_" + System.currentTimeMillis() + "." + ext;
        Path targetPath = Paths.get(COVERS_DIR, filename);

        Files.copy(file.getInputStream(), targetPath, StandardCopyOption.REPLACE_EXISTING);

        String relativeUrl = "/uploads/covers/" + filename;
        pairingService.updateCoverPhoto(coupleSpaceId, relativeUrl);

        log.info("Saved couple cover photo for {}: {}", coupleSpaceId, relativeUrl);

        return ResponseEntity.ok(Map.of(
                "coverPhotoUrl", relativeUrl
        ));
    }

    @GetMapping("/{coupleSpaceId}/summary")
    public ResponseEntity<CoupleSummaryResponse> getCoupleSummary(
            @PathVariable String coupleSpaceId,
            @RequestParam(value = "userId", required = false) String userId) {

        SecurityContextUtil.validateCoupleSpaceAccess(coupleSpaceId);
        String tokenUserId = SecurityContextUtil.getCurrentUserId();
        String effectiveUserId = tokenUserId != null ? tokenUserId : userId;

        return ResponseEntity.ok(pairingService.getCoupleSummary(coupleSpaceId, effectiveUserId));
    }

    @PutMapping("/{coupleSpaceId}/anniversary")
    public ResponseEntity<CoupleSummaryResponse> updateAnniversary(
            @PathVariable String coupleSpaceId,
            @RequestBody Map<String, Object> body) {

        SecurityContextUtil.validateCoupleSpaceAccess(coupleSpaceId);

        String dateStr = (String) body.get("anniversaryDate");
        if (dateStr == null) {
            dateStr = (String) body.get("startDate");
        }
        if (dateStr == null || dateStr.isBlank()) {
            throw new IllegalArgumentException("Anniversary date or start date is required.");
        }

        LocalDateTime parsedDate;
        try {
            if (dateStr.endsWith("Z")) {
                parsedDate = java.time.Instant.parse(dateStr).atZone(java.time.ZoneOffset.UTC).toLocalDateTime();
            } else if (dateStr.contains("T")) {
                parsedDate = LocalDateTime.parse(dateStr.substring(0, Math.min(dateStr.length(), 19)));
            } else {
                parsedDate = java.time.LocalDate.parse(dateStr).atStartOfDay();
            }
        } catch (Exception e) {
            log.error("Failed to parse anniversary date: {}", dateStr, e);
            throw new IllegalArgumentException("Invalid date format: " + dateStr);
        }

        CoupleSummaryResponse resp = pairingService.updateAnniversaryDate(coupleSpaceId, parsedDate);
        return ResponseEntity.ok(resp);
    }
}
