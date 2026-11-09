// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fcm_notification_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(fcmNotificationService)
const fcmNotificationServiceProvider = FcmNotificationServiceProvider._();

final class FcmNotificationServiceProvider
    extends
        $FunctionalProvider<
          FcmNotificationService,
          FcmNotificationService,
          FcmNotificationService
        >
    with $Provider<FcmNotificationService> {
  const FcmNotificationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fcmNotificationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fcmNotificationServiceHash();

  @$internal
  @override
  $ProviderElement<FcmNotificationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FcmNotificationService create(Ref ref) {
    return fcmNotificationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FcmNotificationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FcmNotificationService>(value),
    );
  }
}

String _$fcmNotificationServiceHash() =>
    r'13cf6ab5fe5c2f658fa0fa7c46580f5d9bd906ff';
