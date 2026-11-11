package com.believeus.location.model.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LoginTicketStatusResponse {
    private String ticketId;
    private String status;
    private Boolean requiresApproval;
    private String token;
    private UserProfileDto user;
    private String message;
}
