import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/widgets/zekr_action_button.dart';
import 'package:meshkat_elhoda/features/hadith/presentation/widgets/favourite_icon.dart';

import '../../../../l10n/app_localizations.dart';

class ZekrCard extends StatelessWidget {
  final String zekrText;
  final String? translation;
  final String? source;
  final VoidCallback onCoppy;
  final VoidCallback onShare;
  final VoidCallback onFavorite;
  final int? repeat;
  final double fontScale;
  final bool isFavorite;

  const ZekrCard({
    super.key,
    required this.zekrText,
    this.translation,
    this.source,
    required this.onCoppy,
    required this.onShare,
    required this.onFavorite,
    this.repeat,
    required this.fontScale,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 15.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
                child: Column(
                  children: [
                    Text(
                      zekrText,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.surahName.copyWith(
                        fontSize: 16.sp * fontScale,
                        color:
                            Theme.of(context).textTheme.bodyLarge?.color ??
                            const Color(0xff595754),
                        fontFamily: AppFonts.tajawal,
                      ),
                    ),
                    if (translation != null && translation!.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      Text(
                        translation!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.surahName.copyWith(
                          fontSize: 14.sp * fontScale,
                          color: Theme.of(context).textTheme.bodyMedium?.color ??
                              Colors.grey[700],
                          fontFamily: AppFonts.tajawal,
                          height: 1.5,
                        ),
                      ),
                    ],
                    if (source != null && source!.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      Text(
                        source!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.surahName.copyWith(
                          fontSize: 12.sp * fontScale,
                          color: Colors.grey,
                          fontFamily: AppFonts.tajawal,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              FavoriteIcon(onFavorite: onFavorite, isFavorite: isFavorite),
            ],
          ),

          SizedBox(height: 16.h),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            alignment: WrapAlignment.spaceBetween,
            children: [
              ZekrActionButton(
                // width: 65.w, // Remove fixed width
                text: '$repeat ${AppLocalizations.of(context)!.repeat}',
                onTap: () {},
              ),
              ZekrActionButton(
                // width: 65.w, // Remove fixed width
                text: AppLocalizations.of(context)!.copy,
                icon: Icons.copy,
                onTap: onCoppy,
              ),
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
