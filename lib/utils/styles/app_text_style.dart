import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thae_nge_lay/utils/const/color.dart';

abstract final class AppTextStyle {
  static final whiteTextSmall = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.baseWhite,
  );

  static final baseTextStyleSmall = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.baseBlack,
  );
  static final captionText = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.scanTextColor,
  );

  static final errorTextSmall = TextStyle(
    fontSize: 12.sp,
    color: AppColors.error500,
    fontWeight: FontWeight.w500,
  );

  static final normalTextStyle = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.baseBlack,
  );

  static final scanTextStyle = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.scanTextColor,
  );

  static final normalPrimaryStyle = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryColor,
  );
  static final whiteTextMedium = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.baseWhite,
  );

  static final baseTextStyleMedium = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.baseBlack,
  );

  static final appBarTilte = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryColor,
  );

  static final baseTextStyleLarge = TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.baseBlack,
  );

  static final errorDialogTitle = TextStyle(
    color: AppColors.error500,
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
  );
}
