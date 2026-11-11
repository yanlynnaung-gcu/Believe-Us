import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/router/route_names.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_controller.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  final String initialEmail;

  const ForgotPasswordScreen({
    super.key,
    this.initialEmail = '',
  });

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  // 0: Enter email & request OTP, 1: Enter OTP & Reset password
  int _currentStep = 0;

  late final TextEditingController _emailController;
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  int _resendCountdown = 60;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _emailController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _resendCountdown = 60);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  String get _otp => _otpControllers.map((c) => c.text.trim()).join();

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: BelieveColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: BelieveColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }

  void _onRequestOtp() async {
    final email = _emailController.text.trim().toLowerCase();
    if (email.isEmpty || !email.contains('@')) {
      _showError('Please enter a valid email address.');
      return;
    }

    final success = await ref
        .read(authControllerProvider.notifier)
        .sendForgotPasswordOtp(email);

    if (mounted) {
      if (success) {
        setState(() => _currentStep = 1);
        _startCountdown();
        _showSuccess('A 6-digit code has been sent to $email');
      } else {
        final err = ref.read(authControllerProvider).errorMessage;
        _showError(err ?? 'Failed to send OTP code. Please try again.');
      }
    }
  }

  void _onResendOtp() async {
    if (_resendCountdown > 0) return;
    final email = _emailController.text.trim().toLowerCase();

    final success = await ref
        .read(authControllerProvider.notifier)
        .sendForgotPasswordOtp(email);

    if (mounted) {
      if (success) {
        _startCountdown();
        _showSuccess('A fresh 6-digit code has been sent to $email');
      } else {
        final err = ref.read(authControllerProvider).errorMessage;
        _showError(err ?? 'Failed to resend code. Please try again.');
      }
    }
  }

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      // Handles pasting full 6 digits
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < 6 && i < digits.length; i++) {
        _otpControllers[i].text = digits[i];
      }
      if (digits.length >= 6) {
        _focusNodes[5].requestFocus();
      } else {
        _focusNodes[digits.length.clamp(0, 5)].requestFocus();
      }
      return;
    }

    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
  }

  void _onResetPassword() async {
    final email = _emailController.text.trim().toLowerCase();
    final otp = _otp;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (otp.length < 6) {
      _showError('Please enter all 6 digits of your verification code.');
      return;
    }

    if (newPassword.isEmpty || newPassword.length < 6) {
      _showError('Password must be at least 6 characters long.');
      return;
    }

    if (newPassword != confirmPassword) {
      _showError('Passwords do not match. Please re-enter.');
      return;
    }

    final success = await ref
        .read(authControllerProvider.notifier)
        .resetPassword(
          email: email,
          otp: otp,
          newPassword: newPassword,
        );

    if (mounted) {
      if (success) {
        _showSuccess('Password reset successfully! Please sign in with your new password.');
        context.go(AppRoutes.login);
      } else {
        final err = ref.read(authControllerProvider).errorMessage;
        _showError(err ?? 'Failed to reset password. Please check your code.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: BelieveColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: BelieveColors.textPrimary),
          onPressed: () {
            if (_currentStep == 1) {
              setState(() => _currentStep = 0);
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          'Forgot Password',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: BelieveColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 12.h),

              // Lock/Heart Brand Icon
              Container(
                width: 68.w,
                height: 68.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: BelieveColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: BelieveColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    _currentStep == 0 ? LucideIcons.keyRound : LucideIcons.lock,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              SizedBox(height: 14.h),

              Text(
                _currentStep == 0 ? 'Find Your Account' : 'Reset Password',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: BelieveColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                _currentStep == 0
                    ? 'Enter your registered email address to receive a 6-digit verification code.'
                    : 'Enter the 6-digit code sent to your email and set your new password.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.sp,
                  color: BelieveColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 24.h),

              // Step Form Card
              if (_currentStep == 0)
                _buildEmailStepForm(authState)
              else
                _buildResetStepForm(authState),

              SizedBox(height: 28.h),

              // Back to Sign In Link
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Remember your password? ',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.sp,
                      color: BelieveColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.login),
                    child: Text(
                      'Sign In 💕',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: BelieveColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailStepForm(AuthUIState authState) {
    return GlassmorphicCard(
      padding: EdgeInsets.all(22.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: BelieveColors.primaryGradient,
                ),
                child: const Icon(LucideIcons.mail, color: Colors.white, size: 18),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Email',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: BelieveColors.textPrimary,
                      ),
                    ),
                    Text(
                      'We will dispatch a 6-digit OTP code',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        color: BelieveColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          Text(
            'Your Registered Email Address',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: BelieveColors.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.plusJakartaSans(fontSize: 14.sp),
            decoration: InputDecoration(
              prefixIcon: const Icon(LucideIcons.mail, size: 18),
              hintText: 'e.g. koko@gmail.com',
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
          ),
          SizedBox(height: 24.h),

          GestureDetector(
            onTap: authState.isLoading ? null : _onRequestOtp,
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
                child: authState.isLoading
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
                            LucideIcons.send,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 8.w),
                          Flexible(
                            child: Text(
                              'Send 6-Digit OTP Code 💌',
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

  Widget _buildResetStepForm(AuthUIState authState) {
    final email = _emailController.text.trim().toLowerCase();

    return GlassmorphicCard(
      padding: EdgeInsets.all(22.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Notice banner with option to change email
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: BelieveColors.primarySoft,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: BelieveColors.glassBorder),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.mailCheck, color: BelieveColors.primary, size: 20),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Code sent to $email',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      color: BelieveColors.burgundy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() => _currentStep = 0);
                  },
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

          // 6-digit OTP Inputs
          Text(
            'Enter 6-Digit Code',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: BelieveColors.textPrimary,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              return SizedBox(
                width: 44.w,
                height: 52.h,
                child: TextField(
                  controller: _otpControllers[index],
                  focusNode: _focusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: BelieveColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    contentPadding: EdgeInsets.zero,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(color: BelieveColors.glassBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(color: BelieveColors.primary, width: 2),
                    ),
                  ),
                  onChanged: (val) => _onDigitChanged(index, val),
                ),
              );
            }),
          ),
          SizedBox(height: 10.h),

          // Resend Countdown
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _resendCountdown > 0 ? null : _onResendOtp,
              child: Text(
                _resendCountdown > 0
                    ? 'Resend code in ${_resendCountdown}s'
                    : 'Resend 6-Digit Code 💌',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: _resendCountdown > 0
                      ? BelieveColors.textMuted
                      : BelieveColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(height: 18.h),

          // New Password Field
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
            controller: _newPasswordController,
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

          // Confirm New Password Field
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
            controller: _confirmPasswordController,
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

          // Reset Password Button
          GestureDetector(
            onTap: authState.isLoading ? null : _onResetPassword,
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
                child: authState.isLoading
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
