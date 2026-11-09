package com.believeus.location.model.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SendSafetyNudgeRequest {

    @NotBlank
    private String senderId;

    @NotBlank
    private String partnerId;

    @NotBlank
    private String partnerName;
}
