import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/router/route_names.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';
import 'package:thae_nge_lay/core/utils/image_provider_helper.dart';
import 'package:thae_nge_lay/features/home/presentation/controllers/couple_media_controller.dart';
import 'package:thae_nge_lay/features/location/presentation/controllers/partner_location_notifier.dart';

class PartnerLiveStatusBar extends ConsumerWidget {
  const PartnerLiveStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(partnerLocationProvider);
    final media = ref.watch(coupleMediaProvider);

    Color getBatteryColor(int level) {
      if (level > 50) return BelieveColors.success;
      if (level > 20) return BelieveColors.warning;
      return BelieveColors.error;
    }

    return GlassmorphicCard(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      borderRadius: 22.r,
      onTap: () => context.push(AppRoutes.map),
      child: Row(
        children: [
          // Partner Avatar with pulsing live dot
          Stack(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: BelieveColors.primarySoft,
                backgroundImage:
                    getCustomImageProvider(media.partnerAvatarPath),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: BelieveColors.success,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),

          // Location & Update info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      media.partnerName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: BelieveColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    const Icon(
                      LucideIcons.mapPin,
                      size: 13,
                      color: BelieveColors.primary,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        status.placeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          color: BelieveColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Battery Indicator
                      Icon(
                        status.isCharging
                            ? LucideIcons.batteryCharging
                            : LucideIcons.battery,
                        size: 13,
                        color: getBatteryColor(status.batteryLevel),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${status.batteryLevel}%${status.isCharging ? " (Charging)" : ""}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.sp,
                          color: getBatteryColor(status.batteryLevel),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '• Just now',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.sp,
                          color: BelieveColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Distance Pill
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              gradient: BelieveColors.primaryGradient,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.heart,
                  size: 12,
                  color: Colors.white,
                ),
                SizedBox(width: 4.w),
                Text(
                  '${status.distanceKm ?? 0} km',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
