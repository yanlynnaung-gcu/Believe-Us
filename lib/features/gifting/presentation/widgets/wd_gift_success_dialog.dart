import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';

/// Celebration dialog shown after gift payment success
void showGiftSuccessDialog(
  BuildContext context, {
  required String refCode,
  required String title,
  required int amount,
}) {
  final formatted = '${NumberFormat('#,###').format(amount)} MMK';
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: BelieveColors.primaryGradient,
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Gift Sent with Love! 🎉',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: BelieveColors.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              '$title ($formatted)',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: BelieveColors.primaryDark,
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: BelieveColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                'Verified Ref: $refCode\nIn-Chat Card Delivered',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: BelieveColors.textSecondary,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back to Chat'),
            ),
          ],
        ),
      );
    },
  );
}
