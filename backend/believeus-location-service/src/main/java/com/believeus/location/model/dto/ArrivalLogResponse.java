package com.believeus.location.model.dto;

import com.believeus.location.entity.LocationArrivalLog;
import com.believeus.location.model.MovementStatus;
import lombok.*;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ArrivalLogResponse {

    private Long id;
    private String coupleSpaceId;
    private String userId;
    private Double latitude;
    private Double longitude;
    private String addressLine;
    private String placeName;
    private MovementStatus status;
    private Double speedKmh;
    private Integer batteryLevel;
    private Boolean isCharging;
    private LocalDateTime arrivedAt;
    private LocalDateTime departedAt;
    private LocalDateTime lastUpdatedAt;

    public static ArrivalLogResponse fromEntity(LocationArrivalLog entity) {
        return ArrivalLogResponse.builder()
                .id(entity.getId())
                .coupleSpaceId(entity.getCoupleSpaceId())
                .userId(entity.getUserId())
                .latitude(entity.getLatitude())
                .longitude(entity.getLongitude())
                .addressLine(entity.getAddressLine())
                .placeName(entity.getPlaceName())
                .status(entity.getStatus())
                .speedKmh(entity.getSpeedKmh())
                .batteryLevel(entity.getBatteryLevel())
                .isCharging(entity.getIsCharging())
                .arrivedAt(entity.getArrivedAt())
                .departedAt(entity.getDepartedAt())
                .lastUpdatedAt(entity.getLastUpdatedAt())
                .build();
    }
}
