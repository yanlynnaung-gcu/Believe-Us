// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PairingController)
const pairingControllerProvider = PairingControllerProvider._();

final class PairingControllerProvider
    extends $NotifierProvider<PairingController, PairingUIState> {
  const PairingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pairingControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pairingControllerHash();

  @$internal
  @override
  PairingController create() => PairingController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PairingUIState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PairingUIState>(value),
    );
  }
}

String _$pairingControllerHash() => r'f05824fce335d7f0c164f0480309125d9599c442';

abstract class _$PairingController extends $Notifier<PairingUIState> {
  PairingUIState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<PairingUIState, PairingUIState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PairingUIState, PairingUIState>,
              PairingUIState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
