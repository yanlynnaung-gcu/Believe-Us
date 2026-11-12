// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emergency_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EmergencyController)
const emergencyControllerProvider = EmergencyControllerProvider._();

final class EmergencyControllerProvider
    extends $NotifierProvider<EmergencyController, EmergencyState> {
  const EmergencyControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'emergencyControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$emergencyControllerHash();

  @$internal
  @override
  EmergencyController create() => EmergencyController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EmergencyState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EmergencyState>(value),
    );
  }
}

String _$emergencyControllerHash() =>
    r'3c6ab0a8ca3b024649a76bb64e771e1daa839bec';

abstract class _$EmergencyController extends $Notifier<EmergencyState> {
  EmergencyState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<EmergencyState, EmergencyState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EmergencyState, EmergencyState>,
              EmergencyState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
