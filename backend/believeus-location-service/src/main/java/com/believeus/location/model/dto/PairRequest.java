package com.believeus.location.model.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PairRequest {

    @NotBlank(message = "Current user ID is required")
    private String currentUserId;

    @NotBlank(message = "Invite code is required")
    private String inviteCode;
}
