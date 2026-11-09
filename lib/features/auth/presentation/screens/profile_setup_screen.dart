import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedRole = 'BOYFRIEND';
  DateTime? _selectedBirthday;
  DateTime? _selectedAnniversary;
  int _selectedAvatarIndex = 0;
  File? _customAvatarFile;

  final List<String> _avatarUrls = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200',
  ];

  @override
  void initState() {
    super.initState();
    final currentUser = ref.read(authStateProvider);
    if (currentUser != null &&
        currentUser.displayName != 'Couple Member' &&
        currentUser.displayName != 'My Love') {
      _nameController.text = currentUser.displayName;
    }
    if (currentUser?.role != null) {
      _selectedRole = currentUser!.role;
    }
    if (currentUser?.birthday != null) {
      _selectedBirthday = currentUser!.birthday;
    }
    if (currentUser?.anniversaryDate != null) {
      _selectedAnniversary = currentUser!.anniversaryDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _pickBirthdayDate() async {
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
      setState(() => _selectedBirthday = picked);
    }
  }

  void _pickAnniversaryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedAnniversary ?? now,
      firstDate: DateTime(2000),
      lastDate: now,
      helpText: 'Select Anniversary Date 💍',
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
      setState(() => _selectedAnniversary = picked);
    }
  }

  void _pickCustomAvatar() async {
    final picker = ref.read(mediaPickerServiceProvider);
    final file = await picker.pickAndCropImage(
      context: context,
      cropType: CropType.circleAvatar,
      title: 'Choose Profile Photo ✨',
    );
    if (file != null) {
      setState(() {
        _customAvatarFile = file;
      });
    }
  }

  void _onSaveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your romantic name or nickname.'),
          backgroundColor: BelieveColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedBirthday == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your birthday date.'),
          backgroundColor: BelieveColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final avatarUrl = _customAvatarFile != null
        ? _customAvatarFile!.path
        : _avatarUrls[_selectedAvatarIndex];

    final success = await ref
        .read(authControllerProvider.notifier)
        .completeProfile(
          displayName: name,
          photoUrl: avatarUrl,
          role: _selectedRole,
          birthday: _selectedBirthday,
          anniversaryDate: _selectedAnniversary ?? DateTime.now(),
        );

    if (mounted) {
      if (success) {
        final user = ref.read(authStateProvider);
        if (user != null && user.partnerId != null && user.coupleSpaceId != null) {
          context.go(AppRoutes.home);
        } else {
          context.go(AppRoutes.pairing);
        }
      } else {
        final error = ref.read(authControllerProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to complete profile.'),
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
    final bdayZodiac = _selectedBirthday != null
        ? ZodiacHelper.getZodiac(_selectedBirthday!)
        : null;

    return Scaffold(
      backgroundColor: BelieveColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Our Profile',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w700,
            fontSize: 20.sp,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Let Your Partner Recognize You ✨',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: BelieveColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Set your real photo, sweet romantic name, and role for your private sanctuary.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.sp,
                  color: BelieveColors.textSecondary,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 24.h),

              // Avatar Glass Card
              GlassmorphicCard(
                padding: EdgeInsets.all(20.r),
                child: Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickCustomAvatar,
                        child: Stack(
                          children: [
                            Container(
                              padding: EdgeInsets.all(4.r),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: BelieveColors.romanticSunsetGradient,
                                boxShadow: [
                                  BoxShadow(
                                    color: BelieveColors.primary
                                        .withValues(alpha: 0.25),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 48.r,
                                backgroundColor: Colors.white,
                                backgroundImage: _customAvatarFile != null
                                    ? FileImage(_customAvatarFile!)
                                    : NetworkImage(
                                            _avatarUrls[_selectedAvatarIndex])
                                        as ImageProvider,
                              ),
                            ),
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                padding: EdgeInsets.all(8.r),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: BelieveColors.primaryGradient,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: BelieveColors.primary
                                          .withValues(alpha: 0.3),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  LucideIcons.camera,
                                  size: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                      SizedBox(height: 12.h),
                      Text(
                        _customAvatarFile != null
                            ? 'Custom photo selected ✨ Tap to change'
                            : 'Tap camera to upload, or pick preset below',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: BelieveColors.textMuted,
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Presets
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_avatarUrls.length, (index) {
                          final isSelected = _customAvatarFile == null &&
                              index == _selectedAvatarIndex;
                          return GestureDetector(
                            onTap: () => setState(() {
                              _customAvatarFile = null;
                              _selectedAvatarIndex = index;
                            }),
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              padding: EdgeInsets.all(2.5.r),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? BelieveColors.primary
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 18.r,
                                backgroundImage:
                                    NetworkImage(_avatarUrls[index]),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Role Selector: Boyfriend vs Girlfriend
              Text(
                'I am the:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
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

              SizedBox(height: 20.h),

              // Real Display Name
              Text(
                'Your Romantic Name',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: BelieveColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _nameController,
                style: GoogleFonts.plusJakartaSans(fontSize: 15.sp),
                decoration: InputDecoration(
                  prefixIcon: const Icon(LucideIcons.user, size: 20),
                  hintText: 'e.g. Ko Ko or Thae Thae',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                ),
              ),

              SizedBox(height: 20.h),

              // Birthday DatePicker
              Text(
                'Your Birthday',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: BelieveColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              GestureDetector(
                onTap: _pickBirthdayDate,
                child: GlassmorphicCard(
                  padding: EdgeInsets.all(16.r),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: BelieveColors.romanticSunsetGradient,
                        ),
                        child: const Icon(
                          LucideIcons.cake,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Text(
                          _selectedBirthday != null
                              ? '${DateFormat('MMMM d, yyyy').format(_selectedBirthday!)} ${bdayZodiac != null ? '(${bdayZodiac.emoji} ${bdayZodiac.name})' : ''}'
                              : 'Select your birthday date 🎂',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            color: _selectedBirthday != null
                                ? BelieveColors.textPrimary
                                : BelieveColors.textMuted,
                            fontWeight: _selectedBirthday != null
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      const Icon(
                        LucideIcons.chevronRight,
                        color: BelieveColors.textMuted,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Anniversary DatePicker
              Text(
                'Relationship Anniversary Date (Optional)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: BelieveColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              GestureDetector(
                onTap: _pickAnniversaryDate,
                child: GlassmorphicCard(
                  padding: EdgeInsets.all(16.r),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: BelieveColors.primarySoft,
                        ),
                        child: const Icon(
                          LucideIcons.calendarHeart,
                          color: BelieveColors.primary,
                          size: 18,
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedAnniversary != null
                                  ? DateFormat('MMMM d, yyyy')
                                      .format(_selectedAnniversary!)
                                  : 'Select when your love story began 💍',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.sp,
                                color: _selectedAnniversary != null
                                    ? BelieveColors.textPrimary
                                    : BelieveColors.textMuted,
                                fontWeight: _selectedAnniversary != null
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                            if (_selectedAnniversary != null)
                              Text(
                                '${DateTime.now().difference(_selectedAnniversary!).inDays.abs()} days together',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.sp,
                                  color: BelieveColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Icon(
                        LucideIcons.chevronRight,
                        color: BelieveColors.textMuted,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // Save Button
              GestureDetector(
                onTap: authState.isLoading ? null : _onSaveProfile,
                child: Container(
                  height: 54.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: BelieveColors.primaryGradient,
                    borderRadius: BorderRadius.circular(18.r),
                    boxShadow: [
                      BoxShadow(
                        color: BelieveColors.primary.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
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
                        : Text(
                            'Save & Enter Couple Sanctuary 💕',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
