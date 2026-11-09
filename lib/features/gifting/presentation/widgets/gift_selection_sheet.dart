import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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

class _GiftSelectionSheetState extends ConsumerState<GiftSelectionSheet>
    with WidgetsBindingObserver {
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _noteController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // User returned from KBZPay/WavePay external app -> check & verify transaction
      final giftingState = ref.read(giftingControllerProvider);
      if (giftingState.isAwaitingExternalPayment) {
        ref.read(giftingControllerProvider.notifier).verifyPaymentReturn();
      }
    }
  }

  void _onConfirmPayment() async {
    final selectedPackage = _packages[_selectedPackageIndex];
    final note = _noteController.text.trim();

    await ref.read(giftingControllerProvider.notifier).startExternalPayment(
          package: selectedPackage,
          provider: _selectedProvider,
          note: note,
        );
  }

  void _onManualVerify() async {
    await ref.read(giftingControllerProvider.notifier).verifyPaymentReturn();
  }

  void _onCancelPayment() {
    ref.read(giftingControllerProvider.notifier).cancelPendingPayment();
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
    // Listen for completion or error changes
    ref.listen<GiftingUIState>(giftingControllerProvider, (prev, next) {
      if (next.completedTransaction != null &&
          prev?.completedTransaction != next.completedTransaction) {
        Navigator.of(context).pop();
        _showSuccessDialog(
          next.completedTransaction!.transactionRef,
          next.completedTransaction!.packageTitle,
          next.completedTransaction!.amountMmK,
        );
      } else if (next.errorMessage != null &&
          prev?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: BelieveColors.error,
          ),
        );
      }
    });

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
        child: giftingState.isAwaitingExternalPayment
            ? _buildAwaitingPaymentView(context, giftingState)
            : _buildSelectionView(context, giftingState),
      ),
    );
  }

  /// View shown while user is redirected to external KBZPay / WavePay app
  Widget _buildAwaitingPaymentView(
    BuildContext context,
    GiftingUIState giftingState,
  ) {
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
        // Drag Handle
        Container(
          width: 40.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: BelieveColors.border,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(height: 24.h),

        // Brand Icon / Indicator
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

        // Order Summary Card
        if (session != null)
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: BelieveColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: BelieveColors.border.withValues(alpha: 0.6),
              ),
            ),
            child: Row(
              children: [
                Text(
                  session.package.iconEmoji,
                  style: TextStyle(fontSize: 26.sp),
                ),
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

        // Action Buttons
        GestureDetector(
          onTap: giftingState.isProcessing ? null : _onManualVerify,
          child: Container(
            height: 50.h,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: isKBZ
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
          onPressed: _onCancelPayment,
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

  /// Normal selection view before payment initiation
  Widget _buildSelectionView(
    BuildContext context,
    GiftingUIState giftingState,
  ) {
    return Column(
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
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: BelieveColors.textPrimary,
                  ),
                ),
                Text(
                  'Instant KBZPay & WavePay Couple Gifting',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.sp,
                    color: BelieveColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 20.h),

        // Provider Selector
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
                        ? BelieveColors.kbzPay.withValues(alpha: 0.1)
                        : BelieveColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: _selectedProvider == PaymentProvider.kbzPay
                          ? BelieveColors.kbzPay
                          : BelieveColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.creditCard,
                        size: 16.r,
                        color: BelieveColors.kbzPay,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'KBZPay',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.sp,
                          color: _selectedProvider == PaymentProvider.kbzPay
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
                        ? BelieveColors.wavePay.withValues(alpha: 0.25)
                        : BelieveColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: _selectedProvider == PaymentProvider.wavePay
                          ? BelieveColors.wavePayDark
                          : BelieveColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.wallet,
                        size: 16.r,
                        color: BelieveColors.wavePayDark,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'WavePay',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.sp,
                          color: _selectedProvider == PaymentProvider.wavePay
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
        SizedBox(height: 20.h),

        // Package Selector
        Text(
          'CHOOSE ROMANTIC PACKAGE',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: BelieveColors.textMuted,
          ),
        ),
        SizedBox(height: 10.h),

        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 220.h),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: _packages.length,
            separatorBuilder: (_, __) => SizedBox(height: 8.h),
            itemBuilder: (context, index) {
              final pkg = _packages[index];
              final isSelected = _selectedPackageIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedPackageIndex = index),
                child: Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? BelieveColors.primary.withValues(alpha: 0.08)
                        : BelieveColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: isSelected
                          ? BelieveColors.primary
                          : BelieveColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        pkg.iconEmoji,
                        style: TextStyle(fontSize: 24.sp),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pkg.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 13.sp,
                                color: BelieveColors.textPrimary,
                              ),
                            ),
                            Text(
                              pkg.description,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.sp,
                                color: BelieveColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${NumberFormat("#,###").format(pkg.amountMmK)} MMK',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.sp,
                          color: BelieveColors.primary,
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

        // Romantic Note Input
        Text(
          'SWEET NOTE (ATTACHED TO GIFT)',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: BelieveColors.textMuted,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: _noteController,
          decoration: const InputDecoration(
            hintText: 'Write a romantic message...',
            prefixIcon: Icon(
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
                      'Pay with ${_selectedProvider == PaymentProvider.kbzPay ? "KBZPay" : "WavePay"} (${NumberFormat("#,###").format(_packages[_selectedPackageIndex].amountMmK)} MMK)',
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
    );
  }
}
