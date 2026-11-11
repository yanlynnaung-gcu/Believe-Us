import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/features/chat/domain/models/chat_message.dart';
import 'package:thae_nge_lay/features/chat/presentation/widgets/wd_chat_gift_card_bubble.dart';
import 'package:thae_nge_lay/features/chat/presentation/widgets/waveform_player_bubble.dart';

class WdChatMessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollController;
  final String? currentUserId;

  const WdChatMessageList({
    super.key,
    required this.messages,
    required this.scrollController,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
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
      controller: scrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      reverse: true,
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 12.h,
      ),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = message.senderId == currentUserId;

        return RepaintBoundary(
          child: Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.only(bottom: 12.h),
            decoration: BoxDecoration(
              gradient: isMe ? BelieveColors.primaryGradient : null,
              color: isMe ? null : Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22.r),
                topRight: Radius.circular(22.r),
                bottomLeft: isMe ? Radius.circular(22.r) : Radius.circular(4.r),
                bottomRight: isMe ? Radius.circular(4.r) : Radius.circular(22.r),
              ),
              border: isMe
                  ? null
                  : Border.all(
                      color: BelieveColors.glassBorder,
                      width: 1.2,
                    ),
              boxShadow: [
                BoxShadow(
                  color: (isMe ? BelieveColors.primary : Colors.black)
                      .withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
                        color: isMe ? Colors.white : BelieveColors.textPrimary,
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
                    DateFormat('h:mm a').format(message.createdAt),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.sp,
                      color: isMe
                          ? Colors.white.withValues(alpha: 0.75)
                          : BelieveColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
    );
  }
}
