import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';

class RomanticMarkerGenerator {
  static final Map<String, BitmapDescriptor> _markerCache = {};

  /// Resolves any Flutter ImageProvider into a dart:ui Image
  static Future<ui.Image?> resolveImage(
    ImageProvider provider, {
    Duration timeout = const Duration(seconds: 4),
  }) async {
    final completer = Completer<ui.Image?>();
    final stream = provider.resolve(
      const ImageConfiguration(size: Size(160, 160)),
    );

    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        if (!completer.isCompleted) {
          completer.complete(info.image);
        }
        stream.removeListener(listener);
      },
      onError: (exception, stackTrace) {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
        stream.removeListener(listener);
      },
    );

    stream.addListener(listener);

    return completer.future.timeout(
      timeout,
      onTimeout: () {
        stream.removeListener(listener);
        return null;
      },
    );
  }

  /// Generates a high-resolution romantic pin marker with avatar, badge, and label
  static Future<BitmapDescriptor> createCoupleMarker({
    required String label,
    required Color borderColor,
    required bool isPartner,
    ImageProvider? avatarProvider,
    String? cacheKey,
  }) async {
    if (cacheKey != null && _markerCache.containsKey(cacheKey)) {
      return _markerCache[cacheKey]!;
    }

    ui.Image? avatarImage;
    if (avatarProvider != null) {
      try {
        avatarImage = await resolveImage(avatarProvider);
      } catch (_) {
        avatarImage = null;
      }
    }

    const double width = 200.0;
    const double height = 230.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, width, height));

    const double centerX = width / 2;
    const double avatarRadius = 52.0;
    const double avatarCenterY = 62.0;

    // 1. Drop Shadow for Avatar
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
    canvas.drawCircle(
      const Offset(centerX, avatarCenterY + 4),
      avatarRadius + 2,
      shadowPaint,
    );

    // 2. White Outer Rim
    final whiteRimPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      const Offset(centerX, avatarCenterY),
      avatarRadius + 6,
      whiteRimPaint,
    );

    // 3. Colored Border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;
    canvas.drawCircle(
      const Offset(centerX, avatarCenterY),
      avatarRadius + 2,
      borderPaint,
    );

    // 4. Draw Avatar Image or Romantic Placeholder
    final avatarClipRect = Rect.fromCircle(
      center: const Offset(centerX, avatarCenterY),
      radius: avatarRadius,
    );
    final clipPath = Path()..addOval(avatarClipRect);

    canvas.save();
    canvas.clipPath(clipPath);

    if (avatarImage != null) {
      final src = Rect.fromLTWH(
        0,
        0,
        avatarImage.width.toDouble(),
        avatarImage.height.toDouble(),
      );
      canvas.drawImageRect(avatarImage, src, avatarClipRect, Paint());
    } else {
      // Gradient background placeholder
      final bgGradient = ui.Gradient.linear(
        Offset(centerX, avatarCenterY - avatarRadius),
        Offset(centerX, avatarCenterY + avatarRadius),
        [
          isPartner ? const Color(0xFFFF85A1) : const Color(0xFFC4B5FD),
          isPartner ? BelieveColors.primary : const Color(0xFF8B5CF6),
        ],
      );
      final bgPaint = Paint()..shader = bgGradient;
      canvas.drawCircle(
        const Offset(centerX, avatarCenterY),
        avatarRadius,
        bgPaint,
      );

      // Cute heart / initial icon in center
      _drawCenteredHeart(
        canvas,
        const Offset(centerX, avatarCenterY),
        color: Colors.white,
        size: 38,
      );
    }
    canvas.restore();

    // 5. Corner Badge (Bottom Right of Avatar)
    final badgeCenterX = centerX + avatarRadius * 0.72;
    final badgeCenterY = avatarCenterY + avatarRadius * 0.72;
    const double badgeRadius = 18.0;

    final badgeWhiteBg = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(badgeCenterX, badgeCenterY),
      badgeRadius + 2,
      badgeWhiteBg,
    );

    final badgePaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(badgeCenterX, badgeCenterY),
      badgeRadius,
      badgePaint,
    );

    if (isPartner) {
      _drawCenteredHeart(
        canvas,
        Offset(badgeCenterX, badgeCenterY),
        color: Colors.white,
        size: 16,
      );
    } else {
      _drawCenteredNavArrow(
        canvas,
        Offset(badgeCenterX, badgeCenterY),
        color: Colors.white,
        size: 14,
      );
    }

    // 6. Label Banner Pill Under Avatar
    const double pillHeight = 36.0;
    const double pillWidth = 160.0;
    const double pillTop = avatarCenterY + avatarRadius + 8.0;
    final pillRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: const Offset(centerX, pillTop + (pillHeight / 2)),
        width: pillWidth,
        height: pillHeight,
      ),
      const Radius.circular(18.0),
    );

    // Pill shadow
    final pillShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
    canvas.drawRRect(pillRect.shift(const Offset(0, 3)), pillShadowPaint);

    // Pill fill
    final pillFillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRRect(pillRect, pillFillPaint);

    // Pill stroke
    final pillStrokePaint = Paint()
      ..color = borderColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(pillRect, pillStrokePaint);

    // Text inside pill
    final textBuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textAlign: TextAlign.center,
        fontSize: 14.0,
        fontWeight: FontWeight.w800,
        maxLines: 1,
        ellipsis: '...',
      ),
    )
      ..pushStyle(
        ui.TextStyle(
          color: const Color(0xFF2D2424),
          fontFamily: 'PlusJakartaSans',
        ),
      )
      ..addText(label);

    final paragraph = textBuilder.build()
      ..layout(const ui.ParagraphConstraints(width: pillWidth - 16));
    canvas.drawParagraph(
      paragraph,
      Offset(
        centerX - (paragraph.width / 2),
        pillTop + ((pillHeight - paragraph.height) / 2),
      ),
    );

    // 7. Pin Stem & Pointing Tip to (centerX, height - 6)
    final pinPath = Path()
      ..moveTo(centerX - 10, pillTop + pillHeight - 2)
      ..lineTo(centerX, height - 8)
      ..lineTo(centerX + 10, pillTop + pillHeight - 2)
      ..close();

    final pinPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(pinPath, pinPaint);

    // Coordinate anchor dot at exact bottom tip
    final anchorDotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(centerX, height - 8), 5.0, anchorDotPaint);

    final anchorBorderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(const Offset(centerX, height - 8), 5.0, anchorBorderPaint);

    // Render to PNG image bytes
    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    final descriptor = BitmapDescriptor.bytes(
      byteData!.buffer.asUint8List(),
      width: 80,
      height: 92,
    );

    if (cacheKey != null) {
      _markerCache[cacheKey] = descriptor;
    }
    return descriptor;
  }

  static void _drawCenteredHeart(
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

  static void _drawCenteredNavArrow(
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

  static void clearCache() {
    _markerCache.clear();
  }
}
