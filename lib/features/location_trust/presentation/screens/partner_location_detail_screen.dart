import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';
import 'package:thae_nge_lay/features/home/presentation/controllers/couple_media_controller.dart';
import 'package:thae_nge_lay/features/location_trust/domain/models/partner_location_arrival_model.dart';
import 'package:thae_nge_lay/features/location_trust/presentation/controllers/location_detail_controller.dart';

class PartnerLocationDetailScreen extends ConsumerStatefulWidget {
  const PartnerLocationDetailScreen({super.key});

  @override
  ConsumerState<PartnerLocationDetailScreen> createState() =>
      _PartnerLocationDetailScreenState();
}

class _PartnerLocationDetailScreenState
    extends ConsumerState<PartnerLocationDetailScreen>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  late TabController _tabController;
  late DraggableScrollableController _sheetController;
  late AnimationController _pulseController;
  bool _isSheetMinimized = false;
  final bool _useGoogleMaps = true;

  // Soft pastel custom map styling JSON
  static const String _pastelMapStyle = '''
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
    _tabController = TabController(length: 2, vsync: this);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _sheetController = DraggableScrollableController();
    _sheetController.addListener(() {
      if (_sheetController.isAttached) {
        final isMin = _sheetController.size <= 0.15;
        if (isMin != _isSheetMinimized) {
          setState(() => _isSheetMinimized = isMin);
        }
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mapController?.dispose();
    _tabController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  void _toggleSheet() {
    HapticFeedback.lightImpact();
    if (_sheetController.isAttached) {
      if (_sheetController.size > 0.15) {
        _sheetController.animateTo(
          0.08,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _sheetController.animateTo(
          0.45,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _centerOnPartner(double lat, double lng) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(lat, lng), zoom: 16.5),
        ),
      );
    }
  }

  void _showBothOfUs(
    double userLat,
    double userLng,
    double partnerLat,
    double partnerLng,
  ) {
    if (_mapController != null) {
      final southWest = LatLng(
        math.min(userLat, partnerLat) - 0.01,
        math.min(userLng, partnerLng) - 0.01,
      );
      final northEast = LatLng(
        math.max(userLat, partnerLat) + 0.01,
        math.max(userLng, partnerLng) + 0.01,
      );
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(southwest: southWest, northeast: northEast),
          60,
        ),
      );
    }
  }

  void _openAddTrustedPlaceModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    String selectedIcon = 'home';
    double lat = 16.8295;
    double lng = 96.1305;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
              ),
              padding: EdgeInsets.fromLTRB(
                24.w,
                16.h,
                24.w,
                MediaQuery.of(context).viewInsets.bottom + 28.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: BelieveColors.border,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    'Add Trusted Place ✨',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: BelieveColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Set a 150m sacred safety zone for instant arrival alerts',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      color: BelieveColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Name field
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Place Name',
                      hintText: 'e.g. My Apartment, Study Library, Gym',
                      prefixIcon: const Icon(
                        LucideIcons.mapPin,
                        color: BelieveColors.primary,
                      ),
                      filled: true,
                      fillColor: BelieveColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: const BorderSide(color: BelieveColors.border),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Icon picker
                  Text(
                    'Choose Category Icon',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: BelieveColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _iconOption('home', LucideIcons.home, selectedIcon, () {
                        setModalState(() => selectedIcon = 'home');
                      }),
                      _iconOption('briefcase', LucideIcons.briefcase, selectedIcon, () {
                        setModalState(() => selectedIcon = 'briefcase');
                      }),
                      _iconOption('coffee', LucideIcons.coffee, selectedIcon, () {
                        setModalState(() => selectedIcon = 'coffee');
                      }),
                      _iconOption('heart', LucideIcons.heart, selectedIcon, () {
                        setModalState(() => selectedIcon = 'heart');
                      }),
                      _iconOption('school', LucideIcons.graduationCap, selectedIcon, () {
                        setModalState(() => selectedIcon = 'school');
                      }),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Save button
                  GestureDetector(
                    onTap: () async {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) return;

                      final success = await ref
                          .read(locationDetailControllerProvider.notifier)
                          .addTrustedPlace(
                            name: name,
                            iconName: selectedIcon,
                            latitude: lat,
                            longitude: lng,
                          );

                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success
                                ? 'Trusted place "$name" saved! ✨'
                                : 'Failed to save place.'),
                            backgroundColor: success
                                ? BelieveColors.success
                                : BelieveColors.error,
                          ),
                        );
                      }
                    },
                    child: Container(
                      height: 50.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: BelieveColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: BelieveColors.primary.withValues(alpha: 0.3),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Save Trusted Place 💕',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _iconOption(
    String id,
    IconData icon,
    String selectedId,
    VoidCallback onTap,
  ) {
    final isSelected = id == selectedId;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: isSelected ? BelieveColors.primary : BelieveColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? BelieveColors.primary : BelieveColors.border,
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? Colors.white : BelieveColors.textPrimary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(locationDetailControllerProvider);
    final coupleMedia = ref.watch(coupleMediaProvider);

    return Scaffold(
      backgroundColor: BelieveColors.background,
      body: Stack(
        children: [
          // 1. TOP INTERACTIVE MAP VIEW (Takes ~60% height)
          SizedBox(
            height: 0.62.sh,
            width: double.infinity,
            child: _buildMapView(state, coupleMedia),
          ),

          // Top Navigation Header (Back button + Title)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8.h,
            left: 16.w,
            right: 16.w,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      LucideIcons.chevronLeft,
                      size: 20,
                      color: BelieveColors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: BelieveColors.glassBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: const BoxDecoration(
                            color: BelieveColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            '${state.partnerName}\'s Safe Haven ✨',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: BelieveColors.textPrimary,
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

          // Map Control Floating Buttons (Top Right)
          Positioned(
            top: MediaQuery.of(context).padding.top + 56.h,
            right: 16.w,
            child: Column(
              children: [
                // Sync with Spring Boot Backend
                _buildMapControlBtn(
                  icon: LucideIcons.refreshCw,
                  tooltip: 'Sync Arrival Logs',
                  color: BelieveColors.primary,
                  onTap: () {
                    ref
                        .read(locationDetailControllerProvider.notifier)
                        .refresh();
                  },
                ),
                SizedBox(height: 10.h),
                // Center on Partner
                _buildMapControlBtn(
                  icon: LucideIcons.heartHandshake,
                  tooltip: 'Center on Partner',
                  color: BelieveColors.primary,
                  onTap: () => _centerOnPartner(
                    state.partnerLatitude,
                    state.partnerLongitude,
                  ),
                ),
                SizedBox(height: 10.h),
                // Show Both of Us
                _buildMapControlBtn(
                  icon: LucideIcons.compass,
                  tooltip: 'Show Both of Us',
                  color: BelieveColors.accentLavender,
                  onTap: () => _showBothOfUs(
                    state.currentUserLatitude,
                    state.currentUserLongitude,
                    state.partnerLatitude,
                    state.partnerLongitude,
                  ),
                ),
                SizedBox(height: 10.h),
                // Toggle Bottom Sheet / Full Map
                _buildMapControlBtn(
                  icon: _isSheetMinimized
                      ? LucideIcons.panelBottomOpen
                      : LucideIcons.panelBottomClose,
                  tooltip: _isSheetMinimized
                      ? 'Show Arrival Logs'
                      : 'Full Screen Map',
                  color: BelieveColors.textPrimary,
                  onTap: _toggleSheet,
                ),
              ],
            ),
          ),

          // Distance Pill Floating over Map Center
          Positioned(
            top: 0.28.sh,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                decoration: BoxDecoration(
                  gradient: BelieveColors.romanticSunsetGradient,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: BelieveColors.primary.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '💞 ${state.distanceKm.toStringAsFixed(1)} km apart',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. DRAGGABLE & DISMISSIBLE BOTTOM SHEET (Today's Arrival Log & Trusted Places)
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.45,
            minChildSize: 0.08,
            maxChildSize: 0.88,
            snap: true,
            snapSizes: const [0.08, 0.45, 0.88],
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(32.r)),
                  border: Border.all(color: BelieveColors.glassBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Sheet Handle with tap to minimize/expand
                    GestureDetector(
                      onTap: _toggleSheet,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10.h,
                          horizontal: 20.w,
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 44.w,
                              height: 4.h,
                              decoration: BoxDecoration(
                                color: BelieveColors.border,
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Icon(
                                        LucideIcons.history,
                                        size: 15,
                                        color: BelieveColors.primary,
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Text(
                                          'Today\'s Arrival Log & Places',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w800,
                                            color: BelieveColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 2.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: BelieveColors.primarySoft,
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                      ),
                                      child: Text(
                                        '${state.todayArrivalLogs.length} events',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w700,
                                          color: BelieveColors.burgundy,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    Icon(
                                      _isSheetMinimized
                                          ? LucideIcons.chevronUp
                                          : LucideIcons.chevronDown,
                                      size: 16,
                                      color: BelieveColors.textMuted,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Live Status Card (slides with sheet!)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 4.h,
                      ),
                      child: _buildLiveStatusCard(context, state),
                    ),

                    SizedBox(height: 6.h),

                    // Sheet Tabs
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.w),
                      decoration: BoxDecoration(
                        color: BelieveColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          gradient: BelieveColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Colors.white,
                        unselectedLabelColor: BelieveColors.textSecondary,
                        labelStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        tabs: const [
                          Tab(text: "Today's Arrival Log"),
                          Tab(text: "Trusted Places (150m)"),
                        ],
                      ),
                    ),

                    SizedBox(height: 10.h),

                    // Tab Views
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Tab 1: Chronological Arrival Timeline
                          _buildArrivalTimelineTab(state, scrollController),

                          // Tab 2: Trusted Places & Geofence
                          _buildTrustedPlacesTab(state, scrollController),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMapControlBtn({
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 5,
      shadowColor: color.withValues(alpha: 0.3),
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
              border: Border.all(color: BelieveColors.glassBorder),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildMapView(
    LocationDetailState state,
    CoupleMediaState coupleMedia,
  ) {
    if (!_useGoogleMaps) {
      return _buildRomanticMapCanvasFallback(state, coupleMedia);
    }

    final partnerLatLng = LatLng(state.partnerLatitude, state.partnerLongitude);
    final userLatLng =
        LatLng(state.currentUserLatitude, state.currentUserLongitude);

    // Markers
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('partner'),
        position: partnerLatLng,
        infoWindow: InfoWindow(
          title: "${state.partnerName} (${state.placeName})",
          snippet: state.addressLine,
        ),
      ),
      Marker(
        markerId: const MarkerId('user'),
        position: userLatLng,
        infoWindow: const InfoWindow(title: 'You', snippet: 'Your Live Location'),
      ),
    };

    // Polyline connecting couple
    final polylines = <Polyline>{
      Polyline(
        polylineId: const PolylineId('couple-connection'),
        points: [userLatLng, partnerLatLng],
        color: BelieveColors.primary,
        width: 4,
        patterns: [PatternItem.dash(15), PatternItem.gap(10)],
      ),
    };

    return Stack(
      children: [
        GoogleMap(
          style: _pastelMapStyle,
          initialCameraPosition: CameraPosition(
            target: partnerLatLng,
            zoom: 13.5,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
          },
          markers: markers,
          polylines: polylines,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          onCameraMoveStarted: () {},
        ),

        // Beautiful romantic heart pins overlay
        Positioned.fill(
          child: IgnorePointer(
            child: _buildRomanticHeartPinsOverlay(state, coupleMedia),
          ),
        ),
      ],
    );
  }

  Widget _buildRomanticHeartPinsOverlay(
    LocationDetailState state,
    CoupleMediaState coupleMedia,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return Stack(
          children: [
            // Partner Heart Pin with Beating Ring (Positioned at 36% top, 60% right)
            Positioned(
              top: h * 0.28,
              left: w * 0.58,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated pulsing aura
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ScaleTransition(
                        scale: Tween<double>(begin: 1.0, end: 1.35).animate(
                          CurvedAnimation(
                            parent: _pulseController,
                            curve: Curves.easeInOut,
                          ),
                        ),
                        child: Container(
                          width: 58.r,
                          height: 58.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: BelieveColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                      // Heart Pin Frame
                      Container(
                        width: 46.r,
                        height: 46.r,
                        padding: EdgeInsets.all(3.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: BelieveColors.primaryGradient,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: BelieveColors.primary.withValues(alpha: 0.4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          backgroundImage:
                              NetworkImage(coupleMedia.partnerAvatarPath),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Text(
                      '${state.partnerName} ❤️',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: BelieveColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // My Heart Pin (Positioned at 52% top, 24% left)
            Positioned(
              top: h * 0.44,
              left: w * 0.22,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42.r,
                    height: 42.r,
                    padding: EdgeInsets.all(2.5.r),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: BelieveColors.romanticSunsetGradient,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color:
                              BelieveColors.accentLavender.withValues(alpha: 0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundImage:
                          NetworkImage(coupleMedia.userAvatarPath),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Text(
                      'You 💜',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: BelieveColors.burgundy,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRomanticMapCanvasFallback(
    LocationDetailState state,
    CoupleMediaState coupleMedia,
  ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF6F8), Color(0xFFEFF5FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: _PastelGridPainter(),
          ),
          _buildRomanticHeartPinsOverlay(state, coupleMedia),
        ],
      ),
    );
  }

  Widget _buildLiveStatusCard(
    BuildContext context,
    LocationDetailState state,
  ) {
    final isBatteryLow = state.batteryLevel <= 20;

    return GlassmorphicCard(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Place Badge & Address
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  gradient: BelieveColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: BelieveColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  state.status == MovementStatus.stationary
                      ? LucideIcons.home
                      : LucideIcons.car,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.status == MovementStatus.stationary
                          ? '🏠 At ${state.placeName}'
                          : '🚗 Moving (${state.speedKmh.toStringAsFixed(0)} km/h)',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: BelieveColors.textPrimary,
                      ),
                    ),
                    Text(
                      state.addressLine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.sp,
                        color: BelieveColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // Arrival Time & Stay Duration
          Row(
            children: [
              const Icon(
                LucideIcons.clock,
                size: 13,
                color: BelieveColors.primary,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  'Arrived at ${DateFormat('h:mm a').format(state.arrivedAt)} • Stayed for ${state.stayDurationFormatted}',
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

          SizedBox(height: 12.h),

          // Telemetry Pills & Nudge Action
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Battery Level Pill
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: isBatteryLow
                              ? BelieveColors.error.withValues(alpha: 0.12)
                              : BelieveColors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isBatteryLow
                                ? BelieveColors.error
                                : BelieveColors.border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              state.isCharging
                                  ? LucideIcons.batteryCharging
                                  : LucideIcons.battery,
                              size: 13,
                              color: isBatteryLow
                                  ? BelieveColors.error
                                  : BelieveColors.primary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${state.batteryLevel}%${state.isCharging ? ' (Charging)' : ''}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: isBatteryLow
                                    ? BelieveColors.error
                                    : BelieveColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: 8.w),

                      // GPS Accuracy Pill
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: BelieveColors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: BelieveColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              LucideIcons.radio,
                              size: 12,
                              color: BelieveColors.success,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              state.gpsAccuracy,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: BelieveColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: 8.w),

              // Quick Action Button: Send 'Reached Safely?' Heart
              GestureDetector(
                onTap: state.isNudgeSent
                    ? null
                    : () {
                        ref
                            .read(locationDetailControllerProvider.notifier)
                            .sendSafetyNudge();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              '💌 Sweet safety heart nudge sent to partner!',
                            ),
                            backgroundColor: BelieveColors.primary,
                          ),
                        );
                      },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    gradient: state.isNudgeSent
                        ? null
                        : BelieveColors.primaryGradient,
                    color: state.isNudgeSent ? Colors.grey : null,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: BelieveColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        state.isNudgeSent
                            ? LucideIcons.check
                            : LucideIcons.heart,
                        size: 13,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        state.isNudgeSent ? 'Nudge Sent' : 'Safe?',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArrivalTimelineTab(
    LocationDetailState state,
    ScrollController scrollController,
  ) {
    final logs = state.todayArrivalLogs;
    if (logs.isEmpty) {
      return RefreshIndicator(
        onRefresh: () =>
            ref.read(locationDetailControllerProvider.notifier).refresh(),
        child: ListView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          children: [
            Center(
              child: state.isLoading
                  ? const CircularProgressIndicator.adaptive()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'No arrivals recorded yet today.',
                          style: GoogleFonts.plusJakartaSans(
                            color: BelieveColors.textMuted,
                            fontSize: 13.sp,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        TextButton.icon(
                          onPressed: () => ref
                              .read(locationDetailControllerProvider.notifier)
                              .refresh(),
                          icon: const Icon(LucideIcons.refreshCw, size: 16),
                          label: const Text('Sync with Server'),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(locationDetailControllerProvider.notifier).refresh(),
      child: ListView.builder(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        itemCount: logs.length,
        itemBuilder: (context, index) {
        final log = logs[index];
        final isCurrent = log.departedAt == null;
        final isLast = index == logs.length - 1;

        final durationText = log.departedAt != null
            ? _formatDuration(log.departedAt!.difference(log.arrivedAt))
            : _formatDuration(DateTime.now().difference(log.arrivedAt));

        return GestureDetector(
          onTap: () {
            ref
                .read(locationDetailControllerProvider.notifier)
                .selectArrivalLog(log);
            _centerOnPartner(log.latitude, log.longitude);
          },
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline node with indicator line
                Column(
                  children: [
                    Container(
                      width: 28.r,
                      height: 28.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isCurrent
                            ? BelieveColors.primaryGradient
                            : null,
                        color: isCurrent ? null : BelieveColors.surfaceSubtle,
                        border: Border.all(
                          color: isCurrent
                              ? Colors.white
                              : BelieveColors.primary.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        isCurrent ? LucideIcons.heart : LucideIcons.mapPin,
                        size: 13,
                        color: isCurrent ? Colors.white : BelieveColors.primary,
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: BelieveColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                  ],
                ),

                SizedBox(width: 14.w),

                // Arrival details card
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? BelieveColors.primarySoft
                          : BelieveColors.surface,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: isCurrent
                            ? BelieveColors.primary.withValues(alpha: 0.3)
                            : BelieveColors.border,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              log.placeName,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: BelieveColors.textPrimary,
                              ),
                            ),
                            if (isCurrent)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: BelieveColors.primary,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Text(
                                  'Currently Here',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          log.addressLine,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.sp,
                            color: BelieveColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.calendarClock,
                              size: 12,
                              color: BelieveColors.primary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              log.departedAt != null
                                  ? '${DateFormat('h:mm a').format(log.arrivedAt)} — ${DateFormat('h:mm a').format(log.departedAt!)} ($durationText)'
                                  : 'Arrived ${DateFormat('h:mm a').format(log.arrivedAt)} • ($durationText)',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: BelieveColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

  Widget _buildTrustedPlacesTab(
    LocationDetailState state,
    ScrollController scrollController,
  ) {
    final places = state.trustedPlaces;

    return ListView(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      children: [
        // Add Place Button
        GestureDetector(
          onTap: () => _openAddTrustedPlaceModal(context),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: BelieveColors.primarySoft,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: BelieveColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  LucideIcons.plusCircle,
                  color: BelieveColors.primary,
                  size: 18,
                ),
                SizedBox(width: 8.w),
                Text(
                  '+ Add Trusted Place (150m Geofence)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: BelieveColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 16.h),

        ...places.map((place) {
          final iconData = _resolvePlaceIcon(place.iconName);
          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: BelieveColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: BoxDecoration(
                    gradient: BelieveColors.romanticSunsetGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: Colors.white, size: 18),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: BelieveColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '150m Safety Radius • Arrival & Departure Alerts On',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.sp,
                          color: BelieveColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.bellRing,
                  color: BelieveColors.primary,
                  size: 18,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  IconData _resolvePlaceIcon(String name) {
    switch (name) {
      case 'briefcase':
        return LucideIcons.briefcase;
      case 'coffee':
        return LucideIcons.coffee;
      case 'heart':
        return LucideIcons.heart;
      case 'school':
        return LucideIcons.graduationCap;
      default:
        return LucideIcons.home;
    }
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

class _PastelGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF0E5EB)
      ..strokeWidth = 1.0;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
