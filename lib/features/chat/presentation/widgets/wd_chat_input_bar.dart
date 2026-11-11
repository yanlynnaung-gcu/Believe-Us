import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';

class WdChatInputBar extends StatelessWidget {
  final TextEditingController textController;
  final bool isRecording;
  final int recordSeconds;
  final VoidCallback onSendText;
  final VoidCallback onStartVoiceRecording;
  final VoidCallback onStopAndSendVoice;
  final VoidCallback onCancelVoiceRecording;
  final VoidCallback onOpenGifting;
  final double dynamicBottomSpacing;

  const WdChatInputBar({
    super.key,
    required this.textController,
    required this.isRecording,
    required this.recordSeconds,
    required this.onSendText,
    required this.onStartVoiceRecording,
    required this.onStopAndSendVoice,
    required this.onCancelVoiceRecording,
    required this.onOpenGifting,
    required this.dynamicBottomSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 4.h,
        bottom: dynamicBottomSpacing,
      ),
      child: GlassmorphicCard(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        borderRadius: 32.r,
        child: isRecording ? _buildRecordingBar() : _buildNormalInputBar(context),
      ),
    );
  }

  Widget _buildRecordingBar() {
    final minutes = recordSeconds ~/ 60;
    final seconds = recordSeconds % 60;
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
          onPressed: onCancelVoiceRecording,
        ),
        GestureDetector(
          onTap: onStopAndSendVoice,
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

  Widget _buildNormalInputBar(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(
            LucideIcons.gift,
            color: BelieveColors.champagne,
            size: 22,
          ),
          onPressed: onOpenGifting,
        ),
        Expanded(
          child: TextField(
            controller: textController,
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
            onSubmitted: (_) => onSendText(),
          ),
        ),
        SizedBox(width: 6.w),
        IconButton(
          icon: const Icon(
            LucideIcons.mic,
            color: BelieveColors.primary,
            size: 22,
          ),
          onPressed: onStartVoiceRecording,
        ),
        GestureDetector(
          onTap: onSendText,
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
