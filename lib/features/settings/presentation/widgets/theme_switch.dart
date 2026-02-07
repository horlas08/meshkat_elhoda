import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_assets.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/tasbeh/presentation/widget/custom_icon.dart';

class ThemeSwitch extends StatefulWidget {
  final VoidCallback? onTap;

  const ThemeSwitch({super.key, this.onTap});

  @override
  State<ThemeSwitch> createState() => _ThemeSwitchState();
}

class _ThemeSwitchState extends State<ThemeSwitch> {
  bool isDark = false;

  void toggleSwitch() {
    setState(() {
      isDark = !isDark;
    });
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20.r),
      onTap: toggleSwitch,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: 50.w,
        height: 30.h,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
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
                  iconPath: isDark ? AppAssets.sun : AppAssets.moon,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
