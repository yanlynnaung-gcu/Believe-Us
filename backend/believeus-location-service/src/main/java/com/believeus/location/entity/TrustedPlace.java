package com.believeus.location.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(
        name = "trusted_places",
        indexes = {
                @Index(name = "idx_trusted_place_user", columnList = "userId"),
                @Index(name = "idx_trusted_place_couple_space", columnList = "couple_space_id")
        }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TrustedPlace {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "couple_space_id", length = 64)
    private String coupleSpaceId;

    @Column(nullable = false, length = 64)
    private String userId;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(nullable = false, length = 50)
    private String iconName;

    @Column(nullable = false)
    private Double latitude;

    @Column(nullable = false)
    private Double longitude;

    @Column(nullable = false)
    @Builder.Default
    private Double radiusMeters = 150.0;

    @Column(nullable = false)
    @Builder.Default
    private Boolean notifyArrival = true;

    @Column(nullable = false)
    @Builder.Default
    private Boolean notifyDeparture = true;

    @Column(nullable = false)
    private LocalDateTime createdAt;
}
