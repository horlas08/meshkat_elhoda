import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/features/tasbeh/presentation/widget/custom_icon.dart';

class TasbeehActionButton extends StatelessWidget {
  final String text;
  final String iconPath;
  final VoidCallback? onTap;
  final Color backgroundColor;

  const TasbeehActionButton({
    super.key,
    required this.text,
    required this.iconPath,
    required this.onTap,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5.h),
      child: Container(
        constraints: BoxConstraints(minWidth: 91.w, maxWidth: 120.w),
        padding: EdgeInsets.symmetric(vertical: 16.w, horizontal: 8.w),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(5.h),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                text,
                style: AppTextStyles.surahName.copyWith(
                  fontSize: 18.sp,
                  color: AppColors.whiteColor,
                  fontFamily: AppFonts.tajawal,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            SizedBox(width: 4.w),
            CustomIcon(iconPath: iconPath),
          ],
        ),
      ),
    );
  }
}
