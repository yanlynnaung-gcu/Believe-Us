import 'package:flutter/material.dart';

/// "Thae Thae" - Warm, Romantic, Dreamy Glassmorphism Palette
abstract final class BelieveColors {
  // Primary Romantic Hues
  static const primary = Color(0xFFFF5E7E); // Soft Coral Rose Pink
  static const primaryDark = Color(0xFFE04566);
  static const primaryLight = Color(0xFFFF8FA3);
  static const primarySoft = Color(0xFFFFF0F3); // Soft blush background tint

  // Secondary Romantic Accents & Gradients
  static const blushStart = Color(0xFFFF9A9E); // Romantic Sunset Blush Start
  static const blushEnd = Color(0xFFFECFEF); // Romantic Sunset Blush End
  static const accentLavender = Color(0xFFB892FF); // Dreamy Lavender Accent
  static const roseGold = Color(0xFFF7A8B8);
  static const champagne = Color(0xFFD4AF37); // Gold accent for anniversaries/gifts
  static const burgundy = Color(0xFF781B34); // Deep passionate wine

  // Myanmar Payment Brands
  static const kbzPay = Color(0xFF00377B); // Official KBZPay Deep Blue
  static const wavePay = Color(0xFFFEE100); // Official WavePay Bright Yellow
  static const wavePayDark = Color(0xFFE5C800);

  // Status & Utility
  static const success = Color(0xFF2EB872);
  static const successSoft = Color(0xFFE8F8F0);
  static const warning = Color(0xFFF39C12);
  static const warningSoft = Color(0xFFFEF5E7);
  static const error = Color(0xFFFF4D6D);
  static const errorSoft = Color(0xFFFFF0F3);
  static const info = Color(0xFF5E8BFF);

  // Neutrals (Warm Pearl Blush Light & Deep Velvet Plum Dark)
  static const background = Color(0xFFFFF8FA); // Warm Pearl Blush
  static const surface = Color(0xFFFFFFFF);
  static const glassSurface = Color(0xD9FFFFFF); // 85% opacity white
  static const glassBorder = Color(0xFFFFE3EC); // Soft pink glass border
  static const surfaceSubtle = Color(0xFFFFF2F6);
  static const textPrimary = Color(0xFF2A1B22); // Deep rich plum-black
  static const textSecondary = Color(0xFF7D6B73); // Soft warm mauve
  static const textMuted = Color(0xFFAD9BA3);
  static const border = Color(0xFFFFE3EC);
  static const divider = Color(0xFFF7E6EB);

  // Dark Mode (Deep Velvet Plum)
  static const darkBackground = Color(0xFF1A121B); // Deep Velvet Plum
  static const darkSurface = Color(0xFF261B27);
  static const darkGlassSurface = Color(0xD9261B27);
  static const darkGlassBorder = Color(0xFF402E42);
  static const darkBorder = Color(0xFF38273A);
  static const darkTextPrimary = Color(0xFFFFF2F6);
  static const darkTextSecondary = Color(0xFFCBB7C1);

  // Dreamy Gradients
  static const romanticSunsetGradient = LinearGradient(
    colors: [Color(0xFFFF9A9E), Color(0xFFFECFEF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const primaryGradient = LinearGradient(
    colors: [Color(0xFFFF5E7E), Color(0xFFFF8FA3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const dreamyHeroGradient = LinearGradient(
    colors: [Color(0xFFFF5E7E), Color(0xFFB892FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const coupleLoveGradient = LinearGradient(
    colors: [Color(0xFFFF5E7E), Color(0xFF9B2345)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const goldGradient = LinearGradient(
    colors: [Color(0xFFF39C12), Color(0xFFF1C40F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Soft Rose Shadow
  static final softRoseShadow = BoxShadow(
    color: const Color(0xFFFF5E7E).withValues(alpha: 0.12),
    blurRadius: 24,
    offset: const Offset(0, 8),
  );
}
