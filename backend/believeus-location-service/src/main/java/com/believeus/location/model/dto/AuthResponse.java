package com.believeus.location.model.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AuthResponse {
    private String token;
    private UserProfileDto user;
    private String message;
    private Boolean isNewUser;
    private Boolean requiresApproval;
    private String loginTicketId;
}
