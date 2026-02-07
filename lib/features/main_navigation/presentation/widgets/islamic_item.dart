import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';

class IslamicItem extends StatelessWidget {
  final Color color;
  final String text;
  final String iconPath;
  final VoidCallback? onTap;

  const IslamicItem({
    super.key,
    required this.color,
    required this.text,
    required this.iconPath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.h),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20.h),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(iconPath, height: 40.h, width: 40.w),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                text,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.surahName.copyWith(
                  fontSize: 13.sp,
                  color: Colors.white,
                  fontFamily: AppFonts.tajawal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
