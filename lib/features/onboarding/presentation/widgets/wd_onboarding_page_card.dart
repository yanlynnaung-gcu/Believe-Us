import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';
import 'package:thae_nge_lay/features/onboarding/domain/models/onboarding_item.dart';

class WdOnboardingPageCard extends StatelessWidget {
  final OnboardingItem item;

  const WdOnboardingPageCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Floating Hero Illustration Container
          GlassmorphicCard(
            borderRadius: 120.r,
            padding: EdgeInsets.all(28.r),
            child: Container(
              width: 140.w,
              height: 140.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: item.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: item.gradientColors.first.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                item.icon,
                size: 64.r,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 36.h),

          // Title
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: BelieveColors.textPrimary,
              height: 1.25,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 14.h),

          // Subtitle
          Text(
            item.subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: BelieveColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
