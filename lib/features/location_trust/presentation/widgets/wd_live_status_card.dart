import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';
import 'package:thae_nge_lay/features/location_trust/domain/models/partner_location_arrival_model.dart';
import 'package:thae_nge_lay/features/location_trust/presentation/controllers/location_detail_controller.dart';

/// Glassmorphic card displaying real-time partner status, battery, GPS accuracy, and nudge button
class WdLiveStatusCard extends StatelessWidget {
  final LocationDetailState state;
  final VoidCallback onSendNudge;

  const WdLiveStatusCard({
    super.key,
    required this.state,
    required this.onSendNudge,
  });

  @override
  Widget build(BuildContext context) {
    final isBatteryLow = state.batteryLevel <= 20;

    return GlassmorphicCard(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Place Badge & Address
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  gradient: BelieveColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: BelieveColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  state.status == MovementStatus.stationary
                      ? LucideIcons.home
                      : LucideIcons.car,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.status == MovementStatus.stationary
                          ? '🏠 At ${state.placeName}'
                          : '🚗 Moving (${state.speedKmh.toStringAsFixed(0)} km/h)',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: BelieveColors.textPrimary,
                      ),
                    ),
                    Text(
                      state.addressLine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.sp,
                        color: BelieveColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // Arrival Time & Stay Duration
          Row(
            children: [
              const Icon(
                LucideIcons.clock,
                size: 13,
                color: BelieveColors.primary,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  'Arrived at ${DateFormat('h:mm a').format(state.arrivedAt)} • Stayed for ${state.stayDurationFormatted}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: BelieveColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Telemetry Pills & Nudge Action
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Battery Level Pill
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: isBatteryLow
                              ? BelieveColors.error.withValues(alpha: 0.12)
                              : BelieveColors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isBatteryLow
                                ? BelieveColors.error
                                : BelieveColors.border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              state.isCharging
                                  ? LucideIcons.batteryCharging
                                  : LucideIcons.battery,
                              size: 13,
                              color: isBatteryLow
                                  ? BelieveColors.error
                                  : BelieveColors.primary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${state.batteryLevel}%${state.isCharging ? ' (Charging)' : ''}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: isBatteryLow
                                    ? BelieveColors.error
                                    : BelieveColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: 8.w),

                      // GPS Accuracy Pill
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: BelieveColors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: BelieveColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              LucideIcons.radio,
                              size: 12,
                              color: BelieveColors.success,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              state.gpsAccuracy,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: BelieveColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: 8.w),

              // Quick Action Button: Send 'Reached Safely?' Heart
              GestureDetector(
                onTap: state.isNudgeSent ? null : onSendNudge,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    gradient: state.isNudgeSent
                        ? null
                        : BelieveColors.primaryGradient,
                    color: state.isNudgeSent ? Colors.grey : null,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: BelieveColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        state.isNudgeSent
                            ? LucideIcons.check
                            : LucideIcons.heart,
                        size: 13,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        state.isNudgeSent ? 'Nudge Sent' : 'Safe?',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
