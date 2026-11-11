import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:thae_nge_lay/core/errors/failure.dart';
import 'package:thae_nge_lay/core/network/api_client.dart';
import 'package:thae_nge_lay/features/location_trust/data/datasources/initial_location_trust_data.dart';
import 'package:thae_nge_lay/features/location_trust/data/services/geocoding_service.dart';
import 'package:thae_nge_lay/features/location_trust/data/services/smart_arrival_engine.dart';
import 'package:thae_nge_lay/features/location_trust/domain/models/partner_location_arrival_model.dart';
import 'package:thae_nge_lay/features/location_trust/domain/models/trusted_place_model.dart';
import 'package:thae_nge_lay/features/notifications/data/services/fcm_notification_service.dart';

class LocationArrivalRepository {
  final Dio _dio;
  final FcmNotificationService _fcmService;
  final SmartArrivalEngine _arrivalEngine;

  LocationArrivalRepository({
    Dio? dio,
    required GeocodingService geocodingService,
    required FcmNotificationService fcmService,
  })  : _dio = dio ?? Dio(),
        _fcmService = fcmService,
        _arrivalEngine = SmartArrivalEngine(
          geocodingService: geocodingService,
          fcmService: fcmService,
        );

  final List<TrustedPlaceModel> _cachedTrustedPlaces =
      getInitialTrustedPlaces();
  late final List<PartnerLocationArrivalModel> _cachedArrivalLogs =
      getInitialArrivalLogs();

  double calculateDistanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return SmartArrivalEngine.calculateDistanceMeters(
        lat1, lon1, lat2, lon2);
  }

  Future<Either<Failure, List<PartnerLocationArrivalModel>>>
      getTodayArrivalLogs({
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
      return left(
          Failure.server('Failed to save place: ${response.statusCode}'));
    } on DioException catch (_) {
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

  Future<Either<Failure, PartnerLocationArrivalModel>>
      processLocationHeartbeat({
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
      return left(
          Failure.server('Heartbeat failed: ${response.statusCode}'));
    } on DioException catch (_) {
      return _arrivalEngine.processLocalHeartbeat(
        partnerId: partnerId,
        partnerName: partnerName,
        latitude: latitude,
        longitude: longitude,
        speedKmh: speedKmh,
        batteryLevel: batteryLevel,
        isCharging: isCharging,
        cachedTrustedPlaces: _cachedTrustedPlaces,
        cachedArrivalLogs: _cachedArrivalLogs,
      );
    } catch (e) {
      return left(Failure.server('Arrival tracking error: $e'));
    }
  }

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
        previewText:
            '💌 Sent a sweet heart: "Have you reached safely, my love?"',
      );
      return right(unit);
    } on DioException catch (_) {
      _fcmService.triggerTextMessagePush(
        senderName: 'You',
        previewText:
            '💌 Sent a sweet heart: "Have you reached safely, my love?"',
      );
      return right(unit);
    } catch (e) {
      return left(Failure.server('Failed to send safety nudge: $e'));
    }
  }
}
