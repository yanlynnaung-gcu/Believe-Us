package com.believeus.location.model.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.*;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RegisterRequest {

    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    private String email;

    @NotBlank(message = "Password is required")
    private String password;

    @NotBlank(message = "Display name is required")
    private String displayName;

    @NotBlank(message = "Role is required (BOYFRIEND or GIRLFRIEND)")
    private String role; // "BOYFRIEND" or "GIRLFRIEND"

    private LocalDate birthday;

    private String avatarUrl;

    private String deviceId;

    private String deviceName;
}
