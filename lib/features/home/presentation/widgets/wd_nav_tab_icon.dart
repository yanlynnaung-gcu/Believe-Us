import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';

/// Navigation Tab Icon with Real-Time Animated Badges
class WdNavTabIcon extends StatelessWidget {
  final int index;
  final IconData icon;
  final bool isSelected;
  final int unreadMessagesCount;
  final int unseenGiftsCount;
  final bool isMoving;
  final Animation<double> pulseAnimation;

  const WdNavTabIcon({
    super.key,
    required this.index,
    required this.icon,
    required this.isSelected,
    required this.unreadMessagesCount,
    required this.unseenGiftsCount,
    required this.isMoving,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final baseIcon = Icon(
      icon,
      size: 18.r,
      color: isSelected ? Colors.white : BelieveColors.textMuted,
    );

    // Tab 1: Whisper / Love Chat -> Pulsing Soft Rose-Pink Badge (#E84A7F)
    if (index == 1) {
      if (unreadMessagesCount <= 0) return baseIcon;

      return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          baseIcon,
          Positioned(
            top: -6.h,
            right: -8.w,
            child: AnimatedBuilder(
              animation: pulseAnimation,
              builder: (context, child) {
                final scale = 0.90 + (pulseAnimation.value * 0.18);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
                    constraints: BoxConstraints(minWidth: 16.r, minHeight: 16.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE84A7F),
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE84A7F)
                              .withValues(alpha: 0.45 * pulseAnimation.value),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        unreadMessagesCount > 99 ? '99+' : '$unreadMessagesCount',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    // Tab 2: Close to You / Location -> Live Movement Indicator Pill
    if (index == 2) {
      if (!isMoving) return baseIcon;

      return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          baseIcon,
          Positioned(
            top: -10.h,
            right: -24.w,
            child: AnimatedBuilder(
              animation: pulseAnimation,
              builder: (context, child) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981)
                            .withValues(alpha: 0.4 * pulseAnimation.value),
                        blurRadius: 4,
                        spreadRadius: 0.5,
                      ),
                    ],
                  ),
                  child: Text(
                    '🚗 Moving',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    // Tab 3: Moments / Surprise Gift -> Sparkling Gold/Ruby Gift Box Badge (🎁)
    if (index == 3) {
      if (unseenGiftsCount <= 0) return baseIcon;

      return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          baseIcon,
          Positioned(
            top: -8.h,
            right: -10.w,
            child: AnimatedBuilder(
              animation: pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.90 + (pulseAnimation.value * 0.22),
                  child: Container(
                    padding: EdgeInsets.all(2.r),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFE11D48)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700)
                              .withValues(alpha: 0.6 * pulseAnimation.value),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Text(
                      '🎁',
                      style: TextStyle(fontSize: 9.sp),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    return baseIcon;
  }
}
