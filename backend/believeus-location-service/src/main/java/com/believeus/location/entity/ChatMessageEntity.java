package com.believeus.location.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(
        name = "chat_messages",
        indexes = {
                @Index(name = "idx_chat_msg_couple_space", columnList = "couple_space_id"),
                @Index(name = "idx_chat_msg_space_created", columnList = "couple_space_id, createdAt")
        }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatMessageEntity {

    @Id
    @Column(length = 64)
    private String id;

    @Column(nullable = false, length = 64)
    private String senderId;

    @Column(nullable = false, length = 64)
    private String receiverId;

    @Column(name = "couple_space_id", nullable = false, length = 64)
    private String coupleSpaceId;

    @Column(nullable = false, length = 32)
    private String type; // text, voice, gift

    @Column(length = 2000)
    private String text;

    private String audioPath;

    private Integer audioDurationSeconds;

    @Lob
    private String waveformSamplesJson;

    @Lob
    private String giftDataJson;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @Column(nullable = false)
    @Builder.Default
    private Boolean isRead = false;
}
