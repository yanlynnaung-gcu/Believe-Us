package com.believeus.location.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "couple_spaces")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CoupleSpaceEntity {

    @Id
    private String id;

    @Column(nullable = false)
    private String user1Id;

    @Column(nullable = false)
    private String user2Id;

    @Column(nullable = false)
    private String inviteCode;

    @Column(nullable = false)
    private LocalDateTime pairedAt;

    @Column(nullable = false)
    private LocalDateTime anniversaryDate;

    @Column(length = 500)
    private String coverPhotoUrl;

    @Column(nullable = false)
    @Builder.Default
    private Boolean isActive = true;
}
