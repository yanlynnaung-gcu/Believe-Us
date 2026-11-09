import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';

class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final VoidCallback? onTap;
  final Color? surfaceColor;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? customShadows;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.surfaceColor,
    this.borderColor,
    this.borderWidth = 1.5,
    this.customShadows,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius ?? 24.r);

    Widget content = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding ?? EdgeInsets.all(18.r),
          decoration: BoxDecoration(
            color: surfaceColor ?? Colors.white.withValues(alpha: 0.85),
            borderRadius: radius,
            border: Border.all(
              color: borderColor ?? BelieveColors.glassBorder,
              width: borderWidth,
            ),
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      content = GestureDetector(onTap: onTap, child: content);
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: customShadows ?? [BelieveColors.softRoseShadow],
      ),
      child: content,
    );
  }
}
