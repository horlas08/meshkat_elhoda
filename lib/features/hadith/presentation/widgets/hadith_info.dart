import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';

class HadithInfo extends StatelessWidget {
  const HadithInfo({
    super.key,
    required this.source,
    required this.grade,
    required this.fontScale,
  });

  final String source;
  final String grade;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${AppLocalizations.of(context)!.sourceLabel}: $source',
          style: AppTextStyles.zekr.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.whiteColor
                : AppColors.darkRed,
            fontSize: 11.sp * fontScale,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '${AppLocalizations.of(context)!.hadithGradeLabel}: $grade',
          style: AppTextStyles.zekr.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.whiteColor
                : AppColors.darkRed,
            fontSize: 11.sp * fontScale,
          ),
        ),
      ],
    );
  }
}
