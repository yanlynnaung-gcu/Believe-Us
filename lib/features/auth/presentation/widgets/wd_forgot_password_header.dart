import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';

class WdForgotPasswordHeader extends StatelessWidget {
  final int currentStep;

  const WdForgotPasswordHeader({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 12.h),
        Container(
          width: 68.w,
          height: 68.w,
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
          child: Center(
            child: Icon(
              currentStep == 0 ? LucideIcons.keyRound : LucideIcons.lock,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
        SizedBox(height: 14.h),
        Text(
          currentStep == 0 ? 'Find Your Account' : 'Reset Password',
          style: GoogleFonts.playfairDisplay(
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
            color: BelieveColors.textPrimary,
            letterSpacing: -0.4,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          currentStep == 0
              ? 'Enter your registered email address to receive a 6-digit verification code.'
              : 'Enter the 6-digit code sent to your email and set your new password.',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.sp,
            color: BelieveColors.textSecondary,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }
}
