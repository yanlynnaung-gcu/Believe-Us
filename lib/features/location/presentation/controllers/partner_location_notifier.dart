import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thae_nge_lay/core/network/websocket_sync_service.dart';
import 'package:thae_nge_lay/features/location/data/services/location_service.dart';
import 'package:thae_nge_lay/features/location/domain/models/location_data.dart';

part 'partner_location_notifier.g.dart';

@Riverpod(keepAlive: true)
class PartnerLocationNotifier extends _$PartnerLocationNotifier {
  Timer? _pollingTimer;
  StreamSubscription? _wsSub;

  double _partnerLat = 16.8295;
  double _partnerLon = 96.1305;
  int _partnerBattery = 88;
  bool _partnerIsCharging = true;
  String _placeName = 'Kamayut, Yangon';

  @override
  PartnerLocationStatus build() {
    ref.onDispose(() {
      _pollingTimer?.cancel();
      _wsSub?.cancel();
    });

    final ws = ref.watch(webSocketSyncServiceProvider);
    _wsSub = ws.onEvent('LOCATION_UPDATE').listen((e) {
      try {
        final d = e.data;
        if (d.containsKey('latitude')) {
          _partnerLat = (d['latitude'] as num).toDouble();
        }
        if (d.containsKey('longitude')) {
          _partnerLon = (d['longitude'] as num).toDouble();
        }
        if (d.containsKey('batteryLevel')) {
          _partnerBattery = (d['batteryLevel'] as num).toInt();
        }
        if (d.containsKey('isCharging')) {
          _partnerIsCharging = d['isCharging'] as bool? ?? false;
        }
        if (d.containsKey('placeName')) {
          _placeName = d['placeName'].toString();
        }
        state = _calculateStatus();
      } catch (_) {}
    });

    _startPeriodicUpdates();
    return _calculateStatus();
  }

  PartnerLocationStatus _calculateStatus() {
    final locationSvc = ref.read(locationServiceProvider);
    const userLat = 16.7795;
    const userLon = 96.1603;

    final distanceKm = locationSvc.calculateDistanceInKm(
      startLatitude: userLat,
      startLongitude: userLon,
      endLatitude: _partnerLat,
      endLongitude: _partnerLon,
    );

    return PartnerLocationStatus(
      latitude: _partnerLat,
      longitude: _partnerLon,
      placeName: _placeName,
      batteryLevel: _partnerBattery,
      isCharging: _partnerIsCharging,
      lastUpdated: DateTime.now(),
      isOnline: true,
      distanceKm: double.parse(distanceKm.toStringAsFixed(1)),
    );
  }

  void _startPeriodicUpdates() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      state = _calculateStatus();
    });
  }

  void refreshPartnerStatus() {
    state = _calculateStatus();
  }
}
