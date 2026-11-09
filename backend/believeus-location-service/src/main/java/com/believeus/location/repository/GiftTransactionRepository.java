package com.believeus.location.repository;

import com.believeus.location.entity.GiftTransactionEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface GiftTransactionRepository extends JpaRepository<GiftTransactionEntity, String> {

    List<GiftTransactionEntity> findByCoupleSpaceIdOrderByCreatedAtDesc(String coupleSpaceId);

    long countByCoupleSpaceIdAndReceiverIdAndIsOpenedFalse(String coupleSpaceId, String receiverId);

    List<GiftTransactionEntity> findByCoupleSpaceIdAndReceiverIdAndIsOpenedFalse(String coupleSpaceId, String receiverId);
}
