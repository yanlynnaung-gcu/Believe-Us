package com.believeus.location.service;

import com.believeus.location.entity.ChatMessageEntity;
import com.believeus.location.model.dto.ChatMessageDto;
import com.believeus.location.repository.ChatMessageRepository;
import com.believeus.location.websocket.SyncWebSocketHandler;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class ChatService {

    private final ChatMessageRepository chatMessageRepository;
    private final SyncWebSocketHandler syncWebSocketHandler;
    private final ObjectMapper objectMapper;

    @Transactional(readOnly = true)
    public List<ChatMessageDto> getMessages(String coupleSpaceId) {
        return chatMessageRepository.findByCoupleSpaceIdOrderByCreatedAtDesc(coupleSpaceId)
                .stream()
                .map(entity -> ChatMessageDto.fromEntity(entity, objectMapper))
                .toList();
    }

    @Transactional
    public ChatMessageDto sendMessage(ChatMessageDto dto) {
        String msgId = dto.getId() != null && !dto.getId().isBlank()
                ? dto.getId()
                : "msg_" + UUID.randomUUID().toString().substring(0, 8);

        LocalDateTime now = dto.getCreatedAt() != null ? dto.getCreatedAt() : LocalDateTime.now();

        String waveformsJson = null;
        if (dto.getWaveformSamples() != null) {
            try {
                waveformsJson = objectMapper.writeValueAsString(dto.getWaveformSamples());
            } catch (Exception ignored) {}
        }

        String giftJson = null;
        if (dto.getGiftData() != null) {
            try {
                giftJson = objectMapper.writeValueAsString(dto.getGiftData());
            } catch (Exception ignored) {}
        }

        ChatMessageEntity entity = ChatMessageEntity.builder()
                .id(msgId)
                .senderId(dto.getSenderId())
                .receiverId(dto.getReceiverId())
                .coupleSpaceId(dto.getCoupleSpaceId())
                .type(dto.getType() != null ? dto.getType().toLowerCase() : "text")
                .text(dto.getText())
                .audioPath(dto.getAudioPath())
                .audioDurationSeconds(dto.getAudioDurationSeconds())
                .waveformSamplesJson(waveformsJson)
                .giftDataJson(giftJson)
                .createdAt(now)
                .isRead(false)
                .build();

        ChatMessageEntity saved = chatMessageRepository.save(entity);
        ChatMessageDto result = ChatMessageDto.fromEntity(saved, objectMapper);

        // Real-time broadcast to couple space over WebSocket!
        syncWebSocketHandler.broadcastToCoupleSpace(dto.getCoupleSpaceId(), "CHAT_MESSAGE", result);

        // Calculate and broadcast recipient's unread message count
        long unreadCount = chatMessageRepository.countByCoupleSpaceIdAndReceiverIdAndIsReadFalse(
                dto.getCoupleSpaceId(),
                dto.getReceiverId()
        );
        Map<String, Object> unreadPayload = Map.of(
                "coupleSpaceId", dto.getCoupleSpaceId(),
                "receiverId", dto.getReceiverId(),
                "unreadCount", unreadCount
        );
        syncWebSocketHandler.sendToUser(dto.getReceiverId(), "CHAT_UNREAD_COUNT", unreadPayload);
        syncWebSocketHandler.broadcastToCoupleSpace(dto.getCoupleSpaceId(), "CHAT_UNREAD_COUNT", unreadPayload);

        log.info("[Chat Broadcast] Type: '{}', Space: '{}', Sender: '{}', Unread: {}",
                result.getType(), result.getCoupleSpaceId(), result.getSenderId(), unreadCount);

        return result;
    }

    @Transactional(readOnly = true)
    public long getUnreadCount(String coupleSpaceId, String receiverId) {
        return chatMessageRepository.countByCoupleSpaceIdAndReceiverIdAndIsReadFalse(coupleSpaceId, receiverId);
    }

    @Transactional
    public long markMessagesAsRead(String coupleSpaceId, String receiverId) {
        List<ChatMessageEntity> unreadList = chatMessageRepository
                .findByCoupleSpaceIdAndReceiverIdAndIsReadFalse(coupleSpaceId, receiverId);
        if (!unreadList.isEmpty()) {
            for (ChatMessageEntity msg : unreadList) {
                msg.setIsRead(true);
            }
            chatMessageRepository.saveAll(unreadList);
        }

        Map<String, Object> zeroCountPayload = Map.of(
                "coupleSpaceId", coupleSpaceId,
                "receiverId", receiverId,
                "unreadCount", 0L
        );
        syncWebSocketHandler.sendToUser(receiverId, "CHAT_UNREAD_COUNT", zeroCountPayload);
        syncWebSocketHandler.broadcastToCoupleSpace(coupleSpaceId, "CHAT_UNREAD_COUNT", zeroCountPayload);
        syncWebSocketHandler.broadcastToCoupleSpace(coupleSpaceId, "MESSAGES_READ", Map.of(
                "coupleSpaceId", coupleSpaceId,
                "readBy", receiverId,
                "readCount", unreadList.size()
        ));

        log.info("[Chat Read] Marked {} messages as read for user '{}' in space '{}'",
                unreadList.size(), receiverId, coupleSpaceId);
        return unreadList.size();
    }
}
