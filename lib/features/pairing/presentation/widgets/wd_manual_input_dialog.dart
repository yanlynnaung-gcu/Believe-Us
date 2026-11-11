import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';

/// Clean manual fallback dialog opened when scanning has trouble
void showManualInputDialog(
  BuildContext context, {
  required void Function(String code) onCodeEntered,
}) {
  final TextEditingController dialogCodeController = TextEditingController();
  showDialog(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: BelieveColors.primarySoft,
            ),
            child: const Icon(
              LucideIcons.keyRound,
              color: BelieveColors.primary,
              size: 20,
            ),
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
              onCodeEntered(code);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Please enter all 6 digits of the pairing code.',
                  ),
                  backgroundColor: BelieveColors.error,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: BelieveColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
          ),
          child: Text(
            'Connect ✨',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}
