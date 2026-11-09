import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/router/route_names.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';
import 'package:thae_nge_lay/core/utils/image_provider_helper.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';
import 'package:thae_nge_lay/features/home/presentation/controllers/couple_media_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);
    final media = ref.watch(coupleMediaProvider);

    return Scaffold(
      backgroundColor: BelieveColors.background,
      appBar: AppBar(
        title: Text(
          'Settings & Sanctuary ✨',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: BelieveColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Couple Profile Header Card
            GlassmorphicCard(
              padding: EdgeInsets.all(18.r),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 28.r,
                        backgroundImage:
                            getCustomImageProvider(media.userAvatarPath),
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
                          user?.displayName ?? 'You',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: BelieveColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Paired with ${media.partnerName} ❤️',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
                            color: BelieveColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Space #${user?.coupleSpaceId ?? "space_thae"}',
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
            ),

            SizedBox(height: 24.h),

            // Section: Support & Contact (Prominently featured)
            Text(
              'Support & Love Concierge',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                color: BelieveColors.textPrimary,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: 10.h),

            // Contact Us Navigation Tile
            GlassmorphicCard(
              onTap: () => context.push(AppRoutes.contactUs),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: BelieveColors.primaryGradient,
                    ),
                    child: const Icon(
                      LucideIcons.headset,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contact Us',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: BelieveColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Phone, Email, Viber & Facebook Support',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.sp,
                            color: BelieveColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    LucideIcons.chevronRight,
                    color: BelieveColors.textMuted,
                    size: 18,
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Section: Preferences & Features
            Text(
              'Relationship & App Features',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                color: BelieveColors.textPrimary,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: 10.h),

            _SettingsTile(
              icon: LucideIcons.calendarHeart,
              title: 'Anniversary Milestones',
              subtitle: 'Keep track of important love dates',
              onTap: () => context.push(AppRoutes.anniversary),
            ),
            SizedBox(height: 10.h),

            _SettingsTile(
              icon: LucideIcons.mapPin,
              title: 'Live Location & Guard',
              subtitle: 'Smooth WebSocket distance tracking',
              onTap: () => context.push(AppRoutes.map),
            ),
            SizedBox(height: 10.h),

            _SettingsTile(
              icon: LucideIcons.bellRing,
              title: 'Love Notifications',
              subtitle: 'Arrival alerts, anniversary push & notes',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text(
                      'Love notifications are fully enabled and active ❤️',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 28.h),

            // Section: Account & Session
            Text(
              'Account & Security',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                color: BelieveColors.textPrimary,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: 10.h),

            GlassmorphicCard(
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(
                      'Sign Out?',
                      style: GoogleFonts.playfairDisplay(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    content: Text(
                      'Are you sure you want to sign out from your sacred couple space?',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13.sp),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text(
                          'Sign Out',
                          style: TextStyle(color: BelieveColors.error),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  ref.read(authStateProvider.notifier).signOut();
                }
              },
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: BelieveColors.error.withValues(alpha: 0.1),
                    ),
                    child: const Icon(
                      LucideIcons.logOut,
                      color: BelieveColors.error,
                      size: 18,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Text(
                      'Sign Out',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: BelieveColors.error,
                      ),
                    ),
                  ),
                  const Icon(
                    LucideIcons.chevronRight,
                    color: BelieveColors.textMuted,
                    size: 18,
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      onTap: onTap,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: BelieveColors.primarySoft,
            ),
            child: Icon(icon, color: BelieveColors.primary, size: 18),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: BelieveColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.sp,
                    color: BelieveColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            LucideIcons.chevronRight,
            color: BelieveColors.textMuted,
            size: 18,
          ),
        ],
      ),
    );
  }
}
