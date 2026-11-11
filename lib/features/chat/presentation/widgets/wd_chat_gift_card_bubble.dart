import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';
import 'package:thae_nge_lay/features/chat/presentation/widgets/wd_gift_reveal_sheet.dart';

class ChatGiftCardBubble extends StatelessWidget {
  final Map<String, dynamic> giftData;
  final bool isMe;

  const ChatGiftCardBubble({
    super.key,
    required this.giftData,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final amount = giftData['amount'] ?? '50,000 MMK';
    final provider = giftData['provider'] ?? 'KBZPay';
    final isKBZ = provider == 'KBZPay';
    final packageName = giftData['packageName'] ?? 'Romantic Gift';

    return GestureDetector(
      onTap: () => WdGiftRevealSheet.show(context, giftData),
      child: GlassmorphicCard(
        borderRadius: 22.r,
        padding: EdgeInsets.all(14.r),
        surfaceColor: Colors.white.withValues(alpha: 0.9),
        borderColor: isKBZ
            ? BelieveColors.kbzPay.withValues(alpha: 0.3)
            : BelieveColors.wavePayDark.withValues(alpha: 0.4),
        child: SizedBox(
          width: 240.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: BelieveColors.goldGradient,
                    ),
                    child: const Icon(
                      LucideIcons.gift,
                      color: Colors.white,
                      size: 18,
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .rotate(begin: -0.05, end: 0.05, duration: 600.ms),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          packageName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: BelieveColors.textPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: isKBZ
                                    ? BelieveColors.kbzPay
                                    : BelieveColors.wavePay,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                provider,
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w800,
                                  color: isKBZ ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                amount.toString(),
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w900,
                  color: BelieveColors.primaryDark,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                giftData['note'] ?? 'Special couple blessing',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.sp,
                  color: BelieveColors.textSecondary,
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                decoration: BoxDecoration(
                  gradient: BelieveColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        LucideIcons.sparkles,
                        size: 12,
                        color: Colors.white,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Tap to Open Surprise ✨',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
