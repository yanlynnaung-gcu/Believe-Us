import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:thae_nge_lay/core/router/route_names.dart';
import 'package:thae_nge_lay/features/emergency/domain/models/emergency_sos_model.dart';
import 'package:thae_nge_lay/features/emergency/presentation/controllers/emergency_controller.dart';
import 'package:thae_nge_lay/features/emergency/presentation/widgets/wd_emergency_actions_card.dart';
import 'package:thae_nge_lay/features/emergency/presentation/widgets/wd_emergency_location_badge.dart';
import 'package:thae_nge_lay/features/emergency/presentation/widgets/wd_emergency_pulsing_siren.dart';
import 'package:thae_nge_lay/features/home/presentation/controllers/couple_media_controller.dart';

class EmergencyAlarmScreen extends ConsumerStatefulWidget {
  final EmergencySOSModel? alert;

  const EmergencyAlarmScreen({super.key, this.alert});

  @override
  ConsumerState<EmergencyAlarmScreen> createState() =>
      _EmergencyAlarmScreenState();
}

class _EmergencyAlarmScreenState extends ConsumerState<EmergencyAlarmScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _resolveAlert() {
    ref.read(emergencyControllerProvider.notifier).dismissAlert();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final emergencyState = ref.watch(emergencyControllerProvider);
    final activeAlert = widget.alert ?? emergencyState.activeAlert;
    final coupleMedia = ref.watch(coupleMediaProvider);

    final isSender = activeAlert?.isSender ?? true;
    final partnerName = coupleMedia.partnerName.isNotEmpty
        ? coupleMedia.partnerName
        : 'Partner';
    final senderName =
        isSender ? 'You' : (activeAlert?.senderName ?? partnerName);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          HapticFeedback.mediumImpact();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF180305),
        body: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  final glowOpacity = 0.25 + (_pulseController.value * 0.35);
                  return Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.topCenter,
                        radius: 1.2,
                        colors: [
                          Colors.red.withValues(alpha: glowOpacity),
                          const Color(0xFF280205).withValues(alpha: 0.9),
                          const Color(0xFF120002),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    WdEmergencyPulsingSiren(
                      pulseController: _pulseController,
                      isSender: isSender,
                      senderName: senderName,
                      partnerName: partnerName,
                    ),
                    SizedBox(height: 20.h),
                    WdEmergencyLocationBadge(activeAlert: activeAlert),
                    SizedBox(height: 24.h),
                    WdEmergencyActionsCard(
                      isSender: isSender,
                      senderName: senderName,
                      onResolve: _resolveAlert,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
