import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/features/location_trust/domain/models/partner_location_arrival_model.dart';
import 'package:thae_nge_lay/features/location_trust/presentation/controllers/location_detail_controller.dart';

/// Chronological timeline of today's arrival and departure events
class WdArrivalTimelineTab extends StatelessWidget {
  final LocationDetailState state;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final void Function(PartnerLocationArrivalModel log) onLogSelected;

  const WdArrivalTimelineTab({
    super.key,
    required this.state,
    required this.scrollController,
    required this.onRefresh,
    required this.onLogSelected,
  });

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final logs = state.todayArrivalLogs;
    if (logs.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          children: [
            Center(
              child: state.isLoading
                  ? const CircularProgressIndicator.adaptive()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'No arrivals recorded yet today.',
                          style: GoogleFonts.plusJakartaSans(
                            color: BelieveColors.textMuted,
                            fontSize: 13.sp,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        TextButton.icon(
                          onPressed: onRefresh,
                          icon: const Icon(LucideIcons.refreshCw, size: 16),
                          label: const Text('Sync with Server'),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          final isCurrent = log.departedAt == null;
          final isLast = index == logs.length - 1;

          final durationText = log.departedAt != null
              ? _formatDuration(log.departedAt!.difference(log.arrivedAt))
              : _formatDuration(DateTime.now().difference(log.arrivedAt));

          return GestureDetector(
            onTap: () => onLogSelected(log),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline node with indicator line
                  Column(
                    children: [
                      Container(
                        width: 28.r,
                        height: 28.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient:
                              isCurrent ? BelieveColors.primaryGradient : null,
                          color: isCurrent ? null : BelieveColors.surfaceSubtle,
                          border: Border.all(
                            color: isCurrent
                                ? Colors.white
                                : BelieveColors.primary.withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          isCurrent ? LucideIcons.heart : LucideIcons.mapPin,
                          size: 13,
                          color:
                              isCurrent ? Colors.white : BelieveColors.primary,
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: BelieveColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                    ],
                  ),

                  SizedBox(width: 14.w),

                  // Arrival details card
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 16.h),
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? BelieveColors.primarySoft
                            : BelieveColors.surface,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: isCurrent
                              ? BelieveColors.primary.withValues(alpha: 0.3)
                              : BelieveColors.border,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                log.placeName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: BelieveColors.textPrimary,
                                ),
                              ),
                              if (isCurrent)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: BelieveColors.primary,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Text(
                                    'Currently Here',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            log.addressLine,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.sp,
                              color: BelieveColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.calendarClock,
                                size: 12,
                                color: BelieveColors.primary,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                log.departedAt != null
                                    ? '${DateFormat('h:mm a').format(log.arrivedAt)} — ${DateFormat('h:mm a').format(log.departedAt!)} ($durationText)'
                                    : 'Arrived ${DateFormat('h:mm a').format(log.arrivedAt)} • ($durationText)',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: BelieveColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
