package com.believeus.location.model.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AddTrustedPlaceRequest {

    @NotBlank
    private String userId;

    @NotBlank
    private String name;

    @Builder.Default
    private String iconName = "home";

    @NotNull
    private Double latitude;

    @NotNull
    private Double longitude;

    @Builder.Default
    private Double radiusMeters = 150.0;

    @Builder.Default
    private Boolean notifyArrival = true;

    @Builder.Default
    private Boolean notifyDeparture = true;
}
