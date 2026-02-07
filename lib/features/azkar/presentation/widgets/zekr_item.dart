import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';

class ZekrItem extends StatelessWidget {
  const ZekrItem({
    super.key,
    required this.text,
    required this.imagePath,
    this.onTap,
  });

  final String text;
  final String imagePath;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          border: Border.all(width: 0.8.w, color: AppColors.greyColor),
          borderRadius: BorderRadius.circular(5.r),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset(imagePath, height: 24.h, width: 24.w),
            SizedBox(width: 16),
            Text(
              text,
              style: AppTextStyles.surahName.copyWith(fontSize: 13.sp),
            ),
          ],
        ),
      ),
    );
  }
}
