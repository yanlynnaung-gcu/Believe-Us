package com.believeus.location.repository;

import com.believeus.location.entity.TrustedPlace;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TrustedPlaceRepository extends JpaRepository<TrustedPlace, Long> {

    List<TrustedPlace> findByUserId(String userId);

    List<TrustedPlace> findByCoupleSpaceId(String coupleSpaceId);

    List<TrustedPlace> findByCoupleSpaceIdAndUserId(String coupleSpaceId, String userId);
}
