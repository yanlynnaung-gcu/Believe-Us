// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'couple_media_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CoupleMediaController)
const coupleMediaControllerProvider = CoupleMediaControllerProvider._();

final class CoupleMediaControllerProvider
    extends $NotifierProvider<CoupleMediaController, CoupleMediaState> {
  const CoupleMediaControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'coupleMediaControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$coupleMediaControllerHash();

  @$internal
  @override
  CoupleMediaController create() => CoupleMediaController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CoupleMediaState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CoupleMediaState>(value),
    );
  }
}

String _$coupleMediaControllerHash() =>
    r'b71d98d4ca8d7952f8c4b046a174ab02407af936';

abstract class _$CoupleMediaController extends $Notifier<CoupleMediaState> {
  CoupleMediaState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<CoupleMediaState, CoupleMediaState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CoupleMediaState, CoupleMediaState>,
              CoupleMediaState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
