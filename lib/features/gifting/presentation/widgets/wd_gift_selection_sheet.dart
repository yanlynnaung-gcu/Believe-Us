import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/features/gifting/domain/models/gift_package.dart';
import 'package:thae_nge_lay/features/gifting/presentation/controllers/gifting_controller.dart';
import 'package:thae_nge_lay/features/gifting/presentation/widgets/wd_awaiting_payment_view.dart';
import 'package:thae_nge_lay/features/gifting/presentation/widgets/wd_gift_package_list.dart';
import 'package:thae_nge_lay/features/gifting/presentation/widgets/wd_gift_packages_data.dart';
import 'package:thae_nge_lay/features/gifting/presentation/widgets/wd_gift_pay_button.dart';
import 'package:thae_nge_lay/features/gifting/presentation/widgets/wd_gift_provider_selector.dart';
import 'package:thae_nge_lay/features/gifting/presentation/widgets/wd_gift_success_dialog.dart';

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
      final giftingState = ref.read(giftingControllerProvider);
      if (giftingState.isAwaitingExternalPayment) {
        ref.read(giftingControllerProvider.notifier).verifyPaymentReturn();
      }
    }
  }

  void _onConfirmPayment() async {
    final selectedPackage = kDefaultGiftPackages[_selectedPackageIndex];
    final note = _noteController.text.trim();
    await ref.read(giftingControllerProvider.notifier).startExternalPayment(
          package: selectedPackage,
          provider: _selectedProvider,
          note: note,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<GiftingUIState>(giftingControllerProvider, (prev, next) {
      if (next.completedTransaction != null &&
          prev?.completedTransaction != next.completedTransaction) {
        Navigator.of(context).pop();
        showGiftSuccessDialog(
          context,
          refCode: next.completedTransaction!.transactionRef,
          title: next.completedTransaction!.packageTitle,
          amount: next.completedTransaction!.amountMmK,
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
            ? WdAwaitingPaymentView(
                giftingState: giftingState,
                onManualVerify: () => ref
                    .read(giftingControllerProvider.notifier)
                    .verifyPaymentReturn(),
                onCancel: () => ref
                    .read(giftingControllerProvider.notifier)
                    .cancelPendingPayment(),
              )
            : _buildSelectionView(context, giftingState),
      ),
    );
  }

  Widget _buildSelectionView(BuildContext context, GiftingUIState giftingState) {
    final selectedPkg = kDefaultGiftPackages[_selectedPackageIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
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
        WdGiftProviderSelector(
          selectedProvider: _selectedProvider,
          onProviderSelected: (p) => setState(() => _selectedProvider = p),
        ),
        SizedBox(height: 20.h),
        WdGiftPackageList(
          packages: kDefaultGiftPackages,
          selectedIndex: _selectedPackageIndex,
          onSelectPackage: (i) => setState(() => _selectedPackageIndex = i),
        ),
        SizedBox(height: 18.h),
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
        WdGiftPayButton(
          selectedProvider: _selectedProvider,
          package: selectedPkg,
          isProcessing: giftingState.isProcessing,
          onPay: _onConfirmPayment,
        ),
      ],
    );
  }
}
