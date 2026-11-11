import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';
import 'package:thae_nge_lay/core/utils/image_provider_helper.dart';

class WdProfileAvatarSelector extends StatelessWidget {
  final File? customAvatarFile;
  final int selectedAvatarIndex;
  final List<String> avatarUrls;
  final VoidCallback onPickCustomAvatar;
  final ValueChanged<int> onSelectPreset;

  const WdProfileAvatarSelector({
    super.key,
    required this.customAvatarFile,
    required this.selectedAvatarIndex,
    required this.avatarUrls,
    required this.onPickCustomAvatar,
    required this.onSelectPreset,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      padding: EdgeInsets.all(20.r),
      child: Center(
        child: Column(
          children: [
            GestureDetector(
              onTap: onPickCustomAvatar,
              child: Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: BelieveColors.romanticSunsetGradient,
                      boxShadow: [
                        BoxShadow(
                          color: BelieveColors.primary.withValues(alpha: 0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 48.r,
                      backgroundColor: Colors.white,
                      backgroundImage: customAvatarFile != null
                          ? FileImage(customAvatarFile!)
                          : getCustomImageProvider(avatarUrls[selectedAvatarIndex]),
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
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: BelieveColors.primary.withValues(alpha: 0.3),
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
              customAvatarFile != null
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
              children: List.generate(avatarUrls.length, (index) {
                final isSelected =
                    customAvatarFile == null && index == selectedAvatarIndex;
                return GestureDetector(
                  onTap: () => onSelectPreset(index),
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
                          getCustomImageProvider(avatarUrls[index]),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
