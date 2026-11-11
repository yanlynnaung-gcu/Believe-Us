import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/features/home/presentation/controllers/couple_media_controller.dart';
import 'package:thae_nge_lay/features/location_trust/presentation/controllers/location_detail_controller.dart';
import 'package:thae_nge_lay/features/location_trust/presentation/widgets/wd_add_trusted_place_modal.dart';
import 'package:thae_nge_lay/features/location_trust/presentation/widgets/wd_arrival_log_sheet.dart';
import 'package:thae_nge_lay/features/location_trust/presentation/widgets/wd_distance_pill.dart';
import 'package:thae_nge_lay/features/location_trust/presentation/widgets/wd_location_header.dart';
import 'package:thae_nge_lay/features/location_trust/presentation/widgets/wd_location_map_view.dart';
import 'package:thae_nge_lay/features/location_trust/presentation/widgets/wd_map_control_panel.dart';

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(locationDetailControllerProvider);
    final coupleMedia = ref.watch(coupleMediaProvider);

    return Scaffold(
      backgroundColor: BelieveColors.background,
      body: Stack(
        children: [
          // 1. Interactive Map View
          SizedBox(
            height: 0.62.sh,
            width: double.infinity,
            child: WdLocationMapView(
              state: state,
              coupleMedia: coupleMedia,
              pulseAnimation: Tween<double>(begin: 1.0, end: 1.35).animate(
                CurvedAnimation(
                  parent: _pulseController,
                  curve: Curves.easeInOut,
                ),
              ),
              onMapCreated: (controller) => _mapController = controller,
            ),
          ),

          // 2. Top Navigation Header
          WdLocationHeader(
            partnerName: state.partnerName,
            onBack: () => Navigator.of(context).pop(),
          ),

          // 3. Map Control Floating Action Buttons Panel
          WdMapControlPanel(
            isSheetMinimized: _isSheetMinimized,
            onSync: () =>
                ref.read(locationDetailControllerProvider.notifier).refresh(),
            onCenterPartner: () => _centerOnPartner(
              state.partnerLatitude,
              state.partnerLongitude,
            ),
            onShowBoth: () => _showBothOfUs(
              state.currentUserLatitude,
              state.currentUserLongitude,
              state.partnerLatitude,
              state.partnerLongitude,
            ),
            onToggleSheet: _toggleSheet,
          ),

          // 4. Romantic Distance Pill
          WdDistancePill(distanceKm: state.distanceKm),

          // 5. Draggable Arrival Log & Trusted Places Sheet
          WdArrivalLogSheet(
            sheetController: _sheetController,
            tabController: _tabController,
            state: state,
            onToggleSheet: _toggleSheet,
            onSendNudge: () {
              ref
                  .read(locationDetailControllerProvider.notifier)
                  .sendSafetyNudge();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('💌 Sweet safety heart nudge sent to partner!'),
                  backgroundColor: BelieveColors.primary,
                ),
              );
            },
            onLogSelected: (log) {
              ref
                  .read(locationDetailControllerProvider.notifier)
                  .selectArrivalLog(log);
              _centerOnPartner(log.latitude, log.longitude);
            },
            onAddPlace: () => showAddTrustedPlaceModal(
              context,
              onSave: ({
                required String name,
                required String iconName,
                required double latitude,
                required double longitude,
              }) =>
                  ref
                      .read(locationDetailControllerProvider.notifier)
                      .addTrustedPlace(
                        name: name,
                        iconName: iconName,
                        latitude: latitude,
                        longitude: longitude,
                      ),
            ),
            onRefresh: () =>
                ref.read(locationDetailControllerProvider.notifier).refresh(),
          ),
        ],
      ),
    );
  }
}
