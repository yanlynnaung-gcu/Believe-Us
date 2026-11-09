package com.believeus.location.security;

import com.believeus.location.entity.UserEntity;
import com.believeus.location.repository.UserRepository;
import com.believeus.location.service.JwtTokenService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Map;
import java.util.Optional;

@Component
@RequiredArgsConstructor
@Slf4j
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtTokenService jwtTokenService;
    private final UserRepository userRepository;

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {

        try {
            String token = resolveToken(request);
            if (StringUtils.hasText(token)) {
                Map<String, Object> claims = jwtTokenService.extractAllClaims(token);
                if (claims != null) {
                    String userId = (String) claims.get("sub");
                    String email = (String) claims.get("email");
                    String role = (String) claims.get("role");
                    String coupleSpaceId = (String) claims.get("coupleSpaceId");

                    // Fallback: If token was issued before pairing, lazily sync coupleSpaceId from DB
                    if ((coupleSpaceId == null || coupleSpaceId.isBlank()) && userId != null) {
                        Optional<UserEntity> userOpt = userRepository.findById(userId);
                        if (userOpt.isPresent()) {
                            coupleSpaceId = userOpt.get().getCoupleSpaceId();
                            if (role == null) {
                                role = userOpt.get().getRole();
                            }
                        }
                    }

                    UserPrincipal principal = UserPrincipal.builder()
                            .userId(userId)
                            .email(email)
                            .role(role)
                            .coupleSpaceId(coupleSpaceId)
                            .build();

                    UsernamePasswordAuthenticationToken authentication =
                            new UsernamePasswordAuthenticationToken(
                                    principal,
                                    null,
                                    principal.getAuthorities()
                            );
                    authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                    SecurityContextHolder.getContext().setAuthentication(authentication);
                }
            }
        } catch (Exception e) {
            log.error("[JWT Filter Error] Could not set user authentication in security context: {}", e.getMessage());
        }

        filterChain.doFilter(request, response);
    }

    private String resolveToken(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (StringUtils.hasText(bearerToken) && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }
}
