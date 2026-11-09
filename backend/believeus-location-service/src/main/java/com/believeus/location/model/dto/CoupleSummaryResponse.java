package com.believeus.location.model.dto;

import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CoupleSummaryResponse {
    private String coupleSpaceId;
    private String coverPhotoUrl;
    private LocalDateTime anniversaryDate;
    private Long daysTogether;
    private UserProfileDto myProfile;
    private UserProfileDto partnerProfile;
}
