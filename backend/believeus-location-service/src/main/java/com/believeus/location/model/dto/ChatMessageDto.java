package com.believeus.location.model.dto;

import com.believeus.location.entity.ChatMessageEntity;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatMessageDto {

    private String id;
    private String senderId;
    private String receiverId;
    private String coupleSpaceId;
    private String type; // text, voice, gift
    private String text;
    private String audioPath;
    private Integer audioDurationSeconds;
    private List<Double> waveformSamples;
    private Map<String, Object> giftData;
    private LocalDateTime createdAt;
    private Boolean isRead;

    public static ChatMessageDto fromEntity(ChatMessageEntity entity, ObjectMapper objectMapper) {
        if (entity == null) return null;

        List<Double> waveforms = null;
        if (entity.getWaveformSamplesJson() != null && !entity.getWaveformSamplesJson().isBlank()) {
            try {
                waveforms = objectMapper.readValue(entity.getWaveformSamplesJson(), new TypeReference<List<Double>>() {});
            } catch (Exception ignored) {}
        }

        Map<String, Object> gift = null;
        if (entity.getGiftDataJson() != null && !entity.getGiftDataJson().isBlank()) {
            try {
                gift = objectMapper.readValue(entity.getGiftDataJson(), new TypeReference<Map<String, Object>>() {});
            } catch (Exception ignored) {}
        }

        String audioPath = entity.getAudioPath();
        if (audioPath != null && !audioPath.isBlank()) {
            audioPath = audioPath.trim();
            if (audioPath.startsWith("file:///uploads/")) {
                audioPath = audioPath.substring("file://".length());
            } else if (audioPath.startsWith("file://uploads/")) {
                audioPath = audioPath.substring("file://".length());
            }
        }

        return ChatMessageDto.builder()
                .id(entity.getId())
                .senderId(entity.getSenderId())
                .receiverId(entity.getReceiverId())
                .coupleSpaceId(entity.getCoupleSpaceId())
                .type(entity.getType() != null ? entity.getType().toLowerCase() : "text")
                .text(entity.getText())
                .audioPath(audioPath)
                .audioDurationSeconds(entity.getAudioDurationSeconds())
                .waveformSamples(waveforms)
                .giftData(gift)
                .createdAt(entity.getCreatedAt())
                .isRead(entity.getIsRead())
                .build();
    }
}
