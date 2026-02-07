import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/core/utils/app_assets.dart';
import 'package:meshkat_elhoda/features/prayer_times/domain/entities/next_prayer_info.dart';
import 'package:meshkat_elhoda/features/main_navigation/presentation/widgets/next_prayer_card.dart';

class HomeHeaderSection extends StatelessWidget {
  final NextPrayerInfo nextPrayerInfo;
  final String? location;

  const HomeHeaderSection({
    super.key,
    required this.nextPrayerInfo,
    this.location,
  });

  @override
  Widget build(BuildContext context) {
    // اختيار الصورة بناءً على نوع الصلاة (ليلية/نهارية)
    final backgroundImage = nextPrayerInfo.isNightPrayer
        ? AppAssets
              .dark // صورة الليل
        : AppAssets.light; // صورة النهار - تحتاج إضافة هذا الأصل

    return Stack(
      children: [
        // الصورة الخلفية
        ClipRRect(
          borderRadius: BorderRadius.circular(10.h),
          child: Image.asset(
            backgroundImage,
            width: double.infinity,
            height: 200.h,
            fit: BoxFit.cover,
          ),
        ),

        // كارد الصلاة التالية
        Positioned(
          left: 6.w,
          bottom: 10.h,
          child: NextPrayerCard(
            prayerName: nextPrayerInfo.prayerName,
            prayerTime: nextPrayerInfo.prayerTime,
            remainingTime: nextPrayerInfo.remainingTime,
            location: location,
          ),
        ),
      ],
    );
  }
}
