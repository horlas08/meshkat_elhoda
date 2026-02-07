import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';

class SearchTextFormField extends StatelessWidget {
  const SearchTextFormField({
    super.key,
    this.height,
    this.width,
    this.hintText,
    this.hintWidget,
    this.controller,
    this.onFieldSubmitted,
    this.keyboardType,
    this.onFieldChanged,
  });

  final double? height;
  final double? width;
  final String? hintText;
  final Widget? hintWidget;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final void Function(String)? onFieldSubmitted;
  final void Function(String)? onFieldChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (width ?? 336).w,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: (height ?? 33).h),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: AppColors.blacColor.withValues(alpha: 0.25),
                offset: const Offset(0, 0),
                blurRadius: 5.w,
                spreadRadius: 1.w,
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            onFieldSubmitted: onFieldSubmitted,
            onChanged: onFieldChanged,
            keyboardType: keyboardType,
            style: AppTextStyles.surahName.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            cursorColor: AppColors.greyColor,
            textAlign: TextAlign.start,
            decoration: InputDecoration(
              hintText: hintWidget == null ? hintText ?? '' : null,
              hint: hintWidget,
              hintStyle: AppTextStyles.surahName.copyWith(
                color: AppColors.greyColor,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 10.h,
              ),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              enabledBorder: _customBorder(Theme.of(context).cardColor),
              focusedBorder: _customBorder(Theme.of(context).cardColor),
            ),
          ),
        ),
      ),
    );
  }
}

OutlineInputBorder _customBorder(Color color) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(5.h),
    borderSide: BorderSide(width: 1.w, color: color),
  );
}
