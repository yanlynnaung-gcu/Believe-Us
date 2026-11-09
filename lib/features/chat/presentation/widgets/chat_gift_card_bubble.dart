import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';

class ChatGiftCardBubble extends StatelessWidget {
  final Map<String, dynamic> giftData;
  final bool isMe;

  const ChatGiftCardBubble({
    super.key,
    required this.giftData,
    required this.isMe,
  });

  void _showGiftRevealSheet(BuildContext context) {
    final amount = giftData['amount'] ?? '50,000 MMK';
    final provider = giftData['provider'] ?? 'KBZPay';
    final note = giftData['note'] ?? 'For my beloved darling ❤️';
    final packageName = giftData['packageName'] ?? 'Romantic Monetary Gift';
    final isKBZ = provider == 'KBZPay';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: BelieveColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          ),
          padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 36.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Confetti / Heart Burst Animation
              Container(
                width: 80.w,
                height: 80.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: BelieveColors.goldGradient,
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.gift,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.1, 1.1),
                    duration: 500.ms,
                    curve: Curves.elasticOut,
                  )
                  .then()
                  .scale(
                    begin: const Offset(1.1, 1.1),
                    end: const Offset(1.0, 1.0),
                    duration: 200.ms,
                  ),

              SizedBox(height: 18.h),
              Text(
                'Gift Received with Love! ✨',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: BelieveColors.textPrimary,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                packageName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  color: BelieveColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 18.h),

              // Amount Card
              GlassmorphicCard(
                borderRadius: 20.r,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                surfaceColor: BelieveColors.primarySoft,
                borderColor: BelieveColors.glassBorder,
                child: Text(
                  amount.toString(),
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w900,
                    color: BelieveColors.primaryDark,
                  ),
                ),
              ),
              SizedBox(height: 14.h),

              // Provider Verification Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: isKBZ ? BelieveColors.kbzPay : BelieveColors.wavePay,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      provider,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: isKBZ ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Directly verified payment transfer',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      color: BelieveColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),

              // Romantic Note
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: BelieveColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: BelieveColors.glassBorder),
                ),
                child: Text(
                  '"$note"',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 15.sp,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    color: BelieveColors.burgundy,
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Thank You, My Love ❤️'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final amount = giftData['amount'] ?? '50,000 MMK';
    final provider = giftData['provider'] ?? 'KBZPay';
    final isKBZ = provider == 'KBZPay';
    final packageName = giftData['packageName'] ?? 'Romantic Gift';

    return GestureDetector(
      onTap: () => _showGiftRevealSheet(context),
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
              // 3D Ribbon Gift Box Header
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

              // Amount
              Text(
                amount.toString(),
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w900,
                  color: BelieveColors.primaryDark,
                ),
              ),
              SizedBox(height: 4.h),

              // Note preview
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

              // Reveal pill button
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
