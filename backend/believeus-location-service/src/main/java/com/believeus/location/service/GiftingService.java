package com.believeus.location.service;

import com.believeus.location.entity.GiftTransactionEntity;
import com.believeus.location.model.dto.ChatMessageDto;
import com.believeus.location.model.dto.GiftingRequest;
import com.believeus.location.model.dto.GiftingResponse;
import com.believeus.location.repository.GiftTransactionRepository;
import com.believeus.location.websocket.SyncWebSocketHandler;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.text.NumberFormat;
import java.time.LocalDateTime;
import java.util.*;

@Service
@RequiredArgsConstructor
@Slf4j
public class GiftingService {

    private final ChatService chatService;
    private final SyncWebSocketHandler syncWebSocketHandler;
    private final GiftTransactionRepository giftTransactionRepository;

    public List<Map<String, Object>> getAvailablePackages() {
        return List.of(
                Map.of("id", "pkg_tea", "title", "Romantic Bubble Tea 🧋", "amountMmK", 6000, "description", "Afternoon sweet treat delivered"),
                Map.of("id", "pkg_flowers", "title", "Pink Rose Bouquet 💐", "amountMmK", 25000, "description", "Fresh long-stem roses with sweet message card"),
                Map.of("id", "pkg_dinner", "title", "Candlelight Dinner Date 🕯️", "amountMmK", 65000, "description", "Romantic evening dinner for two"),
                Map.of("id", "pkg_spa", "title", "Relaxing Couple Spa Treatment 🧖‍♀️", "amountMmK", 120000, "description", "Full relaxation aromatherapy spa session")
        );
    }

    @Transactional
    public GiftingResponse processPayment(GiftingRequest request) {
        String txnId = "txn_" + UUID.randomUUID().toString().substring(0, 8);
        String ref = (request.getProvider() != null && request.getProvider().toUpperCase().contains("WAVE") ? "WAVE" : "KPAY")
                + "-" + System.currentTimeMillis();
        LocalDateTime now = LocalDateTime.now();

        // 1. Save persistent Gift Transaction entity
        GiftTransactionEntity entity = GiftTransactionEntity.builder()
                .id(txnId)
                .senderId(request.getSenderId())
                .receiverId(request.getReceiverId())
                .coupleSpaceId(request.getCoupleSpaceId())
                .packageTitle(request.getPackageTitle())
                .amountMmK(request.getAmountMmK())
                .provider(request.getProvider())
                .transactionRef(ref)
                .status("PAID")
                .note(request.getNote())
                .isOpened(false)
                .createdAt(now)
                .build();
        giftTransactionRepository.save(entity);

        GiftingResponse response = GiftingResponse.builder()
                .id(txnId)
                .senderId(request.getSenderId())
                .receiverId(request.getReceiverId())
                .coupleSpaceId(request.getCoupleSpaceId())
                .packageTitle(request.getPackageTitle())
                .amountMmK(request.getAmountMmK())
                .provider(request.getProvider())
                .transactionRef(ref)
                .status("PAID")
                .note(request.getNote())
                .createdAt(now)
                .build();

        // Automatically create in-chat gift message (Domain Rule #5)
        NumberFormat fmt = NumberFormat.getInstance(Locale.US);
        String formattedAmount = fmt.format(request.getAmountMmK()) + " MMK";

        Map<String, Object> giftData = new HashMap<>();
        giftData.put("transactionId", txnId);
        giftData.put("transactionRef", ref);
        giftData.put("amount", formattedAmount);
        giftData.put("amountRaw", request.getAmountMmK());
        giftData.put("packageName", request.getPackageTitle());
        giftData.put("provider", request.getProvider() != null ? request.getProvider() : "KBZPay");
        giftData.put("note", request.getNote());
        giftData.put("sentAt", now.toString());

        ChatMessageDto chatDto = ChatMessageDto.builder()
                .id("msg_" + UUID.randomUUID().toString().substring(0, 8))
                .senderId(request.getSenderId())
                .receiverId(request.getReceiverId())
                .coupleSpaceId(request.getCoupleSpaceId())
                .type("gift")
                .giftData(giftData)
                .createdAt(now)
                .isRead(false)
                .build();

        chatService.sendMessage(chatDto);

        // Broadcast GIFT_RECEIVED event via WebSocket to receiver and couple space
        syncWebSocketHandler.sendToUser(request.getReceiverId(), "GIFT_RECEIVED", response);
        syncWebSocketHandler.broadcastToCoupleSpace(request.getCoupleSpaceId(), "GIFT_RECEIVED", response);

        log.info("[Gift Processed] {} MMK sent via {} to {}", request.getAmountMmK(), request.getProvider(), request.getReceiverId());
        return response;
    }

    @Transactional(readOnly = true)
    public long getUnseenGiftsCount(String coupleSpaceId, String receiverId) {
        return giftTransactionRepository.countByCoupleSpaceIdAndReceiverIdAndIsOpenedFalse(coupleSpaceId, receiverId);
    }

    @Transactional
    public long markGiftsAsSeen(String coupleSpaceId, String receiverId) {
        List<GiftTransactionEntity> unseen = giftTransactionRepository
                .findByCoupleSpaceIdAndReceiverIdAndIsOpenedFalse(coupleSpaceId, receiverId);
        if (!unseen.isEmpty()) {
            for (GiftTransactionEntity g : unseen) {
                g.setIsOpened(true);
            }
            giftTransactionRepository.saveAll(unseen);
        }

        Map<String, Object> zeroPayload = Map.of(
                "coupleSpaceId", coupleSpaceId,
                "receiverId", receiverId,
                "unseenCount", 0L
        );
        syncWebSocketHandler.sendToUser(receiverId, "GIFT_SEEN", zeroPayload);
        syncWebSocketHandler.broadcastToCoupleSpace(coupleSpaceId, "GIFT_SEEN", zeroPayload);

        log.info("[Gifts Seen] Marked {} unseen gifts as opened for user '{}' in space '{}'",
                unseen.size(), receiverId, coupleSpaceId);
        return unseen.size();
    }
}
