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
public class GoogleAuthRequest {

    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    private String email;

    @NotBlank(message = "Display name is required")
    private String displayName;

    private String photoUrl;

    private String googleId;

    private String role; // "BOYFRIEND" or "GIRLFRIEND"

    private LocalDate birthday;
}
