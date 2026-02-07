import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/hadith/presentation/widgets/favourite_icon.dart';
import 'package:meshkat_elhoda/features/hadith/presentation/widgets/zekr_action_button.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';

class HadithCard extends StatelessWidget {
  final String hadithText;
  final String source;
  final VoidCallback onReadMore;
  final VoidCallback onShare;
  final VoidCallback onFavorite;
  final bool isFavorite;

  const HadithCard({
    super.key,
    required this.hadithText,
    required this.source,
    required this.onReadMore,
    required this.onShare,
    required this.onFavorite,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 15.h),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : AppColors.textFieldColor,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '$hadithText\n$source',
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.surahName.copyWith(
                    fontSize: 12.sp,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : const Color(0xff595754),
                    fontFamily: AppFonts.tajawal,
                  ),
                ),
              ),
              FavoriteIcon(onFavorite: onFavorite, isFavorite: isFavorite),
            ],
          ),

          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ZekrActionButton(
                text: AppLocalizations.of(context)!.seeMore,
                textColor: AppColors.whiteColor,
                borderColor: AppColors.goldenColor,
                buttonColor: AppColors.goldenColor,
                onTap: onReadMore,
              ),

              SizedBox(width: 15.w),

              ZekrActionButton(
                text: AppLocalizations.of(context)!.share,
                icon: Icons.share_rounded,
                onTap: onShare,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
