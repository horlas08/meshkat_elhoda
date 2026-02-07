import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/tasbeh/presentation/widget/back_icon.dart';

class IslamicAppbar extends StatelessWidget {
  const IslamicAppbar({
    super.key,
    required this.title,
    required this.onTap,
    this.fontSize = 18,
  });

  final String title;
  final void Function()? onTap;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: BackIcon(onTap: onTap),
        ),
        Text(
          title,
          style: AppTextStyles.topHeadline.copyWith(
            fontSize: fontSize,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.whiteColor
                : AppColors.goldenColor,
          ),
        ),
      ],
    );
  }
}
