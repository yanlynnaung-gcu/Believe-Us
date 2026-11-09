import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';
import 'package:thae_nge_lay/core/utils/image_provider_helper.dart';
import 'package:thae_nge_lay/features/auth/presentation/controllers/auth_state_notifier.dart';
import 'package:thae_nge_lay/features/chat/data/services/audio_recorder_service.dart';
import 'package:thae_nge_lay/features/chat/domain/models/chat_message.dart';
import 'package:thae_nge_lay/features/chat/presentation/controllers/chat_messages_notifier.dart';
import 'package:thae_nge_lay/features/chat/presentation/widgets/chat_gift_card_bubble.dart';
import 'package:thae_nge_lay/features/chat/presentation/widgets/waveform_player_bubble.dart';
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

    // Dynamic bottom spacing: when keyboard is open, dock cleanly right above keyboard.
    // When keyboard is closed and bottom nav is present, sit cleanly above the floating nav bar.
    final dynamicBottomSpacing = isKeyboardOpen
        ? 10.h
        : (widget.hasBottomNavBar
            ? (bottomNavHeight + safeAreaBottom + 8.h)
            : (safeAreaBottom > 0 ? safeAreaBottom : 12.h));

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: BelieveColors.background,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              media.partnerName,
              style: GoogleFonts.playfairDisplay(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: BelieveColors.textPrimary,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: BelieveColors.success,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  'Sacred Bond • Encrypted',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.sp,
                    color: BelieveColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Soft Blurred Couple Photo Wallpaper Background
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
                // Partner Live Status Pill
                const PartnerLiveStatusBar(),

                // Message Stream
                Expanded(
                  child: GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    behavior: HitTestBehavior.translucent,
                    child: messagesAsync.when(
                      data: (messages) {
                        if (messages.isEmpty) {
                          return Center(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    LucideIcons.heart,
                                    size: 48,
                                    color: BelieveColors.primarySoft,
                                  ),
                                  SizedBox(height: 12.h),
                                  Text(
                                    'Your private love stream starts here.\nSend a love note, voice memo or gift surprise!',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13.sp,
                                      color: BelieveColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          controller: _scrollController,
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          reverse: true,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final isMe =
                                message.senderId == user?.id;

                            return Align(
                              alignment: isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: EdgeInsets.only(bottom: 12.h),
                                decoration: BoxDecoration(
                                  gradient: isMe
                                      ? BelieveColors.primaryGradient
                                      : null,
                                  color: isMe
                                      ? null
                                      : Colors.white.withValues(alpha: 0.88),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(22.r),
                                    topRight: Radius.circular(22.r),
                                    bottomLeft: isMe
                                        ? Radius.circular(22.r)
                                        : Radius.circular(4.r),
                                    bottomRight: isMe
                                        ? Radius.circular(4.r)
                                        : Radius.circular(22.r),
                                  ),
                                  border: isMe
                                      ? null
                                      : Border.all(
                                          color: BelieveColors.glassBorder,
                                          width: 1.2,
                                        ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isMe
                                              ? BelieveColors.primary
                                              : Colors.black)
                                          .withValues(alpha: 0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: isMe
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    if (message.type == MessageType.text)
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.w,
                                          vertical: 10.h,
                                        ),
                                        child: Text(
                                          message.text ?? '',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color: isMe
                                                ? Colors.white
                                                : BelieveColors.textPrimary,
                                            height: 1.4,
                                          ),
                                        ),
                                      )
                                    else if (message.type == MessageType.voice)
                                      WaveformPlayerBubble(
                                        message: message,
                                        isMe: isMe,
                                      )
                                    else if (message.type == MessageType.gift)
                                      ChatGiftCardBubble(
                                        giftData: message.giftData ?? {},
                                        isMe: isMe,
                                      ),

                                    // Timestamp
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: 12.w,
                                        right: 12.w,
                                        bottom: 6.h,
                                      ),
                                      child: Text(
                                        DateFormat('h:mm a')
                                            .format(message.createdAt),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10.sp,
                                          color: isMe
                                              ? Colors.white
                                                  .withValues(alpha: 0.75)
                                              : BelieveColors.textMuted,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                    ),
                  ),
                ),

                // Floating Glass Input Bar with dynamic bottom spacing
                AnimatedPadding(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.only(
                    left: 16.w,
                    right: 16.w,
                    top: 4.h,
                    bottom: dynamicBottomSpacing,
                  ),
                  child: GlassmorphicCard(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    borderRadius: 32.r,
                    child: _isRecording
                        ? _buildRecordingBar()
                        : _buildNormalInputBar(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingBar() {
    final minutes = _recordSeconds ~/ 60;
    final seconds = _recordSeconds % 60;
    final timeStr = '$minutes:${seconds.toString().padLeft(2, '0')}';

    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: BelieveColors.error,
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          'Recording Voice Memo... $timeStr',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: BelieveColors.error,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(LucideIcons.trash2, color: BelieveColors.textMuted, size: 20),
          onPressed: _cancelVoiceRecording,
        ),
        GestureDetector(
          onTap: _stopAndSendVoice,
          child: Container(
            width: 40.w,
            height: 40.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: BelieveColors.primaryGradient,
            ),
            child: const Icon(
              LucideIcons.send,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNormalInputBar() {
    return Row(
      children: [
        // Gifting button
        IconButton(
          icon: const Icon(
            LucideIcons.gift,
            color: BelieveColors.champagne,
            size: 22,
          ),
          onPressed: widget.onOpenGiftingSheet ??
              () => GiftSelectionSheet.show(context),
        ),

        // Text input field
        Expanded(
          child: TextField(
            controller: _textController,
            textCapitalization: TextCapitalization.sentences,
            style: GoogleFonts.plusJakartaSans(fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: 'Whisper a sweet love note...',
              hintStyle: GoogleFonts.plusJakartaSans(
                color: BelieveColors.textMuted,
                fontSize: 13.sp,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 10.h,
              ),
              filled: true,
              fillColor: BelieveColors.surfaceSubtle,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24.r),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (_) => _onSendText(),
          ),
        ),
        SizedBox(width: 6.w),

        // Voice recorder button
        IconButton(
          icon: const Icon(
            LucideIcons.mic,
            color: BelieveColors.primary,
            size: 22,
          ),
          onPressed: _startVoiceRecording,
        ),

        // Send Text button
        GestureDetector(
          onTap: _onSendText,
          child: Container(
            width: 40.w,
            height: 40.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: BelieveColors.primaryGradient,
            ),
            child: const Icon(
              LucideIcons.arrowUp,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
