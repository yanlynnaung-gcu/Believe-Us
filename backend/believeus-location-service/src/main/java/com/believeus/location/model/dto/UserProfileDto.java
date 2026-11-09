package com.believeus.location.model.dto;

import com.believeus.location.entity.UserEntity;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserProfileDto {
    private String id;
    private String email;
    private String displayName;
    private String role;
    private LocalDate birthday;
    private String avatarUrl;
    private String partnerId;
    private String coupleSpaceId;
    private Double lastLatitude;
    private Double lastLongitude;
    private String lastAddress;
    private Integer batteryLevel;
    private Boolean isOnline;
    private LocalDateTime createdAt;

    public static UserProfileDto fromEntity(UserEntity entity) {
        if (entity == null) return null;
        return UserProfileDto.builder()
                .id(entity.getId())
                .email(entity.getEmail())
                .displayName(entity.getDisplayName())
                .role(entity.getRole())
                .birthday(entity.getBirthday())
                .avatarUrl(entity.getAvatarUrl())
                .partnerId(entity.getPartnerId())
                .coupleSpaceId(entity.getCoupleSpaceId())
                .lastLatitude(entity.getLastLatitude())
                .lastLongitude(entity.getLastLongitude())
                .lastAddress(entity.getLastAddress())
                .batteryLevel(entity.getBatteryLevel())
                .isOnline(entity.getIsOnline())
                .createdAt(entity.getCreatedAt())
                .build();
    }
}
