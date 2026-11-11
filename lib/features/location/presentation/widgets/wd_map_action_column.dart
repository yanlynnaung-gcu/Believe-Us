import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/features/location/presentation/widgets/wd_map_action_button.dart';

/// Floating right-side quick control buttons (Heart, Refresh, Locate, Layers)
class WdMapActionColumn extends StatelessWidget {
  final MapType currentMapType;
  final VoidCallback onCenterPartner;
  final VoidCallback onRefreshLocations;
  final VoidCallback onCenterUser;
  final VoidCallback onToggleMapType;

  const WdMapActionColumn({
    super.key,
    required this.currentMapType,
    required this.onCenterPartner,
    required this.onRefreshLocations,
    required this.onCenterUser,
    required this.onToggleMapType,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16.w,
      top: 70.h,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          WdMapActionButton(
            icon: LucideIcons.heart,
            color: BelieveColors.primary,
            tooltip: 'Center on Partner (Love)',
            onTap: onCenterPartner,
          ),
          SizedBox(height: 10.h),
          WdMapActionButton(
            icon: LucideIcons.refreshCw,
            color: BelieveColors.primaryDark,
            tooltip: 'Refresh Location & Fit Both',
            onTap: onRefreshLocations,
          ),
          SizedBox(height: 10.h),
          WdMapActionButton(
            icon: LucideIcons.locateFixed,
            color: BelieveColors.accentLavender,
            tooltip: 'Current Location',
            onTap: onCenterUser,
          ),
          SizedBox(height: 10.h),
          WdMapActionButton(
            icon: currentMapType == MapType.normal
                ? LucideIcons.layers
                : LucideIcons.map,
            color: BelieveColors.textPrimary,
            tooltip: 'Toggle Satellite / Pastel Map',
            onTap: onToggleMapType,
          ),
        ],
      ),
    );
  }
}
