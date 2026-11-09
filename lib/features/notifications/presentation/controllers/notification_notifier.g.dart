// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NotificationNotifier)
const notificationProvider = NotificationNotifierProvider._();

final class NotificationNotifierProvider
    extends $StreamNotifierProvider<NotificationNotifier, CoupleNotification> {
  const NotificationNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationNotifierHash();

  @$internal
  @override
  NotificationNotifier create() => NotificationNotifier();
}

String _$notificationNotifierHash() =>
    r'52826598d99f9ae35f02bb05962664eadca19463';

abstract class _$NotificationNotifier
    extends $StreamNotifier<CoupleNotification> {
  Stream<CoupleNotification> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<CoupleNotification>, CoupleNotification>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CoupleNotification>, CoupleNotification>,
              AsyncValue<CoupleNotification>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
