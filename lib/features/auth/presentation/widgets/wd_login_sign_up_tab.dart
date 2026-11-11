import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';
import 'package:thae_nge_lay/features/auth/presentation/widgets/wd_signup_avatar_picker.dart';
import 'package:thae_nge_lay/features/auth/presentation/widgets/wd_signup_birthday_picker.dart';
import 'package:thae_nge_lay/features/auth/presentation/widgets/wd_signup_role_selector.dart';

class WdLoginSignUpTab extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String selectedRole;
  final DateTime? selectedBirthday;
  final File? pickedAvatarFile;
  final bool isLoading;
  final ValueChanged<String> onRoleChanged;
  final VoidCallback onPickAvatar;
  final VoidCallback onPickBirthday;
  final VoidCallback onRegister;

  const WdLoginSignUpTab({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.selectedRole,
    required this.selectedBirthday,
    required this.pickedAvatarFile,
    required this.isLoading,
    required this.onRoleChanged,
    required this.onPickAvatar,
    required this.onPickBirthday,
    required this.onRegister,
  });

  @override
  State<WdLoginSignUpTab> createState() => _WdLoginSignUpTabState();
}

class _WdLoginSignUpTabState extends State<WdLoginSignUpTab> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
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
          WdSignupAvatarPicker(
            pickedAvatarFile: widget.pickedAvatarFile,
            onPickAvatar: widget.onPickAvatar,
          ),
          SizedBox(height: 18.h),
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
            controller: widget.nameController,
            style: GoogleFonts.plusJakartaSans(fontSize: 14.sp),
            decoration: InputDecoration(
              prefixIcon: const Icon(LucideIcons.user, size: 18),
              hintText: 'e.g. Ko Ko or Thae Thae',
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
          ),
          SizedBox(height: 14.h),
          WdSignupRoleSelector(
            selectedRole: widget.selectedRole,
            onRoleSelected: widget.onRoleChanged,
          ),
          SizedBox(height: 14.h),
          WdSignupBirthdayPicker(
            selectedBirthday: widget.selectedBirthday,
            onPickBirthday: widget.onPickBirthday,
          ),
          SizedBox(height: 14.h),
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
            controller: widget.emailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.plusJakartaSans(fontSize: 14.sp),
            decoration: InputDecoration(
              prefixIcon: const Icon(LucideIcons.mail, size: 18),
              hintText: 'e.g. yourname@gmail.com',
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
          ),
          SizedBox(height: 14.h),
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
            controller: widget.passwordController,
            obscureText: _obscurePassword,
            style: GoogleFonts.plusJakartaSans(fontSize: 14.sp),
            decoration: InputDecoration(
              prefixIcon: const Icon(LucideIcons.lock, size: 18),
              hintText: 'Create a secure password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                  size: 18,
                  color: BelieveColors.textMuted,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
          ),
          SizedBox(height: 22.h),
          GestureDetector(
            onTap: widget.isLoading ? null : widget.onRegister,
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
