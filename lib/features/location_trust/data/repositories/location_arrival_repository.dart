import 'dart:math';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:thae_nge_lay/core/errors/failure.dart';
import 'package:thae_nge_lay/core/network/api_client.dart';
import 'package:thae_nge_lay/features/location_trust/data/services/geocoding_service.dart';
import 'package:thae_nge_lay/features/location_trust/domain/models/partner_location_arrival_model.dart';
import 'package:thae_nge_lay/features/location_trust/domain/models/trusted_place_model.dart';
import 'package:thae_nge_lay/features/notifications/data/services/fcm_notification_service.dart';

class LocationArrivalRepository {
  final Dio _dio;
  final GeocodingService _geocodingService;
  final FcmNotificationService _fcmService;

  LocationArrivalRepository({
    Dio? dio,
    required GeocodingService geocodingService,
    required FcmNotificationService fcmService,
  })  : _dio = dio ?? Dio(),
        _geocodingService = geocodingService,
        _fcmService = fcmService;

  final List<TrustedPlaceModel> _cachedTrustedPlaces = [
    TrustedPlaceModel(
      id: 'place-home',
      name: 'Sweet Home',
      iconName: 'home',
      latitude: 16.8295,
      longitude: 96.1305,
      radiusMeters: 150.0,
      notifyArrival: true,
      notifyDeparture: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    TrustedPlaceModel(
      id: 'place-office',
      name: 'Tech Office (Hledan)',
      iconName: 'briefcase',
      latitude: 16.8271,
      longitude: 96.1284,
      radiusMeters: 150.0,
      notifyArrival: true,
      notifyDeparture: true,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    TrustedPlaceModel(
      id: 'place-cafe',
      name: 'Romantic Coffee Bar',
      iconName: 'coffee',
      latitude: 16.8053,
      longitude: 96.1558,
      radiusMeters: 150.0,
      notifyArrival: true,
      notifyDeparture: true,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  late final List<PartnerLocationArrivalModel> _cachedArrivalLogs = [
    PartnerLocationArrivalModel(
      id: 'log-1',
      userId: 'partner_thae_nge_lay',
      latitude: 16.8295,
      longitude: 96.1305,
      addressLine: 'No. 42, Pyay Road, Kamayut Township',
      placeName: 'Sweet Home',
      status: MovementStatus.stationary,
      speedKmh: 0.0,
      batteryLevel: 95,
      isCharging: false,
      arrivedAt: DateTime.now().subtract(const Duration(hours: 10)),
      departedAt: DateTime.now().subtract(const Duration(hours: 6)),
      lastUpdatedAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    PartnerLocationArrivalModel(
      id: 'log-2',
      userId: 'partner_thae_nge_lay',
      latitude: 16.8271,
      longitude: 96.1284,
      addressLine: 'Hledan Center, Insein Road, Kamayut',
      placeName: 'Tech Office (Hledan)',
      status: MovementStatus.stationary,
      speedKmh: 0.0,
      batteryLevel: 84,
      isCharging: true,
      arrivedAt: DateTime.now().subtract(const Duration(hours: 5, minutes: 30)),
      departedAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 18)),
      lastUpdatedAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 18)),
    ),
    PartnerLocationArrivalModel(
      id: 'log-active',
      userId: 'partner_thae_nge_lay',
      latitude: 16.8295,
      longitude: 96.1305,
      addressLine: 'No. 42, Pyay Road, Kamayut Township',
      placeName: 'Sweet Home',
      status: MovementStatus.stationary,
      speedKmh: 0.0,
      batteryLevel: 78,
      isCharging: true,
      arrivedAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 18)),
      departedAt: null,
      lastUpdatedAt: DateTime.now(),
    ),
  ];

  /// Haversine formula to calculate accurate ground distance in meters
  double calculateDistanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371000.0;
    final dLat = (lat2 - lat1) * pi / 180.0;
    final dLon = (lon2 - lon1) * pi / 180.0;

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180.0) *
            cos(lat2 * pi / 180.0) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  /// Get today's chronological arrival logs from the local Spring Boot backend
  Future<Either<Failure, List<PartnerLocationArrivalModel>>> getTodayArrivalLogs({
    String userId = 'partner_thae_nge_lay',
  }) async {
    try {
      final response = await _dio.get('${ApiEndpoints.arrivalsPath}/$userId');
      if (response.statusCode == 200 && response.data is List) {
        final logs = (response.data as List).map((json) {
          return PartnerLocationArrivalModel.fromJson(
            Map<String, dynamic>.from(json as Map),
          );
        }).toList();

        return right(logs);
      }
      return left(
        Failure.server('Unexpected server response: ${response.statusCode}'),
      );
    } on DioException catch (dioErr) {
      // Graceful offline fallback to cached logs if backend is unreachable
      if (_cachedArrivalLogs.isNotEmpty) {
        return right(List.unmodifiable(_cachedArrivalLogs.reversed));
      }
      return left(
        Failure.server('Failed to reach location service: ${dioErr.message}'),
      );
    } catch (e) {
      return left(Failure.server('Failed to retrieve arrival logs: $e'));
    }
  }

  /// Get trusted saved places from the local Spring Boot backend
  Future<Either<Failure, List<TrustedPlaceModel>>> getTrustedPlaces({
    String userId = 'partner_thae_nge_lay',
  }) async {
    try {
      final response = await _dio.get('${ApiEndpoints.placesPath}/$userId');
      if (response.statusCode == 200 && response.data is List) {
        final places = (response.data as List).map((json) {
          return TrustedPlaceModel.fromJson(
            Map<String, dynamic>.from(json as Map),
          );
        }).toList();

        return right(places);
      }
      return left(
        Failure.server('Unexpected server response: ${response.statusCode}'),
      );
    } on DioException catch (dioErr) {
      if (_cachedTrustedPlaces.isNotEmpty) {
        return right(List.unmodifiable(_cachedTrustedPlaces));
      }
      return left(
        Failure.server('Failed to fetch trusted places: ${dioErr.message}'),
      );
    } catch (e) {
      return left(Failure.server('Failed to retrieve trusted places: $e'));
    }
  }

  /// Add a new trusted place via local Spring Boot backend
  Future<Either<Failure, TrustedPlaceModel>> addTrustedPlace({
    String userId = 'partner_thae_nge_lay',
    required String name,
    required String iconName,
    required double latitude,
    required double longitude,
    double radiusMeters = 150.0,
    bool notifyArrival = true,
    bool notifyDeparture = true,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.placesPath,
        data: {
          'userId': userId,
          'name': name,
          'iconName': iconName,
          'latitude': latitude,
          'longitude': longitude,
          'radiusMeters': radiusMeters,
          'notifyArrival': notifyArrival,
          'notifyDeparture': notifyDeparture,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final created = TrustedPlaceModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
        _cachedTrustedPlaces.add(created);
        return right(created);
      }
      return left(Failure.server('Failed to save place: ${response.statusCode}'));
    } on DioException catch (_) {
      // Local fallback
      final fallback = TrustedPlaceModel(
        id: 'place-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        iconName: iconName,
        latitude: latitude,
        longitude: longitude,
        radiusMeters: radiusMeters,
        notifyArrival: notifyArrival,
        notifyDeparture: notifyDeparture,
        createdAt: DateTime.now(),
      );
      _cachedTrustedPlaces.add(fallback);
      return right(fallback);
    } catch (e) {
      return left(Failure.server('Failed to save trusted place: $e'));
    }
  }

  /// Process incoming location telemetry with the Smart Arrival Algorithm
  Future<Either<Failure, PartnerLocationArrivalModel>> processLocationHeartbeat({
    required String partnerId,
    required String partnerName,
    required double latitude,
    required double longitude,
    required double speedKmh,
    required int batteryLevel,
    required bool isCharging,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.heartbeatPath,
        data: {
          'partnerId': partnerId,
          'partnerName': partnerName,
          'latitude': latitude,
          'longitude': longitude,
          'speedKmh': speedKmh,
          'batteryLevel': batteryLevel,
          'isCharging': isCharging,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final arrivalLog = PartnerLocationArrivalModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
        return right(arrivalLog);
      }
      return left(Failure.server('Heartbeat failed: ${response.statusCode}'));
    } on DioException catch (_) {
      // Fallback to local computation with Smart Arrival Algorithm
      return _processLocalHeartbeat(
        partnerId: partnerId,
        partnerName: partnerName,
        latitude: latitude,
        longitude: longitude,
        speedKmh: speedKmh,
        batteryLevel: batteryLevel,
        isCharging: isCharging,
      );
    } catch (e) {
      return left(Failure.server('Arrival tracking error: $e'));
    }
  }

  Future<Either<Failure, PartnerLocationArrivalModel>> _processLocalHeartbeat({
    required String partnerId,
    required String partnerName,
    required double latitude,
    required double longitude,
    required double speedKmh,
    required int batteryLevel,
    required bool isCharging,
  }) async {
    final now = DateTime.now();

    // 1. Check if inside 150m radius of any Trusted Place
    TrustedPlaceModel? matchedPlace;
    for (final place in _cachedTrustedPlaces) {
      final dist = calculateDistanceMeters(
        latitude,
        longitude,
        place.latitude,
        place.longitude,
      );
      if (dist <= place.radiusMeters) {
        matchedPlace = place;
        break;
      }
    }

    PartnerLocationArrivalModel? activeLog;
    if (_cachedArrivalLogs.isNotEmpty &&
        _cachedArrivalLogs.last.departedAt == null) {
      activeLog = _cachedArrivalLogs.last;
    }

    if (matchedPlace != null) {
      if (activeLog != null && activeLog.placeName == matchedPlace.name) {
        final updated = activeLog.copyWith(
          latitude: latitude,
          longitude: longitude,
          batteryLevel: batteryLevel,
          isCharging: isCharging,
          speedKmh: speedKmh,
          lastUpdatedAt: now,
        );
        _cachedArrivalLogs[_cachedArrivalLogs.length - 1] = updated;
        return right(updated);
      } else {
        if (activeLog != null) {
          _cachedArrivalLogs[_cachedArrivalLogs.length - 1] = activeLog.copyWith(
            departedAt: now,
            status: MovementStatus.moving,
          );
        }

        final address = await _geocodingService.reverseGeocode(
          latitude: latitude,
          longitude: longitude,
        );

        final newArrival = PartnerLocationArrivalModel(
          id: 'log-${now.millisecondsSinceEpoch}',
          userId: partnerId,
          latitude: latitude,
          longitude: longitude,
          addressLine: address,
          placeName: matchedPlace.name,
          status: MovementStatus.stationary,
          speedKmh: speedKmh,
          batteryLevel: batteryLevel,
          isCharging: isCharging,
          arrivedAt: now,
          departedAt: null,
          lastUpdatedAt: now,
        );
        _cachedArrivalLogs.add(newArrival);

        if (matchedPlace.notifyArrival) {
          _fcmService.triggerLocationArrivalPush(
            partnerName: partnerName,
            placeName: matchedPlace.name,
          );
        }

        return right(newArrival);
      }
    }

    if (activeLog != null) {
      final distFromActive = calculateDistanceMeters(
        latitude,
        longitude,
        activeLog.latitude,
        activeLog.longitude,
      );

      if (distFromActive > 200.0) {
        _cachedArrivalLogs[_cachedArrivalLogs.length - 1] = activeLog.copyWith(
          departedAt: now,
          status: MovementStatus.moving,
        );
      } else {
        final updated = activeLog.copyWith(
          lastUpdatedAt: now,
          batteryLevel: batteryLevel,
          isCharging: isCharging,
          speedKmh: speedKmh,
        );
        _cachedArrivalLogs[_cachedArrivalLogs.length - 1] = updated;
        return right(updated);
      }
    }

    if (speedKmh < 3.0) {
      final address = await _geocodingService.reverseGeocode(
        latitude: latitude,
        longitude: longitude,
      );

      final newArrival = PartnerLocationArrivalModel(
        id: 'log-${now.millisecondsSinceEpoch}',
        userId: partnerId,
        latitude: latitude,
        longitude: longitude,
        addressLine: address,
        placeName: address.split(',').first,
        status: MovementStatus.stationary,
        speedKmh: speedKmh,
        batteryLevel: batteryLevel,
        isCharging: isCharging,
        arrivedAt: now,
        departedAt: null,
        lastUpdatedAt: now,
      );
      _cachedArrivalLogs.add(newArrival);
      return right(newArrival);
    }

    final movingState = PartnerLocationArrivalModel(
      id: 'moving-${now.millisecondsSinceEpoch}',
      userId: partnerId,
      latitude: latitude,
      longitude: longitude,
      addressLine: 'In Transit',
      placeName: 'Moving (${speedKmh.toStringAsFixed(0)} km/h)',
      status: MovementStatus.moving,
      speedKmh: speedKmh,
      batteryLevel: batteryLevel,
      isCharging: isCharging,
      arrivedAt: now,
      departedAt: null,
      lastUpdatedAt: now,
    );
    return right(movingState);
  }

  /// Send "Reached Safely?" heart nudge via local Spring Boot backend
  Future<Either<Failure, Unit>> sendReachedSafelyNudge({
    required String partnerName,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.nudgePath,
        data: {
          'partnerName': partnerName,
          'senderName': 'You',
        },
      );
      _fcmService.triggerTextMessagePush(
        senderName: 'You',
        previewText: '💌 Sent a sweet heart: "Have you reached safely, my love?"',
      );
      return right(unit);
    } on DioException catch (_) {
      // Even if network fails, dispatch local notification feedback
      _fcmService.triggerTextMessagePush(
        senderName: 'You',
        previewText: '💌 Sent a sweet heart: "Have you reached safely, my love?"',
      );
      return right(unit);
    } catch (e) {
      return left(Failure.server('Failed to send safety nudge: $e'));
    }
  }
}
