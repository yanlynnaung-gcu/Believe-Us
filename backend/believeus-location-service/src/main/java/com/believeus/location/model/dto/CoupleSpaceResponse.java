package com.believeus.location.model.dto;

import com.believeus.location.entity.CoupleSpaceEntity;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CoupleSpaceResponse {

    private String id;
    private String user1Id;
    private String user2Id;
    private String inviteCode;
    private LocalDateTime pairedAt;
    private LocalDateTime anniversaryDate;
    private LocalDateTime startDate;
    private LocalDateTime createdAt;
    private LocalDateTime serverTime;
    private Long daysTogether;
    private String coverPhotoUrl;
    private Boolean isActive;

    public static CoupleSpaceResponse fromEntity(CoupleSpaceEntity entity) {
        if (entity == null) return null;
        LocalDateTime anniversary = entity.getAnniversaryDate() != null
                ? entity.getAnniversaryDate()
                : entity.getPairedAt();
        long days = 1;
        if (anniversary != null) {
            days = Math.max(1, java.time.temporal.ChronoUnit.DAYS.between(anniversary.toLocalDate(), java.time.LocalDate.now()) + 1);
        }
        LocalDateTime now = LocalDateTime.now(java.time.ZoneOffset.UTC);
        return CoupleSpaceResponse.builder()
                .id(entity.getId())
                .user1Id(entity.getUser1Id())
                .user2Id(entity.getUser2Id())
                .inviteCode(entity.getInviteCode())
                .pairedAt(entity.getPairedAt())
                .anniversaryDate(anniversary)
                .startDate(anniversary)
                .createdAt(entity.getPairedAt())
                .serverTime(now)
                .daysTogether(days)
                .coverPhotoUrl(entity.getCoverPhotoUrl())
                .isActive(entity.getIsActive())
                .build();
    }
}
