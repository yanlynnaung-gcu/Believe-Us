import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thae_nge_lay/core/theme/app_colors.dart';

class WdSignupRoleSelector extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onRoleSelected;

  const WdSignupRoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I am the:',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: BelieveColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => onRoleSelected('BOYFRIEND'),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: selectedRole == 'BOYFRIEND'
                        ? BelieveColors.primarySoft
                        : Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: selectedRole == 'BOYFRIEND'
                          ? BelieveColors.primary
                          : BelieveColors.glassBorder,
                      width: selectedRole == 'BOYFRIEND' ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text('👦', style: TextStyle(fontSize: 22.sp)),
                      SizedBox(height: 4.h),
                      Text(
                        'Boyfriend',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: selectedRole == 'BOYFRIEND'
                              ? BelieveColors.primaryDark
                              : BelieveColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: GestureDetector(
                onTap: () => onRoleSelected('GIRLFRIEND'),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: selectedRole == 'GIRLFRIEND'
                        ? BelieveColors.primarySoft
                        : Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: selectedRole == 'GIRLFRIEND'
                          ? BelieveColors.primary
                          : BelieveColors.glassBorder,
                      width: selectedRole == 'GIRLFRIEND' ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text('👧', style: TextStyle(fontSize: 22.sp)),
                      SizedBox(height: 4.h),
                      Text(
                        'Girlfriend',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: selectedRole == 'GIRLFRIEND'
                              ? BelieveColors.primaryDark
                              : BelieveColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
