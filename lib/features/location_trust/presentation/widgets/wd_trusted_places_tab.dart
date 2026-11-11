import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/features/location_trust/presentation/controllers/location_detail_controller.dart';

/// Tab displaying user's geofenced trusted places
class WdTrustedPlacesTab extends StatelessWidget {
  final LocationDetailState state;
  final ScrollController scrollController;
  final VoidCallback onAddPlace;

  const WdTrustedPlacesTab({
    super.key,
    required this.state,
    required this.scrollController,
    required this.onAddPlace,
  });

  IconData _resolvePlaceIcon(String name) {
    switch (name) {
      case 'briefcase':
        return LucideIcons.briefcase;
      case 'coffee':
        return LucideIcons.coffee;
      case 'heart':
        return LucideIcons.heart;
      case 'school':
        return LucideIcons.graduationCap;
      default:
        return LucideIcons.home;
    }
  }

  @override
  Widget build(BuildContext context) {
    final places = state.trustedPlaces;

    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      itemCount: places.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: GestureDetector(
              onTap: onAddPlace,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: BelieveColors.primarySoft,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: BelieveColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      LucideIcons.plusCircle,
                      color: BelieveColors.primary,
                      size: 18,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '+ Add Trusted Place (150m Geofence)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: BelieveColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final place = places[index - 1];
        final iconData = _resolvePlaceIcon(place.iconName);
        return RepaintBoundary(
          child: Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: BelieveColors.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: const BoxDecoration(
                    gradient: BelieveColors.romanticSunsetGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: Colors.white, size: 18),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: BelieveColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '150m Safety Radius • Arrival & Departure Alerts On',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.sp,
                          color: BelieveColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  LucideIcons.bellRing,
                  color: BelieveColors.primary,
                  size: 18,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
