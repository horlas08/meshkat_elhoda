import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';

class SettingItem extends StatelessWidget {
  final IconData? iconData;
  final Widget? iconWidget;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const SettingItem({
    super.key,
    this.iconData,
    this.iconWidget,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icon =
        iconWidget ??
        (iconData != null
            ? Icon(iconData, size: 18.sp, color: AppColors.goldenColor)
            : Icon(Icons.help_outline, size: 18.sp, color: Colors.red));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Row(
          children: [
            icon,
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.surahName.copyWith(
                      fontSize: 12.sp,
                      fontFamily: AppFonts.tajawal,
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppColors.blacColor
                          : AppColors.whiteColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      subtitle!,
                      style: AppTextStyles.surahName.copyWith(
                        fontSize: 10.sp,
                        fontFamily: AppFonts.tajawal,
                        color: AppColors.greyColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
