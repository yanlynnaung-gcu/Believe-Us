import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';
import 'package:thae_nge_lay/features/pairing/presentation/controllers/pairing_controller.dart';
import 'package:thae_nge_lay/features/pairing/presentation/widgets/wd_code_digit_blocks.dart';
import 'package:thae_nge_lay/features/pairing/presentation/widgets/wd_qr_image_box.dart';

/// Tab 1: Show My QR Code with Letter-Spaced Code, 6-Digit Blocks, and Timer
class WdQrDisplay extends StatelessWidget {
  final PairingUIState pairingState;
  final int remainingSeconds;
  final VoidCallback onRetryLoadCode;
  final VoidCallback onGenerateNewCode;

  const WdQrDisplay({
    super.key,
    required this.pairingState,
    required this.remainingSeconds,
    required this.onRetryLoadCode,
    required this.onGenerateNewCode,
  });

  @override
  Widget build(BuildContext context) {
    final myCode = pairingState.inviteCode ?? '...';

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Share This With Your Love ✨',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: BelieveColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Your partner can scan this QR or type your 6-digit secret code.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5.sp,
              color: BelieveColors.textSecondary,
            ),
          ),
          SizedBox(height: 18.h),

          // Glassmorphic QR Container
          GlassmorphicCard(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
            borderRadius: 28.r,
            surfaceColor: Colors.white.withValues(alpha: 0.88),
            child: Column(
              children: [
                WdQrImageBox(
                  pairingState: pairingState,
                  onRetryLoadCode: onRetryLoadCode,
                ),
                if (pairingState.inviteCode != null) ...[
                  SizedBox(height: 10.h),
                  // Bold Letter-Spaced Typography
                  Text(
                    myCode,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 10,
                      color: BelieveColors.primaryDark,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  WdCodeDigitBlocks(
                    myCode: myCode,
                    isGeneratingCode: pairingState.isGeneratingCode,
                    remainingSeconds: remainingSeconds,
                  ),
                  SizedBox(height: 16.h),

                  // Actions: Copy Code & New Code
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12.w,
                    runSpacing: 8.h,
                    children: [
                      InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Clipboard.setData(ClipboardData(text: myCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              backgroundColor: BelieveColors.primaryDark,
                              content: const Row(
                                children: [
                                  Icon(LucideIcons.heart, color: Colors.white, size: 18),
                                  SizedBox(width: 10),
                                  Text('Couple code copied to clipboard! ✨'),
                                ],
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            gradient: BelieveColors.primaryGradient,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: BelieveColors.primary.withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LucideIcons.copy, size: 16, color: Colors.white),
                              SizedBox(width: 6.w),
                              Text(
                                'Copy Code',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: pairingState.isGeneratingCode ? null : onGenerateNewCode,
                        borderRadius: BorderRadius.circular(16.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: BelieveColors.primary.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                LucideIcons.refreshCw,
                                size: 15,
                                color: BelieveColors.primaryDark,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                pairingState.isGeneratingCode ? 'Generating...' : 'New Code',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: BelieveColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Pulsing Waiting Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.heart, size: 16, color: BelieveColors.primary)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.3, 1.3),
                    duration: 700.ms,
                  ),
              SizedBox(width: 10.w),
              Flexible(
                child: Text(
                  'Waiting for your partner to bond...',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: BelieveColors.primaryDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
