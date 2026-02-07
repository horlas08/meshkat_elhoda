import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';

class HadithExplanation extends StatelessWidget {
  const HadithExplanation({
    super.key,
    required this.explanation,
    required this.fontScale,
  });
  final String explanation;
  final double fontScale;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ': الشرح',
          style: AppTextStyles.surahName.copyWith(
            color: AppColors.darkRed,
            fontSize: 13.sp * fontScale,
          ),
        ),
        Text(
          explanation,
          textAlign: TextAlign.start,
          style: AppTextStyles.surahName.copyWith(fontSize: 13.sp * fontScale),
        ),
      ],
    );
  }
}
