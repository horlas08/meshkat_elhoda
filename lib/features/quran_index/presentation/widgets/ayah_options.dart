import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_assets.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/widgets/surah_options.dart';

import '../../../../l10n/app_localizations.dart';

class AyahOptionsDialog extends StatelessWidget {
  const AyahOptionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Container(
      width: 260.w,
      decoration: BoxDecoration(
        color: const Color(0xfffffcf6),
        borderRadius: BorderRadius.circular(5.h),
      ),
      child: Column(
        children: [
          AyahOption(
            iconPath: AppAssets.play,
            title: localizations?.ayahOptionPlay ?? 'Play',
            onTap: () {},
          ),
          AyahOption(
            iconPath: AppAssets.edit,
            title: localizations?.ayahOptionTafsir ?? 'Tafsir',
            onTap: () {},
          ),
          AyahOption(
            iconPath: AppAssets.translate,
            title: localizations?.ayahOptionLanguage ?? 'Language',
            onTap: () {},
          ),
          AyahOption(
            iconPath: AppAssets.download,
            title: localizations?.ayahOptionDownload ?? 'Download',
            onTap: () {},
          ),
          AyahOption(
            iconPath: AppAssets.share,
            title: localizations?.ayahOptionShare ?? 'Share',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
