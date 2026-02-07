import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/features/tasbeh/presentation/widget/back_icon.dart';

class IslamicAppbar extends StatelessWidget {
  const IslamicAppbar({
    super.key,
    required this.title,
    required this.onTap,
    this.color,
    this.fontSize,
  });

  final String title;
  final void Function()? onTap;
  final double? fontSize;
  final Color? color;

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
            color: color,
          ),
        ),
      ],
    );
  }
}
