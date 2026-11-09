import 'dart:io';
import 'package:flutter/material.dart';
import 'package:thae_nge_lay/core/network/api_client.dart';

ImageProvider getCustomImageProvider(String path) {
  if (path.isEmpty) {
    return const NetworkImage(
      'https://images.unsplash.com/photo-1518199266791-5375a83190b7?w=1200',
    );
  }

  if (path.startsWith('/')) {
    return NetworkImage('${ApiEndpoints.baseUrl}$path');
  }

  if (path.startsWith('http://') || path.startsWith('https://')) {
    return NetworkImage(path);
  } else {
    final file = File(path);
    if (file.existsSync()) {
      return FileImage(file);
    }
    // Fallback default image
    return const NetworkImage(
      'https://images.unsplash.com/photo-1518199266791-5375a83190b7?w=1200',
    );
  }
}
