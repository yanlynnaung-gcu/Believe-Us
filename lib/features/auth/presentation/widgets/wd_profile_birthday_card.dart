import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';
import 'package:thae_nge_lay/core/utils/zodiac_helper.dart';

class WdProfileBirthdayCard extends StatelessWidget {
  final DateTime? selectedBirthday;
  final VoidCallback onPickBirthday;

  const WdProfileBirthdayCard({
    super.key,
    required this.selectedBirthday,
    required this.onPickBirthday,
  });

  @override
  Widget build(BuildContext context) {
    final bdayZodiac = selectedBirthday != null
        ? ZodiacHelper.getZodiac(selectedBirthday!)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          onTap: onPickBirthday,
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
                    selectedBirthday != null
                        ? '${DateFormat('MMMM d, yyyy').format(selectedBirthday!)} ${bdayZodiac != null ? '(${bdayZodiac.emoji} ${bdayZodiac.name})' : ''}'
                        : 'Select your birthday date 🎂',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      color: selectedBirthday != null
                          ? BelieveColors.textPrimary
                          : BelieveColors.textMuted,
                      fontWeight: selectedBirthday != null
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
      ],
    );
  }
}
