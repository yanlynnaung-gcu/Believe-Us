import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';
import 'package:thae_nge_lay/core/utils/zodiac_helper.dart';
import 'package:thae_nge_lay/features/gifting/presentation/widgets/gift_selection_sheet.dart';
import 'package:thae_nge_lay/features/home/presentation/controllers/couple_media_controller.dart';

/// 4. Partner Birthday Glass Card
class PartnerBirthdayGlassCard extends ConsumerWidget {
  const PartnerBirthdayGlassCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = ref.watch(coupleMediaProvider);
    final daysUntil = ZodiacHelper.getDaysUntilBirthday(media.partnerBirthday);
    final zodiac = ZodiacHelper.getZodiac(media.partnerBirthday);
    final dateFormatted = DateFormat('MMMM d').format(media.partnerBirthday);

    return GlassmorphicCard(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${media.partnerName}\'s Birthday',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: BelieveColors.textPrimary,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: media.partnerBirthday,
                              firstDate: DateTime(1980),
                              lastDate: DateTime(2035),
                            );
                            if (picked != null) {
                              ref
                                  .read(coupleMediaProvider.notifier)
                                  .updatePartnerBirthday(picked);
                            }
                          },
                          child: const Icon(
                            LucideIcons.edit3,
                            size: 14,
                            color: BelieveColors.primary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '$dateFormatted • ${zodiac.symbol} ${zodiac.name}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        color: BelieveColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Zodiac Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: BelieveColors.primarySoft,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: BelieveColors.glassBorder),
                ),
                child: Text(
                  '${zodiac.emoji} ${zodiac.name}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: BelieveColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Countdown banner
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: BelieveColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: BelieveColors.glassBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    daysUntil == 0
                        ? '🎉 Today is ${media.partnerName}\'s Birthday!'
                        : '🎂 Birthday countdown: In $daysUntil Days!',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: BelieveColors.textPrimary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => GiftSelectionSheet.show(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      gradient: BelieveColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'Send Gift 🎁',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
