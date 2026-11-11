import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/utils/image_provider_helper.dart';

/// Floating romantic heart markers overlay indicating user & partner positions
class WdRomanticHeartPinsOverlay extends StatelessWidget {
  final String partnerName;
  final String? partnerAvatarPath;
  final String? userAvatarPath;
  final Animation<double> pulseAnimation;

  const WdRomanticHeartPinsOverlay({
    super.key,
    required this.partnerName,
    required this.partnerAvatarPath,
    required this.userAvatarPath,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return Stack(
          children: [
            // Partner Heart Pin with Beating Ring (Positioned at 28% top, 58% left)
            Positioned(
              top: h * 0.28,
              left: w * 0.58,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated pulsing aura
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ScaleTransition(
                        scale: pulseAnimation,
                        child: Container(
                          width: 58.r,
                          height: 58.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: BelieveColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                      // Heart Pin Frame
                      Container(
                        width: 46.r,
                        height: 46.r,
                        padding: EdgeInsets.all(3.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: BelieveColors.primaryGradient,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: BelieveColors.primary.withValues(alpha: 0.4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          backgroundImage:
                              getCustomImageProvider(partnerAvatarPath),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Text(
                      '$partnerName ❤️',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: BelieveColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // My Heart Pin (Positioned at 44% top, 22% left)
            Positioned(
              top: h * 0.44,
              left: w * 0.22,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42.r,
                    height: 42.r,
                    padding: EdgeInsets.all(2.5.r),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: BelieveColors.romanticSunsetGradient,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: BelieveColors.accentLavender.withValues(alpha: 0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundImage:
                          getCustomImageProvider(userAvatarPath),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Text(
                      'You 💜',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: BelieveColors.burgundy,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
