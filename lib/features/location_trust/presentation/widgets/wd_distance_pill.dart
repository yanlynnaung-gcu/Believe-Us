import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';

/// Floating romantic pill displaying distance between partners in kilometers
class WdDistancePill extends StatelessWidget {
  final double distanceKm;

  const WdDistancePill({super.key, required this.distanceKm});

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
          child: Text(
            '💞 ${distanceKm.toStringAsFixed(1)} km apart',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
