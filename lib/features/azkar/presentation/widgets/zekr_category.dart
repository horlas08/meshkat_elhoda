import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart'
    show AppTextStyles;
import 'package:meshkat_elhoda/core/utils/size_utils.dart';

class ZkerCategory extends StatelessWidget {
  const ZkerCategory({
    super.key,
    required this.zekrName,
    required this.isAccessible,
    this.onTap,
  });

  final String zekrName;
  final bool isAccessible;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(5.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(5.r),
        splashColor: AppColors.goldenColor.withValues(alpha: .20),
        highlightColor: Colors.transparent,
        onTap: onTap,
        child: Opacity(
          opacity: isAccessible ? 1.0 : 0.6,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    zekrName,
                    style: AppTextStyles.surahName.copyWith(
                      fontSize: 13.sp,
                      fontFamily: AppFonts.tajawal,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                if (!isAccessible) ...[
                  Icon(Icons.lock, size: 18.sp, color: Colors.orange.shade700),
                  SizedBox(width: 8.w),
                ],
                Icon(
                  Icons.arrow_forward_ios,
                  color: isAccessible
                      ? AppColors.goldenColor
                      : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
