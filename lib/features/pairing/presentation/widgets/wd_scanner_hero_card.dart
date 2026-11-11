import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';

/// Scanner Hero Card (Quick Scan Button with Custom Camera Viewfinder)
class WdScannerHeroCard extends StatelessWidget {
  final VoidCallback onOpenScanner;

  const WdScannerHeroCard({
    super.key,
    required this.onOpenScanner,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      padding: EdgeInsets.all(18.r),
      borderRadius: 24.r,
      surfaceColor: Colors.white.withValues(alpha: 0.9),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: BelieveColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: BelieveColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Icon(
                  LucideIcons.scanLine,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scan Partner QR Code',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w800,
                        color: BelieveColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Instant bond using phone camera & glowing viewfinder',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5.sp,
                        color: BelieveColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: BelieveColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 3,
              ),
              onPressed: onOpenScanner,
              icon: const Icon(LucideIcons.camera, size: 18),
              label: Text(
                'Open Camera Scanner ✨',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
