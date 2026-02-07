import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';

class CustomSearchField extends StatelessWidget {
  const CustomSearchField({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onFavourit,
    this.width,
  });

  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final void Function()? onFavourit;
  final void Function(String)? onSubmitted;
  final double? width;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.blacColor.withValues(alpha: 0.25),
              blurRadius: 4.w,
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          style: AppTextStyles.zekr.copyWith(
            color: AppColors.greyColor,
            fontSize: 12.sp,
          ),
          cursorColor: AppColors.greyColor,
          decoration: InputDecoration(
            hint: const HintWidet(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 10.h,
            ),
            filled: true,
            fillColor: AppColors.primaryColor,
            enabledBorder: border(),
            focusedBorder: border(),
          ),
        ),
      ),
    );
  }

  OutlineInputBorder border() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: BorderSide(width: 1.w, color: AppColors.primaryColor),
    );
  }
}

class HintWidet extends StatelessWidget {
  const HintWidet({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppLocalizations.of(context)!.searchHint,
          style: AppTextStyles.zekr.copyWith(
            color: AppColors.greyColor.withValues(alpha: .56),
            fontSize: 14.sp,
          ),
        ),
        SizedBox(width: 8.w),
        Transform.scale(
          scaleX: -1,
          child: Icon(
            Icons.search,
            color: AppColors.greyColor.withValues(alpha: .56),
          ),
        ),
      ],
    );
  }
}
