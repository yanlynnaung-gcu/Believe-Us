import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/services/media_picker_service.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';
import 'package:thae_nge_lay/core/utils/image_provider_helper.dart';
import 'package:thae_nge_lay/features/anniversary/presentation/controllers/anniversary_notifier.dart';
import 'package:thae_nge_lay/features/home/presentation/controllers/couple_media_controller.dart';

/// 2. Interlocking Dual Profile Avatars with Beating Heart & Days Counter
class InterlockingDualAvatars extends ConsumerWidget {
  const InterlockingDualAvatars({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = ref.watch(coupleMediaProvider);
    final anniversary = ref.watch(anniversaryProvider);

    return Column(
      children: [
        SizedBox(
          height: 110.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // User Avatar (Left)
              Positioned(
                left: 0.22.sw,
                child: GestureDetector(
                  onTap: () async {
                    final file =
                        await ref.read(mediaPickerServiceProvider).pickAndCropImage(
                              context: context,
                              cropType: CropType.circleAvatar,
                              title: 'Update Your Avatar ✨',
                            );
                    if (file != null) {
                      ref
                          .read(coupleMediaProvider.notifier)
                          .updateUserAvatar(file.path);
                    }
                  },
                  child: Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: BelieveColors.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: BelieveColors.primary.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 36.r,
                          backgroundImage:
                              getCustomImageProvider(media.userAvatarPath),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(4.r),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const Icon(
                            LucideIcons.camera,
                            size: 13,
                            color: BelieveColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Partner Avatar (Right)
              Positioned(
                right: 0.22.sw,
                child: GestureDetector(
                  onTap: () async {
                    final file =
                        await ref.read(mediaPickerServiceProvider).pickAndCropImage(
                              context: context,
                              cropType: CropType.circleAvatar,
                              title: 'Update Partner Photo ✨',
                            );
                    if (file != null) {
                      ref
                          .read(coupleMediaProvider.notifier)
                          .updatePartnerAvatar(file.path);
                    }
                  },
                  child: Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: BelieveColors.romanticSunsetGradient,
                          boxShadow: [
                            BoxShadow(
                              color: BelieveColors.blushStart.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 36.r,
                          backgroundImage:
                              getCustomImageProvider(media.partnerAvatarPath),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(4.r),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const Icon(
                            LucideIcons.camera,
                            size: 13,
                            color: BelieveColors.blushStart,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // "Together for X Days" Badge
        GlassmorphicCard(
          borderRadius: 24.r,
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.sparkles,
                size: 14,
                color: BelieveColors.champagne,
              ),
              SizedBox(width: 6.w),
              Text(
                'Together for ',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: BelieveColors.textSecondary,
                ),
              ),
              Text(
                '${anniversary.daysTogether} Days',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: BelieveColors.primaryDark,
                ),
              ),
              SizedBox(width: 4.w),
              const Text('❤️'),
            ],
          ),
        ),
      ],
    );
  }
}
