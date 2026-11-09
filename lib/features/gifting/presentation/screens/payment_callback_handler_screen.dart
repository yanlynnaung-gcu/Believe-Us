import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/router/route_names.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';
import 'package:thae_nge_lay/features/gifting/presentation/controllers/gifting_controller.dart';

class PaymentCallbackHandlerScreen extends ConsumerStatefulWidget {
  final String status;
  final String? orderId;
  final String? transactionRef;
  final String? provider;

  const PaymentCallbackHandlerScreen({
    super.key,
    required this.status,
    this.orderId,
    this.transactionRef,
    this.provider,
  });

  @override
  ConsumerState<PaymentCallbackHandlerScreen> createState() =>
      _PaymentCallbackHandlerScreenState();
}

class _PaymentCallbackHandlerScreenState
    extends ConsumerState<PaymentCallbackHandlerScreen> {
  bool _isVerifying = true;
  String? _resultError;
  String? _successRef;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verify();
    });
  }

  Future<void> _verify() async {
    final controller = ref.read(giftingControllerProvider.notifier);
    final tx = await controller.verifyPaymentReturn(
      status: widget.status,
      orderId: widget.orderId,
      transactionRef: widget.transactionRef,
    );

    if (!mounted) return;

    if (tx != null) {
      setState(() {
        _isVerifying = false;
        _successRef = tx.transactionRef;
      });
      // Delay briefly to show success, then navigate back to chat
      await Future.delayed(const Duration(milliseconds: 1400));
      if (mounted) {
        context.go(AppRoutes.chat);
      }
    } else {
      final err = ref.read(giftingControllerProvider).errorMessage;
      setState(() {
        _isVerifying = false;
        _resultError = err ??
            (widget.status.toLowerCase() == 'cancel'
                ? 'Payment cancelled in external wallet app.'
                : 'Payment verification failed.');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKBZ = (widget.provider ?? '').toUpperCase().contains('KBZ') ||
        (widget.provider ?? '').toUpperCase().contains('KPAY');

    return Scaffold(
      backgroundColor: BelieveColors.background,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: GlassmorphicCard(
            padding: EdgeInsets.all(28.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isVerifying) ...[
                  SizedBox(
                    width: 56.r,
                    height: 56.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isKBZ ? BelieveColors.kbzPay : BelieveColors.wavePayDark,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Verifying Payment...',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: BelieveColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Confirming your transaction with Myanmar mobile wallet.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.sp,
                      color: BelieveColors.textSecondary,
                    ),
                  ),
                ] else if (_resultError != null) ...[
                  Container(
                    width: 56.r,
                    height: 56.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: BelieveColors.error.withValues(alpha: 0.1),
                    ),
                    child: const Icon(
                      LucideIcons.alertCircle,
                      color: BelieveColors.error,
                      size: 30,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Payment Status',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: BelieveColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    _resultError!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.sp,
                      color: BelieveColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () => context.go(AppRoutes.chat),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BelieveColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                    ),
                    child: Text(
                      'Back to Chat',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ] else ...[
                  Container(
                    width: 60.r,
                    height: 60.r,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: BelieveColors.primaryGradient,
                    ),
                    child: const Icon(
                      LucideIcons.check,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Gift Delivered! ❤️',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w700,
                      color: BelieveColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Reference: ${_successRef ?? widget.transactionRef ?? ""}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: BelieveColors.primaryDark,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
