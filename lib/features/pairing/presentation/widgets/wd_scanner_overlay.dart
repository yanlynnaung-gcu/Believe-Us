import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/features/pairing/presentation/widgets/wd_viewfinder_corner.dart';

/// Custom Camera Scanner Overlay with glowing viewfinder and animated laser line
void showQrScannerModal(
  BuildContext context, {
  required void Function(String code) onCodeScanned,
  required VoidCallback onManualInputRequested,
  required void Function(String? raw) onInvalidQrScanned,
}) {
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
                        onCodeScanned(match.group(0)!);
                      } else {
                        onInvalidQrScanned(rawValue);
                      }
                      break;
                    }
                  }
                },
              ),
            ),

            // 2. Dark Translucent Framing Mask
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.55)),
            ),

            // 3. Central Glowing Viewfinder Frame
            const WdViewfinderTarget(),

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
                      onManualInputRequested();
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
