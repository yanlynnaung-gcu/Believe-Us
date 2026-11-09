package com.believeus.location.repository;

import com.believeus.location.entity.MilestoneEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface MilestoneRepository extends JpaRepository<MilestoneEntity, String> {

    List<MilestoneEntity> findByCoupleSpaceIdOrderByTargetDateAsc(String coupleSpaceId);

    Optional<MilestoneEntity> findByCoupleSpaceIdAndId(String coupleSpaceId, String id);

    void deleteByCoupleSpaceIdAndId(String coupleSpaceId, String id);
}
