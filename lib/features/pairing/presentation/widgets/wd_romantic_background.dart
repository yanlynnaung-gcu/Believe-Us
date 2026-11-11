import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';

/// Warm pastel gradient background with subtle glowing ambient orbs
class WdRomanticBackground extends StatelessWidget {
  const WdRomanticBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Pastel gradient base
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFFF7F9), // Soft rose blush
                Color(0xFFF9F3FF), // Soft lavender tint
                Color(0xFFFFFBF7), // Warm soft cream
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Ambient glowing orbs for glassmorphism depth
        Positioned(
          top: -40.h,
          right: -30.w,
          child: Container(
            width: 200.w,
            height: 200.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  BelieveColors.primaryLight.withValues(alpha: 0.22),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 260.h,
          left: -70.w,
          child: Container(
            width: 240.w,
            height: 240.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  BelieveColors.accentLavender.withValues(alpha: 0.20),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -40.h,
          right: -20.w,
          child: Container(
            width: 220.w,
            height: 220.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  BelieveColors.blushStart.withValues(alpha: 0.18),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
