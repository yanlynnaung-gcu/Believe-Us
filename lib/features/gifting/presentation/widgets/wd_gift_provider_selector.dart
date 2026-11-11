import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/features/gifting/domain/models/gift_package.dart';

/// Provider selector buttons for KBZPay and WavePay
class WdGiftProviderSelector extends StatelessWidget {
  final PaymentProvider selectedProvider;
  final ValueChanged<PaymentProvider> onProviderSelected;

  const WdGiftProviderSelector({
    super.key,
    required this.selectedProvider,
    required this.onProviderSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT PAYMENT METHOD',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: BelieveColors.textMuted,
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => onProviderSelected(PaymentProvider.kbzPay),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: selectedProvider == PaymentProvider.kbzPay
                        ? BelieveColors.kbzPay.withValues(alpha: 0.1)
                        : BelieveColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: selectedProvider == PaymentProvider.kbzPay
                          ? BelieveColors.kbzPay
                          : BelieveColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.creditCard, size: 16.r, color: BelieveColors.kbzPay),
                      SizedBox(width: 8.w),
                      Text(
                        'KBZPay',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.sp,
                          color: selectedProvider == PaymentProvider.kbzPay
                              ? BelieveColors.kbzPay
                              : BelieveColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: GestureDetector(
                onTap: () => onProviderSelected(PaymentProvider.wavePay),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: selectedProvider == PaymentProvider.wavePay
                        ? BelieveColors.wavePay.withValues(alpha: 0.25)
                        : BelieveColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: selectedProvider == PaymentProvider.wavePay
                          ? BelieveColors.wavePayDark
                          : BelieveColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.wallet, size: 16.r, color: BelieveColors.wavePayDark),
                      SizedBox(width: 8.w),
                      Text(
                        'WavePay',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.sp,
                          color: selectedProvider == PaymentProvider.wavePay
                              ? BelieveColors.wavePayDark
                              : BelieveColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
