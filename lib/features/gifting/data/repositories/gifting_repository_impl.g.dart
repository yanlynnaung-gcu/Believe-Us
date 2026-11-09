// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gifting_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(giftingRepository)
const giftingRepositoryProvider = GiftingRepositoryProvider._();

final class GiftingRepositoryProvider
    extends
        $FunctionalProvider<
          GiftingRepository,
          GiftingRepository,
          GiftingRepository
        >
    with $Provider<GiftingRepository> {
  const GiftingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'giftingRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$giftingRepositoryHash();

  @$internal
  @override
  $ProviderElement<GiftingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GiftingRepository create(Ref ref) {
    return giftingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GiftingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GiftingRepository>(value),
    );
  }
}

String _$giftingRepositoryHash() => r'2a11a8bc92f43b6a4a5eb1112fc34cfa4aee9f18';
