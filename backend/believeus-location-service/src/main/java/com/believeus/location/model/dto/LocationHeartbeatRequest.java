package com.believeus.location.model.dto;

import jakarta.validation.constraints.NotNull;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LocationHeartbeatRequest {

    @NotNull
    private String partnerId;

    private String coupleSpaceId;

    @NotNull
    private String partnerName;

    @NotNull
    private Double latitude;

    @NotNull
    private Double longitude;

    @Builder.Default
    private Double speedKmh = 0.0;

    @Builder.Default
    private Integer batteryLevel = 100;

    @Builder.Default
    private Boolean isCharging = false;
}
