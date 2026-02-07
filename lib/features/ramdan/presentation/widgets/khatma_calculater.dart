import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_assets.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/ramdan/data/khatma_schedule.dart';

import '../../../../l10n/app_localizations.dart';

class RamadanKhatmaCalculator extends StatefulWidget {
  const RamadanKhatmaCalculator({super.key, required this.onGoToMushaf});

  final VoidCallback onGoToMushaf;

  @override
  State<RamadanKhatmaCalculator> createState() =>
      _RamadanKhatmaCalculatorState();
}

class _RamadanKhatmaCalculatorState extends State<RamadanKhatmaCalculator> {
  int selectedKhatmaCount = 1;
  bool showSchedule = false;
  List<DailyWird> schedule = [];

  @override
  void initState() {
    super.initState();
    _updateSchedule();
  }

  void _updateSchedule() {
    schedule = RamadanKhatmaSchedule.generateSchedule(selectedKhatmaCount);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final summary = RamadanKhatmaSchedule.getSummary(selectedKhatmaCount);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.sp),
      margin: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: AppColors.buttonColor.withOpacity(0.5),
        image: const DecorationImage(
          image: AssetImage(AppAssets.mushaf),
          opacity: .02,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            localizations?.ramadanWirdCalculatorTitle ?? "حاسبة ورد رمضان",
            textAlign: TextAlign.center,
            style: AppTextStyles.zekr.copyWith(
              color: AppColors.secondaryColor,
              fontSize: 18.sp,
            ),
          ),

          SizedBox(height: 16.h),

          // اختيار عدد الختمات
          Text(
            localizations?.chooseKhatmaCount ?? "اختر عدد الختمات:",
            style: AppTextStyles.zekr.copyWith(
              color: AppColors.whiteColor,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 12.h),

          // أزرار اختيار عدد الختمات
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final count = index + 1;
              final isSelected = selectedKhatmaCount == count;
              return InkWell(
                onTap: () {
                  setState(() {
                    selectedKhatmaCount = count;
                    _updateSchedule();
                    showSchedule = false;
                  });
                },
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  width: 50.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.secondaryColor
                        : AppColors.whiteColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.secondaryColor
                          : AppColors.whiteColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$count',
                      style: AppTextStyles.zekr.copyWith(
                        color: isSelected ? Colors.white : AppColors.whiteColor,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          SizedBox(height: 20.h),

          // ملخص الورد اليومي
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.1),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                Text(
                  localizations?.dailyWirdHeader ?? "الورد اليومي",
                  style: AppTextStyles.zekr.copyWith(
                    color: AppColors.secondaryColor,
                    fontSize: 18.sp,
                  ),
                ),
                SizedBox(height: 12.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      icon: Icons.book,
                      value: '${summary.pagesPerDay}',
                      label: localizations?.pagesPerDay ?? 'صفحة/يوم',
                    ),
                    _buildStatItem(
                      icon: Icons.layers,
                      value: summary.ajzaaPerDay.toStringAsFixed(1),
                      label: localizations?.juzPerDay ?? 'جزء/يوم',
                    ),
                    _buildStatItem(
                      icon: Icons.auto_stories,
                      value: '${summary.khatmaCount}',
                      label: localizations?.khatma ?? 'ختمة',
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // زر عرض الجدول التفصيلي
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                showSchedule = !showSchedule;
              });
            },
            icon: Icon(
              showSchedule ? Icons.expand_less : Icons.expand_more,
              color: AppColors.goldenColor,
            ),
            label: Text(
              showSchedule
                  ? localizations?.hideSchedule ?? "إخفاء الجدول"
                  : localizations?.showDetailedSchedule ??
                        "عرض الجدول التفصيلي",
              style: AppTextStyles.zekr.copyWith(
                color: AppColors.goldenColor,
                fontSize: 14.sp,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.goldenColor),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),

          // الجدول التفصيلي
          if (showSchedule) ...[
            SizedBox(height: 16.h),
            _buildScheduleTable(context),
          ],

          SizedBox(height: 20.h),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryColor.withOpacity(0.82),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
            onPressed: widget.onGoToMushaf,
            child: Text(
              localizations?.goToMushafButton ?? "الذهاب للمصحف",
              style: AppTextStyles.zekr.copyWith(
                color: AppColors.whiteColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.goldenColor, size: 24.sp),
        SizedBox(height: 4.h),
        Text(
          value,
          style: AppTextStyles.zekr.copyWith(
            color: AppColors.whiteColor,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.zekr.copyWith(
            color: AppColors.whiteColor.withOpacity(0.7),
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleTable(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          // رأس الجدول
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
            decoration: BoxDecoration(
              color: AppColors.secondaryColor.withOpacity(0.3),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 45.w,
                  child: Text(
                    localizations?.dayColumn ?? 'اليوم',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.zekr.copyWith(
                      color: AppColors.goldenColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: 70.w,
                  child: Text(
                    localizations?.pagesColumn ?? 'الصفحات',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.zekr.copyWith(
                      color: AppColors.goldenColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    localizations?.surahsColumn ?? 'السور',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.zekr.copyWith(
                      color: AppColors.goldenColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // صفوف الجدول
          SizedBox(
            height: 300.h,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: schedule.length,
              itemBuilder: (context, index) {
                final wird = schedule[index];
                final isEven = index % 2 == 0;

                return Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 10.h,
                    horizontal: 8.w,
                  ),
                  decoration: BoxDecoration(
                    color: isEven
                        ? Colors.transparent
                        : Colors.white.withOpacity(0.03),
                  ),
                  child: Row(
                    children: [
                      // رقم اليوم
                      Container(
                        width: 35.w,
                        height: 35.h,
                        margin: EdgeInsets.only(left: 10.w),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${wird.day}',
                            style: AppTextStyles.zekr.copyWith(
                              color: AppColors.goldenColor,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      // نطاق الصفحات
                      SizedBox(
                        width: 70.w,
                        child: Column(
                          children: [
                            Text(
                              wird.pagesRange,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.zekr.copyWith(
                                color: AppColors.whiteColor,
                                fontSize: 12.sp,
                              ),
                            ),
                            Text(
                              localizations?.pagesCountText(wird.pagesCount) ??
                                  '(${wird.pagesCount} صفحة)',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.zekr.copyWith(
                                color: AppColors.whiteColor.withOpacity(0.6),
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // السور
                      Expanded(
                        child: Text(
                          wird.surahsText,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.zekr.copyWith(
                            color: AppColors.whiteColor.withOpacity(0.9),
                            fontSize: 11.sp,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
