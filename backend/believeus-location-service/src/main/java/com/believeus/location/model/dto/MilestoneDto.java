package com.believeus.location.model.dto;

import com.believeus.location.entity.MilestoneEntity;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MilestoneDto {

    private String id;
    private String coupleSpaceId;

    @NotBlank(message = "Title is required")
    private String title;

    @NotNull(message = "Target date is required")
    private LocalDateTime targetDate;

    @Builder.Default
    private Boolean isRecurringAnnual = true;

    @Builder.Default
    private String iconEmoji = "❤️";

    private String note;

    @Builder.Default
    private String category = "Anniversary";

    private LocalDateTime createdAt;

    public static MilestoneDto fromEntity(MilestoneEntity entity) {
        if (entity == null) return null;
        return MilestoneDto.builder()
                .id(entity.getId())
                .coupleSpaceId(entity.getCoupleSpaceId())
                .title(entity.getTitle())
                .targetDate(entity.getTargetDate())
                .isRecurringAnnual(entity.getIsRecurringAnnual())
                .iconEmoji(entity.getIconEmoji())
                .note(entity.getNote())
                .category(entity.getCategory())
                .createdAt(entity.getCreatedAt())
                .build();
    }
}
