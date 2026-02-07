import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';

class ZekrSectionHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onActionTap;

  const ZekrSectionHeader({
    super.key,
    required this.title,
    required this.actionText,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.zekr.copyWith(
            color: AppColors.darkRed,
            fontSize: 16.sp,
          ),
        ),
        InkWell(
          onTap: onActionTap,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Text(
            actionText,
            style: AppTextStyles.topHeadline.copyWith(
              color: AppColors.goldenColor,
              decoration: TextDecoration.underline,
              fontSize: 11.sp,
            ),
          ),
        ),
      ],
    );
  }
}
