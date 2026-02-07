import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/core/utils/app_assets.dart';

class TasbehCircle extends StatelessWidget {
  final double turns;
  final double circleSize;
  final int beadCount;
  final int counter;

  const TasbehCircle({
    super.key,
    required this.turns,
    required this.circleSize,
    required this.beadCount,
    required this.counter,
  });

  @override
  Widget build(BuildContext context) {
    double radius = circleSize / 2;
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedRotation(
          turns: turns,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: circleSize.w,
                height: circleSize.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.buttonColor,
                    width: 1.2.w,
                  ),
                ),
              ),

              for (var i = 0; i < beadCount; i++)
                Transform.translate(
                  offset: Offset(
                    radius * cos(2 * pi * i / beadCount),
                    radius * sin(2 * pi * i / beadCount),
                  ),
                  child: SvgPicture.asset(
                    AppAssets.circle,
                    width: 28.w,
                    height: 28.h,
                  ),
                ),
            ],
          ),
        ),

        Text(
          '$counter',
          style: AppTextStyles.surahName.copyWith(
            fontSize: 38.sp,
            color: AppColors.buttonColor,
          ),
        ),
      ],
    );
  }
}
