import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';
import 'package:thae_nge_lay/features/notifications/domain/models/couple_notification.dart';

/// Interactive Push Notification Test Hub card on home dashboard
class WdPushTestHub extends StatelessWidget {
  final int alertsCount;
  final VoidCallback onOpenHistory;
  final void Function(NotificationType type) onTriggerTestPush;

  const WdPushTestHub({
    super.key,
    required this.alertsCount,
    required this.onOpenHistory,
    required this.onTriggerTestPush,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                  onTap: onOpenHistory,
                  child: Text(
                    '$alertsCount alerts',
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
                  onTap: () => onTriggerTestPush(NotificationType.textMessage),
                ),
                _TestPushChip(
                  label: '🎙️ Voice Push',
                  onTap: () => onTriggerTestPush(NotificationType.voiceMessage),
                ),
                _TestPushChip(
                  label: '🎁 KPay/Wave Gift',
                  onTap: () => onTriggerTestPush(NotificationType.giftReceived),
                ),
                _TestPushChip(
                  label: '📍 Location Check-In',
                  onTap: () => onTriggerTestPush(NotificationType.locationArrival),
                ),
                _TestPushChip(
                  label: '💍 Anniversary Alert',
                  onTap: () => onTriggerTestPush(NotificationType.anniversaryReminder),
                ),
              ],
            ),
          ],
        ),
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
