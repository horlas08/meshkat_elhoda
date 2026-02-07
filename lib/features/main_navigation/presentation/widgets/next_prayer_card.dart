import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';

class NextPrayerCard extends StatelessWidget {
  final String prayerName;
  final String prayerTime;
  final String remainingTime;
  final String? location;

  const NextPrayerCard({
    super.key,
    required this.prayerName,
    required this.prayerTime,
    required this.remainingTime,
    this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: location != null ? 95.h : 70.h,
      width: 150.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.h),
        color: const Color(0xE8B4B4B4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (location != null && location!.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.only(top: 6.h, bottom: 2.h),
              child: Text(
                location!,
                style: AppTextStyles.surahName.copyWith(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFonts.tajawal,
                  color: AppColors.blacColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Divider(
              color: AppColors.blacColor.withOpacity(0.3),
              thickness: 0.5,
              indent: 10.w,
              endIndent: 10.w,
              height: 4.h,
            ),
          ],
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        prayerName,
                        style: AppTextStyles.surahName.copyWith(
                          fontWeight: FontWeight.w800,
                          fontFamily: AppFonts.tajawal,
                        ),
                      ),
                      Text(
                        prayerTime,
                        style: AppTextStyles.surahName.copyWith(
                          fontFamily: AppFonts.tajawal,
                        ),
                      ),
                    ],
                  ),
                  VerticalDivider(
                    color: AppColors.blacColor,
                    thickness: 1,
                    indent: 2,
                    endIndent: 2,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.after,
                        style: AppTextStyles.surahFrame.copyWith(
                          fontSize: 10.sp,
                          color: Colors.black,
                          fontFamily: AppFonts.tajawal,
                        ),
                      ),
                      Text(
                        remainingTime,
                        style: AppTextStyles.surahName.copyWith(
                          fontFamily: AppFonts.tajawal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
