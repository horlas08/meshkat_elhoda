import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meshkat_elhoda/core/utils/app_assets.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';

import '../../../../l10n/app_localizations.dart';

class HomeAppBar extends StatelessWidget {
  final String surahName;
  final int partNumber;

  const HomeAppBar({
    super.key,
    required this.surahName,
    required this.partNumber,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          surahName,
          style: AppTextStyles.surahName.copyWith(
            fontSize: 12.sp,
            color: AppColors.darkGrey,
          ),
        ),
        SizedBox(width: 4.w),
        Container(
          width: 10.w,
          height: 10.h,
          decoration: BoxDecoration(
            color: AppColors.greyColor.withAlpha(128),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 5.sp,
            ),
          ),
        ),
        const Spacer(),
        Text(
          '${localizations?.part ?? 'Part'} $partNumber',
          style: AppTextStyles.surahName.copyWith(color: AppColors.darkGrey),
        ),
        SizedBox(width: 2.w),
        SizedBox(
          height: 16.h,
          width: 16.w,
          child: SvgPicture.asset(AppAssets.saved2, fit: BoxFit.contain),
        ),
      ],
    );
  }
}
