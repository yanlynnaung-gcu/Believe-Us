import 'package:flutter/material.dart';

class OnboardingItem {
  final String title;
  final String subtitle;
  final String highlightWord;
  final IconData icon;
  final List<Color> gradientColors;

  const OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.highlightWord,
    required this.icon,
    required this.gradientColors,
  });
}
