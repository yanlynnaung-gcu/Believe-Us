import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';
import 'package:thae_nge_lay/features/chat/presentation/controllers/unread_messages_controller.dart';
import 'package:thae_nge_lay/features/gifting/presentation/controllers/unseen_gifts_controller.dart';
import 'package:thae_nge_lay/features/home/presentation/widgets/wd_nav_tab_icon.dart';
import 'package:thae_nge_lay/features/location_trust/presentation/controllers/partner_movement_status_controller.dart';

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
    final isMoving = ref.watch(partnerMovementStatusProvider.select((s) => s.isMoving));

    final tabs = [
      (icon: LucideIcons.heart, label: 'Us'),
      (icon: LucideIcons.messageCircle, label: 'Love Chat'),
      (
        icon: LucideIcons.mapPin,
        label: isMoving ? 'Moving' : 'Where You Are'
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
                  WdNavTabIcon(
                    index: index,
                    icon: tab.icon,
                    isSelected: isSelected,
                    unreadMessagesCount: unreadMessagesCount,
                    unseenGiftsCount: unseenGiftsCount,
                    isMoving: isMoving,
                    pulseAnimation: _pulseController,
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
}

/// Typedef so both naming conventions (RomanticBottomNavBar & FloatingGlassNavBar) are 100% supported
typedef RomanticBottomNavBar = FloatingGlassNavBar;
