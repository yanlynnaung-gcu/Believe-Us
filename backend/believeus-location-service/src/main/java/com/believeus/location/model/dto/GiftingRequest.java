package com.believeus.location.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GiftingRequest {

    private String senderId;
    private String receiverId;
    private String coupleSpaceId;
    private String packageTitle;
    private Integer amountMmK;
    private String provider; // KBZPAY, WAVEPAY
    private String note;
}
