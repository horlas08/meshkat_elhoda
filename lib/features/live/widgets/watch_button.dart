import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';

class WatchButton extends StatelessWidget {
  const WatchButton({super.key, required this.onWatchTap});

  final VoidCallback onWatchTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onWatchTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 10.w),
        decoration: BoxDecoration(
          color: AppColors.goldenColor,
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Text(
          AppLocalizations.of(context)!.watch,
          style: AppTextStyles.surahName.copyWith(
            color: AppColors.whiteColor,
            fontSize: 13.sp,
            fontFamily: AppFonts.tajawal,
          ),
        ),
      ),
    );
  }
}
