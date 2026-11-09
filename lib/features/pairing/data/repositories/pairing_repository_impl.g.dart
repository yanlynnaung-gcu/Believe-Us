// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pairingRepository)
const pairingRepositoryProvider = PairingRepositoryProvider._();

final class PairingRepositoryProvider
    extends
        $FunctionalProvider<
          PairingRepository,
          PairingRepository,
          PairingRepository
        >
    with $Provider<PairingRepository> {
  const PairingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pairingRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pairingRepositoryHash();

  @$internal
  @override
  $ProviderElement<PairingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PairingRepository create(Ref ref) {
    return pairingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PairingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PairingRepository>(value),
    );
  }
}

String _$pairingRepositoryHash() => r'2f50be72c0b5499dddcf85af33b3c6be18acb01c';
