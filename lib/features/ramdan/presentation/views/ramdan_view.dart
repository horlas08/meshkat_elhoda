import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/core/utils/app_assets.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/widgets/islamic_appbar.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/views/quran_index_view.dart';
import 'package:meshkat_elhoda/features/ramdan/data/ramadan_duas.dart';
import 'package:meshkat_elhoda/features/ramdan/presentation/widgets/duaa_card.dart';
import 'package:meshkat_elhoda/features/ramdan/presentation/widgets/khatma_calculater.dart';
import 'package:meshkat_elhoda/features/ramdan/presentation/widgets/ramadan_greeting_card.dart';
import 'package:meshkat_elhoda/features/prayer_times/presentation/bloc/prayer_times_bloc.dart';
import 'package:meshkat_elhoda/features/prayer_times/presentation/bloc/prayer_times_state.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class RamdanView extends StatelessWidget {
  const RamdanView({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;

    // تنسيق التاريخ
    final now = DateTime.now();
    final dateFormat = DateFormat(
      'EEEE - d MMMM yyyy',
      language == 'ar' ? 'ar' : 'en',
    );
    final formattedDate = dateFormat.format(now);

    return Scaffold(
      backgroundColor: const Color(0xff0b132b),
      body: BlocBuilder<PrayerTimesBloc, PrayerTimesState>(
        builder: (context, state) {
          // الحصول على التاريخ الهجري الحقيقي
          int? hijriMonth;
          int? hijriDay;

          if (state is PrayerTimesLoaded && state.prayerTimes != null) {
            final hijriDate = state.prayerTimes!.dateInfo.hijri;
            hijriMonth = int.tryParse(hijriDate.month.toString());
            hijriDay = int.tryParse(hijriDate.day.toString());
          }

          // التحقق من أننا في شهر رمضان (الشهر 9)
          final isRamadan = hijriMonth == 9;
          final currentRamadanDay = isRamadan ? (hijriDay ?? 1) : 1;
          final todayDua = RamadanDuas.getDuaForDay(
            currentRamadanDay,
            language,
          );

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 195.h,
                      child: Opacity(
                        opacity: 0.4,
                        child: Image.asset(
                          AppAssets.fawanes,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40.h,
                      left: 24.w,
                      right: 24.w,
                      child: IslamicAppbar(
                        title: localizations?.ramadanKarim ?? 'Ramadan Kareem',
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    PositionedDirectional(
                      top: 100.h,
                      start: 24.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations?.ramadanKarimGreeting ??
                                "Ramadan Kareem\nWishing you a blessed month",
                            style: AppTextStyles.zekr.copyWith(
                              color: AppColors.whiteColor,
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // التاريخ الهجري (الأهم)
                              if (state is PrayerTimesLoaded &&
                                  state.prayerTimes != null)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: AppColors.goldenColor,
                                      size: 14.sp,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      '${state.prayerTimes!.dateInfo.hijri.day} ${state.prayerTimes!.dateInfo.hijri.month} ${state.prayerTimes!.dateInfo.hijri.year} هـ',
                                      style: AppTextStyles.zekr.copyWith(
                                        color: AppColors.goldenColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              SizedBox(height: 4.h),
                              // التاريخ الميلادي
                              Row(
                                children: [
                                  if (isRamadan)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.goldenColor
                                            .withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                      child: Text(
                                        language == 'ar'
                                            ? "اليوم $currentRamadanDay من رمضان"
                                            : "Day $currentRamadanDay of Ramadan",
                                        style: AppTextStyles.zekr.copyWith(
                                          color: AppColors.goldenColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ),
                                  if (isRamadan) SizedBox(width: 8.w),
                                  Text(
                                    formattedDate,
                                    style: AppTextStyles.zekr.copyWith(
                                      color: AppColors.whiteColor.withOpacity(
                                        0.8,
                                      ),
                                      fontWeight: FontWeight.w400,
                                      fontSize: 11.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),

                // Today Dua Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Row(
                    children: [
                      Text(
                        localizations?.todayDuaaHeader ?? 'Today\'s Du\'aa',
                        style: AppTextStyles.zekr.copyWith(
                          color: AppColors.whiteColor,
                          fontSize: 16.sp,
                        ),
                      ),
                      const Spacer(),
                      if (isRamadan)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            language == 'ar'
                                ? "دعاء اليوم $currentRamadanDay"
                                : "Day $currentRamadanDay Du'aa",
                            style: AppTextStyles.zekr.copyWith(
                              color: AppColors.goldenColor,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Dua Card - Dynamic based on current day
                DuaaCard(duaa: todayDua),

                // Greet Your Loved Ones
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Text(
                    localizations?.greetYourLovedOnes ??
                        'Greet Your Loved Ones',
                    style: AppTextStyles.zekr.copyWith(
                      color: AppColors.whiteColor,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                const RamadanGreetingCard(),

                // Quran Kareem
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Text(
                    localizations?.quranKarem ?? 'Holy Quran',
                    style: AppTextStyles.zekr.copyWith(
                      color: AppColors.whiteColor,
                      fontSize: 16.sp,
                    ),
                  ),
                ),

                RamadanKhatmaCalculator(
                  onGoToMushaf: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QuranIndexView(),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
