import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';

/// Confirmation dialog when user intends to sign out
Future<bool?> showSignOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
        'Sign Out?',
        style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700),
      ),
      content: Text(
        'Are you sure you want to sign out from your sacred couple space?',
        style: GoogleFonts.plusJakartaSans(fontSize: 13.sp),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text(
            'Sign Out',
            style: TextStyle(color: BelieveColors.error),
          ),
        ),
      ],
    ),
  );
}
