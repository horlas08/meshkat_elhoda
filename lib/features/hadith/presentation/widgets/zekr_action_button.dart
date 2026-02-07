import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';

class ZekrActionButton extends StatelessWidget {
  final String? text;
  final VoidCallback onTap;
  final Color? buttonColor;
  final Color? borderColor;
  final Color? textColor;
  final IconData? icon;
  final double? width;
  const ZekrActionButton({
    super.key,
    this.text,
    required this.onTap,
    this.buttonColor,
    this.textColor,
    this.icon,
    this.borderColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5.r),
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(horizontal: 4.5.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: buttonColor ?? AppColors.textFieldColor,
          borderRadius: BorderRadius.circular(5.r),
          border: Border.all(
            width: 0.7.w,
            color: borderColor ?? AppColors.greyColor,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.goldenColor, size: 15.sp),
                SizedBox(width: 4.w),
              ],
              Text(
                text ?? '',
                style: AppTextStyles.surahName.copyWith(
                  color: textColor,
                  fontSize: 11.sp,
                  fontFamily: AppFonts.tajawal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
