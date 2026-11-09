// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AuthController)
const authControllerProvider = AuthControllerProvider._();

final class AuthControllerProvider
    extends $NotifierProvider<AuthController, AuthUIState> {
  const AuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthUIState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthUIState>(value),
    );
  }
}

String _$authControllerHash() => r'9d05d4e3105d71293c0988c09a7cbbf887ba7b76';

abstract class _$AuthController extends $Notifier<AuthUIState> {
  AuthUIState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AuthUIState, AuthUIState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthUIState, AuthUIState>,
              AuthUIState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
