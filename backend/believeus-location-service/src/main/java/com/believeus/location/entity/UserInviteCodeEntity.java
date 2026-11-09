package com.believeus.location.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;

@Entity
@Table(name = "user_invite_codes")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserInviteCodeEntity {

    @Id
    @Column(length = 6, nullable = false, unique = true)
    private String code;

    @Column(nullable = false)
    private String userId;

    @Column(nullable = false)
    private Instant createdAt;

    @Column(nullable = false)
    private Instant expiresAt;

    @Column(nullable = false)
    @Builder.Default
    private Boolean isUsed = false;
}
