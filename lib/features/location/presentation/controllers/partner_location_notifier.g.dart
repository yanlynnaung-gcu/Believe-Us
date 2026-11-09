// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_location_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PartnerLocationNotifier)
const partnerLocationProvider = PartnerLocationNotifierProvider._();

final class PartnerLocationNotifierProvider
    extends $NotifierProvider<PartnerLocationNotifier, PartnerLocationStatus> {
  const PartnerLocationNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'partnerLocationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$partnerLocationNotifierHash();

  @$internal
  @override
  PartnerLocationNotifier create() => PartnerLocationNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PartnerLocationStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PartnerLocationStatus>(value),
    );
  }
}

String _$partnerLocationNotifierHash() =>
    r'15ce60870d1093c8701109fa01e64e1c2855c0b6';

abstract class _$PartnerLocationNotifier
    extends $Notifier<PartnerLocationStatus> {
  PartnerLocationStatus build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<PartnerLocationStatus, PartnerLocationStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PartnerLocationStatus, PartnerLocationStatus>,
              PartnerLocationStatus,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
