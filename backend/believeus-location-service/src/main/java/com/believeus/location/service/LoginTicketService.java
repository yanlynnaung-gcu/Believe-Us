package com.believeus.location.service;

import com.believeus.location.model.LoginTicket;
import com.believeus.location.model.dto.UserProfileDto;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
@Slf4j
public class LoginTicketService {

    private static final int TICKET_VALIDITY_SECONDS = 120; // 2 minutes

    private final Map<String, LoginTicket> ticketStore = new ConcurrentHashMap<>();

    public LoginTicket createTicket(String userId, String targetDeviceId, String targetDeviceName) {
        cleanExpiredTickets();

        String ticketId = "tkt_" + UUID.randomUUID().toString().replace("-", "").substring(0, 16);
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime expiresAt = now.plusSeconds(TICKET_VALIDITY_SECONDS);

        LoginTicket ticket = LoginTicket.builder()
                .ticketId(ticketId)
                .userId(userId)
                .targetDeviceId(targetDeviceId)
                .targetDeviceName(targetDeviceName != null && !targetDeviceName.isBlank() ? targetDeviceName : "Mobile App")
                .status(LoginTicket.TicketStatus.PENDING)
                .createdAt(now)
                .expiresAt(expiresAt)
                .build();

        ticketStore.put(ticketId, ticket);
        log.info("[LoginTicket] Created ticket '{}' for user '{}', target device '{}'", ticketId, userId, targetDeviceId);
        return ticket;
    }

    public LoginTicket getTicket(String ticketId) {
        if (ticketId == null) return null;
        LoginTicket ticket = ticketStore.get(ticketId);
        if (ticket == null) return null;

        if (ticket.getStatus() == LoginTicket.TicketStatus.PENDING && ticket.isExpired()) {
            ticket.setStatus(LoginTicket.TicketStatus.EXPIRED);
            log.info("[LoginTicket] Ticket '{}' expired.", ticketId);
        }
        return ticket;
    }

    public boolean resolveTicket(String ticketId, boolean approved, String token, UserProfileDto profile) {
        LoginTicket ticket = getTicket(ticketId);
        if (ticket == null || ticket.getStatus() != LoginTicket.TicketStatus.PENDING) {
            return false;
        }

        if (approved) {
            ticket.setStatus(LoginTicket.TicketStatus.APPROVED);
            ticket.setToken(token);
            ticket.setUserProfile(profile);
            log.info("[LoginTicket] Ticket '{}' resolved: APPROVED", ticketId);
        } else {
            ticket.setStatus(LoginTicket.TicketStatus.REJECTED);
            log.info("[LoginTicket] Ticket '{}' resolved: REJECTED", ticketId);
        }
        return true;
    }

    private void cleanExpiredTickets() {
        LocalDateTime cutoff = LocalDateTime.now().minusMinutes(5);
        ticketStore.entrySet().removeIf(entry -> entry.getValue().getCreatedAt().isBefore(cutoff));
    }
}
