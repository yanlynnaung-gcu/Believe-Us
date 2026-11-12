import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:thae_nge_lay/core/network/api_client.dart';

/// Default fallback image URL when no image is provided or path is empty.
const String kDefaultFallbackImageUrl =
    'https://images.unsplash.com/photo-1518199266791-5375a83190b7?w=1200';

const String kDefaultAvatarBoyfriendUrl =
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300';

const String kDefaultAvatarGirlfriendUrl =
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300';

/// Checks if a string looks like a local device filesystem path rather than a server URL.
bool _isLocalFileSystemPath(String path) {
  if (path.startsWith('file://')) return true;
  return path.startsWith('/') &&
      (path.startsWith('/data/') ||
          path.startsWith('/var/') ||
          path.startsWith('/private/') ||
          path.startsWith('/storage/') ||
          path.startsWith('/Users/') ||
          path.startsWith('/home/') ||
          path.startsWith('/tmp/') ||
          path.contains('/cache/') ||
          path.contains('/app_flutter/') ||
          path.contains('image_picker') ||
          path.contains('image_cropper'));
}

/// Resolves an image path (relative or absolute) into a valid absolute URL or local file path.
///
/// - If [path] is null or blank, returns [defaultFallbackUrl].
/// - If [path] is already an HTTP or HTTPS URL, validates scheme & host and returns it trimmed.
/// - If [path] starts with 'file:///uploads/' or 'file://uploads/', strips 'file://' and prepends [ApiEndpoints.baseUrl].
/// - If [path] points to an existing file on the local filesystem, returns the clean file path.
/// - If [path] points to a NON-EXISTENT local filesystem file, returns [defaultFallbackUrl] (never prepends baseUrl).
/// - If [path] is a relative path (e.g., '/uploads/avatars/...' or 'uploads/avatars/...'), prepends [ApiEndpoints.baseUrl].
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
    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
      return trimmed;
    }
    return defaultFallbackUrl;
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
    // Filesystem lookup errors ignore
  }

  // If candidate was a device filesystem path that DOES NOT exist locally:
  // Fall back to default placeholder so we never create bogus URLs like https://host/data/user/0/...
  if (_isLocalFileSystemPath(trimmed) || _isLocalFileSystemPath(localCandidate)) {
    return defaultFallbackUrl;
  }

  // Known backend relative prefix paths
  if (trimmed.startsWith('/uploads/') ||
      trimmed.startsWith('uploads/') ||
      trimmed.startsWith('/avatars/') ||
      trimmed.startsWith('avatars/') ||
      trimmed.startsWith('/covers/') ||
      trimmed.startsWith('covers/') ||
      trimmed.startsWith('/audio/') ||
      trimmed.startsWith('audio/') ||
      trimmed.startsWith('/static/') ||
      trimmed.startsWith('static/')) {
    return _prependBaseUrl(trimmed);
  }

  // Generic relative path on backend
  if (trimmed.startsWith('/')) {
    return _prependBaseUrl(trimmed);
  }

  return defaultFallbackUrl;
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
String? getAudioUrl(String? path) {
  if (path == null) return null;
  final trimmed = path.trim();
  if (trimmed.isEmpty) return null;

  // 1. Already an absolute HTTP or HTTPS URL
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
      return trimmed;
    }
    return null;
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

  if (_isLocalFileSystemPath(trimmed) || _isLocalFileSystemPath(localCandidate)) {
    return null;
  }

  // 4. Relative backend path (e.g. '/uploads/audio/...' or 'uploads/audio/...')
  if (trimmed.startsWith('/uploads/') ||
      trimmed.startsWith('uploads/') ||
      trimmed.startsWith('/audio/') ||
      trimmed.startsWith('audio/') ||
      trimmed.startsWith('/')) {
    return _prependBaseUrl(trimmed);
  }

  return null;
}

/// Returns a suitable [ImageProvider] for a given [path].
///
/// Seamlessly handles:
/// - null or empty paths -> [CachedNetworkImageProvider] with fallback URL
/// - local file paths / URIs -> [FileImage] if file exists
/// - remote URLs -> [CachedNetworkImageProvider] with disk and memory cache
/// - relative backend paths (e.g., '/uploads/avatars/...') -> resolved [CachedNetworkImageProvider]
ImageProvider getCustomImageProvider(
  String? path, {
  String defaultFallbackUrl = kDefaultFallbackImageUrl,
}) {
  if (path == null || path.trim().isEmpty) {
    return CachedNetworkImageProvider(defaultFallbackUrl);
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

  // If it was a missing local device path, return fallback
  if (_isLocalFileSystemPath(trimmed) || _isLocalFileSystemPath(localCandidate)) {
    return CachedNetworkImageProvider(defaultFallbackUrl);
  }

  // Resolve to absolute URL or local path
  final resolved = getImageUrl(trimmed, defaultFallbackUrl: defaultFallbackUrl);

  if (resolved.startsWith('http://') || resolved.startsWith('https://')) {
    final uri = Uri.tryParse(resolved);
    if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
      return CachedNetworkImageProvider(
        resolved,
        errorListener: (err) {
          debugPrint('[ImageProvider] Failed to load image from $resolved: $err');
        },
      );
    }
  }

  // Check if resolved string is an existing file
  try {
    final file = File(resolved);
    if (file.existsSync()) {
      return FileImage(file);
    }
  } catch (_) {}

  // Fallback to default
  return CachedNetworkImageProvider(defaultFallbackUrl);
}

/// Reusable safe image widget that uses [CachedNetworkImage] for network URLs
/// and [FileImage] for local files, with reliable placeholders and error fallbacks
/// so images NEVER disappear during state rebuilds or network hiccups.
class SafeCoupleImage extends StatelessWidget {
  final String? imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String fallbackUrl;
  final Widget? placeholder;
  final Widget? errorWidget;

  const SafeCoupleImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackUrl = kDefaultFallbackImageUrl,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = getImageUrl(imagePath, defaultFallbackUrl: fallbackUrl);

    // If local file exists, show FileImage
    if (!resolvedUrl.startsWith('http://') && !resolvedUrl.startsWith('https://')) {
      final file = File(resolvedUrl);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (ctx, err, stack) =>
              _buildFallbackNetwork(context, fallbackUrl),
        );
      }
    }

    return _buildCachedNetwork(resolvedUrl);
  }

  Widget _buildCachedNetwork(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) =>
          placeholder ??
          Container(
            width: width,
            height: height,
            color: Colors.grey.withValues(alpha: 0.15),
          ),
      errorWidget: (context, url, error) {
        if (url != fallbackUrl) {
          return _buildFallbackNetwork(context, fallbackUrl);
        }
        return errorWidget ??
            Container(
              width: width,
              height: height,
              color: Colors.grey.withValues(alpha: 0.2),
              child: const Icon(Icons.broken_image_rounded, color: Colors.grey),
            );
      },
    );
  }

  Widget _buildFallbackNetwork(BuildContext context, String fallback) {
    return CachedNetworkImage(
      imageUrl: fallback,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: Colors.grey.withValues(alpha: 0.15),
      ),
      errorWidget: (context, url, err) =>
          errorWidget ??
          Container(
            width: width,
            height: height,
            color: Colors.grey.withValues(alpha: 0.2),
            child: const Icon(Icons.favorite_rounded, color: Colors.pinkAccent),
          ),
    );
  }
}
