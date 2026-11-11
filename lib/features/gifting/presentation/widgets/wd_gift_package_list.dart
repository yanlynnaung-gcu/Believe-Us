import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';
import 'package:thae_nge_lay/features/gifting/domain/models/gift_package.dart';

/// Selectable list of romantic gift packages
class WdGiftPackageList extends StatelessWidget {
  final List<GiftPackage> packages;
  final int selectedIndex;
  final ValueChanged<int> onSelectPackage;

  const WdGiftPackageList({
    super.key,
    required this.packages,
    required this.selectedIndex,
    required this.onSelectPackage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CHOOSE ROMANTIC PACKAGE',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: BelieveColors.textMuted,
          ),
        ),
        SizedBox(height: 10.h),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 220.h),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: packages.length,
            separatorBuilder: (_, __) => SizedBox(height: 8.h),
            itemBuilder: (context, index) {
              final pkg = packages[index];
              final isSelected = selectedIndex == index;
              return GestureDetector(
                onTap: () => onSelectPackage(index),
                child: Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? BelieveColors.primary.withValues(alpha: 0.08)
                        : BelieveColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: isSelected ? BelieveColors.primary : BelieveColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(pkg.iconEmoji, style: TextStyle(fontSize: 24.sp)),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pkg.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 13.sp,
                                color: BelieveColors.textPrimary,
                              ),
                            ),
                            Text(
                              pkg.description,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.sp,
                                color: BelieveColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${NumberFormat("#,###").format(pkg.amountMmK)} MMK',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.sp,
                          color: BelieveColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
