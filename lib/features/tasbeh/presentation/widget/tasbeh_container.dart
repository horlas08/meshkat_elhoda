import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/core/utils/app_assets.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/features/tasbeh/presentation/widget/custom_icon.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';

class TasbehContainer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onZikrChanged;

  const TasbehContainer({
    super.key,
    required this.selectedIndex,
    required this.onZikrChanged,
  });

  List<String> getAzkarList(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    return [
      s.subhanAllah,
      s.alhamdulillah,
      s.allahuAkbar,
      s.laIlahaIllallah,
      s.astaghfirullah,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final azkarList = getAzkarList(context);
    final s = AppLocalizations.of(context)!;

    // Ensure index is valid
    final safeIndex = (selectedIndex >= 0 && selectedIndex < azkarList.length)
        ? selectedIndex
        : 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        border: Border.all(width: 4.w, color: AppColors.buttonColor),
        borderRadius: BorderRadius.circular(10.h),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {},
            child: CustomIcon(iconPath: AppAssets.pin),
          ),

          DropdownButton<String>(
            value: azkarList[safeIndex],
            alignment: Alignment.center,
            style: AppTextStyles.surahName,
            icon: CustomIcon(iconPath: AppAssets.down),
            dropdownColor: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(5.h),
            underline: const SizedBox(),
            onChanged: (value) {
              if (value != null) {
                final index = azkarList.indexOf(value);
                if (index != -1) {
                  onZikrChanged(index);
                }
              }
            },
            items: azkarList.map((zikr) {
              return DropdownMenuItem(
                value: zikr,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    zikr,
                    style: AppTextStyles.surahName.copyWith(
                      fontSize: 12.sp,
                      fontFamily: AppFonts.tajawal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
