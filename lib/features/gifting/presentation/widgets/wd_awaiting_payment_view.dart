import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/features/gifting/domain/models/gift_package.dart';
import 'package:thae_nge_lay/features/gifting/presentation/controllers/gifting_controller.dart';

/// View shown while user is redirected to external KBZPay or WavePay app
class WdAwaitingPaymentView extends StatelessWidget {
  final GiftingUIState giftingState;
  final VoidCallback onManualVerify;
  final VoidCallback onCancel;

  const WdAwaitingPaymentView({
    super.key,
    required this.giftingState,
    required this.onManualVerify,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final session = giftingState.activeSession;
    final isKBZ = session?.provider == PaymentProvider.kbzPay;
    final providerName = isKBZ ? 'KBZPay' : 'WavePay';
    final amountFormatted = session != null
        ? '${NumberFormat('#,###').format(session.amountMmK)} MMK'
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: BelieveColors.border,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(height: 24.h),
        Container(
          width: 72.r,
          height: 72.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isKBZ
                ? BelieveColors.kbzPay.withValues(alpha: 0.1)
                : BelieveColors.wavePay.withValues(alpha: 0.2),
            border: Border.all(
              color: isKBZ ? BelieveColors.kbzPay : BelieveColors.wavePayDark,
              width: 2.5,
            ),
          ),
          child: Center(
            child: SizedBox(
              width: 34.r,
              height: 34.r,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isKBZ ? BelieveColors.kbzPay : BelieveColors.wavePayDark,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 18.h),
        Text(
          'Waiting for $providerName Payment',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: BelieveColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'We launched $providerName. Please authorize the payment of $amountFormatted. Upon returning, your romantic blessing will automatically confirm!',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.sp,
              color: BelieveColors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
        SizedBox(height: 20.h),
        if (session != null)
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: BelieveColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: BelieveColors.border.withValues(alpha: 0.6)),
            ),
            child: Row(
              children: [
                Text(session.package.iconEmoji, style: TextStyle(fontSize: 26.sp)),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.package.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: BelieveColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Ref: ${session.transactionRef}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.sp,
                          color: BelieveColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  amountFormatted,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: isKBZ ? BelieveColors.kbzPay : BelieveColors.wavePayDark,
                  ),
                ),
              ],
            ),
          ),
        SizedBox(height: 24.h),
        GestureDetector(
          onTap: giftingState.isProcessing ? null : onManualVerify,
          child: Container(
            height: 50.h,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: isKBZ
                  ? const LinearGradient(colors: [Color(0xFF00377B), Color(0xFF0A55B2)])
                  : const LinearGradient(colors: [Color(0xFFFEE100), Color(0xFFF1C40F)]),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: giftingState.isProcessing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : Text(
                      "I've Completed Payment",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: isKBZ ? Colors.white : Colors.black87,
                      ),
                    ),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        TextButton(
          onPressed: onCancel,
          child: Text(
            'Cancel Payment',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: BelieveColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
