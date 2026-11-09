// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mqtt_sos_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(mqttSosService)
const mqttSosServiceProvider = MqttSosServiceProvider._();

final class MqttSosServiceProvider
    extends $FunctionalProvider<MqttSosService, MqttSosService, MqttSosService>
    with $Provider<MqttSosService> {
  const MqttSosServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mqttSosServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mqttSosServiceHash();

  @$internal
  @override
  $ProviderElement<MqttSosService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MqttSosService create(Ref ref) {
    return mqttSosService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MqttSosService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MqttSosService>(value),
    );
  }
}

String _$mqttSosServiceHash() => r'f3279c839c39f07671fa56322a3f9f8e44eb895f';
