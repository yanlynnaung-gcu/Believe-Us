package com.believeus.location.repository;

import com.believeus.location.entity.EmailOtpEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.Optional;

@Repository
public interface EmailOtpRepository extends JpaRepository<EmailOtpEntity, Long> {

    Optional<EmailOtpEntity> findTopByEmailIgnoreCaseAndVerifiedFalseOrderByCreatedAtDesc(String email);

    void deleteByExpiresAtBefore(LocalDateTime now);
}
