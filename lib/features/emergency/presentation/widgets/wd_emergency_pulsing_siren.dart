import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class WdEmergencyPulsingSiren extends StatelessWidget {
  final AnimationController pulseController;
  final bool isSender;
  final String senderName;
  final String partnerName;

  const WdEmergencyPulsingSiren({
    super.key,
    required this.pulseController,
    required this.isSender,
    required this.senderName,
    required this.partnerName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 12.h),
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
        ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1.15).animate(
            CurvedAnimation(
              parent: pulseController,
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
      ],
    );
  }
}
