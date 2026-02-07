import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/hadith/presentation/widgets/favourite_icon.dart';

class HadithTextWithActions extends StatelessWidget {
  final VoidCallback onFavorite;
  final VoidCallback onShare;
  final VoidCallback onCopy;
  final String hadithText;
  final double fontScale;
  final bool isFavorite;

  const HadithTextWithActions({
    super.key,
    required this.onFavorite,
    required this.onShare,
    required this.onCopy,
    required this.hadithText,
    required this.fontScale,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            hadithText,
            textAlign: TextAlign.start,
            style: AppTextStyles.surahName.copyWith(
              fontSize: 16.sp * fontScale,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.whiteColor
                  : AppColors.blacColor,
            ),
          ),
        ),
        Column(
          children: [
            FavoriteIcon(onFavorite: onFavorite, isFavorite: isFavorite),
            SizedBox(height: 8.h),
            IconButton(
              onPressed: onShare,
              icon: Icon(Icons.share, color: AppColors.goldenColor),
            ),
            SizedBox(height: 8.h),
            IconButton(
              onPressed: onCopy,
              icon: Icon(Icons.copy, color: AppColors.goldenColor),
            ),
          ],
        ),
      ],
    );
  }
}
