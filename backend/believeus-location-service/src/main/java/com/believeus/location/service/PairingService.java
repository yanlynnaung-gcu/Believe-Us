package com.believeus.location.service;

import com.believeus.location.entity.CoupleSpaceEntity;
import com.believeus.location.entity.UserEntity;
import com.believeus.location.entity.UserInviteCodeEntity;
import com.believeus.location.model.dto.CoupleSpaceResponse;
import com.believeus.location.model.dto.CoupleSummaryResponse;
import com.believeus.location.model.dto.UserProfileDto;
import com.believeus.location.repository.CoupleSpaceRepository;
import com.believeus.location.repository.UserInviteCodeRepository;
import com.believeus.location.repository.UserRepository;
import com.believeus.location.websocket.SyncWebSocketHandler;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.Duration;
import java.time.Instant;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class PairingService {

    private final CoupleSpaceRepository coupleSpaceRepository;
    private final UserInviteCodeRepository userInviteCodeRepository;
    private final UserRepository userRepository;
    private final SyncWebSocketHandler syncWebSocketHandler;

    private static final String CODE_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    private static final SecureRandom RANDOM = new SecureRandom();
    private static final Duration CODE_TTL = Duration.ofMinutes(30);

    @Transactional
    public synchronized String getOrCreateInviteCode(String userId) {
        return generateOrRetrieveCode(userId, false);
    }

    @Transactional
    public synchronized String forceGenerateNewCode(String userId) {
        return generateOrRetrieveCode(userId, true);
    }

    private String generateOrRetrieveCode(String userId, boolean forceNew) {
        // 1. Strict 1-to-1 Lock check: already paired users cannot generate a code
        Optional<CoupleSpaceEntity> activeSpace = coupleSpaceRepository.findActiveSpaceByUserId(userId);
        if (activeSpace.isPresent()) {
            throw new IllegalStateException("Strict 1-to-1 Lock Enforced: Your account is already bonded with a partner.");
        }

        final Instant now = Instant.now();

        // 2. Return existing active code if not forcing a new one
        if (!forceNew) {
            Optional<UserInviteCodeEntity> existing = userInviteCodeRepository
                    .findFirstByUserIdAndIsUsedFalseAndExpiresAtAfterOrderByCreatedAtDesc(userId, now);
            if (existing.isPresent()) {
                String code = existing.get().getCode();
                log.info("Retrieved active 6-digit invite code: {} for user: {} (expires at: {})",
                        code, userId, existing.get().getExpiresAt());
                return code;
            }
        }

        // 3. Generate unique pure 6-digit numeric code
        String code;
        int attempts = 0;
        do {
            int num = RANDOM.nextInt(1000000);
            code = String.format("%06d", num);
            attempts++;
            if (attempts > 50) {
                long fallback = Math.abs(System.currentTimeMillis() % 1000000L);
                code = String.format("%06d", fallback);
            }
        } while (userInviteCodeRepository.existsById(code));

        Instant expiresAt = now.plus(CODE_TTL);

        UserInviteCodeEntity codeEntity = UserInviteCodeEntity.builder()
                .code(code)
                .userId(userId)
                .createdAt(now)
                .expiresAt(expiresAt)
                .isUsed(false)
                .build();

        userInviteCodeRepository.save(codeEntity);
        log.info("Generated 6-digit invite code: {} for user: {} (persisted in DB, expires at: {})",
                code, userId, expiresAt);

        return code;
    }

    @Transactional
    public synchronized CoupleSpaceResponse pairWithCode(String currentUserId, String inviteCode) {
        if (inviteCode == null || inviteCode.trim().isEmpty()) {
            throw new IllegalArgumentException("Invite code cannot be empty. Please enter your partner's 6-digit code.");
        }

        // Trim and validate strictly 6-digit numeric code
        String normalizedCode = inviteCode.trim();
        if (!normalizedCode.matches("^\\d{6}$")) {
            throw new IllegalArgumentException("Pairing code must be exactly 6 digits.");
        }

        // 1. Check current user 1-to-1 lock
        if (coupleSpaceRepository.findActiveSpaceByUserId(currentUserId).isPresent()) {
            throw new IllegalStateException("Strict 1-to-1 Lock Enforced: Your account is already bonded with a partner.");
        }

        final Instant now = Instant.now();

        // 2. Query persisted code in H2 database
        Optional<UserInviteCodeEntity> codeOpt = userInviteCodeRepository
                .findFirstByCodeIgnoreCaseAndIsUsedFalseAndExpiresAtAfter(normalizedCode, now);

        if (codeOpt.isEmpty()) {
            log.warn("[Pairing Failed] Code '{}' not found, expired, or already used for user: {}",
                    normalizedCode, currentUserId);
            throw new IllegalArgumentException("Invalid or expired 6-digit couple code. Please ask your partner for their active code.");
        }

        UserInviteCodeEntity codeEntity = codeOpt.get();
        String targetUserId = codeEntity.getUserId();

        // 3. Block self-pairing
        if (targetUserId.equals(currentUserId)) {
            throw new IllegalArgumentException("You cannot pair with your own code. Send this code to your partner so they can connect with you!");
        }

        // 4. Check partner 1-to-1 lock
        if (coupleSpaceRepository.findActiveSpaceByUserId(targetUserId).isPresent()) {
            throw new IllegalStateException("Strict 1-to-1 Lock Enforced: This user is already paired with another partner.");
        }

        // 5. Mark code as used
        codeEntity.setIsUsed(true);
        userInviteCodeRepository.save(codeEntity);

        // 6. Create shared CoupleSpace
        String spaceId = "space_" + UUID.randomUUID().toString().substring(0, 8);
        LocalDateTime ldtNow = LocalDateTime.now();

        CoupleSpaceEntity entity = CoupleSpaceEntity.builder()
                .id(spaceId)
                .user1Id(targetUserId)
                .user2Id(currentUserId)
                .inviteCode(normalizedCode)
                .pairedAt(ldtNow)
                .anniversaryDate(ldtNow)
                .isActive(true)
                .build();

        CoupleSpaceEntity saved = coupleSpaceRepository.save(entity);

        // Update UserEntity partnerId and coupleSpaceId for both users
        userRepository.findById(targetUserId).ifPresent(u1 -> {
            u1.setPartnerId(currentUserId);
            u1.setCoupleSpaceId(spaceId);
            userRepository.save(u1);
        });
        userRepository.findById(currentUserId).ifPresent(u2 -> {
            u2.setPartnerId(targetUserId);
            u2.setCoupleSpaceId(spaceId);
            userRepository.save(u2);
        });

        CoupleSpaceResponse response = CoupleSpaceResponse.fromEntity(saved);

        // 7. Instant real-time notification over WebSocket to both devices
        syncWebSocketHandler.sendToUser(targetUserId, "COUPLE_PAIRED", response);
        syncWebSocketHandler.sendToUser(currentUserId, "COUPLE_PAIRED", response);

        log.info("Successfully paired user: {} with partner: {} using code: {} in couple space: {}",
                currentUserId, targetUserId, normalizedCode, spaceId);

        return response;
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getPairingStatus(String userId) {
        Optional<CoupleSpaceEntity> active = coupleSpaceRepository.findActiveSpaceByUserId(userId);
        if (active.isPresent()) {
            CoupleSpaceResponse resp = CoupleSpaceResponse.fromEntity(active.get());
            String partnerId = active.get().getUser1Id().equals(userId)
                    ? active.get().getUser2Id()
                    : active.get().getUser1Id();
            return Map.of(
                    "isPaired", true,
                    "partnerId", partnerId,
                    "coupleSpace", resp
            );
        }
        return Map.of("isPaired", false);
    }

    @Transactional(readOnly = true)
    public CoupleSummaryResponse getCoupleSummary(String coupleSpaceId, String currentUserId) {
        CoupleSpaceEntity space = coupleSpaceRepository.findById(coupleSpaceId)
                .orElseThrow(() -> new IllegalArgumentException("Couple space not found: " + coupleSpaceId));

        String myId = (currentUserId != null && !currentUserId.isBlank()) ? currentUserId : space.getUser1Id();
        String partnerId = myId.equals(space.getUser1Id()) ? space.getUser2Id() : space.getUser1Id();

        UserEntity myUser = userRepository.findById(myId).orElse(null);
        UserEntity partnerUser = userRepository.findById(partnerId).orElse(null);

        long daysTogether = 1;
        if (space.getAnniversaryDate() != null) {
            daysTogether = Math.max(1, Duration.between(space.getAnniversaryDate(), LocalDateTime.now()).toDays() + 1);
        }

        return CoupleSummaryResponse.builder()
                .coupleSpaceId(space.getId())
                .coverPhotoUrl(space.getCoverPhotoUrl())
                .anniversaryDate(space.getAnniversaryDate())
                .daysTogether(daysTogether)
                .myProfile(UserProfileDto.fromEntity(myUser))
                .partnerProfile(UserProfileDto.fromEntity(partnerUser))
                .build();
    }

    @Transactional
    public String updateCoverPhoto(String coupleSpaceId, String coverPhotoUrl) {
        CoupleSpaceEntity space = coupleSpaceRepository.findById(coupleSpaceId)
                .orElseThrow(() -> new IllegalArgumentException("Couple space not found: " + coupleSpaceId));
        space.setCoverPhotoUrl(coverPhotoUrl);
        coupleSpaceRepository.save(space);

        syncWebSocketHandler.broadcastToCoupleSpace(coupleSpaceId, "COVER_PHOTO_UPDATED", Map.of(
                "coupleSpaceId", coupleSpaceId,
                "coverPhotoUrl", coverPhotoUrl
        ));
        syncWebSocketHandler.broadcastToCoupleSpace(coupleSpaceId, "PROFILE_UPDATED", Map.of(
                "coupleSpaceId", coupleSpaceId,
                "coverPhotoUrl", coverPhotoUrl
        ));

        log.info("Updated cover photo for couple space {}: {}", coupleSpaceId, coverPhotoUrl);
        return coverPhotoUrl;
    }

    @Transactional
    public void unpair(String coupleSpaceId) {
        coupleSpaceRepository.findById(coupleSpaceId).ifPresent(space -> {
            space.setIsActive(false);
            coupleSpaceRepository.save(space);

            userRepository.findById(space.getUser1Id()).ifPresent(u1 -> {
                u1.setPartnerId(null);
                u1.setCoupleSpaceId(null);
                userRepository.save(u1);
            });
            userRepository.findById(space.getUser2Id()).ifPresent(u2 -> {
                u2.setPartnerId(null);
                u2.setCoupleSpaceId(null);
                userRepository.save(u2);
            });

            syncWebSocketHandler.broadcastToCoupleSpace(coupleSpaceId, "COUPLE_UNPAIRED", Map.of("coupleSpaceId", coupleSpaceId));
            log.info("Unpaired couple space: {}", coupleSpaceId);
        });
    }
}
