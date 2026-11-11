import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';

/// Romantic hero banner on Contact Us screen with 24/7 support badge
class WdContactHeroBanner extends StatelessWidget {
  const WdContactHeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      padding: EdgeInsets.all(20.r),
      surfaceColor: Colors.white.withValues(alpha: 0.9),
      child: Column(
        children: [
          Container(
            width: 58.w,
            height: 58.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: BelieveColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: BelieveColors.primarySoft,
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              LucideIcons.heartHandshake,
              color: Colors.white,
              size: 28,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            'We Love Hearing From You',
            style: GoogleFonts.playfairDisplay(
              fontSize: 19.sp,
              fontWeight: FontWeight.w800,
              color: BelieveColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          Text(
            'Whether you need help with pairing, location syncing, gifting, or want to share feedback for your love journey — we are here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              color: BelieveColors.textSecondary,
              height: 1.45,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 6.h,
            ),
            decoration: BoxDecoration(
              color: BelieveColors.primarySoft,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  LucideIcons.sparkles,
                  size: 13,
                  color: BelieveColors.primary,
                ),
                SizedBox(width: 6.w),
                Flexible(
                  child: Text(
                    '24/7 Dedicated Couple Support 💌',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: BelieveColors.burgundy,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
