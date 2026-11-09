// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_messages_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChatMessagesNotifier)
const chatMessagesProvider = ChatMessagesNotifierProvider._();

final class ChatMessagesNotifierProvider
    extends $StreamNotifierProvider<ChatMessagesNotifier, List<ChatMessage>> {
  const ChatMessagesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatMessagesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatMessagesNotifierHash();

  @$internal
  @override
  ChatMessagesNotifier create() => ChatMessagesNotifier();
}

String _$chatMessagesNotifierHash() =>
    r'f4ab01074abcb2b4cb941ebe82c34822a85a0029';

abstract class _$ChatMessagesNotifier
    extends $StreamNotifier<List<ChatMessage>> {
  Stream<List<ChatMessage>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<ChatMessage>>, List<ChatMessage>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ChatMessage>>, List<ChatMessage>>,
              AsyncValue<List<ChatMessage>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
