import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';
import 'package:thae_nge_lay/features/pairing/presentation/controllers/pairing_controller.dart';
import 'package:thae_nge_lay/features/pairing/presentation/widgets/wd_lock_security_card.dart';

/// 6-digit Code Input Card with Connect Button & Security Badge
class WdManualInputCard extends StatelessWidget {
  final TextEditingController codeController;
  final PairingUIState pairingState;
  final VoidCallback onPair;

  const WdManualInputCard({
    super.key,
    required this.codeController,
    required this.pairingState,
    required this.onPair,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Divider badge
        const Center(
          child: Row(
            children: [
              Expanded(child: Divider(color: BelieveColors.border, thickness: 1)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or enter code manually',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: BelieveColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(child: Divider(color: BelieveColors.border, thickness: 1)),
            ],
          ),
        ),

        SizedBox(height: 16.h),

        // Header
        Text(
          'Enter Partner\'s Secret Code',
          style: GoogleFonts.playfairDisplay(
            fontSize: 19.sp,
            fontWeight: FontWeight.w800,
            color: BelieveColors.textPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Ask your partner for their 6-digit code or scan their QR code.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5.sp,
            color: BelieveColors.textSecondary,
          ),
        ),
        SizedBox(height: 16.h),

        GlassmorphicCard(
          padding: EdgeInsets.all(20.r),
          borderRadius: 24.r,
          surfaceColor: Colors.white.withValues(alpha: 0.9),
          child: Column(
            children: [
              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(6),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 10,
                  color: BelieveColors.primaryDark,
                ),
                decoration: InputDecoration(
                  hintText: '482910',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    letterSpacing: 10,
                    fontSize: 26.sp,
                    color: BelieveColors.textMuted,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: const BorderSide(
                      color: BelieveColors.glassBorder,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: const BorderSide(
                      color: BelieveColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Connect Button
              GestureDetector(
                onTap: pairingState.isLoading ? null : onPair,
                child: Container(
                  height: 52.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: BelieveColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: BelieveColors.primary.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: pairingState.isLoading
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
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                LucideIcons.heartHandshake,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8.w),
                              Flexible(
                                child: Text(
                                  'Bond & Connect Now ✨',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              if (pairingState.errorMessage != null && !pairingState.isLoading) ...[
                SizedBox(height: 14.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: BelieveColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: BelieveColors.error.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        LucideIcons.alertCircle,
                        size: 16,
                        color: BelieveColors.error,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          pairingState.errorMessage!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
                            color: BelieveColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        SizedBox(height: 20.h),

        // Strict 1-to-1 Lock Security Alert
        const WdLockSecurityCard(),
      ],
    );
  }
}
