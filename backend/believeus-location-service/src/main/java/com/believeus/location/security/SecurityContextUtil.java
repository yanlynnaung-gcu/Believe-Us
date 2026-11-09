package com.believeus.location.security;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

public final class SecurityContextUtil {

    private SecurityContextUtil() {}

    public static UserPrincipal getCurrentPrincipal() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getPrincipal() instanceof UserPrincipal principal) {
            return principal;
        }
        return null;
    }

    public static String getCurrentUserId() {
        UserPrincipal principal = getCurrentPrincipal();
        return principal != null ? principal.getUserId() : null;
    }

    public static String getCurrentCoupleSpaceId() {
        UserPrincipal principal = getCurrentPrincipal();
        return principal != null ? principal.getCoupleSpaceId() : null;
    }

    public static String requireCurrentUserId() {
        String userId = getCurrentUserId();
        if (userId == null || userId.isBlank()) {
            throw new AccessDeniedException("Authentication required: No authenticated user in security context");
        }
        return userId;
    }

    public static String requireCurrentCoupleSpaceId() {
        String spaceId = getCurrentCoupleSpaceId();
        if (spaceId == null || spaceId.isBlank()) {
            throw new AccessDeniedException("Couple Space required: User is not currently bonded to a partner space");
        }
        return spaceId;
    }

    public static void validateCoupleSpaceAccess(String targetCoupleSpaceId) {
        if (targetCoupleSpaceId == null || targetCoupleSpaceId.isBlank()) {
            return;
        }
        UserPrincipal principal = getCurrentPrincipal();
        if (principal != null && principal.getCoupleSpaceId() != null) {
            if (!principal.getCoupleSpaceId().equals(targetCoupleSpaceId)) {
                throw new AccessDeniedException("Data Isolation Enforced: You do not have permission to access couple space '" + targetCoupleSpaceId + "'");
            }
        }
    }
}
