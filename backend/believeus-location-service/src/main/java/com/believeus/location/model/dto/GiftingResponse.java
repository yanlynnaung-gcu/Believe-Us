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
public class GiftingResponse {

    private String id;
    private String senderId;
    private String receiverId;
    private String coupleSpaceId;
    private String packageTitle;
    private Integer amountMmK;
    private String provider;
    private String transactionRef;
    private String status; // SUCCESS
    private String note;
    private LocalDateTime createdAt;
}
