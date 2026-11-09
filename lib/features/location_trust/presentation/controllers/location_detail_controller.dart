import 'dart:async';
import 'dart:math';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thae_nge_lay/core/network/api_client.dart';
import 'package:thae_nge_lay/core/network/websocket_sync_service.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';
import 'package:thae_nge_lay/features/location_trust/data/repositories/location_arrival_repository.dart';
import 'package:thae_nge_lay/features/location_trust/data/services/geocoding_service.dart';
import 'package:thae_nge_lay/features/location_trust/domain/models/partner_location_arrival_model.dart';
import 'package:thae_nge_lay/features/location_trust/domain/models/trusted_place_model.dart';
import 'package:thae_nge_lay/features/notifications/data/services/fcm_notification_service.dart';

part 'location_detail_controller.g.dart';

class LocationDetailState {
  final double currentUserLatitude;
  final double currentUserLongitude;
  final double partnerLatitude;
  final double partnerLongitude;
  final String partnerName;
  final int batteryLevel;
  final bool isCharging;
  final double speedKmh;
  final String placeName;
  final String addressLine;
  final DateTime arrivedAt;
  final MovementStatus status;
  final double distanceKm;
  final String gpsAccuracy;
  final List<PartnerLocationArrivalModel> todayArrivalLogs;
  final List<TrustedPlaceModel> trustedPlaces;
  final PartnerLocationArrivalModel? selectedArrivalLog;
  final bool isLoading;
  final bool isNudgeSent;

  const LocationDetailState({
    required this.currentUserLatitude,
    required this.currentUserLongitude,
    required this.partnerLatitude,
    required this.partnerLongitude,
    required this.partnerName,
    required this.batteryLevel,
    required this.isCharging,
    required this.speedKmh,
    required this.placeName,
    required this.addressLine,
    required this.arrivedAt,
    required this.status,
    required this.distanceKm,
    required this.gpsAccuracy,
    required this.todayArrivalLogs,
    required this.trustedPlaces,
    this.selectedArrivalLog,
    this.isLoading = false,
    this.isNudgeSent = false,
  });

  String get stayDurationFormatted {
    final diff = DateTime.now().difference(arrivedAt);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  LocationDetailState copyWith({
    double? currentUserLatitude,
    double? currentUserLongitude,
    double? partnerLatitude,
    double? partnerLongitude,
    String? partnerName,
    int? batteryLevel,
    bool? isCharging,
    double? speedKmh,
    String? placeName,
    String? addressLine,
    DateTime? arrivedAt,
    MovementStatus? status,
    double? distanceKm,
    String? gpsAccuracy,
    List<PartnerLocationArrivalModel>? todayArrivalLogs,
    List<TrustedPlaceModel>? trustedPlaces,
    PartnerLocationArrivalModel? selectedArrivalLog,
    bool? isLoading,
    bool? isNudgeSent,
  }) {
    return LocationDetailState(
      currentUserLatitude: currentUserLatitude ?? this.currentUserLatitude,
      currentUserLongitude: currentUserLongitude ?? this.currentUserLongitude,
      partnerLatitude: partnerLatitude ?? this.partnerLatitude,
      partnerLongitude: partnerLongitude ?? this.partnerLongitude,
      partnerName: partnerName ?? this.partnerName,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      isCharging: isCharging ?? this.isCharging,
      speedKmh: speedKmh ?? this.speedKmh,
      placeName: placeName ?? this.placeName,
      addressLine: addressLine ?? this.addressLine,
      arrivedAt: arrivedAt ?? this.arrivedAt,
      status: status ?? this.status,
      distanceKm: distanceKm ?? this.distanceKm,
      gpsAccuracy: gpsAccuracy ?? this.gpsAccuracy,
      todayArrivalLogs: todayArrivalLogs ?? this.todayArrivalLogs,
      trustedPlaces: trustedPlaces ?? this.trustedPlaces,
      selectedArrivalLog: selectedArrivalLog ?? this.selectedArrivalLog,
      isLoading: isLoading ?? this.isLoading,
      isNudgeSent: isNudgeSent ?? this.isNudgeSent,
    );
  }
}

@Riverpod(keepAlive: true)
GeocodingService geocodingService(Ref ref) {
  return GeocodingService();
}

@Riverpod(keepAlive: true)
LocationArrivalRepository locationArrivalRepository(Ref ref) {
  return LocationArrivalRepository(
    dio: ref.watch(dioClientProvider),
    geocodingService: ref.watch(geocodingServiceProvider),
    fcmService: ref.watch(fcmNotificationServiceProvider),
  );
}

@Riverpod(keepAlive: true)
class LocationDetailController extends _$LocationDetailController {
  StreamSubscription? _locSub;
  StreamSubscription? _nudgeSub;

  @override
  LocationDetailState build() {
    ref.onDispose(() {
      _locSub?.cancel();
      _nudgeSub?.cancel();
    });

    final now = DateTime.now();
    final repo = ref.watch(locationArrivalRepositoryProvider);
    final auth = ref.watch(authStateProvider);
    final partnerId = auth?.partnerId ?? 'partner_thae_nge_lay';
    final partnerName = auth?.partnerId != null ? 'My Beloved' : 'Thae Thae';

    final ws = ref.read(webSocketSyncServiceProvider);
    if (auth != null) {
      ws.updateCredentials(userId: auth.id, coupleSpaceId: auth.coupleSpaceId);
    }

    _locSub = ws.onEvent('LOCATION_UPDATE').listen((e) {
      try {
        final arrival = PartnerLocationArrivalModel.fromJson(Map<String, dynamic>.from(e.data));
        final updatedList = [arrival, ...state.todayArrivalLogs.where((l) => l.id != arrival.id)];
        _updateStateWithLogs(updatedList);
      } catch (_) {}
    });

    _nudgeSub = ws.onEvent('SAFETY_NUDGE').listen((_) {
      state = state.copyWith(isNudgeSent: true);
      Future.delayed(const Duration(seconds: 4), () {
        state = state.copyWith(isNudgeSent: false);
      });
    });

    // Initial default state
    final stateObj = LocationDetailState(
      currentUserLatitude: 16.7795,
      currentUserLongitude: 96.1603,
      partnerLatitude: 16.8295,
      partnerLongitude: 96.1305,
      partnerName: partnerName,
      batteryLevel: 78,
      isCharging: true,
      speedKmh: 0.0,
      placeName: 'Sweet Home',
      addressLine: 'No. 42, Pyay Road, Kamayut',
      arrivedAt: now.subtract(const Duration(hours: 2, minutes: 18)),
      status: MovementStatus.stationary,
      distanceKm: 6.2,
      gpsAccuracy: 'Live • Connecting to backend...',
      todayArrivalLogs: const [],
      trustedPlaces: const [],
      isLoading: true,
    );

    _loadInitialData(repo, partnerId);
    return stateObj;
  }

  void _loadInitialData(LocationArrivalRepository repo, String partnerId) async {
    final logsEither = await repo.getTodayArrivalLogs(userId: partnerId);
    final placesEither = await repo.getTrustedPlaces(userId: partnerId);

    logsEither.fold(
      (_) {
        state = state.copyWith(isLoading: false);
      },
      (logs) {
        placesEither.fold(
          (_) {
            _updateStateWithLogs(logs);
          },
          (places) {
            _updateStateWithLogsAndPlaces(logs, places);
          },
        );
      },
    );
  }

  void _updateStateWithLogs(List<PartnerLocationArrivalModel> logs) {
    if (logs.isNotEmpty) {
      final active = logs.firstWhere(
        (l) => l.departedAt == null,
        orElse: () => logs.first,
      );

      final latDiff = (state.partnerLatitude - active.latitude).abs();
      final lngDiff = (state.partnerLongitude - active.longitude).abs();
      final hasMeaningfulChange = latDiff > 0.0001 ||
          lngDiff > 0.0001 ||
          state.batteryLevel != active.batteryLevel ||
          state.isCharging != active.isCharging ||
          state.placeName != active.placeName ||
          state.status != active.status ||
          state.todayArrivalLogs.length != logs.length ||
          state.isLoading;

      if (!hasMeaningfulChange) return;

      final dist = _calcDist(
        state.currentUserLatitude,
        state.currentUserLongitude,
        active.latitude,
        active.longitude,
      );

      state = state.copyWith(
        partnerLatitude: active.latitude,
        partnerLongitude: active.longitude,
        placeName: active.placeName,
        addressLine: active.addressLine,
        batteryLevel: active.batteryLevel,
        isCharging: active.isCharging,
        speedKmh: active.speedKmh,
        status: active.status,
        arrivedAt: active.arrivedAt,
        distanceKm: dist,
        gpsAccuracy: 'Live • Connected to Backend',
        todayArrivalLogs: logs,
        isLoading: false,
      );
    } else {
      if (state.todayArrivalLogs.isNotEmpty || state.isLoading) {
        state = state.copyWith(
          todayArrivalLogs: logs,
          isLoading: false,
        );
      }
    }
  }

  void _updateStateWithLogsAndPlaces(
    List<PartnerLocationArrivalModel> logs,
    List<TrustedPlaceModel> places,
  ) {
    if (logs.isNotEmpty) {
      final active = logs.firstWhere(
        (l) => l.departedAt == null,
        orElse: () => logs.first,
      );
      final dist = _calcDist(
        state.currentUserLatitude,
        state.currentUserLongitude,
        active.latitude,
        active.longitude,
      );

      state = state.copyWith(
        partnerLatitude: active.latitude,
        partnerLongitude: active.longitude,
        placeName: active.placeName,
        addressLine: active.addressLine,
        batteryLevel: active.batteryLevel,
        isCharging: active.isCharging,
        speedKmh: active.speedKmh,
        status: active.status,
        arrivedAt: active.arrivedAt,
        distanceKm: dist,
        gpsAccuracy: 'Live • Connected to Backend',
        todayArrivalLogs: logs,
        trustedPlaces: places,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        todayArrivalLogs: logs,
        trustedPlaces: places,
        isLoading: false,
      );
    }
  }

  double _calcDist(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0; // km
    final dLat = (lat2 - lat1) * pi / 180.0;
    final dLon = (lon2 - lon1) * pi / 180.0;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180.0) *
            cos(lat2 * pi / 180.0) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return double.parse((r * c).toStringAsFixed(1));
  }

  /// Pull-to-refresh or explicit refresh trigger for live logs from Spring Boot
  Future<void> refresh() async {
    final repo = ref.read(locationArrivalRepositoryProvider);
    final auth = ref.read(authStateProvider);
    final partnerId = auth?.partnerId ?? 'partner_thae_nge_lay';

    state = state.copyWith(isLoading: true);
    final logsEither = await repo.getTodayArrivalLogs(userId: partnerId);
    final placesEither = await repo.getTrustedPlaces(userId: partnerId);

    logsEither.fold(
      (_) {
        state = state.copyWith(isLoading: false);
      },
      (logs) {
        placesEither.fold(
          (_) {
            _updateStateWithLogs(logs);
          },
          (places) {
            _updateStateWithLogsAndPlaces(logs, places);
          },
        );
      },
    );
  }

  void selectArrivalLog(PartnerLocationArrivalModel? log) {
    state = state.copyWith(selectedArrivalLog: log);
  }

  Future<void> sendSafetyNudge() async {
    final repo = ref.read(locationArrivalRepositoryProvider);
    state = state.copyWith(isNudgeSent: true);
    await repo.sendReachedSafelyNudge(partnerName: state.partnerName);
    await Future.delayed(const Duration(seconds: 4));
    state = state.copyWith(isNudgeSent: false);
  }

  Future<bool> addTrustedPlace({
    required String name,
    required String iconName,
    required double latitude,
    required double longitude,
  }) async {
    final repo = ref.read(locationArrivalRepositoryProvider);
    final result = await repo.addTrustedPlace(
      name: name,
      iconName: iconName,
      latitude: latitude,
      longitude: longitude,
    );

    return result.fold(
      (failure) => false,
      (newPlace) {
        state = state.copyWith(
          trustedPlaces: [...state.trustedPlaces, newPlace],
        );
        return true;
      },
    );
  }
}
