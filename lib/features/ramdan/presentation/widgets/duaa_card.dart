import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/core/utils/app_assets.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';

class DuaaCard extends StatelessWidget {
  const DuaaCard({super.key, required this.duaa});

  final String duaa;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 185.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            right: -14.w,
            child: SizedBox(
              height: 110.h,
              width: 90.w,
              child: Transform.rotate(
                angle: 0.35,
                child: Opacity(
                  opacity: 0.55,
                  child: Image.asset(AppAssets.fanwos, fit: BoxFit.cover),
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(
                duaa,
                textAlign: TextAlign.center,
                style: AppTextStyles.surahName.copyWith(
                  color: const Color(0xff846821),
                  fontSize: 16.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
