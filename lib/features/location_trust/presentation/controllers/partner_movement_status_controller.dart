import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:thae_nge_lay/core/network/websocket_sync_service.dart';
import 'package:thae_nge_lay/features/location_trust/domain/models/partner_location_arrival_model.dart';

class PartnerMovementStatusState {
  final bool isMoving;
  final double speedKmh;
  final String placeLabel;
  final MovementStatus status;
  final DateTime lastUpdated;

  const PartnerMovementStatusState({
    this.isMoving = false,
    this.speedKmh = 0.0,
    this.placeLabel = 'Stationary',
    this.status = MovementStatus.stationary,
    required this.lastUpdated,
  });

  PartnerMovementStatusState copyWith({
    bool? isMoving,
    double? speedKmh,
    String? placeLabel,
    MovementStatus? status,
    DateTime? lastUpdated,
  }) {
    return PartnerMovementStatusState(
      isMoving: isMoving ?? this.isMoving,
      speedKmh: speedKmh ?? this.speedKmh,
      placeLabel: placeLabel ?? this.placeLabel,
      status: status ?? this.status,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class PartnerMovementStatusNotifier
    extends Notifier<PartnerMovementStatusState> {
  StreamSubscription? _locSub;

  @override
  PartnerMovementStatusState build() {
    final ws = ref.watch(webSocketSyncServiceProvider);

    _locSub?.cancel();
    ref.onDispose(() => _locSub?.cancel());

    _locSub = ws.onEvent('LOCATION_UPDATE').listen((e) {
      try {
        final rawStatus = e.data['status']?.toString().toUpperCase();
        final speed = (e.data['speedKmh'] as num?)?.toDouble() ?? 0.0;
        final isMoving = rawStatus == 'MOVING' || speed > 3.0;
        final placeName = e.data['placeName']?.toString();
        final address = e.data['addressLine']?.toString();
        final place = placeName ?? address ?? (isMoving ? 'Moving' : 'Stationary');
        final placeLabel = isMoving ? 'Moving (${speed.toStringAsFixed(0)} km/h)' : place;
        final newStatus = isMoving ? MovementStatus.moving : MovementStatus.stationary;

        if (state.isMoving != isMoving ||
            (state.speedKmh - speed).abs() > 0.5 ||
            state.placeLabel != placeLabel ||
            state.status != newStatus) {
          state = state.copyWith(
            isMoving: isMoving,
            speedKmh: speed,
            placeLabel: placeLabel,
            status: newStatus,
            lastUpdated: DateTime.now(),
          );
        }
      } catch (_) {}
    });

    return PartnerMovementStatusState(
      isMoving: false,
      speedKmh: 0.0,
      placeLabel: 'Stationary',
      status: MovementStatus.stationary,
      lastUpdated: DateTime.now(),
    );
  }

  void updateStatus({
    required bool isMoving,
    required double speedKmh,
    required String placeLabel,
  }) {
    state = state.copyWith(
      isMoving: isMoving,
      speedKmh: speedKmh,
      placeLabel: placeLabel,
      status: isMoving ? MovementStatus.moving : MovementStatus.stationary,
      lastUpdated: DateTime.now(),
    );
  }
}

final partnerMovementStatusProvider = NotifierProvider<
    PartnerMovementStatusNotifier,
    PartnerMovementStatusState>(PartnerMovementStatusNotifier.new);
