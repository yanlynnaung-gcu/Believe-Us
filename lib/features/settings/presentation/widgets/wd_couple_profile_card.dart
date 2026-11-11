import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';
import 'package:thae_nge_lay/core/utils/image_provider_helper.dart';

/// Top profile card displaying couple avatars, names, and Space ID
class WdCoupleProfileCard extends StatelessWidget {
  final String? userAvatarPath;
  final String displayName;
  final String partnerName;
  final String coupleSpaceId;

  const WdCoupleProfileCard({
    super.key,
    required this.userAvatarPath,
    required this.displayName,
    required this.partnerName,
    required this.coupleSpaceId,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      padding: EdgeInsets.all(18.r),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28.r,
                backgroundImage: getCustomImageProvider(userAvatarPath),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: BelieveColors.primary,
                  ),
                  child: const Icon(
                    LucideIcons.heart,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: BelieveColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Paired with $partnerName ❤️',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    color: BelieveColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Space #$coupleSpaceId',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.sp,
                    color: BelieveColors.textMuted,
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
