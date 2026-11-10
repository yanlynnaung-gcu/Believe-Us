import 'dart:io';
import 'package:flutter/material.dart';
import 'package:thae_nge_lay/core/network/api_client.dart';

/// Default fallback image URL when no image is provided or path is empty.
const String kDefaultFallbackImageUrl =
    'https://images.unsplash.com/photo-1518199266791-5375a83190b7?w=1200';

/// Resolves an image path (relative or absolute) into a valid absolute URL or local file path.
///
/// - If [path] is null or blank, returns [defaultFallbackUrl].
/// - If [path] is already an HTTP or HTTPS URL, returns it trimmed.
/// - If [path] starts with 'file:///uploads/' or 'file://uploads/' (often caused by Uri.base.resolve),
///   it strips the 'file://' scheme and prepends [ApiEndpoints.baseUrl].
/// - If [path] points to an existing file on the local filesystem, returns the clean file path.
/// - If [path] is a relative path (e.g., '/uploads/avatars/...' or 'uploads/avatars/...'),
///   it prepends [ApiEndpoints.baseUrl] to form a valid absolute URL.
String getImageUrl(
  String? path, {
  String defaultFallbackUrl = kDefaultFallbackImageUrl,
}) {
  if (path == null) {
    return defaultFallbackUrl;
  }

  final trimmed = path.trim();
  if (trimmed.isEmpty) {
    return defaultFallbackUrl;
  }

  // Already an absolute HTTP or HTTPS URL
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }

  // Handle 'file:///uploads/' or 'file://uploads/' caused by Uri.base.resolve on relative paths
  if (trimmed.startsWith('file:///uploads/')) {
    final sub = trimmed.substring('file://'.length);
    return _prependBaseUrl(sub);
  }
  if (trimmed.startsWith('file://uploads/')) {
    final sub = trimmed.substring('file://'.length);
    return _prependBaseUrl(sub);
  }

  // Check if it's an existing local file on the device
  String localCandidate = trimmed;
  if (localCandidate.startsWith('file://')) {
    localCandidate = localCandidate.replaceFirst('file://', '');
  }
  try {
    final file = File(localCandidate);
    if (file.existsSync()) {
      return file.path;
    }
  } catch (_) {
    // Ignore any filesystem lookup errors
  }

  // Relative backend path (e.g. '/uploads/avatars/photo.jpg' or 'uploads/avatars/photo.jpg')
  return _prependBaseUrl(trimmed);
}

/// Helper to safely prepend [ApiEndpoints.baseUrl] without double slashes.
String _prependBaseUrl(String relativePath) {
  final base = ApiEndpoints.baseUrl.endsWith('/')
      ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
      : ApiEndpoints.baseUrl;
  final path = relativePath.startsWith('/') ? relativePath : '/$relativePath';
  return '$base$path';
}

/// Resolves an audio path (relative or absolute) into a valid absolute URL or local file path.
///
/// - If [path] is null or blank, returns null.
/// - If [path] is already an HTTP or HTTPS URL, returns it trimmed.
/// - If [path] starts with 'file:///uploads/' or 'file://uploads/', it strips 'file://'
///   and prepends [ApiEndpoints.baseUrl].
/// - If [path] points to an existing file on the local filesystem, returns the clean file path.
/// - If [path] is a relative path (e.g. '/uploads/audio/...' or 'uploads/audio/...'),
///   it prepends [ApiEndpoints.baseUrl] to form a valid HTTP streaming URL.
String? getAudioUrl(String? path) {
  if (path == null) return null;
  final trimmed = path.trim();
  if (trimmed.isEmpty) return null;

  // 1. Already an absolute HTTP or HTTPS URL
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }

  // 2. Handle 'file:///uploads/' or 'file://uploads/'
  if (trimmed.startsWith('file:///uploads/')) {
    final sub = trimmed.substring('file://'.length);
    return _prependBaseUrl(sub);
  }
  if (trimmed.startsWith('file://uploads/')) {
    final sub = trimmed.substring('file://'.length);
    return _prependBaseUrl(sub);
  }

  // 3. Genuine local file on the device
  String localCandidate = trimmed;
  if (localCandidate.startsWith('file://')) {
    localCandidate = localCandidate.replaceFirst('file://', '');
  }
  try {
    final file = File(localCandidate);
    if (file.existsSync()) {
      return file.path;
    }
  } catch (_) {}

  // 4. Relative backend path (e.g. '/uploads/audio/...' or 'uploads/audio/...')
  if (trimmed.startsWith('/uploads/') ||
      trimmed.startsWith('uploads/') ||
      trimmed.startsWith('/audio/') ||
      trimmed.startsWith('audio/')) {
    return _prependBaseUrl(trimmed);
  }

  if (trimmed.startsWith('/')) {
    return _prependBaseUrl(trimmed);
  }

  return trimmed;
}

/// Returns a suitable [ImageProvider] for a given [path].
///
/// Seamlessly handles:
/// - null or empty paths -> [NetworkImage] with fallback URL
/// - local file paths / URIs -> [FileImage] if file exists
/// - remote URLs -> [NetworkImage]
/// - relative backend paths (e.g., '/uploads/avatars/...') -> resolved [NetworkImage]
ImageProvider getCustomImageProvider(String? path) {
  if (path == null || path.trim().isEmpty) {
    return const NetworkImage(kDefaultFallbackImageUrl);
  }

  final trimmed = path.trim();

  // If it's a genuine local file that exists, use FileImage
  String localCandidate = trimmed;
  if (localCandidate.startsWith('file://') &&
      !localCandidate.startsWith('file:///uploads') &&
      !localCandidate.startsWith('file://uploads')) {
    localCandidate = localCandidate.replaceFirst('file://', '');
  }
  try {
    final file = File(localCandidate);
    if (file.existsSync()) {
      return FileImage(file);
    }
  } catch (_) {}

  // Resolve to absolute URL or local path
  final resolved = getImageUrl(trimmed);

  if (resolved.startsWith('http://') || resolved.startsWith('https://')) {
    return NetworkImage(resolved);
  }

  // Check if resolved string is an existing file
  try {
    final file = File(resolved);
    if (file.existsSync()) {
      return FileImage(file);
    }
  } catch (_) {}

  // Fallback to default
  return const NetworkImage(kDefaultFallbackImageUrl);
}
