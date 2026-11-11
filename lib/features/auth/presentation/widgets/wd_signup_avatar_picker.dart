import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';

class WdSignupAvatarPicker extends StatelessWidget {
  final File? pickedAvatarFile;
  final VoidCallback onPickAvatar;

  const WdSignupAvatarPicker({
    super.key,
    required this.pickedAvatarFile,
    required this.onPickAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: GestureDetector(
            onTap: onPickAvatar,
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
                    backgroundImage: pickedAvatarFile != null
                        ? FileImage(pickedAvatarFile!)
                        : null,
                    child: pickedAvatarFile == null
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
            pickedAvatarFile != null
                ? 'Photo selected ✨ Tap to change'
                : 'Tap to pick profile photo 📸',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.sp,
              color: BelieveColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
