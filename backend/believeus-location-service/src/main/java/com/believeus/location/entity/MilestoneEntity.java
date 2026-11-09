package com.believeus.location.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(
        name = "couple_milestones",
        indexes = {
                @Index(name = "idx_milestone_couple_space", columnList = "couple_space_id"),
                @Index(name = "idx_milestone_target_date", columnList = "couple_space_id, targetDate")
        }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MilestoneEntity {

    @Id
    @Column(length = 64)
    private String id;

    @Column(name = "couple_space_id", nullable = false, length = 64)
    private String coupleSpaceId;

    @Column(nullable = false, length = 150)
    private String title;

    @Column(nullable = false)
    private LocalDateTime targetDate;

    @Column(nullable = false)
    @Builder.Default
    private Boolean isRecurringAnnual = true;

    @Column(length = 20)
    @Builder.Default
    private String iconEmoji = "❤️";

    @Column(length = 500)
    private String note;

    @Column(length = 100)
    @Builder.Default
    private String category = "Anniversary";

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }
}
