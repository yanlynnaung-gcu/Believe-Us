import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';

class WdOnboardingControls extends StatelessWidget {
  final int currentIndex;
  final int pageCount;
  final bool isLastPage;
  final VoidCallback onNext;

  const WdOnboardingControls({
    super.key,
    required this.currentIndex,
    required this.pageCount,
    required this.isLastPage,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(28.w, 0, 28.w, 24.h),
      child: Column(
        children: [
          // Animated Page Indicator Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pageCount,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                width: currentIndex == index ? 26.w : 7.w,
                height: 7.h,
                decoration: BoxDecoration(
                  color: currentIndex == index
                      ? BelieveColors.primary
                      : BelieveColors.border,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
          ),
          SizedBox(height: 28.h),

          // Main Button
          GestureDetector(
            onTap: onNext,
            child: Container(
              height: 54.h,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: BelieveColors.primaryGradient,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: BelieveColors.primary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLastPage ? 'Begin Our Journey ✨' : 'Continue',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    const Icon(
                      LucideIcons.arrowRight,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.lock,
                size: 13,
                color: BelieveColors.textMuted,
              ),
              SizedBox(width: 6.w),
              Text(
                '1-to-1 Encrypted Connection for Couples Only',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.sp,
                  color: BelieveColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
