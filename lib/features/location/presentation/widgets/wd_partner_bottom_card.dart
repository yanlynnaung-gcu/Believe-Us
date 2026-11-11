import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/router/route_names.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';

/// Bottom floating glass card with partner status, battery, and check-in alert buttons
class WdPartnerBottomCard extends StatelessWidget {
  final String partnerName;
  final String placeName;
  final double distanceKm;
  final int batteryLevel;
  final bool isCharging;
  final VoidCallback onSendCheckInAlert;

  const WdPartnerBottomCard({
    super.key,
    required this.partnerName,
    required this.placeName,
    required this.distanceKm,
    required this.batteryLevel,
    required this.isCharging,
    required this.onSendCheckInAlert,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24.h,
      left: 20.w,
      right: 20.w,
      child: GlassmorphicCard(
        padding: EdgeInsets.all(20.r),
        surfaceColor: Colors.white.withValues(alpha: 0.95),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '$partnerName is at',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.sp,
                              color: BelieveColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          const Icon(
                            LucideIcons.mapPin,
                            size: 12,
                            color: BelieveColors.primary,
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        placeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: BelieveColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '$distanceKm km away from your heart',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.sp,
                          color: BelieveColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: BelieveColors.primarySoft,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isCharging
                            ? LucideIcons.batteryCharging
                            : LucideIcons.battery,
                        size: 15,
                        color: BelieveColors.success,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '$batteryLevel%',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: BelieveColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),

            // Push Check-In Alert Button
            GestureDetector(
              onTap: onSendCheckInAlert,
              child: Container(
                height: 46.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: BelieveColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: BelieveColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.bell, color: Colors.white, size: 17),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: Text(
                          'Send Arrival Alert & Check-In',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 8.h),

            // Secondary Button: View Arrival Logs & Safe Places
            GestureDetector(
              onTap: () => context.push(AppRoutes.locationDetails),
              child: Container(
                height: 38.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: BelieveColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: BelieveColors.glassBorder),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        LucideIcons.history,
                        color: BelieveColors.burgundy,
                        size: 14,
                      ),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          'Arrival History & Safe Places (150m)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: BelieveColors.burgundy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
