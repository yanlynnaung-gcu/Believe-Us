package com.believeus.location.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserEntity {

    @Id
    @Column(nullable = false, length = 64)
    private String id;

    @Column(nullable = false, unique = true, length = 120)
    private String email;

    @Column(length = 255)
    private String passwordHash;

    @Column(nullable = false, length = 100)
    private String displayName;

    @Column(nullable = false, length = 20)
    private String role; // "BOYFRIEND" or "GIRLFRIEND"

    private LocalDate birthday;

    @Column(length = 500)
    private String avatarUrl;

    @Column(length = 64)
    private String partnerId;

    @Column(length = 64)
    private String coupleSpaceId;

    private Double lastLatitude;

    private Double lastLongitude;

    @Column(length = 255)
    private String lastAddress;

    @Builder.Default
    private Integer batteryLevel = 100;

    @Builder.Default
    private Boolean isOnline = false;

    @Column(length = 128)
    private String currentDeviceId;

    @Column(length = 128)
    private String currentDeviceName;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
