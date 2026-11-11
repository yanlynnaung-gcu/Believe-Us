import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';

class WdOtpVerifyHeader extends StatelessWidget {
  final String email;

  const WdOtpVerifyHeader({
    super.key,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 16.h),
        Container(
          width: 76.w,
          height: 76.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: BelieveColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: BelieveColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              LucideIcons.mailCheck,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
        SizedBox(height: 20.h),
        Text(
          'Verify Your Email 💌',
          style: GoogleFonts.playfairDisplay(
            fontSize: 26.sp,
            fontWeight: FontWeight.w800,
            color: BelieveColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'We sent a 6-digit verification code to:',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.sp,
            color: BelieveColors.textSecondary,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: BelieveColors.primarySoft,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: BelieveColors.glassBorder),
          ),
          child: Text(
            email.isNotEmpty ? email : 'your email',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: BelieveColors.primaryDark,
            ),
          ),
        ),
        SizedBox(height: 32.h),
      ],
    );
  }
}
