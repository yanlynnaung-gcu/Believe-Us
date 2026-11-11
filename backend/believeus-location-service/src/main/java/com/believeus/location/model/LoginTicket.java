package com.believeus.location.model;

import com.believeus.location.model.dto.UserProfileDto;
import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LoginTicket {

    public enum TicketStatus {
        PENDING,
        APPROVED,
        REJECTED,
        EXPIRED
    }

    private String ticketId;
    private String userId;
    private String targetDeviceId;
    private String targetDeviceName;
    private TicketStatus status;
    private LocalDateTime createdAt;
    private LocalDateTime expiresAt;
    private String token;
    private UserProfileDto userProfile;

    public boolean isExpired() {
        return expiresAt != null && LocalDateTime.now().isAfter(expiresAt);
    }
}
