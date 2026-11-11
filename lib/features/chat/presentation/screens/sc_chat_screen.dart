import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/utils/image_provider_helper.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';
import 'package:thae_nge_lay/features/chat/data/services/audio_recorder_service.dart';
import 'package:thae_nge_lay/features/chat/presentation/controllers/chat_messages_notifier.dart';
import 'package:thae_nge_lay/features/chat/presentation/widgets/wd_chat_app_bar.dart';
import 'package:thae_nge_lay/features/chat/presentation/widgets/wd_chat_input_bar.dart';
import 'package:thae_nge_lay/features/chat/presentation/widgets/wd_chat_message_list.dart';
import 'package:thae_nge_lay/features/gifting/presentation/widgets/gift_selection_sheet.dart';
import 'package:thae_nge_lay/features/home/presentation/controllers/couple_media_controller.dart';
import 'package:thae_nge_lay/features/location/presentation/widgets/partner_live_status_bar.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final VoidCallback? onOpenGiftingSheet;
  final bool hasBottomNavBar;
  final double bottomNavHeight;

  const ChatScreen({
    super.key,
    this.onOpenGiftingSheet,
    this.hasBottomNavBar = true,
    this.bottomNavHeight = 76.0,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isRecording = false;
  int _recordSeconds = 0;
  Timer? _recordTimer;

  @override
  void dispose() {
    _recordTimer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSendText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    await ref.read(chatMessagesProvider.notifier).sendTextMessage(text);
  }

  void _startVoiceRecording() async {
    final recorder = ref.read(audioRecorderServiceProvider);
    final started = await recorder.startRecording();
    if (!started) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission required to record voice notes.'),
            backgroundColor: BelieveColors.error,
          ),
        );
      }
      return;
    }

    setState(() {
      _isRecording = true;
      _recordSeconds = 0;
    });

    _recordTimer?.cancel();
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _recordSeconds++);
    });
  }

  void _stopAndSendVoice() async {
    _recordTimer?.cancel();
    final recorder = ref.read(audioRecorderServiceProvider);
    final result = await recorder.stopRecording();

    setState(() {
      _isRecording = false;
      _recordSeconds = 0;
    });

    if (result != null) {
      await ref.read(chatMessagesProvider.notifier).sendVoiceMessage(
            audioPath: result.path,
            durationSeconds: result.durationSeconds,
            waveforms: result.waveforms,
          );
    }
  }

  void _cancelVoiceRecording() async {
    _recordTimer?.cancel();
    final recorder = ref.read(audioRecorderServiceProvider);
    await recorder.cancelRecording();

    setState(() {
      _isRecording = false;
      _recordSeconds = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider);
    final media = ref.watch(coupleMediaProvider);
    final messagesAsync = ref.watch(chatMessagesProvider);

    final bottomNavHeight = widget.bottomNavHeight;
    final safeAreaBottom = MediaQuery.paddingOf(context).bottom;
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    final isKeyboardOpen = keyboardHeight > 0;

    final dynamicBottomSpacing = isKeyboardOpen
        ? 10.h
        : (widget.hasBottomNavBar
            ? (bottomNavHeight + safeAreaBottom + 8.h)
            : (safeAreaBottom > 0 ? safeAreaBottom : 12.h));

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: BelieveColors.background,
      appBar: WdChatAppBar(partnerName: media.partnerName),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.12,
              child: Image(
                image: getCustomImageProvider(media.coverPhotoPath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.transparent),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const PartnerLiveStatusBar(),
                Expanded(
                  child: GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    behavior: HitTestBehavior.translucent,
                    child: messagesAsync.when(
                      data: (messages) => WdChatMessageList(
                        messages: messages,
                        scrollController: _scrollController,
                        currentUserId: user?.id,
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                    ),
                  ),
                ),
                WdChatInputBar(
                  textController: _textController,
                  isRecording: _isRecording,
                  recordSeconds: _recordSeconds,
                  onSendText: _onSendText,
                  onStartVoiceRecording: _startVoiceRecording,
                  onStopAndSendVoice: _stopAndSendVoice,
                  onCancelVoiceRecording: _cancelVoiceRecording,
                  onOpenGifting: widget.onOpenGiftingSheet ??
                      () => GiftSelectionSheet.show(context),
                  dynamicBottomSpacing: dynamicBottomSpacing,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
