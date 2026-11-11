import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/router/route_names.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';

class WdLoginSignInTab extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onLogin;

  const WdLoginSignInTab({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.onLogin,
  });

  @override
  State<WdLoginSignInTab> createState() => _WdLoginSignInTabState();
}

class _WdLoginSignInTabState extends State<WdLoginSignInTab> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      padding: EdgeInsets.all(22.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Back, My Love',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: BelieveColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Sign in with password to reunite with your partner',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              color: BelieveColors.textSecondary,
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            'Email Address',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: BelieveColors.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          TextField(
            controller: widget.emailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.plusJakartaSans(fontSize: 14.sp),
            decoration: InputDecoration(
              prefixIcon: const Icon(LucideIcons.mail, size: 18),
              hintText: 'e.g. koko@gmail.com',
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            'Password',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: BelieveColors.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          TextField(
            controller: widget.passwordController,
            obscureText: _obscurePassword,
            style: GoogleFonts.plusJakartaSans(fontSize: 14.sp),
            decoration: InputDecoration(
              prefixIcon: const Icon(LucideIcons.lock, size: 18),
              hintText: 'Enter your password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                  size: 18,
                  color: BelieveColors.textMuted,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
          ),
          SizedBox(height: 8.h),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                final currentEmail = widget.emailController.text.trim();
                context.push(AppRoutes.forgotPassword, extra: currentEmail);
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Forgot Password?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: BelieveColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(height: 18.h),
          GestureDetector(
            onTap: widget.isLoading ? null : widget.onLogin,
            child: Container(
              height: 52.h,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: BelieveColors.primaryGradient,
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: BelieveColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            LucideIcons.heartHandshake,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 8.w),
                          Flexible(
                            child: Text(
                              'Sign In With Love 💕',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
