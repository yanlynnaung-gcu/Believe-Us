// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gifting_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GiftingController)
const giftingControllerProvider = GiftingControllerProvider._();

final class GiftingControllerProvider
    extends $NotifierProvider<GiftingController, GiftingUIState> {
  const GiftingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'giftingControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$giftingControllerHash();

  @$internal
  @override
  GiftingController create() => GiftingController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GiftingUIState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GiftingUIState>(value),
    );
  }
}

String _$giftingControllerHash() => r'05749b7078181a3937a61b42fdd217f7261a1189';

abstract class _$GiftingController extends $Notifier<GiftingUIState> {
  GiftingUIState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<GiftingUIState, GiftingUIState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GiftingUIState, GiftingUIState>,
              GiftingUIState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
