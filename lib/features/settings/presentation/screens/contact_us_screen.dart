import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/core/theme/glassmorphic_card.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  // Contact details
  static const String _phoneNumber = '+959777123456';
  static const String _displayPhone = '+95 9 777 123 456';
  static const String _emailAddress = 'support@thaethae.love';
  static const String _facebookPageUrl = 'https://www.facebook.com/thaethaeapp';
  static const String _viberChatUrl = 'viber://chat?number=%2B959777123456';
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
              child: const Icon(
                LucideIcons.copy,
                color: Colors.white,
                size: 14,
              ),
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

  void _callPhone() {
    final uri = Uri(scheme: 'tel', path: _phoneNumber);
    _launchUri(
      uri,
      copyFallbackText: _phoneNumber,
      actionLabel: 'phone dialer',
    );
  }

  void _sendEmail({String? customSubject, String? customBody}) {
    final uri = Uri(
      scheme: 'mailto',
      path: _emailAddress,
      queryParameters: {
        'subject': customSubject ?? 'Thae Thae App - Couple Inquiry & Support',
        if (customBody != null && customBody.isNotEmpty) 'body': customBody,
      },
    );
    _launchUri(
      uri,
      copyFallbackText: _emailAddress,
      actionLabel: 'email client',
    );
  }

  void _openFacebook() {
    final uri = Uri.parse(_facebookPageUrl);
    _launchUri(
      uri,
      fallbackUrl: _facebookPageUrl,
      copyFallbackText: _facebookPageUrl,
      actionLabel: 'Facebook',
    );
  }

  void _openViber() {
    final uri = Uri.parse(_viberChatUrl);
    _launchUri(
      uri,
      fallbackUrl: _viberWebFallback,
      copyFallbackText: _phoneNumber,
      actionLabel: 'Viber chat',
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
            // Romantic Hero Banner
            GlassmorphicCard(
              padding: EdgeInsets.all(20.r),
              surfaceColor: Colors.white.withValues(alpha: 0.9),
              child: Column(
                children: [
                  Container(
                    width: 58.w,
                    height: 58.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: BelieveColors.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: BelieveColors.primarySoft,
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      LucideIcons.heartHandshake,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    'We Love Hearing From You',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w800,
                      color: BelieveColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Whether you need help with pairing, location syncing, gifting, or want to share feedback for your love journey — we are here.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      color: BelieveColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: BelieveColors.primarySoft,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.sparkles,
                          size: 13,
                          color: BelieveColors.primary,
                        ),
                        SizedBox(width: 6.w),
                        Flexible(
                          child: Text(
                            '24/7 Dedicated Couple Support 💌',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: BelieveColors.burgundy,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Section Header
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

            // 1. Phone Call Action Card
            _ContactActionCard(
              icon: LucideIcons.phoneCall,
              iconGradient: const LinearGradient(
                colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
              ),
              title: 'Direct Phone Call',
              subtitle: _displayPhone,
              badgeText: 'Instant Dial',
              onTap: _callPhone,
              onCopy: () => _copyToClipboard(_phoneNumber, 'Phone number'),
            ),
            SizedBox(height: 12.h),

            // 2. Email Action Card
            _ContactActionCard(
              icon: LucideIcons.mail,
              iconGradient: BelieveColors.primaryGradient,
              title: 'Email Support',
              subtitle: _emailAddress,
              badgeText: 'Mail App',
              onTap: () => _sendEmail(),
              onCopy: () => _copyToClipboard(_emailAddress, 'Email address'),
            ),
            SizedBox(height: 12.h),

            // 3. Facebook Page Action Card
            _ContactActionCard(
              icon: Icons.facebook,
              iconGradient: const LinearGradient(
                colors: [Color(0xFF1877F2), Color(0xFF0C56B8)],
              ),
              title: 'Facebook Page',
              subtitle: 'facebook.com/thaethaeapp',
              badgeText: 'Official Page',
              onTap: _openFacebook,
              onCopy: () => _copyToClipboard(_facebookPageUrl, 'Facebook link'),
            ),
            SizedBox(height: 12.h),

            // 4. Viber Chat Action Card
            _ContactActionCard(
              icon: LucideIcons.messageSquare,
              iconGradient: const LinearGradient(
                colors: [Color(0xFF7360F2), Color(0xFF59267C)],
              ),
              title: 'Viber Direct Chat',
              subtitle: 'Chat directly via $_displayPhone',
              badgeText: 'Viber App',
              onTap: _openViber,
              onCopy: () => _copyToClipboard(_phoneNumber, 'Viber number'),
            ),

            SizedBox(height: 24.h),

            // Quick Note Card
            GlassmorphicCard(
              padding: EdgeInsets.all(18.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.heartHandshake,
                        color: BelieveColors.primary,
                        size: 18,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Send Us A Quick Love Note',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: BelieveColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  TextField(
                    controller: _feedbackController,
                    maxLines: 3,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.sp,
                      color: BelieveColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'Share feature wishes, lovely ideas, or couple stories...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        color: BelieveColors.textMuted,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide:
                            const BorderSide(color: BelieveColors.glassBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide:
                            const BorderSide(color: BelieveColors.glassBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide:
                            const BorderSide(color: BelieveColors.primary),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    height: 44.h,
                    child: ElevatedButton(
                      onPressed: () {
                        final note = _feedbackController.text.trim();
                        _sendEmail(
                          customSubject: 'Love Note & Feedback for Thae Thae',
                          customBody: note,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BelieveColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.send,
                              size: 16, color: Colors.white),
                          SizedBox(width: 8.w),
                          Text(
                            'Send via Email',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}

class _ContactActionCard extends StatelessWidget {
  final IconData icon;
  final Gradient iconGradient;
  final String title;
  final String subtitle;
  final String badgeText;
  final VoidCallback onTap;
  final VoidCallback onCopy;

  const _ContactActionCard({
    required this.icon,
    required this.iconGradient,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.onTap,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      onTap: onTap,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: iconGradient,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: BelieveColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: BelieveColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(6.r),
                        border:
                            Border.all(color: BelieveColors.glassBorder),
                      ),
                      child: Text(
                        badgeText,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          color: BelieveColors.burgundy,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    color: BelieveColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.copy, size: 16),
            color: BelieveColors.textMuted,
            tooltip: 'Copy',
            onPressed: onCopy,
          ),
          const Icon(
            LucideIcons.chevronRight,
            size: 18,
            color: BelieveColors.textMuted,
          ),
        ],
      ),
    );
  }
}
