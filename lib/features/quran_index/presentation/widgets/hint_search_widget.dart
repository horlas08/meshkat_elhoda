import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:meshkat_elhoda/core/utils/app_assets.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';

import '../../../../l10n/app_localizations.dart';

class HintSearchWidget extends StatelessWidget {
  const HintSearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          localizations?.searchInSurahNames ?? 'Search in Surah Names',
          style: AppTextStyles.surahName.copyWith(
            color: AppColors.greyColor,
            fontFamily: AppFonts.tajawal,
          ),
        ),
        SvgPicture.asset(AppAssets.search),
      ],
    );
  }
}
