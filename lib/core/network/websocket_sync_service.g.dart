// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'websocket_sync_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(webSocketSyncService)
const webSocketSyncServiceProvider = WebSocketSyncServiceProvider._();

final class WebSocketSyncServiceProvider
    extends
        $FunctionalProvider<
          WebSocketSyncService,
          WebSocketSyncService,
          WebSocketSyncService
        >
    with $Provider<WebSocketSyncService> {
  const WebSocketSyncServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'webSocketSyncServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$webSocketSyncServiceHash();

  @$internal
  @override
  $ProviderElement<WebSocketSyncService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WebSocketSyncService create(Ref ref) {
    return webSocketSyncService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WebSocketSyncService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WebSocketSyncService>(value),
    );
  }
}

String _$webSocketSyncServiceHash() =>
    r'ac59987d184d085a2b3c6761e59215c2186a559a';
