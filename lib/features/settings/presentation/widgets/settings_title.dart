import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_assets.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/tasbeh/presentation/widget/custom_icon.dart';

class SettingTitle extends StatefulWidget {
  const SettingTitle({
    super.key,
    required this.title,
    required this.iconPath,
    this.onExpansionChanged,
  });

  final String title;
  final String iconPath;
  final ValueChanged<bool>? onExpansionChanged;

  @override
  State<SettingTitle> createState() => SettingTitleState();
}

class SettingTitleState extends State<SettingTitle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _rotation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void setExpanded(bool expanded) {
    setState(() {
      _isExpanded = expanded;
    });
    if (expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    widget.onExpansionChanged?.call(expanded);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomIcon(
          iconPath: widget.iconPath,
          height: 20,
          width: 20,
          color: Theme.of(context).brightness == Brightness.light
              ? AppColors.goldenColor
              : AppColors.goldenColor,
        ),
        SizedBox(width: 10.w),
        Text(
          widget.title,
          style: AppTextStyles.zekr.copyWith(
            fontSize: 16.sp,
            fontFamily: AppFonts.tajawal,
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.blacColor
                : AppColors.whiteColor,
          ),
        ),
        const Spacer(),
        RotationTransition(
          turns: _rotation,
          child: CustomIcon(
            iconPath: AppAssets.down,
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.goldenColor
                : AppColors.goldenColor,
          ),
        ),
      ],
    );
  }
}
