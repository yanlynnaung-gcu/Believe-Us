import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';
import 'package:thae_nge_lay/features/pairing/presentation/controllers/pairing_controller.dart';

class PairingScreen extends ConsumerStatefulWidget {
  const PairingScreen({super.key});

  @override
  ConsumerState<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends ConsumerState<PairingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _onPair() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your partner\'s 6-digit code.'),
          backgroundColor: BelieveColors.error,
        ),
      );
      return;
    }

    final success =
        await ref.read(pairingControllerProvider.notifier).pairWithCode(code);

    if (mounted && !success) {
      final error = ref.read(pairingControllerProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Pairing failed.'),
          backgroundColor: BelieveColors.error,
        ),
      );
    }
  }

  void _openQrScanner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (context) {
        return SizedBox(
          height: 0.8.sh,
          child: Stack(
            children: [
              MobileScanner(
                onDetect: (capture) {
                  final barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    final rawValue = barcode.rawValue;
                    if (rawValue != null && rawValue.isNotEmpty) {
                      Navigator.of(context).pop();
                      _codeController.text = rawValue.toUpperCase();
                      _onPair();
                      break;
                    }
                  }
                },
              ),
              Positioned(
                top: 40.h,
                right: 20.w,
                child: IconButton(
                  icon: const Icon(LucideIcons.x, color: Colors.white, size: 26),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Positioned(
                bottom: 60.h,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'Align your partner\'s QR code within the frame',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pairingState = ref.watch(pairingControllerProvider);
    final myCode = pairingState.inviteCode ?? '...';
    final qrData = 'thaethae://pair?code=$myCode';

    return Scaffold(
      backgroundColor: BelieveColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Soul Connection',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w700,
            fontSize: 20.sp,
          ),
        ),
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: BelieveColors.glassBorder),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: BelieveColors.primaryGradient,
                borderRadius: BorderRadius.circular(24.r),
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
                Tab(text: 'My Couple Code'),
                Tab(text: 'Connect Partner'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: My Couple Code & QR
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Share This With Your Love ✨',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: BelieveColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Your partner can scan this QR or type your 6-letter secret code.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp,
                    color: BelieveColors.textSecondary,
                  ),
                ),
                SizedBox(height: 24.h),

                // QR Code Glass Card
                GlassmorphicCard(
                  padding: EdgeInsets.all(24.r),
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
                        SizedBox(height: 8.h),
                        Text(
                          pairingState.errorMessage!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
                            color: BelieveColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton.icon(
                          onPressed: () => ref.read(pairingControllerProvider.notifier).retryLoadCode(),
                          icon: const Icon(LucideIcons.refreshCw, size: 16),
                          label: const Text('Retry Connection'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: BelieveColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color: BelieveColors.primary.withValues(alpha: 0.1),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: SizedBox(
                            width: 180.w,
                            height: 180.w,
                            child: pairingState.isGeneratingCode
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: BelieveColors.primary,
                                    ),
                                  )
                                : QrImageView(
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
                        SizedBox(height: 20.h),

                        // 6-digit styled blocks
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
                                  color: BelieveColors.primary.withValues(alpha: 0.3),
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
                        SizedBox(height: 18.h),

                        // Action buttons: Copy & Generate New Code
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: pairingState.inviteCode == null
                                  ? null
                                  : () {
                                      Clipboard.setData(ClipboardData(text: myCode));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Couple code copied to clipboard! ✨'),
                                          backgroundColor: BelieveColors.success,
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
                                      color: BelieveColors.primary.withValues(alpha: 0.3),
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
                            SizedBox(width: 12.w),
                            InkWell(
                              onTap: pairingState.isGeneratingCode
                                  ? null
                                  : () => ref
                                      .read(pairingControllerProvider.notifier)
                                      .generateNewInviteCode(),
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
                        SizedBox(height: 12.h),
                        Text(
                          'Code valid for 30 minutes (persisted in Spring Boot backend)',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.sp,
                            color: BelieveColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Pulsing waiting indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                    Text(
                      'Waiting for your partner to bond...',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: BelieveColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // TAB 2: Connect Partner
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter Partner\'s Secret Code',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: BelieveColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Ask your partner for their 6-digit code or scan their QR code.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp,
                    color: BelieveColors.textSecondary,
                  ),
                ),
                SizedBox(height: 24.h),

                // 6-digit code input in Glass card
                GlassmorphicCard(
                  padding: EdgeInsets.all(20.r),
                  child: Column(
                    children: [
                      TextField(
                        controller: _codeController,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(6),
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9]')),
                        ],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 8,
                          color: BelieveColors.primaryDark,
                        ),
                        decoration: InputDecoration(
                          hintText: 'CODE24',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            letterSpacing: 8,
                            fontSize: 24.sp,
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
                        ),
                      ),
                      SizedBox(height: 18.h),

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
                                color:
                                    BelieveColors.primary.withValues(alpha: 0.35),
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
                                    children: [
                                      const Icon(
                                        LucideIcons.heartHandshake,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        'Bond & Connect Now ✨',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
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
                              const Icon(LucideIcons.alertCircle, size: 16, color: BelieveColors.error),
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

                // Scan QR Button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: BelieveColors.primary,
                      side: const BorderSide(color: BelieveColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    onPressed: _openQrScanner,
                    icon: const Icon(LucideIcons.scanLine, size: 18),
                    label: Text(
                      'Scan Partner QR Code',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // Quick Demo Partner Connector for instant testing
                GlassmorphicCard(
                  padding: EdgeInsets.all(16.r),
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

                SizedBox(height: 24.h),

                // Strict 1-to-1 lock security alert
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
    );
  }
}
