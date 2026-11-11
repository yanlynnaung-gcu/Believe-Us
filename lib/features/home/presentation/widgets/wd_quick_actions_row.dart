import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';

/// Row of quick shortcuts to Love Chat and Monetary Gifting
class WdQuickActionsRow extends StatelessWidget {
  final VoidCallback onOpenChat;
  final VoidCallback onOpenGifting;

  const WdQuickActionsRow({
    super.key,
    required this.onOpenChat,
    required this.onOpenGifting,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Expanded(
            child: GlassmorphicCard(
              padding: EdgeInsets.all(16.r),
              onTap: onOpenChat,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: BelieveColors.primaryGradient,
                    ),
                    child: const Icon(
                      LucideIcons.messageCircle,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'Love Chat',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: BelieveColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Text, voice & gifts',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.sp,
                      color: BelieveColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: GlassmorphicCard(
              padding: EdgeInsets.all(16.r),
              onTap: onOpenGifting,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: BelieveColors.goldGradient,
                    ),
                    child: const Icon(
                      LucideIcons.gift,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'KBZ & Wave',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: BelieveColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Send monetary gift',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.sp,
                      color: BelieveColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
