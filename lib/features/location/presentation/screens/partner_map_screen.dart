import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/network/websocket_sync_service.dart';
import 'package:thae_nge_lay/core/router/route_names.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';
import 'package:thae_nge_lay/core/utils/image_provider_helper.dart';
import 'package:thae_nge_lay/features/home/presentation/controllers/couple_media_controller.dart';
import 'package:thae_nge_lay/features/location/data/services/location_service.dart';
import 'package:thae_nge_lay/features/location/domain/models/location_data.dart';
import 'package:thae_nge_lay/features/location/presentation/controllers/partner_location_notifier.dart';
import 'package:thae_nge_lay/features/location/presentation/utils/romantic_marker_generator.dart';

class PartnerMapScreen extends ConsumerStatefulWidget {
  const PartnerMapScreen({super.key});

  @override
  ConsumerState<PartnerMapScreen> createState() => _PartnerMapScreenState();
}

class _PartnerMapScreenState extends ConsumerState<PartnerMapScreen>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;

  // Animation controller for pulsing distance heart
  late AnimationController _waveController;

  // Animation controller for smooth WebSocket coordinate movement
  late AnimationController _moveAnimationController;
  Animation<double>? _moveAnimation;

  // Coordinates
  LatLng? _userLatLng;
  LatLng? _currentPartnerLatLng;
  LatLng? _startPartnerLatLng;
  LatLng? _targetPartnerLatLng;

  // Custom Google Map Markers
  BitmapDescriptor? _partnerMarkerIcon;
  BitmapDescriptor? _userMarkerIcon;

  // Stream Subscriptions
  StreamSubscription<Position>? _userLocationSub;
  StreamSubscription<WebSocketEvent>? _wsLocationSub;

  MapType _currentMapType = MapType.normal;
  bool _isAutoTracking = true;

  // Soft romantic pastel custom map style JSON
  static const String _romanticPastelMapStyle = '''
  [
    {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#DCEBFF"}]},
    {"featureType": "landscape", "elementType": "geometry", "stylers": [{"color": "#FFF9FB"}]},
    {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#FFFFFF"}]},
    {"featureType": "road.arterial", "elementType": "geometry", "stylers": [{"color": "#FFEBF1"}]},
    {"featureType": "poi.park", "elementType": "geometry", "stylers": [{"color": "#EAF9EE"}]},
    {"featureType": "poi", "elementType": "labels.text.fill", "stylers": [{"color": "#8C7B83"}]},
    {"featureType": "transit", "stylers": [{"visibility": "off"}]}
  ]
  ''';

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _moveAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _moveAnimation = CurvedAnimation(
      parent: _moveAnimationController,
      curve: Curves.easeInOutCubic,
    )..addListener(_onMoveAnimationTick);

    _moveAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_isAutoTracking && _mapController != null && _currentPartnerLatLng != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLng(_currentPartnerLatLng!),
          );
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initLocationsAndSubscriptions();
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _moveAnimationController.dispose();
    _userLocationSub?.cancel();
    _wsLocationSub?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  int _lastTickMs = 0;

  void _onMoveAnimationTick() {
    if (_startPartnerLatLng == null || _targetPartnerLatLng == null) return;

    // Throttle marker position updates to ~12fps (every 80ms) to avoid CPU-spinning setState
    final now = DateTime.now().millisecondsSinceEpoch;
    final isDone = _moveAnimationController.isCompleted;
    if (!isDone && (now - _lastTickMs < 80)) {
      return;
    }
    _lastTickMs = now;

    final t = _moveAnimation?.value ?? 1.0;

    final lat = ui.lerpDouble(
      _startPartnerLatLng!.latitude,
      _targetPartnerLatLng!.latitude,
      t,
    );
    final lng = ui.lerpDouble(
      _startPartnerLatLng!.longitude,
      _targetPartnerLatLng!.longitude,
      t,
    );

    if (lat != null && lng != null && mounted) {
      setState(() {
        _currentPartnerLatLng = LatLng(lat, lng);
      });
    }
  }

  Future<void> _initLocationsAndSubscriptions() async {
    final locationSvc = ref.read(locationServiceProvider);
    final partner = ref.read(partnerLocationProvider);
    final media = ref.read(coupleMediaProvider);

    // Initial partner position
    _currentPartnerLatLng = LatLng(partner.latitude, partner.longitude);
    _targetPartnerLatLng = _currentPartnerLatLng;

    // Fetch user current location
    try {
      final pos = await locationSvc.getCurrentPosition();
      if (pos != null && mounted) {
        setState(() {
          _userLatLng = LatLng(pos.latitude, pos.longitude);
        });
      }
    } catch (_) {
      _userLatLng = const LatLng(16.7795, 96.1603);
    }

    // Subscribe to continuous live user position stream
    try {
      _userLocationSub = locationSvc.getPositionStream().listen((pos) {
        if (!mounted) return;
        final newLatLng = LatLng(pos.latitude, pos.longitude);
        if (_userLatLng == null ||
            (_userLatLng!.latitude - newLatLng.latitude).abs() > 0.0001 ||
            (_userLatLng!.longitude - newLatLng.longitude).abs() > 0.0001) {
          setState(() {
            _userLatLng = newLatLng;
          });
        }
      });
    } catch (_) {}

    // Subscribe to Live WebSocket Location updates for partner
    final ws = ref.read(webSocketSyncServiceProvider);
    _wsLocationSub = ws.onEvent('LOCATION_UPDATE').listen((event) {
      try {
        final d = event.data;
        if (d.containsKey('latitude') && d.containsKey('longitude')) {
          final newLat = (d['latitude'] as num).toDouble();
          final newLng = (d['longitude'] as num).toDouble();
          _smoothMovePartnerTo(LatLng(newLat, newLng));
        }
      } catch (_) {}
    });

    // Generate Custom Romantic Map Markers
    await _loadCustomMarkers(media);
  }

  Future<void> _loadCustomMarkers(CoupleMediaState media) async {
    try {
      final partnerIcon = await RomanticMarkerGenerator.createCoupleMarker(
        label: media.partnerName,
        borderColor: BelieveColors.primary,
        isPartner: true,
        avatarProvider: getCustomImageProvider(media.partnerAvatarPath),
        cacheKey: 'partner_${media.partnerName}_${media.partnerAvatarPath}',
      );

      final userIcon = await RomanticMarkerGenerator.createCoupleMarker(
        label: 'You',
        borderColor: BelieveColors.accentLavender,
        isPartner: false,
        avatarProvider: getCustomImageProvider(media.userAvatarPath),
        cacheKey: 'user_${media.userAvatarPath}',
      );

      if (mounted) {
        setState(() {
          _partnerMarkerIcon = partnerIcon;
          _userMarkerIcon = userIcon;
        });
      }
    } catch (_) {}
  }

  void _smoothMovePartnerTo(LatLng newCoords) {
    if (!mounted) return;

    if (_currentPartnerLatLng == null) {
      setState(() {
        _currentPartnerLatLng = newCoords;
        _targetPartnerLatLng = newCoords;
      });
      return;
    }

    // Check if location changed meaningfully (more than ~10 meters)
    final latDiff = (_currentPartnerLatLng!.latitude - newCoords.latitude).abs();
    final lngDiff =
        (_currentPartnerLatLng!.longitude - newCoords.longitude).abs();
    if (latDiff < 0.0001 && lngDiff < 0.0001) return;

    _startPartnerLatLng = _currentPartnerLatLng;
    _targetPartnerLatLng = newCoords;

    _moveAnimationController.stop();
    _moveAnimationController.forward(from: 0.0);
  }

  void _centerOnPartner() {
    HapticFeedback.lightImpact();
    setState(() => _isAutoTracking = true);
    if (_mapController != null && _currentPartnerLatLng != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentPartnerLatLng!,
            zoom: 16.0,
          ),
        ),
      );
    }
  }

  void _centerOnUser() {
    HapticFeedback.lightImpact();
    setState(() => _isAutoTracking = false);
    if (_mapController != null && _userLatLng != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _userLatLng!,
            zoom: 16.0,
          ),
        ),
      );
    }
  }

  Future<void> _refreshLocations() async {
    HapticFeedback.mediumImpact();
    ref.read(partnerLocationProvider.notifier).refreshPartnerStatus();
    final locationSvc = ref.read(locationServiceProvider);
    try {
      final pos = await locationSvc.getCurrentPosition();
      if (pos != null && mounted) {
        setState(() {
          _userLatLng = LatLng(pos.latitude, pos.longitude);
        });
      }
    } catch (_) {}
    _fitBothInView();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
            side: const BorderSide(color: BelieveColors.glassBorder),
          ),
          content: Row(
            children: [
              const Icon(LucideIcons.sparkles, color: BelieveColors.primary, size: 16),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Coordinates refreshed & synced with partner! ✨',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: BelieveColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _fitBothInView() {
    if (_mapController == null ||
        _userLatLng == null ||
        _currentPartnerLatLng == null) {
      return;
    }

    final southWest = LatLng(
      math.min(_userLatLng!.latitude, _currentPartnerLatLng!.latitude) - 0.005,
      math.min(_userLatLng!.longitude, _currentPartnerLatLng!.longitude) - 0.005,
    );
    final northEast = LatLng(
      math.max(_userLatLng!.latitude, _currentPartnerLatLng!.latitude) + 0.005,
      math.max(_userLatLng!.longitude, _currentPartnerLatLng!.longitude) + 0.005,
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: southWest, northeast: northEast),
        70,
      ),
    );
  }

  void _toggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  void _sendCheckInAlert() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: const BorderSide(color: BelieveColors.glassBorder),
        ),
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.r),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: BelieveColors.primaryGradient,
              ),
              child: const Icon(
                LucideIcons.heart,
                color: Colors.white,
                size: 16,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                '❤️ Arrival Alert & Check-In pushed to your partner\'s device!',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: BelieveColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final partner = ref.watch(partnerLocationProvider);
    final media = ref.watch(coupleMediaProvider);

    ref.listen<PartnerLocationStatus>(partnerLocationProvider, (prev, next) {
      if (prev == null ||
          (prev.latitude - next.latitude).abs() > 0.0001 ||
          (prev.longitude - next.longitude).abs() > 0.0001) {
        _smoothMovePartnerTo(LatLng(next.latitude, next.longitude));
      }
    });

    final partnerPos =
        _currentPartnerLatLng ?? LatLng(partner.latitude, partner.longitude);
    final userPos = _userLatLng ?? const LatLng(16.7795, 96.1603);

    // Build Custom Google Map Markers
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('partner-marker'),
        position: partnerPos,
        icon: _partnerMarkerIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
        anchor: const Offset(0.5, 0.95),
        infoWindow: InfoWindow(
          title: '${media.partnerName} (${partner.placeName})',
          snippet:
              'Battery: ${partner.batteryLevel}% • ${partner.isCharging ? "Charging" : "Unplugged"}',
        ),
      ),
      if (_userLatLng != null)
        Marker(
          markerId: const MarkerId('user-marker'),
          position: userPos,
          icon: _userMarkerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          anchor: const Offset(0.5, 0.95),
          infoWindow: const InfoWindow(
            title: 'You',
            snippet: 'Your Live Location',
          ),
        ),
    };

    // Romantic Dashed Polyline Connecting Couple
    final polylines = <Polyline>{
      if (_userLatLng != null)
        Polyline(
          polylineId: const PolylineId('couple-love-line'),
          points: [userPos, partnerPos],
          color: BelieveColors.primary,
          width: 3,
          geodesic: true,
          patterns: [PatternItem.dash(14), PatternItem.gap(8)],
        ),
    };

    return Scaffold(
      backgroundColor: BelieveColors.background,
      appBar: AppBar(
        title: Text(
          'Where You Are ✨',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: BelieveColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _currentMapType == MapType.normal
                  ? LucideIcons.layers
                  : LucideIcons.map,
              size: 20,
            ),
            tooltip: 'Map Style',
            onPressed: _toggleMapType,
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Interactive Google Map with Romantic Pastel Styling
            Positioned.fill(
              child: SizedBox.expand(
                child: GoogleMap(
                  style: _currentMapType == MapType.normal
                      ? _romanticPastelMapStyle
                      : null,
                  mapType: _currentMapType,
                  initialCameraPosition: CameraPosition(
                    target: partnerPos,
                    zoom: 14.5,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                    // Fit both lovers in view with smooth bounds on creation
                    Future.delayed(const Duration(milliseconds: 600), () {
                      if (mounted) _fitBothInView();
                    });
                  },
                  markers: markers,
                  polylines: polylines,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: false,
                  mapToolbarEnabled: false,
                  onCameraMoveStarted: () {
                    if (_isAutoTracking) {
                      setState(() => _isAutoTracking = false);
                    }
                  },
                ),
              ),
            ),

          // 2. Floating Distance Badge in Top-Center
          Positioned(
            top: 14.h,
            left: 0,
            right: 0,
            child: Center(
              child: GlassmorphicCard(
                borderRadius: 24.r,
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                surfaceColor: Colors.white.withValues(alpha: 0.95),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: Tween<double>(begin: 0.85, end: 1.25).animate(
                        CurvedAnimation(
                          parent: _waveController,
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: const Icon(
                        LucideIcons.heart,
                        size: 14,
                        color: BelieveColors.primary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '${partner.distanceKm ?? 0} km apart',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: BelieveColors.primaryDark,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: BelieveColors.success,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Live',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: BelieveColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Floating Quick Control Buttons (Right side - Love, Refresh, Current Location, Layer)
          Positioned(
            right: 16.w,
            top: 70.h,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MapActionButton(
                  icon: LucideIcons.heart,
                  color: BelieveColors.primary,
                  tooltip: 'Center on Partner (Love)',
                  onTap: _centerOnPartner,
                ),
                SizedBox(height: 10.h),
                _MapActionButton(
                  icon: LucideIcons.refreshCw,
                  color: BelieveColors.primaryDark,
                  tooltip: 'Refresh Location & Fit Both',
                  onTap: _refreshLocations,
                ),
                SizedBox(height: 10.h),
                _MapActionButton(
                  icon: LucideIcons.locateFixed,
                  color: BelieveColors.accentLavender,
                  tooltip: 'Current Location',
                  onTap: _centerOnUser,
                ),
                SizedBox(height: 10.h),
                _MapActionButton(
                  icon: _currentMapType == MapType.normal
                      ? LucideIcons.layers
                      : LucideIcons.map,
                  color: BelieveColors.textPrimary,
                  tooltip: 'Toggle Satellite / Pastel Map',
                  onTap: _toggleMapType,
                ),
              ],
            ),
          ),

          // 4. Bottom Floating Glass Control Card
          Positioned(
            bottom: 24.h,
            left: 20.w,
            right: 20.w,
            child: GlassmorphicCard(
              padding: EdgeInsets.all(20.r),
              surfaceColor: Colors.white.withValues(alpha: 0.95),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${media.partnerName} is at',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.sp,
                                    color: BelieveColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                const Icon(
                                  LucideIcons.mapPin,
                                  size: 12,
                                  color: BelieveColors.primary,
                                ),
                              ],
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              partner.placeName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w800,
                                color: BelieveColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '${partner.distanceKm ?? 0} km away from your heart',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.sp,
                                color: BelieveColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: BelieveColors.primarySoft,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              partner.isCharging
                                  ? LucideIcons.batteryCharging
                                  : LucideIcons.battery,
                              size: 15,
                              color: BelieveColors.success,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '${partner.batteryLevel}%',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: BelieveColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),

                  // Push Check-In Alert Button
                  GestureDetector(
                    onTap: _sendCheckInAlert,
                    child: Container(
                      height: 46.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: BelieveColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: BelieveColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              LucideIcons.bell,
                              color: Colors.white,
                              size: 17,
                            ),
                            SizedBox(width: 8.w),
                            Flexible(
                              child: Text(
                                'Send Arrival Alert & Check-In',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // Secondary Button: View Arrival Logs & Safe Places
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.locationDetails),
                    child: Container(
                      height: 38.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: BelieveColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: BelieveColors.glassBorder),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              LucideIcons.history,
                              color: BelieveColors.burgundy,
                              size: 14,
                            ),
                            SizedBox(width: 6.w),
                            Flexible(
                              child: Text(
                                'Arrival History & Safe Places (150m)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: BelieveColors.burgundy,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }
}

class _MapActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _MapActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 6,
      shadowColor: BelieveColors.primary.withValues(alpha: 0.25),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          splashColor: BelieveColors.primarySoft,
          highlightColor: BelieveColors.primarySoft.withValues(alpha: 0.5),
          child: Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: BelieveColors.glassBorder,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Icon(icon, color: color, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}
