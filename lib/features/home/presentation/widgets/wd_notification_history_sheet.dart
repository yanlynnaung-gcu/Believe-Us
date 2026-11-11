import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/features/notifications/domain/models/couple_notification.dart';

/// Modal bottom sheet displaying chronological list of received couple push notifications
void showNotificationHistorySheet(BuildContext context, List<CoupleNotification> history) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return Container(
        decoration: BoxDecoration(
          color: BelieveColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 44.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: BelieveColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Couple Push Notifications',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: BelieveColors.textPrimary,
                  ),
                ),
                Text(
                  '${history.length} alerts',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    color: BelieveColors.textMuted,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            if (history.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 36.h),
                child: Center(
                  child: Text(
                    'No push notifications received yet.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.sp,
                      color: BelieveColors.textMuted,
                    ),
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 10.h),
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: BelieveColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: BelieveColors.glassBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: BelieveColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            item.body,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.sp,
                              color: BelieveColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      );
    },
  );
}
