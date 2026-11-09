package com.believeus.location.repository;

import com.believeus.location.entity.ChatMessageEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ChatMessageRepository extends JpaRepository<ChatMessageEntity, String> {

    List<ChatMessageEntity> findByCoupleSpaceIdOrderByCreatedAtDesc(String coupleSpaceId);

    long countByCoupleSpaceIdAndReceiverIdAndIsReadFalse(String coupleSpaceId, String receiverId);

    List<ChatMessageEntity> findByCoupleSpaceIdAndReceiverIdAndIsReadFalse(String coupleSpaceId, String receiverId);

    List<ChatMessageEntity> findByReceiverIdAndIsReadFalse(String receiverId);
}
