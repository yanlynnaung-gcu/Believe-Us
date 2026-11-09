import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/network/websocket_sync_service.dart';
import 'package:thae_nge_lay/core/router/route_names.dart';
import 'package:thae_nge_lay/core/services/media_picker_service.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';
import 'package:thae_nge_lay/core/utils/image_provider_helper.dart';
import 'package:thae_nge_lay/core/utils/zodiac_helper.dart';
import 'package:thae_nge_lay/features/anniversary/presentation/controllers/anniversary_notifier.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';
import 'package:thae_nge_lay/features/chat/presentation/controllers/unread_messages_controller.dart';
import 'package:thae_nge_lay/features/emergency/presentation/controllers/emergency_controller.dart';
import 'package:thae_nge_lay/features/gifting/presentation/controllers/unseen_gifts_controller.dart';
import 'package:thae_nge_lay/features/gifting/presentation/widgets/gift_selection_sheet.dart';
import 'package:thae_nge_lay/features/home/presentation/controllers/couple_media_controller.dart';
import 'package:thae_nge_lay/features/location/presentation/controllers/partner_location_notifier.dart';
import 'package:thae_nge_lay/features/location_trust/presentation/controllers/partner_movement_status_controller.dart';
import 'package:thae_nge_lay/features/notifications/data/services/fcm_notification_service.dart';

/// 1. Full-Bleed Shared Couple Photo Hero Header (Top 42%)
class FullBleedCoupleHero extends ConsumerWidget {
  const FullBleedCoupleHero({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = ref.watch(coupleMediaProvider);
    final heroHeight = 0.40.sh;

    return Stack(
      children: [
        // Shared Couple Photo
        Container(
          height: heroHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: getCustomImageProvider(media.coverPhotoPath),
              fit: BoxFit.cover,
            ),
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
    );
  }
}

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

              // Centered Interactive Beating Heart with Haptic & Floating Hearts Micro-Interaction
              const InteractiveDashboardHeart(),
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

/// 3. Live Partner Trust Pill (Location & Battery Status)
class LivePartnerTrustPill extends ConsumerWidget {
  final VoidCallback onTap;

  const LivePartnerTrustPill({super.key, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(partnerLocationProvider);
    final media = ref.watch(coupleMediaProvider);

    return GlassmorphicCard(
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
                backgroundImage: getCustomImageProvider(media.partnerAvatarPath),
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
    );
  }
}

/// 4. Partner Birthday Glass Card
class PartnerBirthdayGlassCard extends ConsumerWidget {
  const PartnerBirthdayGlassCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = ref.watch(coupleMediaProvider);
    final daysUntil = ZodiacHelper.getDaysUntilBirthday(media.partnerBirthday);
    final zodiac = ZodiacHelper.getZodiac(media.partnerBirthday);
    final dateFormatted = DateFormat('MMMM d').format(media.partnerBirthday);

    return GlassmorphicCard(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: BelieveColors.romanticSunsetGradient,
                ),
                child: const Icon(
                  LucideIcons.cake,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${media.partnerName}\'s Birthday',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: BelieveColors.textPrimary,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: media.partnerBirthday,
                              firstDate: DateTime(1980),
                              lastDate: DateTime(2035),
                            );
                            if (picked != null) {
                              ref
                                  .read(coupleMediaProvider.notifier)
                                  .updatePartnerBirthday(picked);
                            }
                          },
                          child: const Icon(
                            LucideIcons.edit3,
                            size: 14,
                            color: BelieveColors.primary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '$dateFormatted • ${zodiac.symbol} ${zodiac.name}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        color: BelieveColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Zodiac Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: BelieveColors.primarySoft,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: BelieveColors.glassBorder),
                ),
                child: Text(
                  '${zodiac.emoji} ${zodiac.name}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: BelieveColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Countdown banner
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: BelieveColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: BelieveColors.glassBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    daysUntil == 0
                        ? '🎉 Today is ${media.partnerName}\'s Birthday!'
                        : '🎂 Birthday countdown: In $daysUntil Days!',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: BelieveColors.textPrimary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => GiftSelectionSheet.show(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      gradient: BelieveColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'Send Gift 🎁',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
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

/// 5. Anniversary Milestone Glass Card
class AnniversaryMilestoneGlassCard extends ConsumerWidget {
  final VoidCallback onTapAdd;

  const AnniversaryMilestoneGlassCard({super.key, required this.onTapAdd});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(anniversaryProvider);
    final next = state.nextMilestone;
    final daysUntil = state.daysUntilNextMilestone ?? 0;

    return GlassmorphicCard(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: BelieveColors.coupleLoveGradient,
                ),
                child: const Icon(
                  LucideIcons.heart,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      next != null ? next.title : 'Anniversary Milestone',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: BelieveColors.textPrimary,
                      ),
                    ),
                    Text(
                      'In $daysUntil Days • Sacred Bond',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        color: BelieveColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Add milestone button
              IconButton(
                icon: const Icon(LucideIcons.plus, color: BelieveColors.primary),
                onPressed: onTapAdd,
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Progress indicator bar towards next milestone
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: LinearProgressIndicator(
              value: (1.0 - (daysUntil / 365.0)).clamp(0.1, 1.0),
              minHeight: 6.h,
              backgroundColor: BelieveColors.primarySoft,
              valueColor: const AlwaysStoppedAnimation(BelieveColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

/// 6. Floating Glass Bottom Navigation Bar / Romantic Bottom Nav Bar with Real-Time Indicators
class FloatingGlassNavBar extends ConsumerStatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const FloatingGlassNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  ConsumerState<FloatingGlassNavBar> createState() => _FloatingGlassNavBarState();
}

class _FloatingGlassNavBarState extends ConsumerState<FloatingGlassNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unreadMessagesCount = ref.watch(unreadMessagesProvider);
    final unseenGiftsCount = ref.watch(unseenGiftsProvider);
    final movementState = ref.watch(partnerMovementStatusProvider);

    final tabs = [
      (icon: LucideIcons.heart, label: 'Us'),
      (icon: LucideIcons.messageCircle, label: 'Love Chat'),
      (
        icon: LucideIcons.mapPin,
        label: movementState.isMoving ? 'Moving' : 'Where You Are'
      ),
      (icon: LucideIcons.gift, label: 'Surprise Gift'),
    ];

    final safeAreaBottom = MediaQuery.paddingOf(context).bottom;

    return GlassmorphicCard(
      borderRadius: 36.r,
      margin: EdgeInsets.fromLTRB(
        20.w,
        0,
        20.w,
        safeAreaBottom > 0 ? safeAreaBottom : 16.h,
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      surfaceColor: Colors.white.withValues(alpha: 0.9),
      borderColor: BelieveColors.glassBorder,
      borderWidth: 1.5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabs.length, (index) {
          final isSelected = widget.selectedIndex == index;
          final tab = tabs[index];

          return GestureDetector(
            onTap: () {
              // Automatically clear relevant badges on tap
              if (index == 1) {
                ref.read(unreadMessagesProvider.notifier).markAsRead();
              } else if (index == 3) {
                ref.read(unseenGiftsProvider.notifier).markGiftsAsSeen();
              }
              widget.onTabSelected(index);
            },
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 14.w : 8.w,
                vertical: 8.h,
              ),
              decoration: BoxDecoration(
                gradient: isSelected ? BelieveColors.primaryGradient : null,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Row(
                children: [
                  _buildTabIcon(
                    index: index,
                    icon: tab.icon,
                    isSelected: isSelected,
                    unreadMessagesCount: unreadMessagesCount,
                    unseenGiftsCount: unseenGiftsCount,
                    movementState: movementState,
                  ),
                  if (isSelected) ...[
                    SizedBox(width: 6.w),
                    Text(
                      tab.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabIcon({
    required int index,
    required IconData icon,
    required bool isSelected,
    required int unreadMessagesCount,
    required int unseenGiftsCount,
    required PartnerMovementStatusState movementState,
  }) {
    final baseIcon = Icon(
      icon,
      size: 18.r,
      color: isSelected ? Colors.white : BelieveColors.textMuted,
    );

    // Tab 1: Whisper / Love Chat -> Pulsing Soft Rose-Pink Badge (#E84A7F)
    if (index == 1) {
      if (unreadMessagesCount <= 0) return baseIcon;

      return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          baseIcon,
          Positioned(
            top: -6.h,
            right: -8.w,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 0.90 + (_pulseController.value * 0.18);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
                    constraints: BoxConstraints(minWidth: 16.r, minHeight: 16.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE84A7F),
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE84A7F)
                              .withValues(alpha: 0.45 * _pulseController.value),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        unreadMessagesCount > 99 ? '99+' : '$unreadMessagesCount',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    // Tab 2: Close to You / Location -> Live Movement Indicator Pill
    if (index == 2) {
      if (!movementState.isMoving) return baseIcon;

      return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          baseIcon,
          Positioned(
            top: -10.h,
            right: -24.w,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981)
                            .withValues(alpha: 0.4 * _pulseController.value),
                        blurRadius: 4,
                        spreadRadius: 0.5,
                      ),
                    ],
                  ),
                  child: Text(
                    '🚗 Moving',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    // Tab 3: Moments / Surprise Gift -> Sparkling Gold/Ruby Gift Box Badge (🎁)
    if (index == 3) {
      if (unseenGiftsCount <= 0) return baseIcon;

      return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          baseIcon,
          Positioned(
            top: -8.h,
            right: -10.w,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 0.90 + (_pulseController.value * 0.22);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    padding: EdgeInsets.all(2.r),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFE11D48)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700)
                              .withValues(alpha: 0.6 * _pulseController.value),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Text(
                      '🎁',
                      style: TextStyle(fontSize: 9.sp),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    return baseIcon;
  }
}

/// Typedef so both naming conventions (RomanticBottomNavBar & FloatingGlassNavBar) are 100% supported
typedef RomanticBottomNavBar = FloatingGlassNavBar;

class _FloatingHeartParticle {
  final int id;
  final String emoji;
  final double dx;
  final double dy;
  final double scale;

  _FloatingHeartParticle({
    required this.id,
    required this.emoji,
    required this.dx,
    required this.dy,
    required this.scale,
  });
}

/// Interactive Beating Heart with Haptics, Spring Bounce, Floating Hearts & WebSocket Ping
class InteractiveDashboardHeart extends ConsumerStatefulWidget {
  const InteractiveDashboardHeart({super.key});

  @override
  ConsumerState<InteractiveDashboardHeart> createState() =>
      _InteractiveDashboardHeartState();
}

class _InteractiveDashboardHeartState
    extends ConsumerState<InteractiveDashboardHeart>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _burstController;
  late Animation<double> _scaleAnimation;
  Timer? _hapticTimer;
  Timer? _cleanupTimer;

  final List<_FloatingHeartParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.35)
            .chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.35, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInQuad)),
        weight: 60,
      ),
    ]).animate(_burstController);
  }

  @override
  void dispose() {
    _hapticTimer?.cancel();
    _cleanupTimer?.cancel();
    _pulseController.dispose();
    _burstController.dispose();
    super.dispose();
  }

  void _onHeartTapped() {
    // 1. Double Heartbeat Haptic Feedback (Lub-Dub)
    HapticFeedback.heavyImpact();
    _hapticTimer?.cancel();
    _hapticTimer = Timer(
      const Duration(milliseconds: 140),
      () => HapticFeedback.mediumImpact(),
    );

    // 2. Burst bounce animation
    _burstController.forward(from: 0.0);

    // 3. Spawn floating heart particles
    final emojis = ['💖', '💕', '💓', '❤️', '✨', '💘', '🥰'];
    setState(() {
      for (int i = 0; i < 6; i++) {
        _particles.add(
          _FloatingHeartParticle(
            id: DateTime.now().microsecondsSinceEpoch + i,
            emoji: emojis[_random.nextInt(emojis.length)],
            dx: (_random.nextDouble() - 0.5) * 80.w,
            dy: -(_random.nextDouble() * 90.h + 30.h),
            scale: 0.8 + _random.nextDouble() * 0.6,
          ),
        );
      }
    });

    _cleanupTimer?.cancel();
    _cleanupTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() {
          _particles.clear();
        });
      }
    });

    // 4. Send WebSocket Event to Partner
    final media = ref.read(coupleMediaProvider);
    final user = ref.read(authStateProvider);
    final senderName = user?.displayName ?? 'You';

    ref.read(webSocketSyncServiceProvider).sendEvent(
      event: 'HEART_PING',
      data: {
        'sender': senderName,
        'partnerName': media.partnerName,
        'message': '❤️ Sent a sweet Heart Ping! Thinking of you!',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    // 5. In-App Notification & SnackBar
    ref.read(fcmNotificationServiceProvider).triggerTextMessagePush(
      senderName: senderName,
      previewText: '❤️ Sent a Love Ping to ${media.partnerName}!',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: const BorderSide(color: BelieveColors.glassBorder),
        ),
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.r),
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
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                '❤️ Heart Ping sent to ${media.partnerName}! Thinking of you...',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: BelieveColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Floating Heart Particles Layer
        ..._particles.map((p) {
          return TweenAnimationBuilder<double>(
            key: ValueKey(p.id),
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1200),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(p.dx * value, p.dy * value),
                child: Opacity(
                  opacity: (1.0 - value).clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: p.scale * (1.0 + (value * 0.3)),
                    child: Text(
                      p.emoji,
                      style: TextStyle(fontSize: 18.sp),
                    ),
                  ),
                ),
              );
            },
          );
        }),

        // Interactive Beating Heart Button
        GestureDetector(
          onTap: _onHeartTapped,
          behavior: HitTestBehavior.opaque,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: BelieveColors.glassBorder, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: BelieveColors.primary.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.85, end: 1.15).animate(
                    CurvedAnimation(
                      parent: _pulseController,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: const Icon(
                    LucideIcons.heart,
                    color: BelieveColors.primary,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
