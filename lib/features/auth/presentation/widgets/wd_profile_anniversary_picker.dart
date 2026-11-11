import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';

class WdProfileAnniversaryPicker extends StatelessWidget {
  final DateTime? selectedAnniversary;
  final VoidCallback onPickAnniversary;

  const WdProfileAnniversaryPicker({
    super.key,
    required this.selectedAnniversary,
    required this.onPickAnniversary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          onTap: onPickAnniversary,
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
                        selectedAnniversary != null
                            ? DateFormat('MMMM d, yyyy')
                                .format(selectedAnniversary!)
                            : 'Select when your love story began 💍',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          color: selectedAnniversary != null
                              ? BelieveColors.textPrimary
                              : BelieveColors.textMuted,
                          fontWeight: selectedAnniversary != null
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      if (selectedAnniversary != null)
                        Text(
                          '${DateTime.now().difference(selectedAnniversary!).inDays.abs()} days together',
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
      ],
    );
  }
}
