import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';

import '../../../../l10n/app_localizations.dart';

class SurahDetails extends StatelessWidget {
  final String arabicName;
  final String englishName;
  final int numberOfAyats;
  final String type;
  final int arrangement;
  final bool isFirst;
  final bool isLast;
  final bool isSelected;
  final VoidCallback? onTap;

  const SurahDetails({
    super.key,
    required this.arabicName,
    required this.englishName,
    required this.numberOfAyats,
    required this.type,
    required this.arrangement,
    this.isFirst = false,
    this.isLast = false,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    final borderClr = isSelected
        ? AppColors.secondaryColor
        : AppColors.greyColor;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              top: isFirst
                  ? BorderSide(color: borderClr, width: 1.w)
                  : BorderSide.none,
              bottom: isLast
                  ? BorderSide(color: borderClr, width: 1.w)
                  : BorderSide(color: borderClr, width: 0.5.w),
              left: BorderSide(color: borderClr, width: 1.w),
              right: BorderSide(color: borderClr, width: 1.w),
            ),
            borderRadius: BorderRadius.only(
              topLeft: isFirst ? Radius.circular(5.h) : Radius.zero,
              topRight: isFirst ? Radius.circular(5.h) : Radius.zero,
              bottomLeft: isLast ? Radius.circular(5.h) : Radius.zero,
              bottomRight: isLast ? Radius.circular(5.h) : Radius.zero,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اسم السورة بالعربية
                    Text(
                      arabicName,
                      style: AppTextStyles.surahName.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color:
                            Theme.of(context).textTheme.bodyLarge?.color ??
                            AppColors.darkGrey,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    // اسم السورة بالإنجليزية
                    Text(
                      englishName,
                      style: AppTextStyles.surahName.copyWith(
                        fontSize: 12.sp,
                        color: AppColors.greyColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: 4.h),

                    // معلومات السورة
                    Text(
                      '${localizations?.surahArrangementLabel ?? 'Number'} $arrangement - '
                      '${localizations?.surahAyahsCountLabel ?? 'Verses'} $numberOfAyats - '
                      '$type',
                      style: AppTextStyles.surahName.copyWith(
                        fontSize: 7.sp,
                        color: AppColors.greyColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              // دائرة رقم السورة
              Container(
                width: 24.w,
                height: 24.h,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.secondaryColor
                      : AppColors.greyColor.withValues(alpha: 0.64),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$arrangement',
                    style: AppTextStyles.surahName.copyWith(
                      color: AppColors.whiteColor,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
