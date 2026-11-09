import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/features/gifting/domain/models/gift_package.dart';
import 'package:thae_nge_lay/features/gifting/presentation/controllers/gifting_controller.dart';

class GiftSelectionSheet extends ConsumerStatefulWidget {
  const GiftSelectionSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const GiftSelectionSheet(),
    );
  }

  @override
  ConsumerState<GiftSelectionSheet> createState() => _GiftSelectionSheetState();
}

class _GiftSelectionSheetState extends ConsumerState<GiftSelectionSheet> {
  PaymentProvider _selectedProvider = PaymentProvider.kbzPay;
  int _selectedPackageIndex = 0;
  final TextEditingController _noteController = TextEditingController(
    text: 'For my dearest love ❤️',
  );

  final List<GiftPackage> _packages = const [
    GiftPackage(
      id: 'pkg_10k',
      title: 'Pocket Blessing',
      description: 'Morning coffee & sweet treat',
      amountMmK: 10000,
      iconEmoji: '☕',
      categoryTag: 'Monetary',
    ),
    GiftPackage(
      id: 'pkg_30k',
      title: 'Darling Care Package',
      description: 'Snacks and love essentials',
      amountMmK: 30000,
      iconEmoji: '🍰',
      categoryTag: 'Monetary',
    ),
    GiftPackage(
      id: 'pkg_roses',
      title: '99 Red Roses Bouquet',
      description: 'Everlasting romance across distance',
      amountMmK: 35000,
      iconEmoji: '🌹',
      categoryTag: 'Virtual Bouquet',
    ),
    GiftPackage(
      id: 'pkg_50k',
      title: 'Golden Love Blessing',
      description: 'Generous couple gift',
      amountMmK: 50000,
      iconEmoji: '🎁',
      categoryTag: 'Monetary',
    ),
    GiftPackage(
      id: 'pkg_dinner',
      title: 'Candlelight Date Feast',
      description: 'Luxury dinner treat for two',
      amountMmK: 80000,
      iconEmoji: '🍷',
      categoryTag: 'Virtual Date',
    ),
    GiftPackage(
      id: 'pkg_flight',
      title: 'Reunion Flight Ticket',
      description: 'Bridging the distance to hold you',
      amountMmK: 150000,
      iconEmoji: '✈️',
      categoryTag: 'Reunion Fund',
    ),
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _onConfirmPayment() async {
    final selectedPackage = _packages[_selectedPackageIndex];
    final note = _noteController.text.trim();

    final tx = await ref.read(giftingControllerProvider.notifier).sendGift(
          package: selectedPackage,
          provider: _selectedProvider,
          note: note,
        );

    if (mounted) {
      if (tx != null) {
        Navigator.of(context).pop();
        _showSuccessDialog(tx.transactionRef, selectedPackage.title, tx.amountMmK);
      } else {
        final error = ref.read(giftingControllerProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Payment transaction failed.'),
            backgroundColor: BelieveColors.error,
          ),
        );
      }
    }
  }

  void _showSuccessDialog(String refCode, String title, int amount) {
    final formatted = '${NumberFormat('#,###').format(amount)} MMK';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64.w,
                height: 64.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: BelieveColors.primaryGradient,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Gift Sent with Love! 🎉',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: BelieveColors.textPrimary,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                '$title ($formatted)',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: BelieveColors.primaryDark,
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: BelieveColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  'Verified Ref: $refCode\nIn-Chat Card Delivered',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: BelieveColors.textSecondary,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to Chat'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final giftingState = ref.watch(giftingControllerProvider);

    return Container(
      decoration: BoxDecoration(
        color: BelieveColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      padding: EdgeInsets.only(
        top: 20.h,
        left: 20.w,
        right: 20.w,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: BelieveColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: BelieveColors.goldGradient,
                  ),
                  child: const Icon(
                    Icons.card_giftcard_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: 10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Surprise Your Partner',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: BelieveColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Instant KBZPay & WavePay Couple Gifting',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        color: BelieveColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Payment Provider Selector
            Text(
              'Select Myanmar Payment Method',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: BelieveColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                // KBZPay Button
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(
                      () => _selectedProvider = PaymentProvider.kbzPay,
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: _selectedProvider == PaymentProvider.kbzPay
                            ? BelieveColors.kbzPay
                            : BelieveColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: _selectedProvider == PaymentProvider.kbzPay
                              ? BelieveColors.kbzPay
                              : BelieveColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'KBZPay',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: _selectedProvider == PaymentProvider.kbzPay
                                ? Colors.white
                                : BelieveColors.kbzPay,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),

                // WavePay Button
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(
                      () => _selectedProvider = PaymentProvider.wavePay,
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: _selectedProvider == PaymentProvider.wavePay
                            ? BelieveColors.wavePay
                            : BelieveColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: _selectedProvider == PaymentProvider.wavePay
                              ? BelieveColors.wavePayDark
                              : BelieveColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'WavePay',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Packages Grid
            Text(
              'Choose Gift Package or Amount',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: BelieveColors.textPrimary,
              ),
            ),
            SizedBox(height: 10.h),

            SizedBox(
              height: 120.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _packages.length,
                itemBuilder: (context, index) {
                  final pkg = _packages[index];
                  final isSelected = index == _selectedPackageIndex;
                  final formatted =
                      '${NumberFormat('#,###').format(pkg.amountMmK)} Ks';

                  return GestureDetector(
                    onTap: () => setState(() => _selectedPackageIndex = index),
                    child: Container(
                      width: 130.w,
                      margin: EdgeInsets.only(right: 10.w),
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? BelieveColors.primarySoft
                            : BelieveColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: isSelected
                              ? BelieveColors.primary
                              : BelieveColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(pkg.iconEmoji, style: TextStyle(fontSize: 22.sp)),
                          SizedBox(height: 4.h),
                          Text(
                            pkg.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: BelieveColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            formatted,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w800,
                              color: BelieveColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 18.h),

            // Sweet Love Note
            Text(
              'Sweet Note to Partner',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: BelieveColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: 'Write a romantic message...',
                prefixIcon: const Icon(
                  Icons.favorite_rounded,
                  color: BelieveColors.primary,
                  size: 18,
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Pay Action Button
            GestureDetector(
              onTap: giftingState.isProcessing ? null : _onConfirmPayment,
              child: Container(
                height: 52.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: _selectedProvider == PaymentProvider.kbzPay
                      ? const LinearGradient(
                          colors: [Color(0xFF00377B), Color(0xFF0A55B2)],
                        )
                      : const LinearGradient(
                          colors: [Color(0xFFFEE100), Color(0xFFF1C40F)],
                        ),
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
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Send via ${_selectedProvider == PaymentProvider.kbzPay ? "KBZPay" : "WavePay"} (${NumberFormat("#,###").format(_packages[_selectedPackageIndex].amountMmK)} MMK)',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: _selectedProvider == PaymentProvider.kbzPay
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
