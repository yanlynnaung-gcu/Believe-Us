import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';

/// Shows an invalid QR dialog and error snackbar
void showInvalidQrDialog(BuildContext context, [String? scannedText]) {
  HapticFeedback.mediumImpact();
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: BelieveColors.error.withValues(alpha: 0.12),
            ),
            child: const Icon(
              LucideIcons.scanLine,
              color: BelieveColors.error,
              size: 20,
            ),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      backgroundColor: BelieveColors.error,
      content: const Text(
        'Invalid QR code. Please scan a valid 6-digit couple pairing code.',
      ),
    ),
  );
}
