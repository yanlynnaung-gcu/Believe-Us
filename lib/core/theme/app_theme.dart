import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';

abstract final class BelieveTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: BelieveColors.primary,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      scaffoldBackgroundColor: BelieveColors.background,
      colorScheme: const ColorScheme.light(
        primary: BelieveColors.primary,
        onPrimary: Colors.white,
        secondary: BelieveColors.accentLavender,
        onSecondary: Colors.white,
        surface: BelieveColors.surface,
        onSurface: BelieveColors.textPrimary,
        error: BelieveColors.error,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 34.sp,
          fontWeight: FontWeight.w800,
          color: BelieveColors.textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 28.sp,
          fontWeight: FontWeight.w700,
          color: BelieveColors.textPrimary,
          letterSpacing: -0.4,
        ),
        headlineLarge: GoogleFonts.playfairDisplay(
          fontSize: 24.sp,
          fontWeight: FontWeight.w700,
          color: BelieveColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          color: BelieveColors.textPrimary,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: BelieveColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
          color: BelieveColors.textPrimary,
          height: 1.4,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 13.sp,
          fontWeight: FontWeight.w400,
          color: BelieveColors.textSecondary,
          height: 1.4,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: BelieveColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: BelieveColors.textPrimary,
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        iconTheme: const IconThemeData(color: BelieveColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.85),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
          side: const BorderSide(color: BelieveColors.glassBorder, width: 1.5),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: BelieveColors.primary,
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, 52.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: BelieveColors.primary,
          minimumSize: Size(double.infinity, 52.h),
          side: const BorderSide(color: BelieveColors.glassBorder, width: 1.5),
          backgroundColor: Colors.white.withValues(alpha: 0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.75),
        contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 15.h),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: BelieveColors.textMuted,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: const BorderSide(color: BelieveColors.glassBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: const BorderSide(color: BelieveColors.primary, width: 2),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
      ),
    );
  }
}
