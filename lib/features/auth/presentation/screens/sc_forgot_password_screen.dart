import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/router/route_names.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_controller.dart';
import 'package:thae_nge_lay/features/auth/presentation/widgets/wd_forgot_password_email_step.dart';
import 'package:thae_nge_lay/features/auth/presentation/widgets/wd_forgot_password_footer.dart';
import 'package:thae_nge_lay/features/auth/presentation/widgets/wd_forgot_password_header.dart';
import 'package:thae_nge_lay/features/auth/presentation/widgets/wd_forgot_password_reset_step.dart';
import 'package:thae_nge_lay/features/auth/presentation/widgets/wd_otp_digit_input_row.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  final String initialEmail;

  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  int _currentStep = 0;
  late final TextEditingController _emailController;
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
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

  void _showFeedback(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? BelieveColors.error : BelieveColors.success,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }

  void _onRequestOtp() async {
    final email = _emailController.text.trim().toLowerCase();
    if (email.isEmpty || !email.contains('@')) {
      _showFeedback('Please enter a valid email address.', isError: true);
      return;
    }
    final success = await ref
        .read(authControllerProvider.notifier)
        .sendForgotPasswordOtp(email);
    if (mounted) {
      if (success) {
        setState(() => _currentStep = 1);
        _startCountdown();
        _showFeedback('A 6-digit code has been sent to $email');
      } else {
        final err = ref.read(authControllerProvider).errorMessage;
        _showFeedback(err ?? 'Failed to send OTP code. Please try again.',
            isError: true);
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
        _showFeedback('A fresh 6-digit code has been sent to $email');
      } else {
        final err = ref.read(authControllerProvider).errorMessage;
        _showFeedback(err ?? 'Failed to resend code. Please try again.',
            isError: true);
      }
    }
  }

  void _onResetPassword() async {
    final email = _emailController.text.trim().toLowerCase();
    final otp = _otp;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (otp.length < 6) {
      _showFeedback('Please enter all 6 digits of your verification code.',
          isError: true);
      return;
    }
    if (newPassword.isEmpty || newPassword.length < 6) {
      _showFeedback('Password must be at least 6 characters long.',
          isError: true);
      return;
    }
    if (newPassword != confirmPassword) {
      _showFeedback('Passwords do not match. Please re-enter.', isError: true);
      return;
    }

    final success = await ref.read(authControllerProvider.notifier).resetPassword(
          email: email,
          otp: otp,
          newPassword: newPassword,
        );

    if (mounted) {
      if (success) {
        _showFeedback(
            'Password reset successfully! Please sign in with your new password.');
        context.go(AppRoutes.login);
      } else {
        final err = ref.read(authControllerProvider).errorMessage;
        _showFeedback(err ?? 'Failed to reset password. Please check your code.',
            isError: true);
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
          icon:
              const Icon(LucideIcons.arrowLeft, color: BelieveColors.textPrimary),
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
              WdForgotPasswordHeader(currentStep: _currentStep),
              if (_currentStep == 0)
                WdForgotPasswordEmailStep(
                  emailController: _emailController,
                  isLoading: authState.isLoading,
                  onRequestOtp: _onRequestOtp,
                )
              else
                WdForgotPasswordResetStep(
                  email: _emailController.text.trim().toLowerCase(),
                  otpControllers: _otpControllers,
                  focusNodes: _focusNodes,
                  newPasswordController: _newPasswordController,
                  confirmPasswordController: _confirmPasswordController,
                  resendCountdown: _resendCountdown,
                  isLoading: authState.isLoading,
                  onDigitChanged: (index, val) =>
                      WdOtpDigitInputRow.handleDigitChanged(
                    index: index,
                    value: val,
                    controllers: _otpControllers,
                    focusNodes: _focusNodes,
                  ),
                  onResendOtp: _onResendOtp,
                  onEditEmail: () => setState(() => _currentStep = 0),
                  onResetPassword: _onResetPassword,
                ),
              const WdForgotPasswordFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
