import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_assets.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/tasbeh/presentation/widget/custom_icon.dart';

class FilterIcon extends StatelessWidget {
  const FilterIcon({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 13.h),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.blacColor.withValues(alpha: 0.25),
              blurRadius: 4.w,
            ),
          ],
        ),
        child: CustomIcon(
          iconPath: AppAssets.filteration,
          height: 20,
          width: 20,
        ),
      ),
    );
  }
}
