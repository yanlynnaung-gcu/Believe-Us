import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';

/// Preview tab view for Tab 3 (Gift & Surprise Shop)
class WdGiftShopPreview extends StatelessWidget {
  final VoidCallback onOpenGiftingSheet;

  const WdGiftShopPreview({super.key, required this.onOpenGiftingSheet});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: BelieveColors.goldGradient,
            ),
            child: const Icon(LucideIcons.gift, size: 48, color: Colors.white),
          ),
          SizedBox(height: 20.h),
          Text(
            'Surprise Your Partner',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: BelieveColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Send instant monetary blessings and virtual packages\nvia KBZPay & WavePay.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.sp,
              color: BelieveColors.textSecondary,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: onOpenGiftingSheet,
            child: const Text('Open Gift Selection Sheet ✨'),
          ),
        ],
      ),
    );
  }
}
