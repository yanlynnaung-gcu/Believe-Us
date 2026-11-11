import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';
import 'package:thae_nge_lay/features/auth/presentation/widgets/wd_otp_digit_input_row.dart';

class WdForgotPasswordResetStep extends StatefulWidget {
  final String email;
  final List<TextEditingController> otpControllers;
  final List<FocusNode> focusNodes;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final int resendCountdown;
  final bool isLoading;
  final void Function(int index, String value) onDigitChanged;
  final VoidCallback onResendOtp;
  final VoidCallback onEditEmail;
  final VoidCallback onResetPassword;

  const WdForgotPasswordResetStep({
    super.key,
    required this.email,
    required this.otpControllers,
    required this.focusNodes,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.resendCountdown,
    required this.isLoading,
    required this.onDigitChanged,
    required this.onResendOtp,
    required this.onEditEmail,
    required this.onResetPassword,
  });

  @override
  State<WdForgotPasswordResetStep> createState() =>
      _WdForgotPasswordResetStepState();
}

class _WdForgotPasswordResetStepState extends State<WdForgotPasswordResetStep> {
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      padding: EdgeInsets.all(22.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: BelieveColors.primarySoft,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: BelieveColors.glassBorder),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.mailCheck,
                    color: BelieveColors.primary, size: 20),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Code sent to ${widget.email}',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      color: BelieveColors.burgundy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: widget.onEditEmail,
                  child: Text(
                    'Edit',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      color: BelieveColors.primary,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            'Enter 6-Digit Code',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: BelieveColors.textPrimary,
            ),
          ),
          SizedBox(height: 10.h),
          WdOtpDigitInputRow(
            controllers: widget.otpControllers,
            focusNodes: widget.focusNodes,
            onDigitChanged: widget.onDigitChanged,
          ),
          SizedBox(height: 10.h),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: widget.resendCountdown > 0 ? null : widget.onResendOtp,
              child: Text(
                widget.resendCountdown > 0
                    ? 'Resend code in ${widget.resendCountdown}s'
                    : 'Resend 6-Digit Code 💌',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: widget.resendCountdown > 0
                      ? BelieveColors.textMuted
                      : BelieveColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            'New Password',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: BelieveColors.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          TextField(
            controller: widget.newPasswordController,
            obscureText: _obscureNewPassword,
            style: GoogleFonts.plusJakartaSans(fontSize: 14.sp),
            decoration: InputDecoration(
              prefixIcon: const Icon(LucideIcons.lock, size: 18),
              hintText: 'At least 6 characters',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNewPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                  size: 18,
                  color: BelieveColors.textMuted,
                ),
                onPressed: () {
                  setState(() => _obscureNewPassword = !_obscureNewPassword);
                },
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            'Confirm New Password',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: BelieveColors.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          TextField(
            controller: widget.confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            style: GoogleFonts.plusJakartaSans(fontSize: 14.sp),
            decoration: InputDecoration(
              prefixIcon: const Icon(LucideIcons.lock, size: 18),
              hintText: 'Re-enter your new password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                  size: 18,
                  color: BelieveColors.textMuted,
                ),
                onPressed: () {
                  setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                },
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
          ),
          SizedBox(height: 24.h),
          GestureDetector(
            onTap: widget.isLoading ? null : widget.onResetPassword,
            child: Container(
              height: 52.h,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: BelieveColors.primaryGradient,
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: BelieveColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            LucideIcons.checkCheck,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 8.w),
                          Flexible(
                            child: Text(
                              'Reset Password 💕',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
