import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_assets.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/widgets/zekr_action_button.dart';
import 'package:meshkat_elhoda/features/tasbeh/presentation/view/tasbeeh_view.dart';

import '../../../../l10n/app_localizations.dart';

class StartTasbehCard extends StatelessWidget {
  const StartTasbehCard({super.key, this.onTap});
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: AppColors.textFieldColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Image.asset(AppAssets.masbha, height: 26.h, width: 26.w),

          SizedBox(width: 8.w),

          Text(
            AppLocalizations.of(context)!.smartMisbah,
            style: AppTextStyles.surahName.copyWith(
              fontSize: 14.sp,
              fontFamily: AppFonts.tajawal,
            ),
          ),
          Spacer(),

          ZekrActionButton(
            text: AppLocalizations.of(context)!.startTasbeh,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TasbehVeiw()),
              );
            },
            textColor: AppColors.whiteColor,
            buttonColor: AppColors.goldenColor,
            borderColor: AppColors.goldenColor,
          ),
        ],
      ),
    );
  }
}
