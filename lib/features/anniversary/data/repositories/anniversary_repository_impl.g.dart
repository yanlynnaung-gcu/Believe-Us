// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anniversary_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(anniversaryRepository)
const anniversaryRepositoryProvider = AnniversaryRepositoryProvider._();

final class AnniversaryRepositoryProvider
    extends
        $FunctionalProvider<
          AnniversaryRepository,
          AnniversaryRepository,
          AnniversaryRepository
        >
    with $Provider<AnniversaryRepository> {
  const AnniversaryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'anniversaryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$anniversaryRepositoryHash();

  @$internal
  @override
  $ProviderElement<AnniversaryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AnniversaryRepository create(Ref ref) {
    return anniversaryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnniversaryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnniversaryRepository>(value),
    );
  }
}

String _$anniversaryRepositoryHash() =>
    r'74611305140163945da55bdbed71323d6ff1d555';
