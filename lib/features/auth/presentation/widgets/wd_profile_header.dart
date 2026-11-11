import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';

class WdProfileHeader extends StatelessWidget {
  const WdProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Let Your Partner Recognize You ✨',
          style: GoogleFonts.playfairDisplay(
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
            color: BelieveColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Set your real photo, sweet romantic name, and role for your private sanctuary.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.sp,
            color: BelieveColors.textSecondary,
            height: 1.4,
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }
}
