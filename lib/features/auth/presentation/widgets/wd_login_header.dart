import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';

class WdLoginHeader extends StatelessWidget {
  const WdLoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 24.h),
        Container(
          width: 76.w,
          height: 76.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: BelieveColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: BelieveColors.primary.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              LucideIcons.heart,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
        SizedBox(height: 14.h),
        Text(
          'Thae Thae',
          style: GoogleFonts.playfairDisplay(
            fontSize: 28.sp,
            fontWeight: FontWeight.w800,
            color: BelieveColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Your Private 1-to-1 Couple Sanctuary ✨',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.sp,
            color: BelieveColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 22.h),
      ],
    );
  }
}
