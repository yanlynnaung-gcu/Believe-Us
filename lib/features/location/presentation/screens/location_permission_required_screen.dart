import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';
import 'package:thae_nge_lay/features/location/presentation/controllers/location_permission_controller.dart';

class LocationPermissionRequiredScreen extends ConsumerStatefulWidget {
  const LocationPermissionRequiredScreen({super.key});

  @override
  ConsumerState<LocationPermissionRequiredScreen> createState() =>
      _LocationPermissionRequiredScreenState();
}

class _LocationPermissionRequiredScreenState
    extends ConsumerState<LocationPermissionRequiredScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onRequestPermission() async {
    setState(() => _isRequesting = true);
    final granted = await ref
        .read(locationPermissionControllerProvider.notifier)
        .requestLocationPermission();
    if (mounted) {
      setState(() => _isRequesting = false);
      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission or GPS is still disabled. Please enable it in Settings to continue.',
            ),
            backgroundColor: BelieveColors.error,
          ),
        );
      }
    }
  }

  void _onSimulatorBypass() async {
    await ref
        .read(locationPermissionControllerProvider.notifier)
        .grantSimulatedPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BelieveColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pulsing Radar / Pin Container
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 190.w * (0.8 + 0.2 * _pulseController.value),
                        height: 190.w * (0.8 + 0.2 * _pulseController.value),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: BelieveColors.primary
                              .withValues(alpha: 0.15 * (1 - _pulseController.value)),
                        ),
                      ),
                      Container(
                        width: 130.w,
                        height: 130.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: BelieveColors.romanticSunsetGradient,
                          boxShadow: [
                            BoxShadow(
                              color: BelieveColors.primary.withValues(alpha: 0.3),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            LucideIcons.mapPin,
                            size: 52,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 36.h),

              Text(
                'Sacred Presence ✨',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w800,
                  color: BelieveColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 12.h),

              Text(
                'Thae Thae is built on sacred 1-to-1 transparency. The app cannot function without continuous location permission so your partner can always see your distance, arrival alerts, and safety status.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  color: BelieveColors.textSecondary,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 32.h),

              // Security & Privacy Box
              GlassmorphicCard(
                padding: EdgeInsets.all(16.r),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: BelieveColors.success.withValues(alpha: 0.12),
                      ),
                      child: const Icon(
                        LucideIcons.shieldCheck,
                        color: BelieveColors.success,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Your location is encrypted and visible ONLY to your bonded partner. Never shared with third parties.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          color: BelieveColors.textSecondary,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),

              // Primary Action: Enable Location
              GestureDetector(
                onTap: _isRequesting ? null : _onRequestPermission,
                child: Container(
                  height: 54.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: BelieveColors.primaryGradient,
                    borderRadius: BorderRadius.circular(18.r),
                    boxShadow: [
                      BoxShadow(
                        color: BelieveColors.primary.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isRequesting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Enable Location & GPS 💕',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Simulator / Test Bypass Option
              TextButton(
                onPressed: _onSimulatorBypass,
                child: Text(
                  'Continue with Simulated GPS (Dev/Test)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.sp,
                    color: BelieveColors.textMuted,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
