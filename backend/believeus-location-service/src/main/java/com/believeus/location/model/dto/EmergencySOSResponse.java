package com.believeus.location.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EmergencySOSResponse {
    private boolean success;
    private String alertId;
    private String senderId;
    private String senderName;
    private String partnerId;
    private String partnerName;
    private String coupleSpaceId;
    private Double latitude;
    private Double longitude;
    private Long timestamp;
    private String message;
    private String address;
    private String status;
}
