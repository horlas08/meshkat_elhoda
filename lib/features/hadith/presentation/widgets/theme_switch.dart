import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/utils/app_assets.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/settings/presentation/cubit/theme_cubit.dart';
import 'package:meshkat_elhoda/features/tasbeh/presentation/widget/custom_icon.dart';

class ThemeSwitch extends StatelessWidget {
  final VoidCallback? onTap;

  const ThemeSwitch({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Read current theme mode from Bloc
    final themeMode = context.watch<ThemeCubit>().state;
    final isDark = themeMode == ThemeMode.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(20.r),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 45.w,
        height: 30.h,
        padding: EdgeInsets.all(4.sp),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isDark
              ? AppColors.whiteColor.withValues(alpha: 0.12)
              : AppColors.buttonColor,
        ),
        child: Stack(
          children: [
            Align(
              alignment: isDark ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                width: 15,
                height: 15,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xffD9D9D9),
                ),
              ),
            ),

            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 15,
                height: 15,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: CustomIcon(
                  iconPath: isDark ? AppAssets.moon : AppAssets.sun,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
