import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/network/websocket_sync_service.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/features/home/presentation/controllers/couple_media_controller.dart';
import 'package:thae_nge_lay/features/location/data/services/location_service.dart';
import 'package:thae_nge_lay/features/location/presentation/controllers/partner_location_notifier.dart';
import 'package:thae_nge_lay/features/location/presentation/utils/marker_loader_helper.dart';
import 'package:thae_nge_lay/features/location/presentation/utils/partner_map_animator.dart';
import 'package:thae_nge_lay/features/location/presentation/widgets/wd_distance_header_badge.dart';
import 'package:thae_nge_lay/features/location/presentation/widgets/wd_location_snackbars.dart';
import 'package:thae_nge_lay/features/location/presentation/widgets/wd_map_action_column.dart';
import 'package:thae_nge_lay/features/location/presentation/widgets/wd_partner_bottom_card.dart';
import 'package:thae_nge_lay/features/location/presentation/widgets/wd_partner_google_map.dart';

class PartnerMapScreen extends ConsumerStatefulWidget {
  const PartnerMapScreen({super.key});

  @override
  ConsumerState<PartnerMapScreen> createState() => _PartnerMapScreenState();
}

class _PartnerMapScreenState extends ConsumerState<PartnerMapScreen>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  late AnimationController _waveController;
  late PartnerMapMovementAnimator _animator;

  LatLng? _userLatLng;
  LatLng? _currentPartnerLatLng;
  BitmapDescriptor? _partnerMarkerIcon;
  BitmapDescriptor? _userMarkerIcon;

  StreamSubscription<Position>? _userLocationSub;
  StreamSubscription<WebSocketEvent>? _wsLocationSub;

  MapType _currentMapType = MapType.normal;
  bool _isAutoTracking = true;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _animator = PartnerMapMovementAnimator(
      controller: AnimationController(vsync: this, duration: const Duration(milliseconds: 1000)),
      onTick: () {
        final pos = _animator.computeCurrentLatLng();
        if (pos != null && mounted) setState(() => _currentPartnerLatLng = pos);
      },
    );

    _animator.controller.addStatusListener((status) {
      if (status == AnimationStatus.completed &&
          _isAutoTracking &&
          _mapController != null &&
          _currentPartnerLatLng != null) {
        _mapController!.animateCamera(CameraUpdate.newLatLng(_currentPartnerLatLng!));
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _initLocations());
  }

  @override
  void dispose() {
    _waveController.dispose();
    _animator.dispose();
    _userLocationSub?.cancel();
    _wsLocationSub?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initLocations() async {
    _userLocationSub?.cancel();
    _wsLocationSub?.cancel();

    final locationSvc = ref.read(locationServiceProvider);
    final partner = ref.read(partnerLocationProvider);
    final media = ref.read(coupleMediaProvider);

    _currentPartnerLatLng = LatLng(partner.latitude, partner.longitude);

    try {
      final pos = await locationSvc.getCurrentPosition();
      if (pos != null && mounted) setState(() => _userLatLng = LatLng(pos.latitude, pos.longitude));
    } catch (_) {
      _userLatLng = const LatLng(16.7795, 96.1603);
    }

    try {
      _userLocationSub = locationSvc.getPositionStream().listen((pos) {
        if (!mounted) return;
        final newLatLng = LatLng(pos.latitude, pos.longitude);
        if (_userLatLng == null ||
            (_userLatLng!.latitude - newLatLng.latitude).abs() > 0.0001 ||
            (_userLatLng!.longitude - newLatLng.longitude).abs() > 0.0001) {
          setState(() => _userLatLng = newLatLng);
        }
      });
    } catch (_) {}

    final ws = ref.read(webSocketSyncServiceProvider);
    _wsLocationSub = ws.onEvent('LOCATION_UPDATE').listen((event) {
      final d = event.data;
      if (d.containsKey('latitude') && d.containsKey('longitude')) {
        final newLat = (d['latitude'] as num).toDouble();
        final newLng = (d['longitude'] as num).toDouble();
        _animator.animateTo(LatLng(newLat, newLng), _currentPartnerLatLng);
      }
    });

    final icons = await loadCoupleMarkerIcons(media);
    if (mounted) {
      setState(() {
        _partnerMarkerIcon = icons['partner'];
        _userMarkerIcon = icons['user'];
      });
    }
  }

  void _centerOnPartner() {
    HapticFeedback.lightImpact();
    setState(() => _isAutoTracking = true);
    if (_mapController != null && _currentPartnerLatLng != null) {
      _mapController!.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentPartnerLatLng!, zoom: 16.0),
      ));
    }
  }

  void _centerOnUser() {
    HapticFeedback.lightImpact();
    setState(() => _isAutoTracking = false);
    if (_mapController != null && _userLatLng != null) {
      _mapController!.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _userLatLng!, zoom: 16.0),
      ));
    }
  }

  Future<void> _refreshLocations() async {
    HapticFeedback.mediumImpact();
    ref.read(partnerLocationProvider.notifier).refreshPartnerStatus();
    try {
      final pos = await ref.read(locationServiceProvider).getCurrentPosition();
      if (pos != null && mounted) setState(() => _userLatLng = LatLng(pos.latitude, pos.longitude));
    } catch (_) {}
    PartnerMapMovementAnimator.fitBounds(
      controller: _mapController,
      userLatLng: _userLatLng,
      partnerLatLng: _currentPartnerLatLng,
    );
    if (mounted) showLocationRefreshedSnackBar(context);
  }

  @override
  Widget build(BuildContext context) {
    final partner = ref.watch(partnerLocationProvider);
    final media = ref.watch(coupleMediaProvider);
    final partnerPos = _currentPartnerLatLng ?? LatLng(partner.latitude, partner.longitude);

    return Scaffold(
      backgroundColor: BelieveColors.background,
      appBar: AppBar(
        title: Text(
          'Where You Are ✨',
          style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(_currentMapType == MapType.normal ? LucideIcons.layers : LucideIcons.map),
            onPressed: () => setState(() {
              _currentMapType = _currentMapType == MapType.normal ? MapType.satellite : MapType.normal;
            }),
          ),
        ],
      ),
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: WdPartnerGoogleMap(
                  mapType: _currentMapType,
                  partnerPos: partnerPos,
                  userPos: _userLatLng,
                  partnerMarkerIcon: _partnerMarkerIcon,
                  userMarkerIcon: _userMarkerIcon,
                  partnerName: media.partnerName,
                  placeName: partner.placeName,
                  batteryLevel: partner.batteryLevel,
                  isCharging: partner.isCharging,
                  onMapCreated: (controller) {
                    _mapController = controller;
                    Future.delayed(const Duration(milliseconds: 600), () {
                      PartnerMapMovementAnimator.fitBounds(
                        controller: _mapController,
                        userLatLng: _userLatLng,
                        partnerLatLng: _currentPartnerLatLng,
                      );
                    });
                  },
                  onCameraMoveStarted: () {
                    if (_isAutoTracking) setState(() => _isAutoTracking = false);
                  },
                ),
              ),
            ),
            WdDistanceHeaderBadge(
              distanceKm: partner.distanceKm ?? 0,
              waveAnimation: Tween<double>(begin: 0.85, end: 1.25).animate(
                CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
              ),
            ),
            WdMapActionColumn(
              currentMapType: _currentMapType,
              onCenterPartner: _centerOnPartner,
              onRefreshLocations: _refreshLocations,
              onCenterUser: _centerOnUser,
              onToggleMapType: () => setState(() {
                _currentMapType = _currentMapType == MapType.normal ? MapType.satellite : MapType.normal;
              }),
            ),
            WdPartnerBottomCard(
              partnerName: media.partnerName,
              placeName: partner.placeName,
              distanceKm: partner.distanceKm ?? 0,
              batteryLevel: partner.batteryLevel,
              isCharging: partner.isCharging,
              onSendCheckInAlert: () => showCheckInAlertSnackBar(context),
            ),
          ],
        ),
      ),
    );
  }
}
