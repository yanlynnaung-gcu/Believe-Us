package com.believeus.location.repository;

import com.believeus.location.entity.UserEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<UserEntity, String> {
    Optional<UserEntity> findByEmailIgnoreCase(String email);
    Optional<UserEntity> findByPartnerId(String partnerId);
    boolean existsByEmailIgnoreCase(String email);
}
