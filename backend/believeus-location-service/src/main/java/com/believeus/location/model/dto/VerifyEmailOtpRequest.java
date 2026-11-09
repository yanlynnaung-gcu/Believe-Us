package com.believeus.location.model.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VerifyEmailOtpRequest {

    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email address format")
    private String email;

    @NotBlank(message = "Verification code is required")
    @Size(min = 6, max = 6, message = "OTP code must be 6 digits")
    private String otp;
}
