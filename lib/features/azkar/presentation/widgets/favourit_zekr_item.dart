import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/hadith/presentation/widgets/favourite_icon.dart';

import '../../../../l10n/app_localizations.dart';

class FavoritZekrItem extends StatelessWidget {
  final String zekrText;
  final int? repeat;
  final void Function() onFavourit;

  const FavoritZekrItem({
    super.key,
    required this.zekrText,
    required this.onFavourit,
    this.repeat = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            FavoriteIcon(onFavorite: onFavourit),
            SizedBox(width: 8.w),
            Text(zekrText, style: AppTextStyles.surahName),
            Spacer(),
            Text('${AppLocalizations.of(context)!.repeat}$repeat', style: AppTextStyles.surahName),
          ],
        ),
        SizedBox(height: 8.h),
        Divider(),
        SizedBox(height: 8.h),
      ],
    );
  }
}
