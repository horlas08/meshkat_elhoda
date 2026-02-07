import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/live/widgets/live_now_weidget.dart';
import 'package:meshkat_elhoda/features/live/widgets/watch_button.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';

class LiveChannelCard extends StatelessWidget {
  const LiveChannelCard({
    super.key,
    required this.title,
    required this.image,
    required this.channelName,
    required this.onWatchTap,
    required this.onAboutTap,
  });

  final String title;
  final String channelName;
  final String image;
  final VoidCallback onWatchTap;
  final VoidCallback onAboutTap;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.r),
        color: Theme.of(context).cardColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image.asset(image, height: 32.h, width: 32.w),
                  SizedBox(width: 8.w),
                  Text(
                    title,
                    style: AppTextStyles.zekr.copyWith(
                      fontSize: 14.sp,
                      fontFamily: AppFonts.tajawal,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8.h),
              Text(
                channelName,
                style: AppTextStyles.surahName.copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  fontFamily: AppFonts.tajawal,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                localizations?.licensedBroadcast ??
                    'هذا البث مرخّص من القنوات السعودية الرسمية',
                style: AppTextStyles.surahName.copyWith(
                  color: AppColors.greyColor,
                  fontFamily: AppFonts.tajawal,
                  fontSize: 7.sp,
                ),
              ),
              SizedBox(height: 8.h),
              LiveNowWidget(),
            ],
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(height: 8.h),

              /*InkWell(
                onTap: onAboutTap,
                child: CustomIcon(iconPath: AppAssets.about),
              ),*/
              SizedBox(height: 32.h),

              WatchButton(onWatchTap: onWatchTap),
            ],
          ),
        ],
      ),
    );
  }
}
