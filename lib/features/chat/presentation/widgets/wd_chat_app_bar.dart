import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';

class WdChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String partnerName;

  const WdChatAppBar({
    super.key,
    required this.partnerName,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        children: [
          Text(
            partnerName,
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
    );
  }
}
