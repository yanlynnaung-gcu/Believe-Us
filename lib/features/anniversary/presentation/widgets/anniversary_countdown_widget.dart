import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:thae_nge_lay/core/router/route_names.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/features/anniversary/presentation/controllers/anniversary_notifier.dart';

class AnniversaryCountdownWidget extends ConsumerWidget {
  const AnniversaryCountdownWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(anniversaryProvider);

    final nextMilestone = state.nextMilestone;
    final daysUntil = state.daysUntilNextMilestone ?? 0;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.anniversary),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          gradient: BelieveColors.coupleLoveGradient,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: BelieveColors.primary.withValues(alpha: 0.3),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'TOGETHER FOREVER',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 14.r,
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Big Days Count
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${state.daysTogether}',
                  style: TextStyle(
                    fontSize: 48.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                    height: 1,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Days in Love',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),

            // Upcoming Milestone Pill
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                children: [
                  Text(
                    nextMilestone?.iconEmoji ?? '💌',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      nextMilestone != null
                          ? '${nextMilestone.title}: in $daysUntil days'
                          : 'Every day is a milestone with you',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
