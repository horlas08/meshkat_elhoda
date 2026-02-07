import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/prayer_times/domain/entities/prayer_times_entity.dart';

class PrayerTimesCard extends StatelessWidget {
  final PrayerTimesEntity prayerTimes;

  const PrayerTimesCard({super.key, required this.prayerTimes});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withOpacity(0.8),
            AppColors.primaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'مواقيت الصلاة',
            style: TextStyle(
              fontFamily: AppFonts.tajawal,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.goldenColor,
            ),
          ),
          SizedBox(height: 16.h),
          _buildPrayerTimeRow('الفجر', prayerTimes.fajr),
          _buildDivider(),
          _buildPrayerTimeRow('الشروق', prayerTimes.sunrise),
          _buildDivider(),
          _buildPrayerTimeRow('الظهر', prayerTimes.dhuhr),
          _buildDivider(),
          _buildPrayerTimeRow('العصر', prayerTimes.asr),
          _buildDivider(),
          _buildPrayerTimeRow('المغرب', prayerTimes.maghrib),
          _buildDivider(),
          _buildPrayerTimeRow('العشاء', prayerTimes.isha),
        ],
      ),
    );
  }

  Widget _buildPrayerTimeRow(String name, String time) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(
              fontFamily: AppFonts.tajawal,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.goldenColor,
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontFamily: AppFonts.tajawal,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.goldenColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: AppColors.goldenColor, thickness: 1, height: 1);
  }
}
