package com.believeus.location.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.Instant;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;

@Service
@Slf4j
public class JwtTokenService {

    private final String secretKey;
    private final ObjectMapper objectMapper;
    private final long expirationSeconds;

    public JwtTokenService(
            @Value("${believeus.jwt.secret:believeus_sacred_couple_jwt_secret_key_2026_super_secure_multi_couple_prod}") String secretKey,
            @Value("${believeus.jwt.expiration-seconds:31536000}") long expirationSeconds,
            ObjectMapper objectMapper) {
        this.secretKey = secretKey;
        this.expirationSeconds = expirationSeconds;
        this.objectMapper = objectMapper;
    }

    public String generateToken(String userId, String email) {
        return generateToken(userId, email, null, null);
    }

    public String generateToken(String userId, String email, String role, String coupleSpaceId) {
        try {
            long now = Instant.now().getEpochSecond();
            long exp = now + expirationSeconds;

            Map<String, Object> header = Map.of(
                    "alg", "HS256",
                    "typ", "JWT"
            );

            Map<String, Object> claims = new HashMap<>();
            claims.put("sub", userId);
            claims.put("userId", userId);
            claims.put("email", email != null ? email : "");
            if (role != null) claims.put("role", role);
            if (coupleSpaceId != null) claims.put("coupleSpaceId", coupleSpaceId);
            claims.put("iat", now);
            claims.put("exp", exp);

            String encodedHeader = base64UrlEncode(objectMapper.writeValueAsBytes(header));
            String encodedPayload = base64UrlEncode(objectMapper.writeValueAsBytes(claims));
            String dataToSign = encodedHeader + "." + encodedPayload;
            String signature = sign(dataToSign, secretKey);

            return dataToSign + "." + signature;
        } catch (Exception e) {
            log.error("Failed to generate JWT token for user: {}", userId, e);
            throw new RuntimeException("Error generating authentication token", e);
        }
    }

    public Map<String, Object> extractAllClaims(String token) {
        try {
            if (token == null || !token.contains(".")) {
                return null;
            }
            if (token.startsWith("Bearer ")) {
                token = token.substring(7);
            }
            String[] parts = token.split("\\.");
            if (parts.length != 3) {
                return null;
            }

            // Verify HMAC signature
            String expectedSig = sign(parts[0] + "." + parts[1], secretKey);
            if (!MessageDigest.isEqual(parts[2].getBytes(StandardCharsets.UTF_8), expectedSig.getBytes(StandardCharsets.UTF_8))) {
                log.warn("Invalid JWT signature");
                return null;
            }

            byte[] payloadBytes = Base64.getUrlDecoder().decode(parts[1]);
            @SuppressWarnings("unchecked")
            Map<String, Object> claims = objectMapper.readValue(payloadBytes, Map.class);

            // Check expiration
            Number exp = (Number) claims.get("exp");
            if (exp != null && exp.longValue() < Instant.now().getEpochSecond()) {
                log.warn("JWT token has expired");
                return null;
            }

            return claims;
        } catch (Exception e) {
            log.warn("Failed to extract claims from token: {}", e.getMessage());
            return null;
        }
    }

    public String extractUserId(String token) {
        Map<String, Object> claims = extractAllClaims(token);
        if (claims == null) return null;
        return (String) claims.get("sub");
    }

    public String extractCoupleSpaceId(String token) {
        Map<String, Object> claims = extractAllClaims(token);
        if (claims == null) return null;
        return (String) claims.get("coupleSpaceId");
    }

    public String extractEmail(String token) {
        Map<String, Object> claims = extractAllClaims(token);
        if (claims == null) return null;
        return (String) claims.get("email");
    }

    public String extractRole(String token) {
        Map<String, Object> claims = extractAllClaims(token);
        if (claims == null) return null;
        return (String) claims.get("role");
    }

    public boolean validateToken(String token) {
        return extractAllClaims(token) != null;
    }

    private String sign(String data, String key) throws Exception {
        Mac mac = Mac.getInstance("HmacSHA256");
        SecretKeySpec secretKeySpec = new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
        mac.init(secretKeySpec);
        byte[] rawHmac = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
        return base64UrlEncode(rawHmac);
    }

    private String base64UrlEncode(byte[] bytes) {
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }
}
