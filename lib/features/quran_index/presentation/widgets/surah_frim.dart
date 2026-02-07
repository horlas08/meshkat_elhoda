import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';

class SurahFrameWidget extends StatelessWidget {
  const SurahFrameWidget({super.key, required this.surahName});
  final String surahName;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text('24', style: AppTextStyles.surahFrame),
        Positioned(
          top: 20.h,
          left: 136.w,
          child: Center(
            child: Text(
              surahName,
              style: AppTextStyles.surahName.copyWith(fontSize: 20.sp),
            ),
          ),
        ),
      ],
    );
  }
}
