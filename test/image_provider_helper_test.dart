import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thae_nge_lay/core/network/api_client.dart';
import 'package:thae_nge_lay/core/utils/image_provider_helper.dart';

void main() {
  group('ImageProviderHelper and URL Resolution Tests', () {
    test('resolves relative path starting with / into absolute baseUrl URL', () {
      const relative = '/uploads/avatars/user_123.jpg';
      final resolved = getImageUrl(relative);
      expect(resolved, '${ApiEndpoints.baseUrl}/uploads/avatars/user_123.jpg');
      expect(resolved.startsWith('https://') || resolved.startsWith('http://'), isTrue);
    });

    test('resolves relative path without leading / into absolute baseUrl URL', () {
      const relative = 'uploads/avatars/user_456.png';
      final resolved = getImageUrl(relative);
      expect(resolved, '${ApiEndpoints.baseUrl}/uploads/avatars/user_456.png');
    });

    test('resolves file:///uploads/... corrupted URI back to absolute baseUrl URL', () {
      const corrupted = 'file:///uploads/avatars/partner_789.jpg';
      final resolved = getImageUrl(corrupted);
      expect(resolved, '${ApiEndpoints.baseUrl}/uploads/avatars/partner_789.jpg');
      expect(resolved.startsWith('file://'), isFalse);
    });

    test('resolves file://uploads/... corrupted URI back to absolute baseUrl URL', () {
      const corrupted = 'file://uploads/avatars/partner_999.jpg';
      final resolved = getImageUrl(corrupted);
      expect(resolved, '${ApiEndpoints.baseUrl}/uploads/avatars/partner_999.jpg');
    });

    test('preserves absolute http/https URLs as-is', () {
      const httpsUrl = 'https://images.unsplash.com/photo-1518199266791-5375a83190b7?w=1200';
      expect(getImageUrl(httpsUrl), httpsUrl);

      const httpUrl = 'http://example.com/avatar.jpg';
      expect(getImageUrl(httpUrl), httpUrl);
    });

    test('returns default fallback URL for null, empty, or whitespace-only paths', () {
      expect(getImageUrl(null), kDefaultFallbackImageUrl);
      expect(getImageUrl(''), kDefaultFallbackImageUrl);
      expect(getImageUrl('   '), kDefaultFallbackImageUrl);
    });

    test('returns local file path for an existing local file', () {
      final tempFile = File('${Directory.systemTemp.path}/test_avatar.jpg');
      tempFile.writeAsStringSync('dummy content');
      addTearDown(() => tempFile.deleteSync());

      final resolved = getImageUrl(tempFile.path);
      expect(resolved, tempFile.path);

      final provider = getCustomImageProvider(tempFile.path);
      expect(provider, isA<FileImage>());
      expect((provider as FileImage).file.path, tempFile.path);
    });

    test('getCustomImageProvider returns NetworkImage with valid URL for relative backend path', () {
      const relative = '/uploads/avatars/avatar_real.jpg';
      final provider = getCustomImageProvider(relative);
      expect(provider, isA<NetworkImage>());
      final netImage = provider as NetworkImage;
      expect(netImage.url, '${ApiEndpoints.baseUrl}$relative');
      // Verify no 'file://' host error could happen
      final uri = Uri.parse(netImage.url);
      expect(uri.hasScheme, isTrue);
      expect(uri.host.isNotEmpty, isTrue);
    });

    test('getCustomImageProvider returns fallback NetworkImage for empty or null path', () {
      final providerNull = getCustomImageProvider(null);
      expect(providerNull, isA<NetworkImage>());
      expect((providerNull as NetworkImage).url, kDefaultFallbackImageUrl);

      final providerEmpty = getCustomImageProvider('');
      expect(providerEmpty, isA<NetworkImage>());
      expect((providerEmpty as NetworkImage).url, kDefaultFallbackImageUrl);
    });
  });
}
