import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';

class QuranIcon extends StatelessWidget {
  final String title;
  final String iconPath;
  final double spacing;

  const QuranIcon({
    super.key,
    required this.title,
    required this.iconPath,
    this.spacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          iconPath,
          height: 16.h,
          width: 16.w,
          fit: BoxFit.contain,
          colorFilter: ColorFilter.mode(
            IconTheme.of(context).color ?? Colors.grey,
            BlendMode.srcIn,
          ),
        ),
        SizedBox(height: spacing.h),
        Text(
          title,
          style: TextStyle(
            color: AppColors.greyColor,
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            fontFamily: AppFonts.tajawal,
          ),
        ),
      ],
    );
  }
}
