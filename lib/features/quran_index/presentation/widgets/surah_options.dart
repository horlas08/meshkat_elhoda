import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';

class AyahOption extends StatelessWidget {
  final String title;
  final String iconPath;
  final VoidCallback onTap;

  const AyahOption({
    super.key,
    required this.title,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            SizedBox(
              height: 18.h,
              width: 18.w,
              child: SvgPicture.asset(iconPath, fit: BoxFit.contain),
            ),
            SizedBox(width: 16.w),
            Text(title, style: AppTextStyles.surahName),
            const Spacer(),
            Icon(
              Icons.arrow_back_ios_new,
              size: 18.sp,
              color: AppColors.greyColor,
            ),
          ],
        ),
      ),
    );
  }
}
