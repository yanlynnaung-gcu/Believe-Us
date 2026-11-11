import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/features/settings/presentation/widgets/wd_contact_action_card.dart';

/// Section listing the 4 direct contact channels (Phone, Email, Facebook, Viber)
class WdContactChannelList extends StatelessWidget {
  final VoidCallback onCallPhone;
  final VoidCallback onSendEmail;
  final VoidCallback onOpenFacebook;
  final VoidCallback onOpenViber;
  final void Function(String text, String label) onCopy;

  const WdContactChannelList({
    super.key,
    required this.onCallPhone,
    required this.onSendEmail,
    required this.onOpenFacebook,
    required this.onOpenViber,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    const phoneNumber = '+959778625843';
    const emailAddress = 'yanlynnaung.ucsmgy@gmail.com';
    const facebookPageUrl = 'https://www.facebook.com/share/1DR4umP335/';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Direct Channels',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: BelieveColors.textPrimary,
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: 12.h),
        WdContactActionCard(
          icon: LucideIcons.phoneCall,
          iconGradient: const LinearGradient(
            colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
          ),
          title: 'Direct Phone Call',
          subtitle: phoneNumber,
          badgeText: 'Instant Dial',
          onTap: onCallPhone,
          onCopy: () => onCopy(phoneNumber, 'Phone number'),
        ),
        SizedBox(height: 12.h),
        WdContactActionCard(
          icon: LucideIcons.mail,
          iconGradient: BelieveColors.primaryGradient,
          title: 'Email Support',
          subtitle: emailAddress,
          badgeText: 'Mail App',
          onTap: onSendEmail,
          onCopy: () => onCopy(emailAddress, 'Email address'),
        ),
        SizedBox(height: 12.h),
        WdContactActionCard(
          icon: Icons.facebook,
          iconGradient: const LinearGradient(
            colors: [Color(0xFF1877F2), Color(0xFF0C56B8)],
          ),
          title: 'Facebook Page',
          subtitle: 'facebook.com/thaethaeapp',
          badgeText: 'Official Page',
          onTap: onOpenFacebook,
          onCopy: () => onCopy(facebookPageUrl, 'Facebook link'),
        ),
        SizedBox(height: 12.h),
        WdContactActionCard(
          icon: LucideIcons.messageSquare,
          iconGradient: const LinearGradient(
            colors: [Color(0xFF7360F2), Color(0xFF59267C)],
          ),
          title: 'Viber Direct Chat',
          subtitle: 'Chat directly via $phoneNumber',
          badgeText: 'Viber App',
          onTap: onOpenViber,
          onCopy: () => onCopy(phoneNumber, 'Viber number'),
        ),
      ],
    );
  }
}
