import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/features/pairing/presentation/controllers/pairing_controller.dart';
import 'package:thae_nge_lay/features/pairing/presentation/widgets/wd_invalid_qr_dialog.dart';
import 'package:thae_nge_lay/features/pairing/presentation/widgets/wd_manual_input_card.dart';
import 'package:thae_nge_lay/features/pairing/presentation/widgets/wd_manual_input_dialog.dart';
import 'package:thae_nge_lay/features/pairing/presentation/widgets/wd_pairing_success_dialog.dart';
import 'package:thae_nge_lay/features/pairing/presentation/widgets/wd_qr_display.dart';
import 'package:thae_nge_lay/features/pairing/presentation/widgets/wd_romantic_background.dart';
import 'package:thae_nge_lay/features/pairing/presentation/widgets/wd_scanner_hero_card.dart';
import 'package:thae_nge_lay/features/pairing/presentation/widgets/wd_scanner_overlay.dart';
import 'package:thae_nge_lay/features/pairing/presentation/widgets/wd_welcoming_header.dart';

class PairingScreen extends ConsumerStatefulWidget {
  const PairingScreen({super.key});

  @override
  ConsumerState<PairingScreen> createState() => _PairingScreenState();
}

/// Compatibility typedef
typedef QRPairingScreen = PairingScreen;

class _PairingScreenState extends ConsumerState<PairingScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _codeController = TextEditingController();

  int _remainingSeconds = 1800; // 30 minutes
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _startCountdown();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pairingControllerProvider.notifier).retryLoadCode();
    });
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        if (mounted) setState(() => _remainingSeconds--);
      } else {
        _remainingSeconds = 1800;
        ref.read(pairingControllerProvider.notifier).generateNewInviteCode();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _codeController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _onPair() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 6 digits of your partner\'s code.'),
          backgroundColor: BelieveColors.error,
        ),
      );
      return;
    }

    final success = await ref
        .read(pairingControllerProvider.notifier)
        .pairWithCode(code);
    if (!success && mounted) {
      final err = ref.read(pairingControllerProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err ?? 'Pairing failed. Please verify the code.'),
          backgroundColor: BelieveColors.error,
        ),
      );
    }
  }

  void _openQrScanner() {
    showQrScannerModal(
      context,
      onCodeScanned: (extractedCode) {
        _codeController.text = extractedCode;
        _onPair();
      },
      onManualInputRequested: () {
        showManualInputDialog(
          context,
          onCodeEntered: (code) {
            _codeController.text = code;
            _onPair();
          },
        );
      },
      onInvalidQrScanned: (raw) => showInvalidQrDialog(context, raw),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen for pairing completion to trigger celebration modal
    ref.listen<PairingUIState>(pairingControllerProvider, (previous, next) {
      if (next.isPaired && !(previous?.isPaired ?? false)) {
        showPairingSuccessDialog(context);
      }
    });

    final pairingState = ref.watch(pairingControllerProvider);

    return Stack(
      children: [
        const WdRomanticBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(height: 8.h),
                const WdWelcomingHeader(),
                SizedBox(height: 12.h),

                // Pill-style Segmented Switcher
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20.w),
                  height: 46.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(color: BelieveColors.glassBorder, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: BelieveColors.primary.withValues(alpha: 0.08),
                        blurRadius: 14,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.transparent,
                    dividerColor: Colors.transparent,
                    dividerHeight: 0.0,
                    indicator: BoxDecoration(
                      gradient: BelieveColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: BelieveColors.primary.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: BelieveColors.textMuted,
                    labelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: const [
                      Tab(text: 'Show My QR'),
                      Tab(text: 'Connect Partner'),
                    ],
                  ),
                ),
                SizedBox(width: 350.w, child: const Divider()),

                // TabBarView Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // TAB 1: Show My QR
                      WdQrDisplay(
                        pairingState: pairingState,
                        remainingSeconds: _remainingSeconds,
                        onRetryLoadCode: () => ref
                            .read(pairingControllerProvider.notifier)
                            .retryLoadCode(),
                        onGenerateNewCode: () {
                          HapticFeedback.selectionClick();
                          setState(() => _remainingSeconds = 1800);
                          ref
                              .read(pairingControllerProvider.notifier)
                              .generateNewInviteCode();
                        },
                      ),

                      // TAB 2: Connect Partner
                      SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 14.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            WdScannerHeroCard(onOpenScanner: _openQrScanner),
                            SizedBox(height: 16.h),
                            WdManualInputCard(
                              codeController: _codeController,
                              pairingState: pairingState,
                              onPair: _onPair,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
