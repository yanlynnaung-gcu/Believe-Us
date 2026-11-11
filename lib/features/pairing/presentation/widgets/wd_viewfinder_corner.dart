import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';

/// Corner bracket for glowing QR viewfinder
class WdViewfinderCorner extends StatelessWidget {
  final bool top;
  final bool left;

  const WdViewfinderCorner({
    super.key,
    required this.top,
    required this.left,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top ? 0 : null,
      bottom: !top ? 0 : null,
      left: left ? 0 : null,
      right: !left ? 0 : null,
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(
          border: Border(
            top: top
                ? const BorderSide(color: BelieveColors.primary, width: 4)
                : BorderSide.none,
            bottom: !top
                ? const BorderSide(color: BelieveColors.primary, width: 4)
                : BorderSide.none,
            left: left
                ? const BorderSide(color: BelieveColors.primary, width: 4)
                : BorderSide.none,
            right: !left
                ? const BorderSide(color: BelieveColors.primary, width: 4)
                : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: top && left ? Radius.circular(16.r) : Radius.zero,
            topRight: top && !left ? Radius.circular(16.r) : Radius.zero,
            bottomLeft: !top && left ? Radius.circular(16.r) : Radius.zero,
            bottomRight: !top && !left ? Radius.circular(16.r) : Radius.zero,
          ),
          boxShadow: [
            BoxShadow(
              color: BelieveColors.primary.withValues(alpha: 0.6),
              blurRadius: 10,
            ),
          ],
        ),
      ),
    );
  }
}

/// Central Viewfinder Target with 4 corners and laser beam animation
class WdViewfinderTarget extends StatelessWidget {
  const WdViewfinderTarget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 250.w,
        height: 250.w,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: BelieveColors.primary.withValues(alpha: 0.2),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),

            // 4 Glowing Corner Brackets
            const WdViewfinderCorner(top: true, left: true),
            const WdViewfinderCorner(top: true, left: false),
            const WdViewfinderCorner(top: false, left: true),
            const WdViewfinderCorner(top: false, left: false),

            // Smooth Scanning Laser Animation Bar
            Positioned(
              top: 0,
              left: 12.w,
              right: 12.w,
              child: Container(
                height: 3.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Colors.transparent,
                      BelieveColors.primary,
                      BelieveColors.primaryLight,
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: BelieveColors.primary.withValues(alpha: 0.8),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .moveY(begin: 8.h, end: 232.h, duration: 2000.ms),
            ),
          ],
        ),
      ),
    );
  }
}
