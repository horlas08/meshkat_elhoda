import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';

class BackIcon extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? color;
  const BackIcon({super.key, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: CircleBorder(),
      child: Container(
        width: 32.w,
        height: 32.h,
        padding: EdgeInsetsDirectional.only(start: 2.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color ?? AppColors.secondaryColor,
            width: 2.w,
          ),
        ),
        child: Icon(
          Icons.arrow_forward_ios,
          color: color ?? AppColors.secondaryColor,
          size: 20.sp,
        ),
      ),
    );
  }
}
