import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:thae_nge_lay/core/router/route_names.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';
import 'package:thae_nge_lay/features/emergency/domain/models/emergency_sos_model.dart';
import 'package:thae_nge_lay/features/emergency/presentation/controllers/emergency_controller.dart';
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

    // Initial emergency haptic vibration pulse
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _makeCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
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
    final senderName = isSender ? 'You' : (activeAlert?.senderName ?? partnerName);

    return PopScope(
      canPop: false, // Prevent accidental back gestures during active emergency
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          // Require explicit dismiss button tap
          HapticFeedback.mediumImpact();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF180305),
        body: Stack(
          children: [
            // 1. Red Flashing Emergency Radial Glow Backdrop
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
                    SizedBox(height: 12.h),

                    // Urgent Warning Banner
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(
                          color: Colors.redAccent.withValues(alpha: 0.7),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.triangleAlert,
                            color: Colors.redAccent,
                            size: 16,
                          ),
                          SizedBox(width: 8.w),
                          Flexible(
                            child: Text(
                              isSender
                                  ? 'SOS DISTRESS BEACON ACTIVE'
                                  : 'DISTRESS ALERT RECEIVED',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Pulsing Siren Icon Beacon
                    ScaleTransition(
                      scale: Tween<double>(begin: 0.95, end: 1.15).animate(
                        CurvedAnimation(
                          parent: _pulseController,
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: Container(
                        width: 120.r,
                        height: 120.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red.shade900.withValues(alpha: 0.5),
                          border: Border.all(
                            color: Colors.redAccent,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withValues(alpha: 0.6),
                              blurRadius: 30,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            LucideIcons.siren,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Main Status Title
                    Text(
                      isSender
                          ? 'Emergency Alert Sent!'
                          : '🚨 $senderName Needs Immediate Help!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    Text(
                      isSender
                          ? 'Distress broadcast sent to $partnerName via WebSocket & High-Priority Push with your live coordinates.'
                          : 'Real-time GPS coordinates and emergency distress signal broadcast from $senderName.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.sp,
                        color: Colors.white.withValues(alpha: 0.85),
                        height: 1.4,
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Distress Message Card
                    GlassmorphicCard(
                      borderRadius: 16.r,
                      padding: EdgeInsets.all(16.r),
                      surfaceColor: Colors.red.shade900.withValues(alpha: 0.35),
                      borderColor: Colors.redAccent.withValues(alpha: 0.4),
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.messageSquareWarning,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              activeAlert?.message ??
                                  '🚨 EMERGENCY SOS: Immediate assistance required!',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 14.h),

                    // Live Coordinates & Address Card
                    GlassmorphicCard(
                      borderRadius: 16.r,
                      padding: EdgeInsets.all(16.r),
                      surfaceColor: Colors.white.withValues(alpha: 0.08),
                      borderColor: Colors.white.withValues(alpha: 0.15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.mapPin,
                                color: Colors.redAccent,
                                size: 16,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  'Live Incident Location',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 3.h,
                                ),
                                decoration: BoxDecoration(
                                  color: BelieveColors.success.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: BelieveColors.success,
                                  ),
                                ),
                                child: Text(
                                  'High Accuracy GPS',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700,
                                    color: BelieveColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            activeAlert != null
                                ? '${activeAlert.latitude.toStringAsFixed(5)}° N, ${activeAlert.longitude.toStringAsFixed(5)}° E'
                                : '16.82950° N, 96.13050° E',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            activeAlert?.address.isNotEmpty == true
                                ? activeAlert!.address
                                : 'Pyay Road, Kamayut, Yangon',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.sp,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Timestamp: ${DateFormat('h:mm:ss a • d MMM yyyy').format(activeAlert?.timestamp ?? DateTime.now())}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.sp,
                              color: Colors.white38,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Quick Action 1: Call Partner
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          elevation: 6,
                        ),
                        onPressed: () => _makeCall('+959123456789'),
                        icon: const Icon(LucideIcons.phoneCall, size: 20),
                        label: Text(
                          isSender ? 'Direct Call Partner' : 'Call $senderName Immediately',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 10.h),

                    // Quick Action 2: Call Police (199) & View Live Map
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white38),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ),
                            onPressed: () => _makeCall('199'),
                            icon: const Icon(LucideIcons.shieldAlert, size: 18),
                            label: Text(
                              'Call 199 (Police)',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white38),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ),
                            onPressed: () => context.push(AppRoutes.map),
                            icon: const Icon(LucideIcons.map, size: 18),
                            label: Text(
                              'View on Map',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // Dismiss / Resolve SOS Button
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 12.h,
                        ),
                      ),
                      onPressed: () {
                        ref.read(emergencyControllerProvider.notifier).dismissAlert();
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(AppRoutes.home);
                        }
                      },
                      icon: const Icon(LucideIcons.checkCircle, size: 18),
                      label: Text(
                        'I\'m Safe Now • Resolve Alert',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
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
