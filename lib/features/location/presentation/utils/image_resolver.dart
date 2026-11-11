import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Helper to resolve Flutter ImageProvider into dart:ui Image
Future<ui.Image?> resolveImageToDartUi(
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
