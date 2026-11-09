package com.believeus.location.entity;

import com.believeus.location.model.MovementStatus;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(
        name = "location_arrival_logs",
        indexes = {
                @Index(name = "idx_arrival_couple_space", columnList = "couple_space_id"),
                @Index(name = "idx_arrival_user_time", columnList = "userId, arrivedAt"),
                @Index(name = "idx_arrival_space_user", columnList = "couple_space_id, userId")
        }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LocationArrivalLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "couple_space_id", length = 64)
    private String coupleSpaceId;

    @Column(nullable = false, length = 64)
    private String userId;

    @Column(nullable = false)
    private Double latitude;

    @Column(nullable = false)
    private Double longitude;

    @Column(nullable = false, length = 500)
    private String addressLine;

    @Column(nullable = false, length = 100)
    private String placeName;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 32)
    private MovementStatus status;

    private Double speedKmh;

    private Integer batteryLevel;

    private Boolean isCharging;

    @Column(nullable = false)
    private LocalDateTime arrivedAt;

    private LocalDateTime departedAt;

    @Column(nullable = false)
    private LocalDateTime lastUpdatedAt;
}
