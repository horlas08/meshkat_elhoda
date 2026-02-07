import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';

class AsmaaAlluahGrid extends StatelessWidget {
  final List<String> names;
  const AsmaaAlluahGrid({super.key, required this.names});

  @override
  Widget build(BuildContext context) {
    // حساب أطول نص لتحديد حجم الخط المناسب
    final longestNameLength = names
        .map((name) => name.length)
        .reduce((a, b) => a > b ? a : b);

    // تحديد حجم الخط بناءً على أطول نص
    final double fontSize = longestNameLength > 20
        ? 10.sp
        : longestNameLength > 15
        ? 11.sp
        : longestNameLength > 12
        ? 12.sp
        : 13.sp;

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 6.w,
            mainAxisSpacing: 4.h,
            childAspectRatio: 1.1,
          ),
          padding: EdgeInsets.zero,
          itemCount: names.length,
          itemBuilder: (context, index) {
            return Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
              child: Text(
                names[index],
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.whiteColor
                      : AppColors.darkRed,
                  fontWeight: FontWeight.w700,
                  fontSize: fontSize, // نفس الحجم لجميع الأسماء
                  height: 1.2,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
