import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/router/route_names.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';
import 'package:thae_nge_lay/features/chat/presentation/controllers/unread_messages_controller.dart';
import 'package:thae_nge_lay/features/chat/presentation/screens/chat_screen.dart';
import 'package:thae_nge_lay/features/emergency/presentation/controllers/emergency_controller.dart';
import 'package:thae_nge_lay/features/gifting/presentation/controllers/unseen_gifts_controller.dart';
import 'package:thae_nge_lay/features/gifting/presentation/widgets/gift_selection_sheet.dart';
import 'package:thae_nge_lay/features/home/presentation/widgets/home_redesign_widgets.dart';
import 'package:thae_nge_lay/features/home/presentation/widgets/wd_couple_bond_banner.dart';
import 'package:thae_nge_lay/features/home/presentation/widgets/wd_gift_shop_preview.dart';
import 'package:thae_nge_lay/features/home/presentation/widgets/wd_notification_history_sheet.dart';
import 'package:thae_nge_lay/features/home/presentation/widgets/wd_push_test_hub.dart';
import 'package:thae_nge_lay/features/home/presentation/widgets/wd_quick_actions_row.dart';
import 'package:thae_nge_lay/features/location/presentation/controllers/partner_location_notifier.dart';
import 'package:thae_nge_lay/features/location_trust/presentation/screens/partner_location_detail_screen.dart';
import 'package:thae_nge_lay/features/notifications/data/services/fcm_notification_service.dart';
import 'package:thae_nge_lay/features/notifications/domain/models/couple_notification.dart';
import 'package:thae_nge_lay/features/notifications/presentation/controllers/notification_notifier.dart';

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {
  int _currentTabIndex = 0;

  void _triggerTestPush(NotificationType type) {
    final fcm = ref.read(fcmNotificationServiceProvider);
    final partner = ref.read(partnerLocationProvider);
    switch (type) {
      case NotificationType.textMessage:
        fcm.triggerTextMessagePush(senderName: 'My Love', previewText: 'Thinking about holding your hand right now ❤️');
        break;
      case NotificationType.voiceMessage:
        fcm.triggerVoiceMessagePush(senderName: 'My Love', durationSeconds: 8);
        break;
      case NotificationType.giftReceived:
        fcm.triggerGiftReceivedPush(senderName: 'My Love', provider: 'KBZPay', amount: '50,000 MMK');
        break;
      case NotificationType.locationArrival:
        fcm.triggerLocationArrivalPush(partnerName: 'My Love', placeName: partner.placeName);
        break;
      case NotificationType.anniversaryReminder:
        fcm.triggerAnniversaryReminderPush(title: 'The Day We Said Yes', daysRemaining: 14);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final partnerId = ref.watch(authStateProvider.select((u) => u?.partnerId));
    final coupleSpaceId = ref.watch(authStateProvider.select((u) => u?.coupleSpaceId));

    ref.listen<AsyncValue<CoupleNotification>>(notificationProvider, (prev, next) {
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
                  decoration: const BoxDecoration(shape: BoxShape.circle, gradient: BelieveColors.primaryGradient),
                  child: const Icon(LucideIcons.heart, color: Colors.white, size: 16),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(notif.title, style: GoogleFonts.plusJakartaSans(fontSize: 12.sp, fontWeight: FontWeight.w800, color: BelieveColors.textPrimary)),
                      Text(notif.body, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 11.sp, color: BelieveColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      });
    });

    ref.listen<EmergencyState>(emergencyControllerProvider, (prev, next) {
      if (next.isAlarmActive && (prev == null || !prev.isAlarmActive)) {
        context.push(AppRoutes.emergencyAlarm, extra: next.activeAlert);
      }
    });

    final safeAreaBottom = MediaQuery.paddingOf(context).bottom;
    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    const bottomNavHeight = 76.0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: BelieveColors.background,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentTabIndex,
            children: [
              _buildUsSanctuaryView(context, partnerId, coupleSpaceId, bottomNavHeight: bottomNavHeight, safeAreaBottom: safeAreaBottom),
              const ChatScreen(hasBottomNavBar: true, bottomNavHeight: bottomNavHeight),
              const PartnerLocationDetailScreen(),
              WdGiftShopPreview(onOpenGiftingSheet: () => GiftSelectionSheet.show(context)),
            ],
          ),
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
                        context.push(AppRoutes.locationDetails);
                      } else if (index == 3) {
                        ref.read(unseenGiftsProvider.notifier).markGiftsAsSeen();
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
    final alertsCount = ref.watch(fcmNotificationServiceProvider.select((s) => s.history.length));

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: bottomNavHeight + safeAreaBottom + 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RepaintBoundary(child: FullBleedCoupleHero()),
          Transform.translate(offset: Offset(0, -32.h), child: const InterlockingDualAvatars()),
          RepaintBoundary(
            child: LivePartnerTrustPill(onTap: () => context.push(AppRoutes.locationDetails)),
          ),
          const PartnerBirthdayGlassCard(),
          AnniversaryMilestoneGlassCard(onTapAdd: () => context.push(AppRoutes.anniversary)),
          SizedBox(height: 12.h),
          WdQuickActionsRow(
            onOpenChat: () => setState(() => _currentTabIndex = 1),
            onOpenGifting: () => GiftSelectionSheet.show(context),
          ),
          SizedBox(height: 16.h),
          WdPushTestHub(
            alertsCount: alertsCount,
            onOpenHistory: () => showNotificationHistorySheet(
              context,
              ref.read(fcmNotificationServiceProvider).history,
            ),
            onTriggerTestPush: _triggerTestPush,
          ),
          SizedBox(height: 16.h),
          WdCoupleBondBanner(
            coupleSpaceId: coupleSpaceId,
            onOpenSettings: () => context.push(AppRoutes.settings),
            onSignOut: () => ref.read(authStateProvider.notifier).signOut(),
          ),
        ],
      ),
    );
  }
}
