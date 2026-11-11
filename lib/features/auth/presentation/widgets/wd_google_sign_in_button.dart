import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';

class WdGoogleSignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onGoogleSignIn;

  const WdGoogleSignInButton({
    super.key,
    required this.isLoading,
    required this.onGoogleSignIn,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'OR',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: BelieveColors.textMuted,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        SizedBox(height: 18.h),
        GlassmorphicCard(
          borderRadius: 20.r,
          padding: EdgeInsets.symmetric(vertical: 13.h),
          onTap: isLoading ? null : onGoogleSignIn,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24.w,
                height: 24.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Center(
                  child: Text(
                    'G',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF4285F4),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Flexible(
                child: Text(
                  'Continue with Google Account',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: BelieveColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: BelieveColors.primarySoft,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: BelieveColors.glassBorder),
          ),
          child: Row(
            children: [
              const Icon(
                LucideIcons.shieldCheck,
                color: BelieveColors.primary,
                size: 20,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  '100% Private & Free. BCrypt password hashing & secure couple authentication. Only you and your connected partner share this space.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.sp,
                    color: BelieveColors.burgundy,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 28.h),
      ],
    );
  }
}
