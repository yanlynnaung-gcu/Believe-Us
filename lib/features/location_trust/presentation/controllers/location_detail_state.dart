import 'package:thae_nge_lay/features/location_trust/domain/models/partner_location_arrival_model.dart';
import 'package:thae_nge_lay/features/location_trust/domain/models/trusted_place_model.dart';

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
