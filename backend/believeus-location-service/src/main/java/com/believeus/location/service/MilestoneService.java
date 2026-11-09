package com.believeus.location.service;

import com.believeus.location.entity.MilestoneEntity;
import com.believeus.location.model.dto.MilestoneDto;
import com.believeus.location.repository.MilestoneRepository;
import com.believeus.location.websocket.SyncWebSocketHandler;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class MilestoneService {

    private final MilestoneRepository milestoneRepository;
    private final SyncWebSocketHandler syncWebSocketHandler;

    @Transactional(readOnly = true)
    public List<MilestoneDto> getMilestones(String coupleSpaceId) {
        if (coupleSpaceId == null || coupleSpaceId.isBlank()) {
            return List.of();
        }
        return milestoneRepository.findByCoupleSpaceIdOrderByTargetDateAsc(coupleSpaceId)
                .stream()
                .map(MilestoneDto::fromEntity)
                .toList();
    }

    @Transactional
    public MilestoneDto addMilestone(String coupleSpaceId, MilestoneDto dto) {
        if (coupleSpaceId == null || coupleSpaceId.isBlank()) {
            throw new IllegalArgumentException("Cannot add milestone without a valid CoupleSpace");
        }

        String id = dto.getId() != null && !dto.getId().isBlank()
                ? dto.getId()
                : "ms_" + UUID.randomUUID().toString().substring(0, 8);

        MilestoneEntity entity = MilestoneEntity.builder()
                .id(id)
                .coupleSpaceId(coupleSpaceId)
                .title(dto.getTitle())
                .targetDate(dto.getTargetDate())
                .isRecurringAnnual(dto.getIsRecurringAnnual() != null ? dto.getIsRecurringAnnual() : true)
                .iconEmoji(dto.getIconEmoji() != null ? dto.getIconEmoji() : "❤️")
                .note(dto.getNote())
                .category(dto.getCategory() != null ? dto.getCategory() : "Anniversary")
                .createdAt(LocalDateTime.now())
                .build();

        MilestoneEntity saved = milestoneRepository.save(entity);
        MilestoneDto responseDto = MilestoneDto.fromEntity(saved);

        // Dynamic couple room broadcast
        syncWebSocketHandler.broadcastToCoupleTopic(
                coupleSpaceId,
                "milestones",
                "MILESTONE_ADDED",
                responseDto
        );
        log.info("[Milestone Added] CoupleSpace: {}, Title: '{}'", coupleSpaceId, entity.getTitle());

        return responseDto;
    }

    @Transactional
    public void deleteMilestone(String coupleSpaceId, String milestoneId) {
        if (coupleSpaceId == null || coupleSpaceId.isBlank() || milestoneId == null) {
            return;
        }
        milestoneRepository.deleteByCoupleSpaceIdAndId(coupleSpaceId, milestoneId);

        syncWebSocketHandler.broadcastToCoupleTopic(
                coupleSpaceId,
                "milestones",
                "MILESTONE_DELETED",
                java.util.Map.of("milestoneId", milestoneId)
        );
        log.info("[Milestone Deleted] CoupleSpace: {}, MilestoneId: {}", coupleSpaceId, milestoneId);
    }
}
