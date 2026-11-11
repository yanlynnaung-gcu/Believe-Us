import 'dart:async';
import 'package:flutter/services.dart';

/// Triple-press consecutive detection logic:
/// Requires 3 presses within a 3.0 second window.
class VolumeTriplePressDetector {
  final List<DateTime> _pressTimestamps = [];
  Timer? _pressResetTimer;
  final void Function(int count) onCountChanged;
  final VoidCallback onTriplePress;

  VolumeTriplePressDetector({
    required this.onCountChanged,
    required this.onTriplePress,
  });

  void handlePress() {
    final now = DateTime.now();

    // 1. Purge any presses that occurred more than 3000ms ago
    _pressTimestamps.removeWhere(
      (t) => now.difference(t).inMilliseconds > 3000,
    );
    _pressTimestamps.add(now);

    final currentCount = _pressTimestamps.length;
    onCountChanged(currentCount);

    // Haptic tick feedback on physical button press
    HapticFeedback.selectionClick();

    // Cancel any previous trailing reset timer
    _pressResetTimer?.cancel();
    _pressResetTimer = Timer(const Duration(milliseconds: 3100), () {
      _pressTimestamps.clear();
      onCountChanged(0);
    });

    // 2. Trigger instant emergency action upon confirmed triple press
    if (currentCount >= 3) {
      _pressTimestamps.clear();
      _pressResetTimer?.cancel();
      onCountChanged(0);
      onTriplePress();
    }
  }

  void dispose() {
    _pressResetTimer?.cancel();
    _pressTimestamps.clear();
  }
}
