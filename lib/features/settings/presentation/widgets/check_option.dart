import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';

class CheckOption extends StatefulWidget {
  final String title;
  final ValueChanged<bool>? onChanged;
  final bool? isChecked;
  const CheckOption({
    super.key,
    required this.title,
    this.onChanged,
    this.isChecked = false,
  });
  @override
  State<CheckOption> createState() => _CheckOptionState();
}

class _CheckOptionState extends State<CheckOption> {
  late bool isChecked;
  @override
  void initState() {
    super.initState();
    isChecked = widget.isChecked!;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35.h,
      child: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        ),
        child: CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          title: Text(
            widget.title,
            style: AppTextStyles.surahName.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              fontFamily: AppFonts.tajawal,
            ),
          ),
          value: isChecked,
          fillColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.goldenColor;
            }
            return const Color(0xfff3f4f6);
          }),
          side: BorderSide(color: const Color(0xffe5e7eb), width: 1.w),
          onChanged: (value) {
            setState(() {
              isChecked = value ?? false;
            });
            widget.onChanged?.call(isChecked);
          },
        ),
      ),
    );
  }
}
