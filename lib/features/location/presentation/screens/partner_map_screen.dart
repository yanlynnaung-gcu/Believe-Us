import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';
import 'package:thae_nge_lay/core/utils/image_provider_helper.dart';
import 'package:thae_nge_lay/features/home/presentation/controllers/couple_media_controller.dart';
import 'package:thae_nge_lay/features/location/presentation/controllers/partner_location_notifier.dart';

class PartnerMapScreen extends ConsumerStatefulWidget {
  const PartnerMapScreen({super.key});

  @override
  ConsumerState<PartnerMapScreen> createState() => _PartnerMapScreenState();
}

class _PartnerMapScreenState extends ConsumerState<PartnerMapScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _sendCheckInAlert() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
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
                '❤️ Arrival Alert & Check-In pushed to your partner\'s device!',
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
    final partner = ref.watch(partnerLocationProvider);
    final media = ref.watch(coupleMediaProvider);

    return Scaffold(
      backgroundColor: BelieveColors.background,
      appBar: AppBar(
        title: Text(
          'Where You Are ✨',
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
      body: Stack(
        children: [
          // Pastel-Styled Romantic Map Grid Canvas
          Positioned.fill(
            child: Container(
              color: const Color(0xFFFAF5F2),
              child: CustomPaint(
                painter: _PastelMapPainter(),
              ),
            ),
          ),

          // Dashed Romantic Heart Connecting Curve
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _CoupleDashedRoutePainter(
                    progress: _waveController.value,
                  ),
                );
              },
            ),
          ),

          // Floating Distance Badge in Center of the Curve
          Positioned(
            top: 0.38.sh,
            left: 0,
            right: 0,
            child: Center(
              child: GlassmorphicCard(
                borderRadius: 24.r,
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                surfaceColor: Colors.white.withValues(alpha: 0.95),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.heart,
                      size: 14,
                      color: BelieveColors.primary,
                    )
                        .animate(
                            onPlay: (controller) =>
                                controller.repeat(reverse: true))
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1.2, 1.2),
                          duration: 800.ms,
                        ),
                    SizedBox(width: 8.w),
                    Text(
                      '${partner.distanceKm ?? 0} km apart',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: BelieveColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Partner Heart Avatar Marker (Top - Mandalay)
          Positioned(
            top: 70.h,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  GlassmorphicCard(
                    borderRadius: 16.r,
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${media.partnerName} • ${partner.placeName}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: BelieveColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Glowing Rose-Pink Heart Frame Marker
                  _HeartAvatarMarker(
                    imagePath: media.partnerAvatarPath,
                    borderColor: BelieveColors.primary,
                    badgeIcon: LucideIcons.heart,
                  ),
                ],
              ),
            ),
          ),

          // User Heart Avatar Marker (Bottom - Yangon)
          Positioned(
            bottom: 200.h,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  _HeartAvatarMarker(
                    imagePath: media.userAvatarPath,
                    borderColor: BelieveColors.accentLavender,
                    badgeIcon: LucideIcons.navigation,
                  ),
                  SizedBox(height: 8.h),
                  GlassmorphicCard(
                    borderRadius: 16.r,
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    child: Text(
                      'You • Yangon, Myanmar',
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
          ),

          // Bottom Floating Glass Control Card
          Positioned(
            bottom: 24.h,
            left: 20.w,
            right: 20.w,
            child: GlassmorphicCard(
              padding: EdgeInsets.all(20.r),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Distance Between Your Hearts',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.sp,
                              color: BelieveColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${partner.distanceKm ?? 0} km',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.w900,
                              color: BelieveColors.primary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: BelieveColors.primarySoft,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              partner.isCharging
                                  ? LucideIcons.batteryCharging
                                  : LucideIcons.battery,
                              size: 15,
                              color: BelieveColors.success,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '${partner.batteryLevel}% Battery',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: BelieveColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),

                  // Push Check-In Alert Button
                  GestureDetector(
                    onTap: _sendCheckInAlert,
                    child: Container(
                      height: 50.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: BelieveColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: BelieveColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              LucideIcons.bell,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Send Arrival Alert & Check-In',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeartAvatarMarker extends StatelessWidget {
  final String imagePath;
  final Color borderColor;
  final IconData badgeIcon;

  const _HeartAvatarMarker({
    required this.imagePath,
    required this.borderColor,
    required this.badgeIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 72.w,
          height: 72.w,
          padding: EdgeInsets.all(4.r),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: borderColor, width: 3),
            boxShadow: [
              BoxShadow(
                color: borderColor.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: CircleAvatar(
            backgroundImage: getCustomImageProvider(imagePath),
          ),
        ),
        Positioned(
          bottom: -4,
          right: -4,
          child: Container(
            padding: EdgeInsets.all(5.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: borderColor,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(badgeIcon, size: 12, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _PastelMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFFF0EAE4)
      ..strokeWidth = 1.0;

    const step = 44.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CoupleDashedRoutePainter extends CustomPainter {
  final double progress;

  _CoupleDashedRoutePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Offset(size.width * 0.5, size.height * 0.22);
    final p2 = Offset(size.width * 0.5, size.height * 0.62);
    final control = Offset(size.width * 0.78, size.height * 0.42);

    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..quadraticBezierTo(control.dx, control.dy, p2.dx, p2.dy);

    final pathPaint = Paint()
      ..color = BelieveColors.primary.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawPath(path, pathPaint);

    // Glowing heart moving along the curve
    final t = progress;
    final heartX =
        (1 - t) * (1 - t) * p1.dx + 2 * (1 - t) * t * control.dx + t * t * p2.dx;
    final heartY =
        (1 - t) * (1 - t) * p1.dy + 2 * (1 - t) * t * control.dy + t * t * p2.dy;

    final dotPaint = Paint()
      ..color = BelieveColors.primary
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(heartX, heartY), 8, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _CoupleDashedRoutePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
