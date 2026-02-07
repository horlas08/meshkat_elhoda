import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_assets.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/core/widgets/islamic_appbar.dart';
import 'package:meshkat_elhoda/features/live/live_stream.dart';
import 'package:meshkat_elhoda/features/live/widgets/live_channel_card.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';

class HaramLife extends StatelessWidget {
  const HaramLife({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    final isArabic = languageCode == 'ar';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IslamicAppbar(
                title: s.haramLiveTitle,
                fontSize: 20.sp,
                onTap: () => Navigator.pop(context),
              ),

              SizedBox(height: 71.h),

              Text(
                s.chooseChannel,
                style: AppTextStyles.zekr.copyWith(
                  color: AppColors.buttonColor,
                  fontFamily: AppFonts.tajawal,
                  fontSize: 18.sp,
                ),
              ),
              SizedBox(height: 35.h),

              LiveChannelCard(
                title: s.makkah,
                channelName: s.saudiChannel,
                image: AppAssets.makkah,
                onAboutTap: () {},
                onWatchTap: () {
                  final copyrightNotice = isArabic
                      ? 'البث يعرض من قناة القرءان الكريم التابعة لهيئة الإذاعة والتلفزيون السعودية على منصة يوتيوب والتطبيق لاينشر ولا يخزن ولا يعيد بث أي محتوى وجميع الحقوق محفوظة لمالكيها.'
                      : 'The broadcast is displayed from the Qur’an Channel التابعة لهيئة الإذاعة والتلفزيون السعودية on YouTube.\nThe app does not publish, store, or rebroadcast any content, and all rights are reserved to their owners.';
                  final copyrightRights = isArabic
                      ? '©جميع الحقوق محفوظة - لهيئة الإذاعة والتلفزيون السعودية'
                      : '© All rights reserved – Saudi Broadcasting Authority.';
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MakkahLiveStreamWebView(
                        url:
                            'https://www.youtube.com/channel/UCos52azQNBgW63_9uDJoPDA/live',
                        channelName: s.quranChannel,
                        copyrightNotice: copyrightNotice,
                        copyrightRights: copyrightRights,
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 28.h),

              LiveChannelCard(
                title: s.madinah,
                channelName: s.madinahChannel,
                image: AppAssets.madinah,
                onAboutTap: () {},
                onWatchTap: () {
                  final copyrightNotice = isArabic
                      ? 'البث يعرض من قناة السنة النبوية التابعة لهيئة الإذاعة والتلفزيون السعودية على منصة يوتيوب والتطبيق لاينشر ولا يخزن ولا يعيد بث أي محتوى وجميع الحقوق محفوظة لمالكيها.'
                      : 'The broadcast is displayed from the Sunnah Channel التابعة لهيئة الإذاعة والتلفزيون السعودية on YouTube.\nThe app does not publish, store, or rebroadcast any content, and all rights are reserved to their owners.';
                  final copyrightRights = isArabic
                      ? '©جميع الحقوق محفوظة - لهيئة الإذاعة والتلفزيون السعودية'
                      : '© All rights reserved – Saudi Broadcasting Authority.';
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MakkahLiveStreamWebView(
                        url:
                            'https://www.youtube.com/live/TpT8b8JFZ6E?si=dkvFCwK4TRWVZDzi',
                        channelName: s.madinah,
                        copyrightNotice: copyrightNotice,
                        copyrightRights: copyrightRights,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
