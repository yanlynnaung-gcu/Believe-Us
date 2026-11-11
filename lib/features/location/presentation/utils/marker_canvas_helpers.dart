import 'package:flutter/material.dart';

/// Canvas drawing helpers for custom romantic map pin markers
class MarkerCanvasHelpers {
  static void drawCenteredHeart(
    Canvas canvas,
    Offset center, {
    required Color color,
    required double size,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size;
    final h = size;

    final left = center.dx - (w / 2);
    final top = center.dy - (h / 2);

    path.moveTo(left + w / 2, top + h * 0.82);
    path.cubicTo(
      left + w * 0.1,
      top + h * 0.55,
      left,
      top + h * 0.28,
      left + w * 0.25,
      top + h * 0.1,
    );
    path.cubicTo(
      left + w * 0.45,
      top - h * 0.02,
      left + w / 2,
      top + h * 0.25,
      left + w / 2,
      top + h * 0.25,
    );
    path.cubicTo(
      left + w / 2,
      top + h * 0.25,
      left + w * 0.55,
      top - h * 0.02,
      left + w * 0.75,
      top + h * 0.1,
    );
    path.cubicTo(
      left + w,
      top + h * 0.28,
      left + w * 0.9,
      top + h * 0.55,
      left + w / 2,
      top + h * 0.82,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  static void drawCenteredNavArrow(
    Canvas canvas,
    Offset center, {
    required Color color,
    required double size,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final half = size / 2;

    path.moveTo(center.dx, center.dy - half);
    path.lineTo(center.dx + half, center.dy + half);
    path.lineTo(center.dx, center.dy + (half * 0.4));
    path.lineTo(center.dx - half, center.dy + half);
    path.close();

    canvas.drawPath(path, paint);
  }
}
