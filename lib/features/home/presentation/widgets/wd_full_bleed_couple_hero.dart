import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/router/route_names.dart';
import 'package:thae_nge_lay/core/services/media_picker_service.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';
import 'package:thae_nge_lay/core/utils/image_provider_helper.dart';
import 'package:thae_nge_lay/features/emergency/presentation/controllers/emergency_controller.dart';
import 'package:thae_nge_lay/features/home/presentation/controllers/couple_media_controller.dart';

/// 1. Full-Bleed Shared Couple Photo Hero Header (Top 42%)
class FullBleedCoupleHero extends ConsumerWidget {
  const FullBleedCoupleHero({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = ref.watch(coupleMediaProvider);
    final heroHeight = 0.40.sh;

    return RepaintBoundary(
      child: Stack(
        children: [
        // Shared Couple Photo with disk cache and robust fallback
        SizedBox(
          height: heroHeight,
          width: double.infinity,
          child: SafeCoupleImage(
            imagePath: media.coverPhotoPath,
            width: double.infinity,
            height: heroHeight,
            fit: BoxFit.cover,
            fallbackUrl: kDefaultFallbackImageUrl,
          ),
        ),

        // Dreamy Sunset Gradient Overlay with bottom fade into pearl blush
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.25),
                  Colors.transparent,
                  BelieveColors.background.withValues(alpha: 0.8),
                  BelieveColors.background,
                ],
                stops: const [0.0, 0.45, 0.85, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        // Top App Bar Title
        Positioned(
          top: 48.h,
          left: 20.w,
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        side: const BorderSide(color: BelieveColors.glassBorder),
                      ),
                      content: Row(
                        children: [
                          const Icon(
                            LucideIcons.heart,
                            color: BelieveColors.primary,
                            size: 16,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '❤️ Thae Thae - Sanctuary of Love',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              color: BelieveColors.textPrimary,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(7.r),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: BelieveColors.primaryGradient,
                  ),
                  child: const Icon(
                    LucideIcons.heart,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'Thae Thae',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Floating Glass Action Buttons in top-right (Settings & Camera)
        Positioned(
          top: 44.h,
          right: 20.w,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GlassmorphicCard(
                borderRadius: 30.r,
                padding: EdgeInsets.all(10.r),
                surfaceColor: Colors.red.withValues(alpha: 0.45),
                borderColor: Colors.redAccent.withValues(alpha: 0.7),
                onTap: () async {
                  await ref.read(emergencyControllerProvider.notifier).triggerEmergencySOS();
                  if (context.mounted) {
                    context.push(AppRoutes.emergencyAlarm);
                  }
                },
                child: const Icon(
                  LucideIcons.siren,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 8.w),
              GlassmorphicCard(
                borderRadius: 30.r,
                padding: EdgeInsets.all(10.r),
                surfaceColor: Colors.white.withValues(alpha: 0.4),
                borderColor: Colors.white.withValues(alpha: 0.6),
                onTap: () => context.push(AppRoutes.settings),
                child: const Icon(
                  LucideIcons.settings,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 8.w),
              GlassmorphicCard(
                borderRadius: 30.r,
                padding: EdgeInsets.all(10.r),
                surfaceColor: Colors.white.withValues(alpha: 0.4),
                borderColor: Colors.white.withValues(alpha: 0.6),
                onTap: () async {
                  final file = await ref.read(mediaPickerServiceProvider).pickAndCropImage(
                        context: context,
                        cropType: CropType.coverPhoto,
                        title: 'Update Couple Cover Photo ✨',
                      );
                  if (file != null) {
                    ref.read(coupleMediaProvider.notifier).updateCoverPhoto(file.path);
                  }
                },
                child: const Icon(
                  LucideIcons.camera,
                  color: Colors.white,
                  size: 20,
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
