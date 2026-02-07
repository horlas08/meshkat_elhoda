import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';

class AppTextStyles {
  static final TextStyle surahName = TextStyle(
    fontSize: 10.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.blacColor,
    fontFamily: AppFonts.quran,
  );

  static final TextStyle surahFrame = TextStyle(
    fontFamily: AppFonts.surahFrame,
    fontSize: 58.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.secondaryColor.withValues(alpha: 0.33),
    inherit: false,
  );

  static final TextStyle zekr = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.blacColor,
    fontFamily: AppFonts.tajawal,
  );

  static final TextStyle topHeadline = TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w800,
    color: AppColors.darkRed,
    fontFamily: AppFonts.tajawal,
  );
}
