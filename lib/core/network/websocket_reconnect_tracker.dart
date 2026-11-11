import 'dart:math';
import 'package:flutter/foundation.dart';

/// Tracks exponential backoff state and calculates randomized jittered retry delays.
class WebSocketReconnectTracker {
  int attempts = 0;
  static const int initialRetryDelayMs = 2500; // 2.5s for Railway cold starts
  static const int maxRetryDelayMs = 30000;    // 30s cap
  static const double backoffMultiplier = 1.5;
  final Random _random = Random();

  void reset() {
    attempts = 0;
  }

  int getNextDelayMs() {
    final jitterMs = _random.nextInt(500);
    final delayMs = (initialRetryDelayMs * pow(backoffMultiplier, attempts))
        .clamp(0, maxRetryDelayMs)
        .toInt() + jitterMs;

    attempts++;
    if (kDebugMode &&
        const bool.fromEnvironment('VERBOSE_WS_LOGS', defaultValue: false)) {
      debugPrint(
        '[WebSocket Backoff] Reconnecting in ${delayMs}ms (Attempt #$attempts, max capped at ${maxRetryDelayMs}ms)...',
      );
    }
    return delayMs;
  }
}
