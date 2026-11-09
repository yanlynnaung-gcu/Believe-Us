package com.believeus.location.repository;

import com.believeus.location.entity.UserInviteCodeEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.Optional;

@Repository
public interface UserInviteCodeRepository extends JpaRepository<UserInviteCodeEntity, String> {

    Optional<UserInviteCodeEntity> findFirstByCodeIgnoreCaseAndIsUsedFalseAndExpiresAtAfter(String code, Instant now);

    Optional<UserInviteCodeEntity> findFirstByUserIdAndIsUsedFalseAndExpiresAtAfterOrderByCreatedAtDesc(String userId, Instant now);
}
