package com.believeus.location.model.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SendEmailOtpRequest {

    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email address format")
    private String email;
}
