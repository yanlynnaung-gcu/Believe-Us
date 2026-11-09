// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_permission_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LocationPermissionController)
const locationPermissionControllerProvider =
    LocationPermissionControllerProvider._();

final class LocationPermissionControllerProvider
    extends $NotifierProvider<LocationPermissionController, bool> {
  const LocationPermissionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationPermissionControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationPermissionControllerHash();

  @$internal
  @override
  LocationPermissionController create() => LocationPermissionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$locationPermissionControllerHash() =>
    r'a9cb9c23bcab8401ea4e50f435876684d1b20d73';

abstract class _$LocationPermissionController extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
