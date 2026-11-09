package com.believeus.location.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EmergencySOSRequest {
    private Double latitude;
    private Double longitude;
    private Long timestamp;
    private String message;
    private String address;
}
