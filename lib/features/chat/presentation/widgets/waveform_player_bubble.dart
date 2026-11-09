import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/features/chat/data/services/audio_playback_service.dart';
import 'package:thae_nge_lay/features/chat/domain/models/chat_message.dart';

class WaveformPlayerBubble extends ConsumerStatefulWidget {
  final ChatMessage message;
  final bool isMe;

  const WaveformPlayerBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  ConsumerState<WaveformPlayerBubble> createState() =>
      _WaveformPlayerBubbleState();
}

class _WaveformPlayerBubbleState extends ConsumerState<WaveformPlayerBubble> {
  bool _showHeartReaction = false;

  void _onPlay() {
    final playbackService = ref.read(audioPlaybackServiceProvider);
    final path = widget.message.audioPath;
    if (path != null) {
      playbackService.playAudio(path);
      setState(() => _showHeartReaction = true);
    } else {
      setState(() => _showHeartReaction = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final playbackService = ref.watch(audioPlaybackServiceProvider);
    final currentState = playbackService.currentState;
    final isActive = currentState.activeAudioPath == widget.message.audioPath;
    final isPlaying = isActive && currentState.isPlaying;

    final samples = widget.message.waveformSamples ??
        [0.4, 0.7, 0.5, 0.9, 0.6, 0.8, 0.4, 0.5, 0.7, 0.3, 0.6, 0.8, 0.5, 0.7];

    double progress = 0.0;
    if (isActive && currentState.totalDuration.inMilliseconds > 0) {
      progress = (currentState.position.inMilliseconds /
              currentState.totalDuration.inMilliseconds)
          .clamp(0.0, 1.0);
    }

    final durationSeconds = widget.message.audioDurationSeconds ?? 0;
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    final durationText = '$minutes:${seconds.toString().padLeft(2, '0')}';

    return Container(
      width: 220.w,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            children: [
              // Rose-Gold Play/Pause Button
              GestureDetector(
                onTap: _onPlay,
                child: Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: widget.isMe
                        ? const LinearGradient(
                            colors: [Color(0xFFFFFFFF), Color(0xFFFFF0F3)],
                          )
                        : BelieveColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: BelieveColors.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      isPlaying ? LucideIcons.pause : LucideIcons.play,
                      color: widget.isMe ? BelieveColors.primary : Colors.white,
                      size: 20.r,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),

              // Animated Soundwave Bars
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 28.h,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(samples.length, (index) {
                          final barProgress = index / samples.length;
                          final isPlayed = isActive && barProgress <= progress;

                          Color barColor;
                          if (widget.isMe) {
                            barColor = isPlayed
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.4);
                          } else {
                            barColor = isPlayed
                                ? BelieveColors.primary
                                : BelieveColors.textMuted.withValues(alpha: 0.4);
                          }

                          final height =
                              (samples[index] * 24.h).clamp(4.h, 24.h);

                          return Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin: EdgeInsets.symmetric(horizontal: 1.w),
                              height: isPlaying ? (height * 1.1) : height,
                              decoration: BoxDecoration(
                                color: barColor,
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      durationText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: widget.isMe
                            ? Colors.white.withValues(alpha: 0.85)
                            : BelieveColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Floating Heart Reaction when listened to
          if (_showHeartReaction)
            Positioned(
              top: -16.h,
              right: 0,
              child: const Text('💖')
                  .animate()
                  .moveY(begin: 0, end: -20, duration: 800.ms)
                  .fadeOut(duration: 800.ms),
            ),
        ],
      ),
    );
  }
}
