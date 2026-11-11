import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/router/route_names.dart';
import 'package:thae_nge_lay/core/services/media_picker_service.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';
import 'package:thae_nge_lay/core/utils/zodiac_helper.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // 0: Password Sign In (Default), 1: Sign Up
  int _activeTabIndex = 0;

  // Sign In Controllers
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  bool _obscureLoginPassword = true;

  // Sign Up Controllers
  final TextEditingController _regNameController = TextEditingController();
  final TextEditingController _regEmailController = TextEditingController();
  final TextEditingController _regPasswordController = TextEditingController();
  bool _obscureRegPassword = true;
  String _selectedRole = 'BOYFRIEND';
  DateTime? _selectedBirthday;
  File? _pickedAvatarFile;

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    super.dispose();
  }

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

  Future<void> _pickAvatar() async {
    final file = await ref.read(mediaPickerServiceProvider).pickAndCropImage(
      context: context,
      cropType: CropType.circleAvatar,
      title: 'Choose Profile Photo ✨',
    );
    if (file != null) {
      setState(() {
        _pickedAvatarFile = file;
      });
    }
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final initial = _selectedBirthday ?? DateTime(now.year - 22, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1960),
      lastDate: now,
      helpText: 'Select Your Birthday 🎂',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: BelieveColors.primary,
              onPrimary: Colors.white,
              onSurface: BelieveColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedBirthday = picked;
      });
    }
  }

  void _onLogin() async {
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;

    if (email.isEmpty || !email.contains('@')) {
      _showError('Please enter a valid email address.');
      return;
    }
    if (password.isEmpty) {
      _showError('Please enter your password.');
      return;
    }

    final success = await ref.read(authControllerProvider.notifier).login(
      email: email,
      password: password,
    );
    if (!success && mounted) {
      final err = ref.read(authControllerProvider).errorMessage;
      _showError(err ?? 'Login failed. Please check your credentials.');
    }
  }

  void _onRegister() async {
    final name = _regNameController.text.trim();
    final email = _regEmailController.text.trim();
    final password = _regPasswordController.text;

    if (name.isEmpty) {
      _showError('Please enter your romantic name or nickname.');
      return;
    }
    if (_selectedBirthday == null) {
      _showError('Please select your birthday date.');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      _showError('Please enter a valid email address.');
      return;
    }
    if (password.length < 6) {
      _showError('Password must be at least 6 characters.');
      return;
    }

    final success = await ref.read(authControllerProvider.notifier).register(
      email: email,
      password: password,
      displayName: name,
      role: _selectedRole,
      birthday: _selectedBirthday,
      avatarFile: _pickedAvatarFile,
    );

    if (!success && mounted) {
      final err = ref.read(authControllerProvider).errorMessage;
      _showError(err ?? 'Registration failed. Please try again.');
    }
  }

  void _onGoogleSignIn() async {
    final success = await ref.read(authControllerProvider.notifier).signInWithGoogle(
      role: _selectedRole,
      birthday: _selectedBirthday,
    );
    if (!success && mounted) {
      final err = ref.read(authControllerProvider).errorMessage;
      if (err != null) _showError(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: BelieveColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 24.h),

              // Couple Heart Brand Logo
              Container(
                width: 76.w,
                height: 76.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: BelieveColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: BelieveColors.primary.withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.heart,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
              SizedBox(height: 14.h),

              Text(
                'Thae Thae',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  color: BelieveColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Your Private 1-to-1 Couple Sanctuary ✨',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.sp,
                  color: BelieveColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 22.h),

              // 2-Way Segmented Tab Switcher (Sign In & Sign Up)
              Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: BelieveColors.glassBorder),
                ),
                child: Row(
                  children: [
                    _buildTabItem(title: 'Sign In 💕', index: 0),
                    _buildTabItem(title: 'Sign Up ✨', index: 1),
                  ],
                ),
              ),
              SizedBox(height: 18.h),

              // Dynamic Form Content
              if (_activeTabIndex == 0)
                _buildSignInForm(authState)
              else
                _buildSignUpForm(authState),

              SizedBox(height: 18.h),

              // OR divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      'OR',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: BelieveColors.textMuted,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              SizedBox(height: 18.h),

              // Google Sign-In Button (100% Free)
              GlassmorphicCard(
                borderRadius: 20.r,
                padding: EdgeInsets.symmetric(vertical: 13.h),
                onTap: authState.isLoading ? null : _onGoogleSignIn,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24.w,
                      height: 24.w,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Center(
                        child: Text(
                          'G',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF4285F4),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Flexible(
                      child: Text(
                        'Continue with Google Account',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: BelieveColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Security & 1-to-1 trust note
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: BelieveColors.primarySoft,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: BelieveColors.glassBorder),
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.shieldCheck,
                      color: BelieveColors.primary,
                      size: 20,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        '100% Private & Free. BCrypt password hashing & secure couple authentication. Only you and your connected partner share this space.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.sp,
                          color: BelieveColors.burgundy,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 28.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({required String title, required int index}) {
    final isSelected = _activeTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_activeTabIndex != index) {
            setState(() => _activeTabIndex = index);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 9.h),
          decoration: BoxDecoration(
            gradient: isSelected ? BelieveColors.primaryGradient : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Center(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : BelieveColors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInForm(AuthUIState authState) {
    return GlassmorphicCard(
      padding: EdgeInsets.all(22.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Back, My Love',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: BelieveColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Sign in with password to reunite with your partner',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              color: BelieveColors.textSecondary,
            ),
          ),
          SizedBox(height: 18.h),

          // Email Field
          Text(
            'Email Address',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: BelieveColors.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          TextField(
            controller: _loginEmailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.plusJakartaSans(fontSize: 14.sp),
            decoration: InputDecoration(
              prefixIcon: const Icon(LucideIcons.mail, size: 18),
              hintText: 'e.g. koko@gmail.com',
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
          ),
          SizedBox(height: 14.h),

          // Password Field
          Text(
            'Password',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: BelieveColors.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          TextField(
            controller: _loginPasswordController,
            obscureText: _obscureLoginPassword,
            style: GoogleFonts.plusJakartaSans(fontSize: 14.sp),
            decoration: InputDecoration(
              prefixIcon: const Icon(LucideIcons.lock, size: 18),
              hintText: 'Enter your password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureLoginPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                  size: 18,
                  color: BelieveColors.textMuted,
                ),
                onPressed: () {
                  setState(() => _obscureLoginPassword = !_obscureLoginPassword);
                },
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
          ),
          SizedBox(height: 8.h),

          // Forgot Password Link
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                final currentEmail = _loginEmailController.text.trim();
                context.push(AppRoutes.forgotPassword, extra: currentEmail);
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Forgot Password?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: BelieveColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(height: 18.h),

          // Sign In Button
          GestureDetector(
            onTap: authState.isLoading ? null : _onLogin,
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
                              'Sign In With Love 💕',
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

  Widget _buildSignUpForm(AuthUIState authState) {
    final birthdayFormatted = _selectedBirthday != null
        ? DateFormat('MMMM d, yyyy').format(_selectedBirthday!)
        : null;
    final zodiac = _selectedBirthday != null
        ? ZodiacHelper.getZodiac(_selectedBirthday!)
        : null;

    return GlassmorphicCard(
      padding: EdgeInsets.all(22.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create Our Love Account',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: BelieveColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Fill in your details to start your couple sanctuary',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              color: BelieveColors.textSecondary,
            ),
          ),
          SizedBox(height: 20.h),

          // 1. Mandatory Profile Photo Picker
          Center(
            child: GestureDetector(
              onTap: _pickAvatar,
              child: Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(3.r),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: BelieveColors.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: BelieveColors.primary.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 44.r,
                      backgroundColor: Colors.white,
                      backgroundImage: _pickedAvatarFile != null
                          ? FileImage(_pickedAvatarFile!)
                          : null,
                      child: _pickedAvatarFile == null
                          ? Icon(
                              LucideIcons.camera,
                              size: 32.r,
                              color: BelieveColors.primary,
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: BelieveColors.primary,
                      ),
                      child: const Icon(
                        LucideIcons.plus,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Center(
            child: Text(
              _pickedAvatarFile != null
                  ? 'Photo selected ✨ Tap to change'
                  : 'Tap to pick profile photo 📸',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.sp,
                color: BelieveColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 18.h),

          // 2. Real Display Name
          Text(
            'Your Romantic Display Name',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: BelieveColors.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          TextField(
            controller: _regNameController,
            style: GoogleFonts.plusJakartaSans(fontSize: 14.sp),
            decoration: InputDecoration(
              prefixIcon: const Icon(LucideIcons.user, size: 18),
              hintText: 'e.g. Ko Ko or Thae Thae',
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
          ),
          SizedBox(height: 14.h),

          // 3. Role Selector (Boyfriend vs Girlfriend)
          Text(
            'I am the:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: BelieveColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedRole = 'BOYFRIEND'),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: _selectedRole == 'BOYFRIEND'
                          ? BelieveColors.primarySoft
                          : Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: _selectedRole == 'BOYFRIEND'
                            ? BelieveColors.primary
                            : BelieveColors.glassBorder,
                        width: _selectedRole == 'BOYFRIEND' ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text('👦', style: TextStyle(fontSize: 22.sp)),
                        SizedBox(height: 4.h),
                        Text(
                          'Boyfriend',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: _selectedRole == 'BOYFRIEND'
                                ? BelieveColors.primaryDark
                                : BelieveColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedRole = 'GIRLFRIEND'),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: _selectedRole == 'GIRLFRIEND'
                          ? BelieveColors.primarySoft
                          : Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: _selectedRole == 'GIRLFRIEND'
                            ? BelieveColors.primary
                            : BelieveColors.glassBorder,
                        width: _selectedRole == 'GIRLFRIEND' ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text('👧', style: TextStyle(fontSize: 22.sp)),
                        SizedBox(height: 4.h),
                        Text(
                          'Girlfriend',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: _selectedRole == 'GIRLFRIEND'
                                ? BelieveColors.primaryDark
                                : BelieveColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // 4. Birthday DatePicker
          Text(
            'Your Birthday',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: BelieveColors.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          GestureDetector(
            onTap: _pickBirthday,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: BelieveColors.glassBorder),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.cake, size: 18, color: BelieveColors.primary),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      birthdayFormatted != null
                          ? '$birthdayFormatted ${zodiac != null ? '(${zodiac.emoji} ${zodiac.name})' : ''}'
                          : 'Tap to select your birthday 🎂',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: birthdayFormatted != null ? FontWeight.w600 : FontWeight.w400,
                        color: birthdayFormatted != null
                            ? BelieveColors.textPrimary
                            : BelieveColors.textMuted,
                      ),
                    ),
                  ),
                  const Icon(LucideIcons.calendar, size: 16, color: BelieveColors.textMuted),
                ],
              ),
            ),
          ),
          SizedBox(height: 14.h),

          // 5. Email
          Text(
            'Email Address',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: BelieveColors.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          TextField(
            controller: _regEmailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.plusJakartaSans(fontSize: 14.sp),
            decoration: InputDecoration(
              prefixIcon: const Icon(LucideIcons.mail, size: 18),
              hintText: 'e.g. yourname@gmail.com',
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
          ),
          SizedBox(height: 14.h),

          // 6. Password
          Text(
            'Password (Min 6 characters)',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: BelieveColors.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          TextField(
            controller: _regPasswordController,
            obscureText: _obscureRegPassword,
            style: GoogleFonts.plusJakartaSans(fontSize: 14.sp),
            decoration: InputDecoration(
              prefixIcon: const Icon(LucideIcons.lock, size: 18),
              hintText: 'Create a secure password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureRegPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                  size: 18,
                  color: BelieveColors.textMuted,
                ),
                onPressed: () {
                  setState(() => _obscureRegPassword = !_obscureRegPassword);
                },
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
          ),
          SizedBox(height: 22.h),

          // Create Account Button
          GestureDetector(
            onTap: authState.isLoading ? null : _onRegister,
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
                            LucideIcons.sparkles,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 8.w),
                          Flexible(
                            child: Text(
                              'Create Our Love Account ✨',
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
