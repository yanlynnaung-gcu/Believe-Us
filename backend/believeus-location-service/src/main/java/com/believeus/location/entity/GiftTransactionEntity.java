package com.believeus.location.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(
        name = "gift_transactions",
        indexes = {
                @Index(name = "idx_gift_couple_space", columnList = "couple_space_id"),
                @Index(name = "idx_gift_space_created", columnList = "couple_space_id, createdAt")
        }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GiftTransactionEntity {

    @Id
    @Column(length = 64)
    private String id;

    @Column(nullable = false, length = 64)
    private String senderId;

    @Column(nullable = false, length = 64)
    private String receiverId;

    @Column(name = "couple_space_id", nullable = false, length = 64)
    private String coupleSpaceId;

    @Column(nullable = false, length = 120)
    private String packageTitle;

    @Column(nullable = false)
    private Integer amountMmK;

    @Column(length = 50)
    private String provider;

    @Column(length = 100)
    private String transactionRef;

    @Column(nullable = false, length = 20)
    @Builder.Default
    private String status = "PAID";

    @Column(length = 500)
    private String note;

    @Column(nullable = false)
    @Builder.Default
    private Boolean isOpened = false;

    @Column(nullable = false)
    private LocalDateTime createdAt;
}
