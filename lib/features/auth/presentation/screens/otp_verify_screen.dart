import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/router/route_names.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_controller.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';

class OtpVerifyScreen extends ConsumerStatefulWidget {
  final String email;

  const OtpVerifyScreen({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _resendCountdown = 60;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
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

  String get _otp => _controllers.map((c) => c.text.trim()).join();

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      // Handles pasting full 6 digits
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < 6 && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      if (digits.length >= 6) {
        _focusNodes[5].requestFocus();
        _onVerify();
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
        if (_otp.length == 6) {
          _onVerify();
        }
      }
    }
  }

  void _onResendOtp() async {
    if (_resendCountdown > 0) return;

    final success = await ref
        .read(authControllerProvider.notifier)
        .sendEmailOtp(widget.email);

    if (mounted) {
      if (success) {
        _startCountdown();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('A fresh 6-digit code has been sent to ${widget.email}'),
            backgroundColor: BelieveColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        final err = ref.read(authControllerProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err ?? 'Failed to resend code. Please try again.'),
            backgroundColor: BelieveColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _onVerify() async {
    final otp = _otp;
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 6 digits of your verification code.'),
          backgroundColor: BelieveColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final result = await ref
        .read(authControllerProvider.notifier)
        .verifyEmailOtp(email: widget.email, otp: otp);

    if (mounted) {
      if (result.success) {
        final user = ref.read(authStateProvider);
        if (result.isNewUser || user == null || !user.isProfileComplete) {
          context.go(AppRoutes.profileSetup);
        } else if (user.partnerId != null && user.coupleSpaceId != null) {
          context.go(AppRoutes.home);
        } else {
          context.go(AppRoutes.pairing);
        }
      } else {
        final err = ref.read(authControllerProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err ?? 'Verification failed. Please check the code.'),
            backgroundColor: BelieveColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
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
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 16.h),

              // Couple Heart Brand Logo
              Container(
                width: 76.w,
                height: 76.w,
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
                child: const Center(
                  child: Icon(
                    LucideIcons.mailCheck,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              Text(
                'Verify Your Email 💌',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w800,
                  color: BelieveColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'We sent a 6-digit verification code to:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.sp,
                  color: BelieveColors.textSecondary,
                ),
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: BelieveColors.primarySoft,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: BelieveColors.glassBorder),
                ),
                child: Text(
                  widget.email.isNotEmpty ? widget.email : 'your email',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: BelieveColors.primaryDark,
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              // 6 Digits Box Form
              GlassmorphicCard(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 26.h),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 44.w,
                          height: 54.h,
                          child: KeyboardListener(
                            focusNode: FocusNode(),
                            onKeyEvent: (event) {
                              if (event is KeyDownEvent &&
                                  event.logicalKey == LogicalKeyboardKey.backspace &&
                                  _controllers[index].text.isEmpty &&
                                  index > 0) {
                                _focusNodes[index - 1].requestFocus();
                              }
                            },
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 6, // Allows full paste in first box
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w800,
                                color: BelieveColors.primaryDark,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                contentPadding: EdgeInsets.zero,
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                  borderSide: const BorderSide(
                                    color: BelieveColors.glassBorder,
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                  borderSide: const BorderSide(
                                    color: BelieveColors.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                              onChanged: (val) => _onDigitChanged(index, val),
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 24.h),

                    // Verify Button
                    GestureDetector(
                      onTap: authState.isLoading ? null : _onVerify,
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
                                      LucideIcons.heartHandshake,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8.w),
                                    Flexible(
                                      child: Text(
                                        'Verify & Enter Sanctuary 💕',
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
              ),
              SizedBox(height: 24.h),

              // Countdown / Resend Section
              if (_resendCountdown > 0)
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
                        'Resend verification code in ${_resendCountdown}s',
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
                  onPressed: authState.isLoading ? null : _onResendOtp,
                  icon: const Icon(LucideIcons.refreshCw, size: 16, color: BelieveColors.primary),
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

              // Note
              Text(
                '100% Free Gmail SMTP Verification • No SMS Charges',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.sp,
                  color: BelieveColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
