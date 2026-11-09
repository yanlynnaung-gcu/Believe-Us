import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:thae_nge_lay/core/router/route_names.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';
import 'package:thae_nge_lay/features/pairing/presentation/controllers/pairing_controller.dart';

/// Professional & Romantic Couple QR Pairing Screen for "Believe Us".
/// Provides dual-tabbed pill switcher, 6-digit pure QR generator with live countdown,
/// camera scanner viewfinder with animated laser line, and delightful micro-interactions.
class PairingScreen extends ConsumerStatefulWidget {
  const PairingScreen({super.key});

  @override
  ConsumerState<PairingScreen> createState() => _PairingScreenState();
}

/// Typedef alias for compatibility with feature requests referencing `QRPairingScreen`.
typedef QRPairingScreen = PairingScreen;

class _PairingScreenState extends ConsumerState<PairingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _codeController = TextEditingController();

  // Expiration countdown: 30 minutes validity (1800 seconds)
  Timer? _countdownTimer;
  int _remainingSeconds = 1800;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Live expiration countdown timer
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        // Automatically refresh code when timer reaches zero
        _remainingSeconds = 1800;
        ref.read(pairingControllerProvider.notifier).generateNewInviteCode();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _tabController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  String _formatCountdown(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _onPair() async {
    final rawInput = _codeController.text.trim();
    final match = RegExp(r'\d{6}').firstMatch(rawInput);
    if (match == null) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          backgroundColor: BelieveColors.error,
          content: Row(
            children: [
              const Icon(LucideIcons.alertCircle, color: Colors.white, size: 18),
              SizedBox(width: 10.w),
              const Expanded(
                child: Text('Please enter a valid 6-digit couple pairing code.'),
              ),
            ],
          ),
        ),
      );
      return;
    }

    final code = match.group(0)!;
    _codeController.text = code;

    HapticFeedback.selectionClick();
    final success =
        await ref.read(pairingControllerProvider.notifier).pairWithCode(code);

    if (mounted && !success) {
      HapticFeedback.mediumImpact();
      final error = ref.read(pairingControllerProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          backgroundColor: BelieveColors.error,
          content: Row(
            children: [
              const Icon(LucideIcons.alertCircle, color: Colors.white, size: 18),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(error ?? 'Pairing failed. Please check the code.'),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showInvalidQrDialog([String? scannedText]) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: BelieveColors.error.withValues(alpha: 0.12),
              ),
              child: const Icon(LucideIcons.scanLine, color: BelieveColors.error, size: 20),
            ),
            SizedBox(width: 10.w),
            Text(
              'Invalid QR Code',
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.w800,
                fontSize: 18.sp,
                color: BelieveColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'Invalid QR code. Please scan a valid 6-digit couple pairing code.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.sp,
            color: BelieveColors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'OK',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: BelieveColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        backgroundColor: BelieveColors.error,
        content: const Text('Invalid QR code. Please scan a valid 6-digit couple pairing code.'),
      ),
    );
  }

  /// Clean manual fallback dialog opened when scanning has trouble
  void _openManualInputDialog() {
    final TextEditingController dialogCodeController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: BelieveColors.primarySoft,
              ),
              child: const Icon(LucideIcons.keyRound, color: BelieveColors.primary, size: 20),
            ),
            SizedBox(width: 10.w),
            Text(
              'Enter 6-Digit Code',
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.w800,
                fontSize: 18.sp,
                color: BelieveColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type the 6-digit secret code shown on your partner\'s screen to bond immediately.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.sp,
                color: BelieveColors.textSecondary,
                height: 1.4,
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: dialogCodeController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                LengthLimitingTextInputFormatter(6),
                FilteringTextInputFormatter.digitsOnly,
              ],
              textAlign: TextAlign.center,
              autofocus: true,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 26.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 8,
                color: BelieveColors.primaryDark,
              ),
              decoration: InputDecoration(
                hintText: '482910',
                hintStyle: GoogleFonts.plusJakartaSans(
                  letterSpacing: 8,
                  fontSize: 24.sp,
                  color: BelieveColors.textMuted,
                ),
                filled: true,
                fillColor: BelieveColors.surfaceSubtle,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: const BorderSide(color: BelieveColors.glassBorder, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: const BorderSide(color: BelieveColors.primary, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: BelieveColors.textMuted,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final code = dialogCodeController.text.trim();
              if (code.length == 6) {
                Navigator.of(dialogCtx).pop();
                _codeController.text = code;
                _onPair();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter all 6 digits of the pairing code.'),
                    backgroundColor: BelieveColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BelieveColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
            ),
            child: Text(
              'Connect ✨',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Custom Camera Scanner Overlay with glowing viewfinder and animated laser line
  void _openQrScanner() {
    bool hasHandled = false;
    final MobileScannerController scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    final ValueNotifier<bool> isTorchOn = ValueNotifier(false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          height: 0.88.sh,
          decoration: BoxDecoration(
            color: const Color(0xFF0F0B11),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          ),
          child: Stack(
            children: [
              // 1. Live Camera Preview
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
                child: MobileScanner(
                  controller: scannerController,
                  onDetect: (capture) {
                    if (hasHandled) return;
                    final barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      final rawValue = barcode.rawValue;
                      if (rawValue != null && rawValue.trim().isNotEmpty) {
                        hasHandled = true;
                        Navigator.of(bottomSheetContext).pop();

                        // Strict 6-digit regex parser
                        final match = RegExp(r'\d{6}').firstMatch(rawValue.trim());
                        if (match != null) {
                          final extractedCode = match.group(0)!;
                          _codeController.text = extractedCode;
                          _onPair();
                        } else {
                          _showInvalidQrDialog(rawValue);
                        }
                        break;
                      }
                    }
                  },
                ),
              ),

              // 2. Dark Translucent Framing Mask
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.55),
                ),
              ),

              // 3. Central Glowing Viewfinder Frame
              Center(
                child: SizedBox(
                  width: 250.w,
                  height: 250.w,
                  child: Stack(
                    children: [
                      // Clear viewport cutout glow
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.r),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: BelieveColors.primary.withValues(alpha: 0.2),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),

                      // 4 Glowing Corner Brackets
                      _buildViewfinderCorner(top: true, left: true),
                      _buildViewfinderCorner(top: true, left: false),
                      _buildViewfinderCorner(top: false, left: true),
                      _buildViewfinderCorner(top: false, left: false),

                      // Smooth Scanning Laser Animation Bar
                      Positioned(
                        top: 0,
                        left: 12.w,
                        right: 12.w,
                        child: Container(
                          height: 3.h,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Colors.transparent,
                                BelieveColors.primary,
                                BelieveColors.primaryLight,
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: BelieveColors.primary.withValues(alpha: 0.8),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .moveY(
                              begin: 8.h,
                              end: 232.h,
                              duration: 2000.ms,
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. Top Header Controls (Close & Torch)
              Positioned(
                top: 20.h,
                left: 20.w,
                right: 20.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black45,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(LucideIcons.x, color: Colors.white, size: 20),
                      ),
                      onPressed: () => Navigator.of(bottomSheetContext).pop(),
                    ),
                    Text(
                      'Scan Partner\'s QR ✨',
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: isTorchOn,
                      builder: (context, torchActive, _) {
                        return IconButton(
                          icon: Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: torchActive ? BelieveColors.primary : Colors.black45,
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Icon(
                              torchActive ? LucideIcons.flashlight : LucideIcons.flashlightOff,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          onPressed: () {
                            scannerController.toggleTorch();
                            isTorchOn.value = !isTorchOn.value;
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              // 5. Bottom Helper Text & Manual Fallback Button
              Positioned(
                bottom: 36.h,
                left: 24.w,
                right: 24.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.scan, color: Colors.white, size: 16),
                          SizedBox(width: 8.w),
                          Text(
                            'Align partner\'s QR code within the frame',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14.h),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(bottomSheetContext).pop();
                        _openManualInputDialog();
                      },
                      icon: const Icon(LucideIcons.keyboard, color: Colors.white70, size: 16),
                      label: Text(
                        'Having trouble scanning? Enter 6-digit code manually',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 12.5.sp,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      scannerController.dispose();
      isTorchOn.dispose();
    });
  }

  Widget _buildViewfinderCorner({required bool top, required bool left}) {
    return Positioned(
      top: top ? 0 : null,
      bottom: !top ? 0 : null,
      left: left ? 0 : null,
      right: !left ? 0 : null,
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(
          border: Border(
            top: top
                ? const BorderSide(color: BelieveColors.primary, width: 4)
                : BorderSide.none,
            bottom: !top
                ? const BorderSide(color: BelieveColors.primary, width: 4)
                : BorderSide.none,
            left: left
                ? const BorderSide(color: BelieveColors.primary, width: 4)
                : BorderSide.none,
            right: !left
                ? const BorderSide(color: BelieveColors.primary, width: 4)
                : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: top && left ? Radius.circular(16.r) : Radius.zero,
            topRight: top && !left ? Radius.circular(16.r) : Radius.zero,
            bottomLeft: !top && left ? Radius.circular(16.r) : Radius.zero,
            bottomRight: !top && !left ? Radius.circular(16.r) : Radius.zero,
          ),
          boxShadow: [
            BoxShadow(
              color: BelieveColors.primary.withValues(alpha: 0.6),
              blurRadius: 10,
            ),
          ],
        ),
      ),
    );
  }

  /// Delightful success animation dialog with floating hearts navigating to dashboard
  void _showPairingSuccessDialog() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        // Auto navigate to home dashboard after celebration delay
        Future.delayed(const Duration(milliseconds: 2200), () {
          if (dialogCtx.mounted) {
            Navigator.of(dialogCtx).pop();
          }
          if (mounted) {
            context.go(AppRoutes.home);
          }
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Floating decorative hearts
              Positioned(
                top: -30.h,
                left: 30.w,
                child: const Icon(LucideIcons.heart, color: BelieveColors.primaryLight, size: 28)
                    .animate()
                    .scale(duration: 600.ms)
                    .fadeIn()
                    .moveY(begin: 30, end: -60, duration: 1800.ms),
              ),
              Positioned(
                top: -50.h,
                right: 40.w,
                child: const Icon(LucideIcons.heart, color: BelieveColors.primary, size: 36)
                    .animate(delay: 150.ms)
                    .scale(duration: 600.ms)
                    .fadeIn()
                    .moveY(begin: 40, end: -80, duration: 2000.ms),
              ),
              Positioned(
                top: -15.h,
                right: 15.w,
                child: const Icon(LucideIcons.sparkles, color: BelieveColors.champagne, size: 24)
                    .animate(delay: 300.ms)
                    .scale()
                    .fadeIn()
                    .moveY(begin: 20, end: -50, duration: 1600.ms),
              ),

              // Central Celebration Glass Card
              GlassmorphicCard(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
                borderRadius: 28.r,
                surfaceColor: Colors.white.withValues(alpha: 0.96),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72.w,
                      height: 72.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: BelieveColors.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: BelieveColors.primary.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          LucideIcons.heartHandshake,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    )
                        .animate()
                        .scale(duration: 600.ms, curve: Curves.elasticOut),
                    SizedBox(height: 18.h),
                    Text(
                      'Soulmates Connected! ❤️',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: BelieveColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Your private 1-to-1 couple sanctuary is now bonded forever.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.sp,
                        color: BelieveColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: BelieveColors.primary,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'Entering Sanctuary...',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: BelieveColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Warm pastel gradient background with subtle glowing ambient orbs
  Widget _buildRomanticBackground() {
    return Stack(
      children: [
        // Pastel gradient base
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFFF7F9), // Soft rose blush
                Color(0xFFF9F3FF), // Soft lavender tint
                Color(0xFFFFFBF7), // Warm soft cream
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Ambient glowing orbs for glassmorphism depth
        Positioned(
          top: -40.h,
          right: -30.w,
          child: Container(
            width: 200.w,
            height: 200.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  BelieveColors.primaryLight.withValues(alpha: 0.22),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 260.h,
          left: -70.w,
          child: Container(
            width: 240.w,
            height: 240.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  BelieveColors.accentLavender.withValues(alpha: 0.20),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -40.h,
          right: -20.w,
          child: Container(
            width: 220.w,
            height: 220.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  BelieveColors.blushStart.withValues(alpha: 0.18),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Warm welcoming header with romantic icon and instructional subtitle
  Widget _buildWelcomingHeader() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                BelieveColors.primarySoft,
                Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: BelieveColors.primary.withValues(alpha: 0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: BelieveColors.primary.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            LucideIcons.heartHandshake,
            color: BelieveColors.primary,
            size: 26,
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 1200.ms,
              ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Soul Connection ✨',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
            color: BelieveColors.textPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.shieldCheck, size: 14, color: BelieveColors.primary),
            SizedBox(width: 5.w),
            Flexible(
              child: Text(
                'Connect with your soulmate securely',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w500,
                  color: BelieveColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen for pairing completion to trigger celebration modal
    ref.listen<PairingUIState>(pairingControllerProvider, (previous, next) {
      if (next.isPaired && !(previous?.isPaired ?? false)) {
        _showPairingSuccessDialog();
      }
    });

    final pairingState = ref.watch(pairingControllerProvider);
    final myCode = pairingState.inviteCode ?? '...';
    final qrData = myCode;

    return Stack(
      children: [
        // 1. Romantic Background
        _buildRomanticBackground(),

        // 2. Main Content
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(height: 8.h),
                _buildWelcomingHeader(),
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

                SizedBox(height: 8.h),

                // TabBarView Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // ================= TAB 1: Show My QR =================
                      SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
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

                    // Polished Glassmorphic QR Container
                    GlassmorphicCard(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
                      borderRadius: 28.r,
                      surfaceColor: Colors.white.withValues(alpha: 0.88),
                      child: Column(
                        children: [
                          if (pairingState.errorMessage != null && pairingState.inviteCode == null) ...[
                            Icon(LucideIcons.cloudOff, size: 40.r, color: BelieveColors.error),
                            SizedBox(height: 12.h),
                            Text(
                              'Backend Connection Error',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: BelieveColors.error,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              pairingState.errorMessage!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.sp,
                                color: BelieveColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 14.h),
                            ElevatedButton.icon(
                              onPressed: () => ref
                                  .read(pairingControllerProvider.notifier)
                                  .retryLoadCode(),
                              icon: const Icon(LucideIcons.refreshCw, size: 16),
                              label: const Text('Retry Connection'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: BelieveColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                              ),
                            ),
                          ] else ...[
                            // Center Polished White Card with Generous Padding
                            Container(
                              padding: EdgeInsets.all(16.r),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: BelieveColors.primary.withValues(alpha: 0.12),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                                border: Border.all(
                                  color: BelieveColors.primarySoft,
                                  width: 1.5,
                                ),
                              ),
                              child: SizedBox(
                                width: 175.w,
                                height: 175.w,
                                child: pairingState.isGeneratingCode
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: BelieveColors.primary,
                                        ),
                                      )
                                    : QrImageView(
                                        key: ValueKey('qr_image_$qrData'),
                                        data: qrData,
                                        version: QrVersions.auto,
                                        eyeStyle: const QrEyeStyle(
                                          eyeShape: QrEyeShape.square,
                                          color: BelieveColors.primaryDark,
                                        ),
                                        dataModuleStyle: const QrDataModuleStyle(
                                          dataModuleShape: QrDataModuleShape.square,
                                          color: BelieveColors.textPrimary,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // Large Bold Letter-Spaced Typography Directly Below QR
                            Text(
                              myCode,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 32.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 10,
                                color: BelieveColors.primaryDark,
                              ),
                            ),
                            SizedBox(height: 12.h),

                            // 6 Styled Digit Blocks
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: (pairingState.isGeneratingCode || myCode.length != 6
                                      ? ['·', '·', '·', '·', '·', '·']
                                      : myCode.split(''))
                                  .map((char) {
                                return Container(
                                  width: 36.w,
                                  height: 46.h,
                                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: BelieveColors.primary.withValues(alpha: 0.35),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: BelieveColors.primary.withValues(alpha: 0.08),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      char,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w800,
                                        color: BelieveColors.primary,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 14.h),

                            // Subtle Live Expiration Countdown Timer Indicator
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                              decoration: BoxDecoration(
                                color: BelieveColors.primarySoft,
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: BelieveColors.primary.withValues(alpha: 0.25),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    LucideIcons.clock,
                                    size: 13,
                                    color: BelieveColors.primary,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'Code expires in ${_formatCountdown(_remainingSeconds)}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                      color: BelieveColors.primaryDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // Action Buttons: Copy Code (with Haptic Feedback) & New Code
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 12.w,
                              runSpacing: 8.h,
                              children: [
                                InkWell(
                                  onTap: pairingState.inviteCode == null
                                      ? null
                                      : () {
                                          HapticFeedback.lightImpact();
                                          Clipboard.setData(ClipboardData(text: myCode));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(16.r),
                                              ),
                                              backgroundColor: BelieveColors.primaryDark,
                                              content: Row(
                                                children: [
                                                  const Icon(LucideIcons.heart,
                                                      color: Colors.white, size: 18),
                                                  SizedBox(width: 10.w),
                                                  const Text('Couple code copied to clipboard! ✨'),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                  borderRadius: BorderRadius.circular(16.r),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 10.h,
                                    ),
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
                                        const Icon(
                                          LucideIcons.copy,
                                          size: 16,
                                          color: Colors.white,
                                        ),
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
                                  onTap: pairingState.isGeneratingCode
                                      ? null
                                      : () {
                                          HapticFeedback.selectionClick();
                                          setState(() {
                                            _remainingSeconds = 1800;
                                          });
                                          ref
                                              .read(pairingControllerProvider.notifier)
                                              .generateNewInviteCode();
                                        },
                                  borderRadius: BorderRadius.circular(16.r),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14.w,
                                      vertical: 10.h,
                                    ),
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
                    SizedBox(height: 20.h),

                    // Pulsing Waiting Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.heart,
                          size: 16,
                          color: BelieveColors.primary,
                        )
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
              ),

              // ================= TAB 2: Connect Partner =================
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Scanner Hero Card (Quick Scan Button with Custom Camera Viewfinder)
                    GlassmorphicCard(
                      padding: EdgeInsets.all(18.r),
                      borderRadius: 24.r,
                      surfaceColor: Colors.white.withValues(alpha: 0.9),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12.r),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: BelieveColors.primaryGradient,
                                  boxShadow: [
                                    BoxShadow(
                                      color: BelieveColors.primary.withValues(alpha: 0.3),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  LucideIcons.scanLine,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              SizedBox(width: 14.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Scan Partner QR Code',
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.w800,
                                        color: BelieveColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      'Instant bond using phone camera & glowing viewfinder',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5.sp,
                                        color: BelieveColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 14.h),
                          SizedBox(
                            width: double.infinity,
                            height: 48.h,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: BelieveColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                elevation: 3,
                              ),
                              onPressed: _openQrScanner,
                              icon: const Icon(LucideIcons.camera, size: 18),
                              label: Text(
                                'Open Camera Scanner ✨',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Divider badge
                    Center(
                      child: Row(
                        children: [
                          Expanded(child: Divider(color: BelieveColors.border, thickness: 1)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: Text(
                              'or enter code manually',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5.sp,
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

                    // 6-digit Code Input Card
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
                            controller: _codeController,
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
                            onTap: pairingState.isLoading ? null : _onPair,
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
                                  const Icon(LucideIcons.alertCircle,
                                      size: 16, color: BelieveColors.error),
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

                    SizedBox(height: 18.h),

                    // Quick Demo Partner Connector
                    GlassmorphicCard(
                      padding: EdgeInsets.all(16.r),
                      borderRadius: 20.r,
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: BelieveColors.accentLavender.withValues(alpha: 0.2),
                            ),
                            child: const Icon(
                              LucideIcons.sparkles,
                              color: BelieveColors.accentLavender,
                              size: 18,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Testing without 2nd device?',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: BelieveColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Connect with pre-seeded demo partner "LOVE24".',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.sp,
                                    color: BelieveColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              _codeController.text = 'LOVE24';
                              _onPair();
                            },
                            child: Text(
                              'Connect',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                color: BelieveColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Strict 1-to-1 Lock Security Alert
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: BelieveColors.primarySoft,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: BelieveColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            LucideIcons.lock,
                            color: BelieveColors.primary,
                            size: 18,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              'Strict 1-to-1 Lock: Once paired, both accounts are bound permanently to each other. Neither account can pair with anyone else unless explicitly unlinked.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.sp,
                                color: BelieveColors.burgundy,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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
      ],
    ),
  ),
),
],
);
  }
}
