package com.believeus.location.repository;

import com.believeus.location.entity.CoupleSpaceEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface CoupleSpaceRepository extends JpaRepository<CoupleSpaceEntity, String> {

    Optional<CoupleSpaceEntity> findByInviteCodeAndIsActiveTrue(String inviteCode);

    @Query("SELECT c FROM CoupleSpaceEntity c WHERE (c.user1Id = :userId OR c.user2Id = :userId) AND c.isActive = true")
    Optional<CoupleSpaceEntity> findActiveSpaceByUserId(@Param("userId") String userId);
}
