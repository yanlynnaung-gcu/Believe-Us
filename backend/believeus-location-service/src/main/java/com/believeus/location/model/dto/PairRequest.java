package com.believeus.location.model.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
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
    @Pattern(regexp = "^\\d{6}$", message = "Pairing code must be exactly 6 digits")
    private String inviteCode;
}
