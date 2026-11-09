package com.believeus.location.service;

import com.believeus.location.entity.LocationArrivalLog;
import com.believeus.location.entity.TrustedPlace;
import com.believeus.location.model.MovementStatus;
import com.believeus.location.model.dto.AddTrustedPlaceRequest;
import com.believeus.location.model.dto.LocationHeartbeatRequest;
import com.believeus.location.model.dto.SendSafetyNudgeRequest;
import com.believeus.location.repository.LocationArrivalLogRepository;
import com.believeus.location.repository.TrustedPlaceRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class LocationArrivalService {

    private final LocationArrivalLogRepository arrivalLogRepository;
    private final TrustedPlaceRepository trustedPlaceRepository;
    private final com.believeus.location.repository.UserRepository userRepository;
    private final GeocodingService geocodingService;
    private final FirebaseMessagingService firebaseMessagingService;
    private final com.believeus.location.websocket.SyncWebSocketHandler syncWebSocketHandler;

    private static final double EARTH_RADIUS_METERS = 6371000.0;
    private static final double DEFAULT_DEPARTURE_THRESHOLD_METERS = 200.0;
    private static final double STATIONARY_SPEED_THRESHOLD_KMH = 3.0;

    /**
     * Calculates the great-circle distance between two points in meters using the Haversine formula
     */
    public double calculateDistanceMeters(double lat1, double lon1, double lat2, double lon2) {
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);

        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLon / 2) * Math.sin(dLon / 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return EARTH_RADIUS_METERS * c;
    }

    /**
     * Smart Arrival Detection & Tracking Algorithm
     */
    @Transactional
    public LocationArrivalLog processHeartbeat(LocationHeartbeatRequest request) {
        LocalDateTime now = LocalDateTime.now();

        // Resolve coupleSpaceId from request or persisted UserEntity
        final String resolvedCoupleSpaceId;
        String reqSpaceId = request.getCoupleSpaceId();
        if (reqSpaceId != null && !reqSpaceId.isBlank()) {
            resolvedCoupleSpaceId = reqSpaceId;
        } else {
            resolvedCoupleSpaceId = userRepository.findById(request.getPartnerId())
                    .map(com.believeus.location.entity.UserEntity::getCoupleSpaceId)
                    .orElse(null);
        }

        // Update real UserEntity telemetry
        userRepository.findById(request.getPartnerId()).ifPresent(user -> {
            user.setLastLatitude(request.getLatitude());
            user.setLastLongitude(request.getLongitude());
            user.setBatteryLevel(request.getBatteryLevel());
            user.setIsOnline(true);
            userRepository.save(user);
        });

        // Calculate partner's current speed or distance delta between consecutive pings
        Optional<LocationArrivalLog> lastPingOpt = resolvedCoupleSpaceId != null
                ? arrivalLogRepository.findFirstByCoupleSpaceIdAndUserIdOrderByLastUpdatedAtDesc(resolvedCoupleSpaceId, request.getPartnerId())
                : arrivalLogRepository.findFirstByUserIdOrderByLastUpdatedAtDesc(request.getPartnerId());
        double calculatedSpeedKmh = 0.0;
        double distDeltaMeters = 0.0;
        boolean movementDetected = false;

        if (lastPingOpt.isPresent()) {
            LocationArrivalLog lastPing = lastPingOpt.get();
            distDeltaMeters = calculateDistanceMeters(
                    request.getLatitude(),
                    request.getLongitude(),
                    lastPing.getLatitude(),
                    lastPing.getLongitude()
            );
            long seconds = Math.max(1, java.time.Duration.between(lastPing.getLastUpdatedAt(), now).getSeconds());
            if (seconds <= 120 && distDeltaMeters > 20.0) {
                calculatedSpeedKmh = (distDeltaMeters / seconds) * 3.6;
                movementDetected = true;
            }
        }

        double effectiveSpeed = (request.getSpeedKmh() != null && request.getSpeedKmh() > 0.0)
                ? request.getSpeedKmh()
                : calculatedSpeedKmh;

        if (effectiveSpeed > STATIONARY_SPEED_THRESHOLD_KMH) {
            movementDetected = true;
        }

        List<TrustedPlace> trustedPlaces = trustedPlaceRepository.findByUserId(request.getPartnerId());

        // 1. Check if within geofence of any Trusted Place (default 150m)
        TrustedPlace matchedPlace = null;
        for (TrustedPlace place : trustedPlaces) {
            double distance = calculateDistanceMeters(
                    request.getLatitude(),
                    request.getLongitude(),
                    place.getLatitude(),
                    place.getLongitude()
            );
            if (distance <= place.getRadiusMeters()) {
                matchedPlace = place;
                break;
            }
        }

        Optional<LocationArrivalLog> activeLogOpt = resolvedCoupleSpaceId != null
                ? arrivalLogRepository.findFirstByCoupleSpaceIdAndUserIdAndDepartedAtIsNullOrderByArrivedAtDesc(resolvedCoupleSpaceId, request.getPartnerId())
                : arrivalLogRepository.findFirstByUserIdAndDepartedAtIsNullOrderByArrivedAtDesc(request.getPartnerId());

        if (matchedPlace != null) {
            // Partner is currently inside a Trusted Place radius (e.g. Home, Office)
            if (activeLogOpt.isPresent()) {
                LocationArrivalLog activeLog = activeLogOpt.get();
                if (activeLog.getPlaceName().equals(matchedPlace.getName())) {
                    // Continuing stay at current place -> update telemetry & lastUpdatedAt
                    activeLog.setLatitude(request.getLatitude());
                    activeLog.setLongitude(request.getLongitude());
                    activeLog.setBatteryLevel(request.getBatteryLevel());
                    activeLog.setIsCharging(request.getIsCharging());
                    activeLog.setSpeedKmh(effectiveSpeed);
                    activeLog.setStatus(movementDetected ? MovementStatus.MOVING : MovementStatus.STATIONARY);
                    activeLog.setLastUpdatedAt(now);
                    return notifyLocationWs(arrivalLogRepository.save(activeLog), request.getPartnerId());
                } else {
                    // Partner moved directly from another place -> Depart previous
                    activeLog.setDepartedAt(now);
                    activeLog.setStatus(MovementStatus.MOVING);
                    arrivalLogRepository.save(activeLog);
                }
            }

            // Create new Arrival record
            String address = geocodingService.reverseGeocode(request.getLatitude(), request.getLongitude());
            LocationArrivalLog newArrival = LocationArrivalLog.builder()
                    .coupleSpaceId(resolvedCoupleSpaceId)
                    .userId(request.getPartnerId())
                    .latitude(request.getLatitude())
                    .longitude(request.getLongitude())
                    .addressLine(address)
                    .placeName(matchedPlace.getName())
                    .status(movementDetected ? MovementStatus.MOVING : MovementStatus.STATIONARY)
                    .speedKmh(effectiveSpeed)
                    .batteryLevel(request.getBatteryLevel())
                    .isCharging(request.getIsCharging())
                    .arrivedAt(now)
                    .departedAt(null)
                    .lastUpdatedAt(now)
                    .build();

            LocationArrivalLog saved = arrivalLogRepository.save(newArrival);

            // Send instant FCM high-priority arrival notification
            if (Boolean.TRUE.equals(matchedPlace.getNotifyArrival())) {
                firebaseMessagingService.sendArrivalNotification(
                        request.getPartnerName(),
                        matchedPlace.getName(),
                        now,
                        request.getBatteryLevel()
                );
            }

            return notifyLocationWs(saved, request.getPartnerId());
        }

        // Partner is outside trusted places
        if (activeLogOpt.isPresent()) {
            LocationArrivalLog activeLog = activeLogOpt.get();
            double distFromActive = calculateDistanceMeters(
                    request.getLatitude(),
                    request.getLongitude(),
                    activeLog.getLatitude(),
                    activeLog.getLongitude()
            );

            if (distFromActive > DEFAULT_DEPARTURE_THRESHOLD_METERS) {
                // Partner moved > 200m away -> departed!
                activeLog.setDepartedAt(now);
                activeLog.setStatus(MovementStatus.MOVING);
                arrivalLogRepository.save(activeLog);
                log.info("Partner '{}' departed from '{}' (moved {}m)",
                        request.getPartnerId(), activeLog.getPlaceName(), Math.round(distFromActive));
            } else {
                // Continuing at current location
                activeLog.setLastUpdatedAt(now);
                activeLog.setBatteryLevel(request.getBatteryLevel());
                activeLog.setIsCharging(request.getIsCharging());
                activeLog.setSpeedKmh(effectiveSpeed);
                activeLog.setStatus(movementDetected ? MovementStatus.MOVING : MovementStatus.STATIONARY);
                return notifyLocationWs(arrivalLogRepository.save(activeLog), request.getPartnerId());
            }
        }

        // Check if partner is stationary or moving in transit
        if (!movementDetected && effectiveSpeed <= STATIONARY_SPEED_THRESHOLD_KMH) {
            String address = geocodingService.reverseGeocode(request.getLatitude(), request.getLongitude());
            String placeLabel = address.contains(",") ? address.split(",")[0].trim() : address;

            LocationArrivalLog newArrival = LocationArrivalLog.builder()
                    .coupleSpaceId(resolvedCoupleSpaceId)
                    .userId(request.getPartnerId())
                    .latitude(request.getLatitude())
                    .longitude(request.getLongitude())
                    .addressLine(address)
                    .placeName(placeLabel)
                    .status(MovementStatus.STATIONARY)
                    .speedKmh(effectiveSpeed)
                    .batteryLevel(request.getBatteryLevel())
                    .isCharging(request.getIsCharging())
                    .arrivedAt(now)
                    .departedAt(null)
                    .lastUpdatedAt(now)
                    .build();

            return notifyLocationWs(arrivalLogRepository.save(newArrival), request.getPartnerId());
        }

        // Moving in transit (> 3 km/h or > 20m delta in 2 mins)
        LocationArrivalLog inTransit = LocationArrivalLog.builder()
                .coupleSpaceId(resolvedCoupleSpaceId)
                .userId(request.getPartnerId())
                .latitude(request.getLatitude())
                .longitude(request.getLongitude())
                .addressLine("In Transit")
                .placeName(String.format("Moving (%.0f km/h)", effectiveSpeed))
                .status(MovementStatus.MOVING)
                .speedKmh(effectiveSpeed)
                .batteryLevel(request.getBatteryLevel())
                .isCharging(request.getIsCharging())
                .arrivedAt(now)
                .departedAt(null)
                .lastUpdatedAt(now)
                .build();
        return notifyLocationWs(inTransit, request.getPartnerId());
    }

    private LocationArrivalLog notifyLocationWs(LocationArrivalLog log, String partnerId) {
        if (log != null) {
            com.believeus.location.model.dto.ArrivalLogResponse dto =
                    com.believeus.location.model.dto.ArrivalLogResponse.fromEntity(log);
            syncWebSocketHandler.sendToUser(partnerId, "LOCATION_UPDATE", dto);
            userRepository.findById(partnerId).ifPresent(user -> {
                if (user.getPartnerId() != null) {
                    syncWebSocketHandler.sendToUser(user.getPartnerId(), "LOCATION_UPDATE", dto);
                }
                String spaceId = log.getCoupleSpaceId() != null ? log.getCoupleSpaceId() : user.getCoupleSpaceId();
                if (spaceId != null) {
                    syncWebSocketHandler.broadcastToCoupleSpace(spaceId, "LOCATION_UPDATE", dto);
                }
            });
        }
        return log;
    }

    @Transactional(readOnly = true)
    public List<LocationArrivalLog> getTodayArrivalLogs(String userId) {
        return arrivalLogRepository.findByUserIdOrderByArrivedAtDesc(userId);
    }

    @Transactional(readOnly = true)
    public List<LocationArrivalLog> getTodayArrivalLogs(String coupleSpaceId, String userId) {
        if (coupleSpaceId != null) {
            return arrivalLogRepository.findByCoupleSpaceIdAndUserIdOrderByArrivedAtDesc(coupleSpaceId, userId);
        }
        return arrivalLogRepository.findByUserIdOrderByArrivedAtDesc(userId);
    }

    @Transactional(readOnly = true)
    public List<TrustedPlace> getTrustedPlaces(String userId) {
        return trustedPlaceRepository.findByUserId(userId);
    }

    @Transactional(readOnly = true)
    public List<TrustedPlace> getTrustedPlacesBySpace(String coupleSpaceId) {
        return trustedPlaceRepository.findByCoupleSpaceId(coupleSpaceId);
    }

    @Transactional
    public TrustedPlace addTrustedPlace(AddTrustedPlaceRequest request) {
        String coupleSpaceId = userRepository.findById(request.getUserId())
                .map(com.believeus.location.entity.UserEntity::getCoupleSpaceId)
                .orElse(null);

        TrustedPlace place = TrustedPlace.builder()
                .coupleSpaceId(coupleSpaceId)
                .userId(request.getUserId())
                .name(request.getName())
                .iconName(request.getIconName())
                .latitude(request.getLatitude())
                .longitude(request.getLongitude())
                .radiusMeters(request.getRadiusMeters())
                .notifyArrival(request.getNotifyArrival())
                .notifyDeparture(request.getNotifyDeparture())
                .createdAt(LocalDateTime.now())
                .build();

        return trustedPlaceRepository.save(place);
    }

    public boolean sendSafetyNudge(SendSafetyNudgeRequest request) {
        syncWebSocketHandler.sendToUser(request.getPartnerName(), "SAFETY_NUDGE", Map.of(
                "title", "💌 Partner sent a safety heart",
                "message", "Have you reached safely, my love?",
                "partnerName", request.getPartnerName()
        ));
        return firebaseMessagingService.sendSafetyNudgeNotification(
                request.getPartnerName(),
                request.getPartnerName()
        );
    }

    @Transactional(readOnly = true)
    public Optional<LocationArrivalLog> getLatestLocation(String userId) {
        return arrivalLogRepository.findFirstByUserIdOrderByArrivedAtDesc(userId);
    }
}
