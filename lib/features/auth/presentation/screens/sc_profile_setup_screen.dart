import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/router/route_names.dart';
import 'package:thae_nge_lay/core/services/media_picker_service.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_controller.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';
import 'package:thae_nge_lay/features/auth/presentation/widgets/wd_profile_anniversary_picker.dart';
import 'package:thae_nge_lay/features/auth/presentation/widgets/wd_profile_avatar_selector.dart';
import 'package:thae_nge_lay/features/auth/presentation/widgets/wd_profile_birthday_card.dart';
import 'package:thae_nge_lay/features/auth/presentation/widgets/wd_profile_header.dart';
import 'package:thae_nge_lay/features/auth/presentation/widgets/wd_profile_save_button.dart';
import 'package:thae_nge_lay/features/auth/presentation/widgets/wd_signup_role_selector.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() =>
      _ProfileSetupScreenState();
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

  void _showFeedback(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: BelieveColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _pickBirthdayDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime(now.year - 22, 1, 1),
      firstDate: DateTime(1960),
      lastDate: now,
      helpText: 'Select Your Birthday 🎂',
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
      setState(() => _customAvatarFile = file);
    }
  }

  void _onSaveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showFeedback('Please enter your romantic name or nickname.');
      return;
    }
    if (_selectedBirthday == null) {
      _showFeedback('Please select your birthday date.');
      return;
    }

    final avatarUrl = _customAvatarFile != null
        ? _customAvatarFile!.path
        : _avatarUrls[_selectedAvatarIndex];

    final success =
        await ref.read(authControllerProvider.notifier).completeProfile(
              displayName: name,
              photoUrl: avatarUrl,
              role: _selectedRole,
              birthday: _selectedBirthday,
              anniversaryDate: _selectedAnniversary ?? DateTime.now(),
            );

    if (mounted) {
      if (success) {
        final user = ref.read(authStateProvider);
        if (user != null &&
            user.partnerId != null &&
            user.coupleSpaceId != null) {
          context.go(AppRoutes.home);
        } else {
          context.go(AppRoutes.pairing);
        }
      } else {
        final error = ref.read(authControllerProvider).errorMessage;
        _showFeedback(error ?? 'Failed to complete profile.');
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
              const WdProfileHeader(),
              WdProfileAvatarSelector(
                customAvatarFile: _customAvatarFile,
                selectedAvatarIndex: _selectedAvatarIndex,
                avatarUrls: _avatarUrls,
                onPickCustomAvatar: _pickCustomAvatar,
                onSelectPreset: (index) => setState(() {
                  _customAvatarFile = null;
                  _selectedAvatarIndex = index;
                }),
              ),
              SizedBox(height: 20.h),
              WdSignupRoleSelector(
                selectedRole: _selectedRole,
                onRoleSelected: (role) => setState(() => _selectedRole = role),
              ),
              SizedBox(height: 20.h),
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
              WdProfileBirthdayCard(
                selectedBirthday: _selectedBirthday,
                onPickBirthday: _pickBirthdayDate,
              ),
              SizedBox(height: 20.h),
              WdProfileAnniversaryPicker(
                selectedAnniversary: _selectedAnniversary,
                onPickAnniversary: _pickAnniversaryDate,
              ),
              SizedBox(height: 32.h),
              WdProfileSaveButton(
                isLoading: authState.isLoading,
                onSave: _onSaveProfile,
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
