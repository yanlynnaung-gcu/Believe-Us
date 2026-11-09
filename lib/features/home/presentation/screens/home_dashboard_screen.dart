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
import 'package:thae_nge_lay/features/chat/presentation/controllers/unread_messages_controller.dart';
import 'package:thae_nge_lay/features/chat/presentation/screens/chat_screen.dart';
import 'package:thae_nge_lay/features/emergency/presentation/controllers/emergency_controller.dart';
import 'package:thae_nge_lay/features/gifting/presentation/controllers/unseen_gifts_controller.dart';
import 'package:thae_nge_lay/features/gifting/presentation/widgets/gift_selection_sheet.dart';
import 'package:thae_nge_lay/features/home/presentation/widgets/home_redesign_widgets.dart';
import 'package:thae_nge_lay/features/location/presentation/controllers/partner_location_notifier.dart';
import 'package:thae_nge_lay/features/location_trust/presentation/screens/partner_location_detail_screen.dart';
import 'package:thae_nge_lay/features/notifications/data/services/fcm_notification_service.dart';
import 'package:thae_nge_lay/features/notifications/domain/models/couple_notification.dart';
import 'package:thae_nge_lay/features/notifications/presentation/controllers/notification_notifier.dart';

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() =>
      _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {
  int _currentTabIndex = 0;

  void _triggerTestPush(NotificationType type) {
    final fcm = ref.read(fcmNotificationServiceProvider);
    final partner = ref.read(partnerLocationProvider);

    switch (type) {
      case NotificationType.textMessage:
        fcm.triggerTextMessagePush(
          senderName: 'My Love',
          previewText: 'Thinking about holding your hand right now ❤️',
        );
        break;
      case NotificationType.voiceMessage:
        fcm.triggerVoiceMessagePush(
          senderName: 'My Love',
          durationSeconds: 8,
        );
        break;
      case NotificationType.giftReceived:
        fcm.triggerGiftReceivedPush(
          senderName: 'My Love',
          provider: 'KBZPay',
          amount: '50,000 MMK',
        );
        break;
      case NotificationType.locationArrival:
        fcm.triggerLocationArrivalPush(
          partnerName: 'My Love',
          placeName: partner.placeName,
        );
        break;
      case NotificationType.anniversaryReminder:
        fcm.triggerAnniversaryReminderPush(
          title: 'The Day We Said Yes',
          daysRemaining: 14,
        );
        break;
    }
  }

  void _showNotificationHistory(BuildContext context) {
    final history = ref.read(fcmNotificationServiceProvider).history;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: BelieveColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          ),
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: BelieveColors.border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Couple Push Notifications',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: BelieveColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${history.length} alerts',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      color: BelieveColors.textMuted,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              if (history.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 36.h),
                  child: Center(
                    child: Text(
                      'No push notifications received yet.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.sp,
                        color: BelieveColors.textMuted,
                      ),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 10.h),
                        padding: EdgeInsets.all(14.r),
                        decoration: BoxDecoration(
                          color: BelieveColors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: BelieveColors.glassBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: BelieveColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              item.body,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.sp,
                                color: BelieveColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider);

    // In-App Notification Banner Listener
    ref.listen<AsyncValue<CoupleNotification>>(
      notificationProvider,
      (prev, next) {
        next.whenData((notif) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.white,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.r),
                side: const BorderSide(color: BelieveColors.glassBorder),
              ),
              content: Row(
                children: [
                  Container(
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
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          notif.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w800,
                            color: BelieveColors.textPrimary,
                          ),
                        ),
                        Text(
                          notif.body,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.sp,
                            color: BelieveColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );

    ref.listen<EmergencyState>(emergencyControllerProvider, (prev, next) {
      if (next.isAlarmActive && (prev == null || !prev.isAlarmActive)) {
        context.push(AppRoutes.emergencyAlarm, extra: next.activeAlert);
      }
    });

    final safeAreaBottom = MediaQuery.paddingOf(context).bottom;
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    final isKeyboardOpen = keyboardHeight > 0;
    const bottomNavHeight = 76.0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: BelieveColors.background,
      body: Stack(
        children: [
          // Screen View based on current tab
          IndexedStack(
            index: _currentTabIndex,
            children: [
              // TAB 0: "Us" (Home Sanctuary)
              _buildUsSanctuaryView(
                context,
                user?.partnerId,
                user?.coupleSpaceId,
                bottomNavHeight: bottomNavHeight,
                safeAreaBottom: safeAreaBottom,
              ),

              // TAB 1: "Love Chat"
              const ChatScreen(
                hasBottomNavBar: true,
                bottomNavHeight: bottomNavHeight,
              ),

              // TAB 2: "Where You Are" -> Partner Location Detail Screen
              const PartnerLocationDetailScreen(),

              // TAB 3: Gift & Surprise Shop
              _buildGiftShopPreviewView(context),
            ],
          ),

          // Floating Glass Bottom Navigation Bar with Smart Auto-Hide on Keyboard
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSlide(
              offset: isKeyboardOpen ? const Offset(0, 1.4) : Offset.zero,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: AnimatedOpacity(
                opacity: isKeyboardOpen ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: IgnorePointer(
                  ignoring: isKeyboardOpen,
                  child: FloatingGlassNavBar(
                    selectedIndex: _currentTabIndex,
                    onTabSelected: (index) {
                      if (index == 1) {
                        ref.read(unreadMessagesProvider.notifier).markAsRead();
                        setState(() => _currentTabIndex = index);
                      } else if (index == 2) {
                        // Direct navigation to dedicated Partner Location Details Screen
                        context.push(AppRoutes.locationDetails);
                      } else if (index == 3) {
                        ref.read(unseenGiftsProvider.notifier).markGiftsAsSeen();
                        // Direct Gift Selection Sheet
                        GiftSelectionSheet.show(context);
                      } else {
                        setState(() => _currentTabIndex = index);
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsSanctuaryView(
    BuildContext context,
    String? partnerId,
    String? coupleSpaceId, {
    required double bottomNavHeight,
    required double safeAreaBottom,
  }) {
    final history = ref.watch(fcmNotificationServiceProvider).history;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: bottomNavHeight + safeAreaBottom + 24.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Full-Bleed Shared Couple Photo Hero Header (Top 42%)
          const FullBleedCoupleHero(),

          // 2. Interlocking Dual Avatars (Overlapping Hero)
          Transform.translate(
            offset: Offset(0, -32.h),
            child: const InterlockingDualAvatars(),
          ),

          // 3. Live Partner Trust Pill -> Tap to open Partner Location Details
          LivePartnerTrustPill(
            onTap: () => context.push(AppRoutes.locationDetails),
          ),

          // 4. Partner Birthday Glass Card
          const PartnerBirthdayGlassCard(),

          // 5. Anniversary Milestone Glass Card
          AnniversaryMilestoneGlassCard(
            onTapAdd: () => context.push(AppRoutes.anniversary),
          ),

          SizedBox(height: 12.h),

          // Quick Action Cards
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Expanded(
                  child: GlassmorphicCard(
                    padding: EdgeInsets.all(16.r),
                    onTap: () => setState(() => _currentTabIndex = 1),
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
                    onTap: () => GiftSelectionSheet.show(context),
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
          ),

          SizedBox(height: 16.h),

          // Interactive Push Notification Test Hub
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: GlassmorphicCard(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.bell,
                        color: BelieveColors.primary,
                        size: 16,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Push Notification Engine',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                            color: BelieveColors.textPrimary,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showNotificationHistory(context),
                        child: Text(
                          '${history.length} alerts',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.sp,
                            color: BelieveColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      _TestPushChip(
                        label: '💬 Text Push',
                        onTap: () => _triggerTestPush(NotificationType.textMessage),
                      ),
                      _TestPushChip(
                        label: '🎙️ Voice Push',
                        onTap: () => _triggerTestPush(NotificationType.voiceMessage),
                      ),
                      _TestPushChip(
                        label: '🎁 KPay/Wave Gift',
                        onTap: () => _triggerTestPush(NotificationType.giftReceived),
                      ),
                      _TestPushChip(
                        label: '📍 Location Check-In',
                        onTap: () => _triggerTestPush(NotificationType.locationArrival),
                      ),
                      _TestPushChip(
                        label: '💍 Anniversary Alert',
                        onTap: () =>
                            _triggerTestPush(NotificationType.anniversaryReminder),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // 1-to-1 Bond Confirmation
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: BelieveColors.primarySoft,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: BelieveColors.glassBorder),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.lock,
                    color: BelieveColors.primary,
                    size: 18,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      coupleSpaceId != null
                          ? '1-to-1 Sacred Connection • Space #$coupleSpaceId'
                          : '1-to-1 Sacred Connection • Pending Pairing',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.sp,
                        color: BelieveColors.burgundy,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.settings, size: 16),
                    tooltip: 'Sanctuary Settings & Support',
                    onPressed: () => context.push(AppRoutes.settings),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.logOut, size: 16),
                    tooltip: 'Sign Out',
                    onPressed: () =>
                        ref.read(authStateProvider.notifier).signOut(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftShopPreviewView(BuildContext context) {
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
            child: const Icon(
              LucideIcons.gift,
              size: 48,
              color: Colors.white,
            ),
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
            onPressed: () => GiftSelectionSheet.show(context),
            child: const Text('Open Gift Selection Sheet ✨'),
          ),
        ],
      ),
    );
  }
}

class _TestPushChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TestPushChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: BelieveColors.glassBorder),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: BelieveColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
