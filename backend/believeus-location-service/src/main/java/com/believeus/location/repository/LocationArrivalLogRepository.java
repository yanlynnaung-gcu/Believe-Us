package com.believeus.location.repository;

import com.believeus.location.entity.LocationArrivalLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface LocationArrivalLogRepository extends JpaRepository<LocationArrivalLog, Long> {

    List<LocationArrivalLog> findByUserIdOrderByArrivedAtDesc(String userId);

    Optional<LocationArrivalLog> findFirstByUserIdAndDepartedAtIsNullOrderByArrivedAtDesc(String userId);

    Optional<LocationArrivalLog> findFirstByUserIdOrderByArrivedAtDesc(String userId);

    Optional<LocationArrivalLog> findFirstByUserIdOrderByLastUpdatedAtDesc(String userId);

    // Couple-Space Isolated Queries
    List<LocationArrivalLog> findByCoupleSpaceIdOrderByArrivedAtDesc(String coupleSpaceId);

    List<LocationArrivalLog> findByCoupleSpaceIdAndUserIdOrderByArrivedAtDesc(String coupleSpaceId, String userId);

    Optional<LocationArrivalLog> findFirstByCoupleSpaceIdAndUserIdAndDepartedAtIsNullOrderByArrivedAtDesc(String coupleSpaceId, String userId);

    Optional<LocationArrivalLog> findFirstByCoupleSpaceIdAndUserIdOrderByArrivedAtDesc(String coupleSpaceId, String userId);

    Optional<LocationArrivalLog> findFirstByCoupleSpaceIdAndUserIdOrderByLastUpdatedAtDesc(String coupleSpaceId, String userId);
}
