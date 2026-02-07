import 'dart:io';
import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_assets.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/widgets/quran_icon.dart';

import '../../../../l10n/app_localizations.dart';

class QuranAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;

  const QuranAppBar({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final canPop = Navigator.canPop(context);

    return Container(
      height: 100.h,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(5.h),
          bottomRight: Radius.circular(5.h),
        ),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.w,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 20.h),
        child: Row(
          children: [
            // زر الرجوع لنظام iOS
            if (Platform.isIOS && canPop)
              Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: AppColors.goldenColor,
                    size: 22.sp,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            Expanded(
              child: TabBar(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                controller: tabController,
                labelColor: AppColors.goldenColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.goldenColor,
                tabs: [
                  QuranIcon(
                    title: localizations?.quranIndex ?? 'Index',
                    iconPath: AppAssets.content,
                  ),
                  QuranIcon(
                    title: localizations?.quranParts ?? 'Parts',
                    iconPath: AppAssets.parts,
                  ),
                  QuranIcon(
                    title: localizations?.quranBookmarks ?? 'Bookmarks',
                    iconPath: AppAssets.saved,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(85.h); // تأكد من أن الارتفاع مناسب
}
