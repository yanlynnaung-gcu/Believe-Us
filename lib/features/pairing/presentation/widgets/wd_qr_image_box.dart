import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/features/pairing/presentation/controllers/pairing_controller.dart';

/// Center Container with QR Image or Error Retry
class WdQrImageBox extends StatelessWidget {
  final PairingUIState pairingState;
  final VoidCallback onRetryLoadCode;

  const WdQrImageBox({
    super.key,
    required this.pairingState,
    required this.onRetryLoadCode,
  });

  @override
  Widget build(BuildContext context) {
    if (pairingState.errorMessage != null && pairingState.inviteCode == null) {
      return Column(
        children: [
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
            onPressed: onRetryLoadCode,
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
        ],
      );
    }

    final qrData = pairingState.inviteCode ?? '...';

    return Container(
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
        border: Border.all(color: BelieveColors.primarySoft, width: 1.5),
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
    );
  }
}
