import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';

/// 6 Styled Digit Blocks and Live Expiration Countdown Timer
class WdCodeDigitBlocks extends StatelessWidget {
  final String myCode;
  final bool isGeneratingCode;
  final int remainingSeconds;

  const WdCodeDigitBlocks({
    super.key,
    required this.myCode,
    required this.isGeneratingCode,
    required this.remainingSeconds,
  });

  String _formatCountdown(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 6 Styled Digit Blocks
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: (isGeneratingCode || myCode.length != 6
                  ? ['·', '·', '·', '·', '·', '·']
                  : myCode.split(''))
              .map((char) {
            return Container(
              width: 36.w,
              height: 46.h,
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: BelieveColors.primary.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: BelieveColors.primary.withValues(alpha: 0.08),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  char,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: BelieveColors.primary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 14.h),

        // Expiration Countdown Timer Indicator
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: BelieveColors.primarySoft,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: BelieveColors.primary.withValues(alpha: 0.25),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.clock, size: 13, color: BelieveColors.primary),
              SizedBox(width: 6.w),
              Text(
                'Code expires in ${_formatCountdown(remainingSeconds)}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: BelieveColors.primaryDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
