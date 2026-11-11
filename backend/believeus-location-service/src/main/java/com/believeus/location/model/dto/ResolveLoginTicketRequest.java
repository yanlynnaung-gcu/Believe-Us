package com.believeus.location.model.dto;

import jakarta.validation.constraints.NotNull;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ResolveLoginTicketRequest {

    @NotNull(message = "Approval decision (true/false) is required")
    private Boolean approved;
}
