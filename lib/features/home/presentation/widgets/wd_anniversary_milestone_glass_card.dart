import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';
import 'package:thae_nge_lay/features/anniversary/presentation/controllers/anniversary_notifier.dart';

/// 5. Anniversary Milestone Glass Card
class AnniversaryMilestoneGlassCard extends ConsumerWidget {
  final VoidCallback onTapAdd;

  const AnniversaryMilestoneGlassCard({super.key, required this.onTapAdd});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(anniversaryProvider);
    final next = state.nextMilestone;
    final daysUntil = state.daysUntilNextMilestone ?? 0;

    return GlassmorphicCard(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: BelieveColors.coupleLoveGradient,
                ),
                child: const Icon(
                  LucideIcons.heart,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      next != null ? next.title : 'Anniversary Milestone',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: BelieveColors.textPrimary,
                      ),
                    ),
                    Text(
                      'In $daysUntil Days • Sacred Bond',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        color: BelieveColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Add milestone button
              IconButton(
                icon: const Icon(LucideIcons.plus, color: BelieveColors.primary),
                onPressed: onTapAdd,
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Progress indicator bar towards next milestone
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: LinearProgressIndicator(
              value: (1.0 - (daysUntil / 365.0)).clamp(0.1, 1.0),
              minHeight: 6.h,
              backgroundColor: BelieveColors.primarySoft,
              valueColor: const AlwaysStoppedAnimation(BelieveColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
