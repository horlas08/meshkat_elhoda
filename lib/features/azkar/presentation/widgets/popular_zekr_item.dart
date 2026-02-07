import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';

class PopularZekrItem extends StatelessWidget {
  const PopularZekrItem({
    super.key,
    required this.zekrType,
    required this.isAccessible,
    this.onTap,
  });

  final String zekrType;
  final bool isAccessible;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(5.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5.r),
        splashColor: AppColors.goldenColor.withValues(alpha: 0.3),
        highlightColor: AppColors.goldenColor.withValues(alpha: 0.3),
        child: Opacity(
          opacity: isAccessible ? 1.0 : 0.6,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
            decoration: BoxDecoration(
              border: Border.all(
                width: 0.7.w,
                color: isAccessible
                    ? (Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade700
                          : AppColors.greyColor)
                    : Colors.grey.shade400,
              ),
              borderRadius: BorderRadius.circular(5.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    zekrType,
                    style: AppTextStyles.surahName.copyWith(
                      fontSize: 13.sp,
                      fontFamily: AppFonts.tajawal,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    textAlign: TextAlign.center,
                    softWrap: true,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!isAccessible) ...[
                  SizedBox(width: 4.w),
                  Icon(Icons.lock, size: 14.sp, color: Colors.orange.shade700),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
