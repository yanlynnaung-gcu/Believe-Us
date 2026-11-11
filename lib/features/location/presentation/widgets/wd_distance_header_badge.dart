import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';

/// Top-center floating glass badge indicating real-time distance between lovers
class WdDistanceHeaderBadge extends StatelessWidget {
  final double distanceKm;
  final Animation<double> waveAnimation;

  const WdDistanceHeaderBadge({
    super.key,
    required this.distanceKm,
    required this.waveAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 14.h,
      left: 0,
      right: 0,
      child: Center(
        child: RepaintBoundary(
          child: GlassmorphicCard(
            borderRadius: 24.r,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            surfaceColor: Colors.white.withValues(alpha: 0.95),
            child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: waveAnimation,
                child: const Icon(
                  LucideIcons.heart,
                  size: 14,
                  color: BelieveColors.primary,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '$distanceKm km apart',
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
  );
}
}
