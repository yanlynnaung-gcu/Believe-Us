import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/features/location_trust/presentation/widgets/wd_map_control_btn.dart';

/// Floating panel of quick map control buttons (Sync, Center, Both, Sheet toggle)
class WdMapControlPanel extends StatelessWidget {
  final bool isSheetMinimized;
  final VoidCallback onSync;
  final VoidCallback onCenterPartner;
  final VoidCallback onShowBoth;
  final VoidCallback onToggleSheet;

  const WdMapControlPanel({
    super.key,
    required this.isSheetMinimized,
    required this.onSync,
    required this.onCenterPartner,
    required this.onShowBoth,
    required this.onToggleSheet,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 56.h,
      right: 16.w,
      child: RepaintBoundary(
        child: Column(
          children: [
            WdMapControlBtn(
              icon: LucideIcons.refreshCw,
              tooltip: 'Sync Arrival Logs',
              color: BelieveColors.primary,
              onTap: onSync,
            ),
            SizedBox(height: 10.h),
            WdMapControlBtn(
              icon: LucideIcons.heartHandshake,
              tooltip: 'Center on Partner',
              color: BelieveColors.primary,
              onTap: onCenterPartner,
            ),
            SizedBox(height: 10.h),
            WdMapControlBtn(
              icon: LucideIcons.compass,
              tooltip: 'Show Both of Us',
              color: BelieveColors.accentLavender,
              onTap: onShowBoth,
            ),
            SizedBox(height: 10.h),
            WdMapControlBtn(
              icon: isSheetMinimized
                  ? LucideIcons.panelBottomOpen
                  : LucideIcons.panelBottomClose,
              tooltip: isSheetMinimized
                  ? 'Show Arrival Logs'
                  : 'Full Screen Map',
              color: BelieveColors.textPrimary,
              onTap: onToggleSheet,
            ),
          ],
        ),
      ),
    );
  }
}
