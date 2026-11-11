import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';
import 'package:thae_nge_lay/features/emergency/domain/models/emergency_sos_model.dart';

class WdEmergencyLocationBadge extends StatelessWidget {
  final EmergencySOSModel? activeAlert;

  const WdEmergencyLocationBadge({
    super.key,
    required this.activeAlert,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Distress Message Card
        GlassmorphicCard(
          borderRadius: 16.r,
          padding: EdgeInsets.all(16.r),
          surfaceColor: Colors.red.shade900.withValues(alpha: 0.35),
          borderColor: Colors.redAccent.withValues(alpha: 0.4),
          child: Row(
            children: [
              const Icon(
                LucideIcons.messageSquareWarning,
                color: Colors.redAccent,
                size: 20,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  activeAlert?.message ??
                      '🚨 EMERGENCY SOS: Immediate assistance required!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 14.h),

        // Live Coordinates & Address Card
        GlassmorphicCard(
          borderRadius: 16.r,
          padding: EdgeInsets.all(16.r),
          surfaceColor: Colors.white.withValues(alpha: 0.08),
          borderColor: Colors.white.withValues(alpha: 0.15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    LucideIcons.mapPin,
                    color: Colors.redAccent,
                    size: 16,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Live Incident Location',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: BelieveColors.success.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: BelieveColors.success,
                      ),
                    ),
                    child: Text(
                      'High Accuracy GPS',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: BelieveColors.success,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                activeAlert != null
                    ? '${activeAlert!.latitude.toStringAsFixed(5)}° N, ${activeAlert!.longitude.toStringAsFixed(5)}° E'
                    : '16.82950° N, 96.13050° E',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                activeAlert?.address.isNotEmpty == true
                    ? activeAlert!.address
                    : 'Pyay Road, Kamayut, Yangon',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Timestamp: ${DateFormat('h:mm:ss a • d MMM yyyy').format(activeAlert?.timestamp ?? DateTime.now())}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.sp,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
