import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';

class BackIcon extends StatelessWidget {
  final VoidCallback? onTap;
  const BackIcon({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: CircleBorder(),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          width: 32.w,
          height: 32.h,
          padding: EdgeInsetsDirectional.only(end: 2.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.secondaryColor, width: 2.w),
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.secondaryColor,
            size: 20.sp,
          ),
        ),
      ),
    );
  }
}
