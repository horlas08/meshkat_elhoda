import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_assets.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/tasbeh/presentation/widget/custom_icon.dart';

class DateDetailsWidget extends StatelessWidget {
  final String day;
  final String month;
  final String year;
  final String date;
  final VoidCallback? onTap;

  const DateDetailsWidget({
    super.key,
    required this.day,
    required this.month,
    required this.year,
    required this.date,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$day، $date $month $year',
          style: AppTextStyles.surahName.copyWith(
            fontSize: 13.sp,
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.blacColor
                : AppColors.whiteColor,
            fontFamily: AppFonts.tajawal,
          ),
        ),
        SizedBox(width: 8.w),
        GestureDetector(
          onTap: onTap,
          child: CustomIcon(
            iconPath: AppAssets.down,
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.blacColor
                : AppColors.whiteColor,
          ),
        ),
      ],
    );
  }
}
