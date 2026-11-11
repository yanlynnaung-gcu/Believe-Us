import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/router/route_names.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';

/// Delightful success animation dialog with floating hearts navigating to dashboard
void showPairingSuccessDialog(BuildContext context) {
  HapticFeedback.heavyImpact();
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) {
      // Auto navigate to home dashboard after celebration delay
      Future.delayed(const Duration(milliseconds: 2200), () {
        if (dialogCtx.mounted) {
          Navigator.of(dialogCtx).pop();
        }
        if (context.mounted) {
          context.go(AppRoutes.home);
        }
      });

      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Floating decorative hearts
            Positioned(
              top: -30.h,
              left: 30.w,
              child: const Icon(
                LucideIcons.heart,
                color: BelieveColors.primaryLight,
                size: 28,
              )
                  .animate()
                  .scale(duration: 600.ms)
                  .fadeIn()
                  .moveY(begin: 30, end: -60, duration: 1800.ms),
            ),
            Positioned(
              top: -50.h,
              right: 40.w,
              child: const Icon(
                LucideIcons.heart,
                color: BelieveColors.primary,
                size: 36,
              )
                  .animate(delay: 150.ms)
                  .scale(duration: 600.ms)
                  .fadeIn()
                  .moveY(begin: 40, end: -80, duration: 2000.ms),
            ),
            Positioned(
              top: -15.h,
              right: 15.w,
              child: const Icon(
                LucideIcons.sparkles,
                color: BelieveColors.champagne,
                size: 24,
              )
                  .animate(delay: 300.ms)
                  .scale()
                  .fadeIn()
                  .moveY(begin: 20, end: -50, duration: 1600.ms),
            ),

            // Central Celebration Glass Card
            GlassmorphicCard(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
              borderRadius: 28.r,
              surfaceColor: Colors.white.withValues(alpha: 0.96),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72.w,
                    height: 72.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: BelieveColors.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: BelieveColors.primary.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        LucideIcons.heartHandshake,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ).animate().scale(
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    'Soulmates Connected! ❤️',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: BelieveColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Your private 1-to-1 couple sanctuary is now bonded forever.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.sp,
                      color: BelieveColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: BelieveColors.primary,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'Entering Sanctuary...',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: BelieveColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
