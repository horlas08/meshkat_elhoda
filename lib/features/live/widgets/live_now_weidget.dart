import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';

class LiveNowWidget extends StatelessWidget {
  const LiveNowWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          AppLocalizations.of(context)!.liveNow,
          style: AppTextStyles.surahName.copyWith(
            color: Colors.green,
            fontFamily: AppFonts.tajawal,
            fontSize: 7.sp,
          ),
        ),
        SizedBox(width: 5.w),
        CircleAvatar(radius: 2.w, backgroundColor: Colors.green),
      ],
    );
  }
}
