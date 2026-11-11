import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/router/route_names.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';
import 'package:thae_nge_lay/features/home/presentation/controllers/couple_media_controller.dart';
import 'package:thae_nge_lay/features/settings/presentation/widgets/wd_couple_profile_card.dart';
import 'package:thae_nge_lay/features/settings/presentation/widgets/wd_settings_tile.dart';
import 'package:thae_nge_lay/features/settings/presentation/widgets/wd_sign_out_dialog.dart';

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
            WdCoupleProfileCard(
              userAvatarPath: media.userAvatarPath,
              displayName: user?.displayName ?? 'You',
              partnerName: media.partnerName,
              coupleSpaceId: user?.coupleSpaceId ?? 'space_thae',
            ),
            SizedBox(height: 24.h),
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
            WdSettingsTile(
              icon: LucideIcons.calendarHeart,
              title: 'Anniversary Milestones',
              subtitle: 'Keep track of important love dates',
              onTap: () => context.push(AppRoutes.anniversary),
            ),
            SizedBox(height: 10.h),
            WdSettingsTile(
              icon: LucideIcons.mapPin,
              title: 'Live Location & Guard',
              subtitle: 'Smooth WebSocket distance tracking',
              onTap: () => context.push(AppRoutes.map),
            ),
            SizedBox(height: 10.h),
            WdSettingsTile(
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
                final confirm = await showSignOutDialog(context);
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
