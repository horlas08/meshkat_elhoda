import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/mosques/domain/entities/mosque.dart';

class MosqueCard extends StatelessWidget {
  final Mosque mosque;
  final double userLat;
  final double userLng;

  const MosqueCard({
    super.key,
    required this.mosque,
    required this.userLat,
    required this.userLng,
  });

  String _distanceText() {
    final d = Geolocator.distanceBetween(
      userLat,
      userLng,
      mosque.latitude,
      mosque.longitude,
    );
    if (d >= 1000) {
      return '${(d / 1000).toStringAsFixed(1)} km';
    }
    return '${d.toStringAsFixed(0)} m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.greyColor.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40.h,
            width: 40.w,
            decoration: BoxDecoration(
              color: AppColors.goldenColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.mosque_outlined, color: AppColors.goldenColor),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mosque.name,
                  style: AppTextStyles.surahName.copyWith(
                    fontSize: 14.sp,
                    fontFamily: AppFonts.tajawal,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Text(
                  mosque.address,
                  style: AppTextStyles.topHeadline.copyWith(
                    fontSize: 12.sp,
                    fontFamily: AppFonts.tajawal,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            _distanceText(),
            style: AppTextStyles.surahName.copyWith(
              fontSize: 12.sp,
              color: AppColors.goldenColor,
            ),
          ),
        ],
      ),
    );
  }
}
