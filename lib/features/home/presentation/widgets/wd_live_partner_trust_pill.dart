import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';
import 'package:thae_nge_lay/core/utils/image_provider_helper.dart';
import 'package:thae_nge_lay/features/home/presentation/controllers/couple_media_controller.dart';
import 'package:thae_nge_lay/features/location/presentation/controllers/partner_location_notifier.dart';

/// 3. Live Partner Trust Pill (Location & Battery Status)
class LivePartnerTrustPill extends ConsumerWidget {
  final VoidCallback onTap;

  const LivePartnerTrustPill({super.key, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(partnerLocationProvider);
    final partnerAvatarPath = ref.watch(coupleMediaProvider.select((m) => m.partnerAvatarPath));

    return RepaintBoundary(
      child: GlassmorphicCard(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        onTap: onTap,
        child: Row(
        children: [
          // Small Partner Avatar with live green pulse
          Stack(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundImage: getCustomImageProvider(partnerAvatarPath),
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

          // Location details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      LucideIcons.mapPin,
                      size: 14,
                      color: BelieveColors.primary,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        status.placeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: BelieveColors.textPrimary,
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
                      Icon(
                        status.isCharging
                            ? LucideIcons.batteryCharging
                            : LucideIcons.battery,
                        size: 13,
                        color: status.batteryLevel > 20
                            ? BelieveColors.success
                            : BelieveColors.error,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${status.batteryLevel}% battery • Live',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.sp,
                          color: BelieveColors.textSecondary,
                          fontWeight: FontWeight.w500,
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
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              gradient: BelieveColors.primaryGradient,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Text(
              '${status.distanceKm ?? 0} km',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
