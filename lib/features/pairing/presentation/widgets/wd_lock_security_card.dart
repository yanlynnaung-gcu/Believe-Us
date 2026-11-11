import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';

/// Strict 1-to-1 Lock Security Alert Card
class WdLockSecurityCard extends StatelessWidget {
  const WdLockSecurityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: BelieveColors.primarySoft,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: BelieveColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            LucideIcons.lock,
            color: BelieveColors.primary,
            size: 18,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Strict 1-to-1 Lock: Once paired, both accounts are bound permanently to each other. Neither account can pair with anyone else unless explicitly unlinked.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.sp,
                color: BelieveColors.burgundy,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
