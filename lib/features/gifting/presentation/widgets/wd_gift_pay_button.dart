import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:thae_nge_lay/features/gifting/domain/models/gift_package.dart';

/// Primary action button to pay with KBZPay or WavePay
class WdGiftPayButton extends StatelessWidget {
  final PaymentProvider selectedProvider;
  final GiftPackage package;
  final bool isProcessing;
  final VoidCallback onPay;

  const WdGiftPayButton({
    super.key,
    required this.selectedProvider,
    required this.package,
    required this.isProcessing,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final isKBZ = selectedProvider == PaymentProvider.kbzPay;
    return GestureDetector(
      onTap: isProcessing ? null : onPay,
      child: Container(
        height: 52.h,
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
          child: isProcessing
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                )
              : Text(
                  'Pay with ${isKBZ ? "KBZPay" : "WavePay"} (${NumberFormat("#,###").format(package.amountMmK)} MMK)',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: isKBZ ? Colors.white : Colors.black87,
                  ),
                ),
        ),
      ),
    );
  }
}
