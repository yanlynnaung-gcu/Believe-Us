import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/utils/zodiac_helper.dart';

class WdSignupBirthdayPicker extends StatelessWidget {
  final DateTime? selectedBirthday;
  final VoidCallback onPickBirthday;

  const WdSignupBirthdayPicker({
    super.key,
    required this.selectedBirthday,
    required this.onPickBirthday,
  });

  @override
  Widget build(BuildContext context) {
    final birthdayFormatted = selectedBirthday != null
        ? DateFormat('MMMM d, yyyy').format(selectedBirthday!)
        : null;
    final zodiac = selectedBirthday != null
        ? ZodiacHelper.getZodiac(selectedBirthday!)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          onTap: onPickBirthday,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: BelieveColors.glassBorder),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.cake,
                    size: 18, color: BelieveColors.primary),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    birthdayFormatted != null
                        ? '$birthdayFormatted ${zodiac != null ? '(${zodiac.emoji} ${zodiac.name})' : ''}'
                        : 'Tap to select your birthday 🎂',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: birthdayFormatted != null
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: birthdayFormatted != null
                          ? BelieveColors.textPrimary
                          : BelieveColors.textMuted,
                    ),
                  ),
                ),
                const Icon(LucideIcons.calendar,
                    size: 16, color: BelieveColors.textMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
