import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';

class WdAuthTabSwitcher extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTabSelected;
  final List<String> tabs;

  const WdAuthTabSwitcher({
    super.key,
    required this.activeIndex,
    required this.onTabSelected,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: BelieveColors.glassBorder),
      ),
      child: Row(
        children: List.generate(
          tabs.length,
          (index) {
            final isSelected = activeIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  if (activeIndex != index) {
                    onTabSelected(index);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(vertical: 9.h),
                  decoration: BoxDecoration(
                    gradient: isSelected ? BelieveColors.primaryGradient : null,
                    color: isSelected ? null : Colors.transparent,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Center(
                    child: Text(
                      tabs[index],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color:
                            isSelected ? Colors.white : BelieveColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
