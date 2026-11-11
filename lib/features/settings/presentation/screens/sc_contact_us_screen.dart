import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/features/settings/presentation/widgets/wd_contact_channel_list.dart';
import 'package:thae_nge_lay/features/settings/presentation/widgets/wd_contact_feedback_card.dart';
import 'package:thae_nge_lay/features/settings/presentation/widgets/wd_contact_hero_banner.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  static const String _phoneNumber = '+959778625843';
  static const String _emailAddress = 'yanlynnaung.ucsmgy@gmail.com';
  static const String _facebookPageUrl =
      'https://www.facebook.com/share/1DR4umP335/';
  static const String _viberChatUrl = 'viber://chat?number=%2B959404106269';
  static const String _viberWebFallback = 'https://viber.com';

  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _launchUri(
    Uri uri, {
    String? fallbackUrl,
    String? copyFallbackText,
    required String actionLabel,
  }) async {
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && fallbackUrl != null) {
        final fallbackUri = Uri.parse(fallbackUrl);
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      } else if (!launched) {
        _showCopySnackBar(copyFallbackText ?? uri.toString(), actionLabel);
      }
    } catch (_) {
      if (fallbackUrl != null) {
        try {
          await launchUrl(
            Uri.parse(fallbackUrl),
            mode: LaunchMode.externalApplication,
          );
          return;
        } catch (_) {}
      }
      _showCopySnackBar(copyFallbackText ?? uri.toString(), actionLabel);
    }
  }

  void _showCopySnackBar(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: const BorderSide(color: BelieveColors.glassBorder),
        ),
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.r),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: BelieveColors.primaryGradient,
              ),
              child: const Icon(LucideIcons.copy, color: Colors.white, size: 14),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'Could not launch $label directly. Copied "$text" to clipboard! ❤️',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: BelieveColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
          side: const BorderSide(color: BelieveColors.glassBorder),
        ),
        content: Row(
          children: [
            const Icon(LucideIcons.checkCheck, color: BelieveColors.success, size: 16),
            SizedBox(width: 8.w),
            Text(
              '$label copied to clipboard! ✨',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: BelieveColors.textPrimary,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BelieveColors.background,
      appBar: AppBar(
        title: Text(
          'Contact Us ✨',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: BelieveColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WdContactHeroBanner(),
            SizedBox(height: 24.h),
            WdContactChannelList(
              onCallPhone: () => _launchUri(
                Uri(scheme: 'tel', path: _phoneNumber),
                copyFallbackText: _phoneNumber,
                actionLabel: 'phone dialer',
              ),
              onSendEmail: () => _launchUri(
                Uri(
                  scheme: 'mailto',
                  path: _emailAddress,
                  queryParameters: {
                    'subject': 'Thae Thae App - Couple Inquiry & Support',
                  },
                ),
                copyFallbackText: _emailAddress,
                actionLabel: 'email client',
              ),
              onOpenFacebook: () => _launchUri(
                Uri.parse(_facebookPageUrl),
                fallbackUrl: _facebookPageUrl,
                copyFallbackText: _facebookPageUrl,
                actionLabel: 'Facebook',
              ),
              onOpenViber: () => _launchUri(
                Uri.parse(_viberChatUrl),
                fallbackUrl: _viberWebFallback,
                copyFallbackText: _phoneNumber,
                actionLabel: 'Viber chat',
              ),
              onCopy: _copyToClipboard,
            ),
            SizedBox(height: 24.h),
            WdContactFeedbackCard(
              controller: _feedbackController,
              onSend: () {
                final note = _feedbackController.text.trim();
                _launchUri(
                  Uri(
                    scheme: 'mailto',
                    path: _emailAddress,
                    queryParameters: {
                      'subject': 'Love Note & Feedback for Thae Thae',
                      if (note.isNotEmpty) 'body': note,
                    },
                  ),
                  copyFallbackText: _emailAddress,
                  actionLabel: 'email client',
                );
              },
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}
