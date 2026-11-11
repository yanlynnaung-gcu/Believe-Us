import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';

/// Bottom confirmation banner showing 1-to-1 couple space connection with settings and signout buttons
class WdCoupleBondBanner extends StatelessWidget {
  final String? coupleSpaceId;
  final VoidCallback onOpenSettings;
  final VoidCallback onSignOut;

  const WdCoupleBondBanner({
    super.key,
    required this.coupleSpaceId,
    required this.onOpenSettings,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: BelieveColors.primarySoft,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: BelieveColors.glassBorder),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.lock, color: BelieveColors.primary, size: 18),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                coupleSpaceId != null
                    ? '1-to-1 Sacred Connection • Space #$coupleSpaceId'
                    : '1-to-1 Sacred Connection • Pending Pairing',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.sp,
                  color: BelieveColors.burgundy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(LucideIcons.settings, size: 16),
              tooltip: 'Sanctuary Settings & Support',
              onPressed: onOpenSettings,
            ),
            IconButton(
              icon: const Icon(LucideIcons.logOut, size: 16),
              tooltip: 'Sign Out',
              onPressed: onSignOut,
            ),
          ],
        ),
      ),
    );
  }
}
