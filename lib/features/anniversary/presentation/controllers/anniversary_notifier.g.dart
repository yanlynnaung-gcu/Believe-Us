// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anniversary_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AnniversaryNotifier)
const anniversaryProvider = AnniversaryNotifierProvider._();

final class AnniversaryNotifierProvider
    extends $NotifierProvider<AnniversaryNotifier, AnniversaryEngineState> {
  const AnniversaryNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'anniversaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$anniversaryNotifierHash();

  @$internal
  @override
  AnniversaryNotifier create() => AnniversaryNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnniversaryEngineState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnniversaryEngineState>(value),
    );
  }
}

String _$anniversaryNotifierHash() =>
    r'31fb1350ab87fef8e76e5fda51c0f5803fd68692';

abstract class _$AnniversaryNotifier extends $Notifier<AnniversaryEngineState> {
  AnniversaryEngineState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AnniversaryEngineState, AnniversaryEngineState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AnniversaryEngineState, AnniversaryEngineState>,
              AnniversaryEngineState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
