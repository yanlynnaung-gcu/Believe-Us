import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';

class WdOtpResendSection extends StatelessWidget {
  final int resendCountdown;
  final bool isLoading;
  final VoidCallback onResend;

  const WdOtpResendSection({
    super.key,
    required this.resendCountdown,
    required this.isLoading,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (resendCountdown > 0)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.timer,
                size: 16,
                color: BelieveColors.textMuted,
              ),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  'Resend verification code in ${resendCountdown}s',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: BelieveColors.textMuted,
                  ),
                ),
              ),
            ],
          )
        else
          TextButton.icon(
            onPressed: isLoading ? null : onResend,
            icon: const Icon(LucideIcons.refreshCw,
                size: 16, color: BelieveColors.primary),
            label: Text(
              'Resend 6-Digit Code 💌',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: BelieveColors.primary,
              ),
            ),
          ),
        SizedBox(height: 36.h),
        Text(
          '100% Free Gmail SMTP Verification • No SMS Charges',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.sp,
            color: BelieveColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
