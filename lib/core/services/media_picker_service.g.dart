// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_picker_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(mediaPickerService)
const mediaPickerServiceProvider = MediaPickerServiceProvider._();

final class MediaPickerServiceProvider
    extends
        $FunctionalProvider<
          MediaPickerService,
          MediaPickerService,
          MediaPickerService
        >
    with $Provider<MediaPickerService> {
  const MediaPickerServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediaPickerServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediaPickerServiceHash();

  @$internal
  @override
  $ProviderElement<MediaPickerService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MediaPickerService create(Ref ref) {
    return mediaPickerService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MediaPickerService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MediaPickerService>(value),
    );
  }
}

String _$mediaPickerServiceHash() =>
    r'1ccc75a45c51c078b0cb3a39333e2b8f6795d49d';
