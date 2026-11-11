import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:thae_nge_lay/core/router/route_names.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';
import 'package:thae_nge_lay/features/chat/presentation/controllers/unread_messages_controller.dart';
import 'package:thae_nge_lay/features/chat/presentation/screens/chat_screen.dart';
import 'package:thae_nge_lay/features/emergency/presentation/controllers/emergency_controller.dart';
import 'package:thae_nge_lay/features/gifting/presentation/controllers/unseen_gifts_controller.dart';
import 'package:thae_nge_lay/features/gifting/presentation/widgets/gift_selection_sheet.dart';
import 'package:thae_nge_lay/features/home/presentation/widgets/home_redesign_widgets.dart';
import 'package:thae_nge_lay/features/home/presentation/widgets/wd_gift_shop_preview.dart';
import 'package:thae_nge_lay/features/home/presentation/widgets/wd_quick_actions_row.dart';
import 'package:thae_nge_lay/features/location_trust/presentation/screens/partner_location_detail_screen.dart';

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final partnerId = ref.watch(authStateProvider.select((u) => u?.partnerId));
    final coupleSpaceId = ref.watch(authStateProvider.select((u) => u?.coupleSpaceId));

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
        ],
      ),
    );
  }
}
