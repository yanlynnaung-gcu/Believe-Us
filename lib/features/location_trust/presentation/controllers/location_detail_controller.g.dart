// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(geocodingService)
const geocodingServiceProvider = GeocodingServiceProvider._();

final class GeocodingServiceProvider
    extends
        $FunctionalProvider<
          GeocodingService,
          GeocodingService,
          GeocodingService
        >
    with $Provider<GeocodingService> {
  const GeocodingServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'geocodingServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$geocodingServiceHash();

  @$internal
  @override
  $ProviderElement<GeocodingService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GeocodingService create(Ref ref) {
    return geocodingService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeocodingService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeocodingService>(value),
    );
  }
}

String _$geocodingServiceHash() => r'bc1cee82703540e849f5a7391ba70f2e9d455dad';

@ProviderFor(locationArrivalRepository)
const locationArrivalRepositoryProvider = LocationArrivalRepositoryProvider._();

final class LocationArrivalRepositoryProvider
    extends
        $FunctionalProvider<
          LocationArrivalRepository,
          LocationArrivalRepository,
          LocationArrivalRepository
        >
    with $Provider<LocationArrivalRepository> {
  const LocationArrivalRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationArrivalRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationArrivalRepositoryHash();

  @$internal
  @override
  $ProviderElement<LocationArrivalRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocationArrivalRepository create(Ref ref) {
    return locationArrivalRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocationArrivalRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocationArrivalRepository>(value),
    );
  }
}

String _$locationArrivalRepositoryHash() =>
    r'47e96aa42cf8dd96b8e35ce855028465ad242620';

@ProviderFor(LocationDetailController)
const locationDetailControllerProvider = LocationDetailControllerProvider._();

final class LocationDetailControllerProvider
    extends $NotifierProvider<LocationDetailController, LocationDetailState> {
  const LocationDetailControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationDetailControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationDetailControllerHash();

  @$internal
  @override
  LocationDetailController create() => LocationDetailController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocationDetailState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocationDetailState>(value),
    );
  }
}

String _$locationDetailControllerHash() =>
    r'9ff00017b5c1537f6df8ea9eef90c0dc1d905088';

abstract class _$LocationDetailController
    extends $Notifier<LocationDetailState> {
  LocationDetailState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<LocationDetailState, LocationDetailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LocationDetailState, LocationDetailState>,
              LocationDetailState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
