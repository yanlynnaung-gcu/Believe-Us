import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/features/anniversary/domain/models/anniversary_milestone.dart';

class WdMilestoneCard extends StatelessWidget {
  final AnniversaryMilestone milestone;

  const WdMilestoneCard({
    super.key,
    required this.milestone,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMMM d, yyyy').format(milestone.targetDate);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: BelieveColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: BelieveColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: const BoxDecoration(
              color: BelieveColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                milestone.iconEmoji,
                style: TextStyle(fontSize: 20.sp),
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: BelieveColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: BelieveColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (milestone.isRecurringAnnual)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 4.h,
              ),
              decoration: BoxDecoration(
                color: BelieveColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Annual',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: BelieveColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
