import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';

void showLocationRefreshedSnackBar(BuildContext context) {
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

void showCheckInAlertSnackBar(BuildContext context) {
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
            child: const Icon(LucideIcons.heart, color: Colors.white, size: 16),
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
