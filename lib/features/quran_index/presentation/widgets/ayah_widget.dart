import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/quran_index/domain/entities/ayah_entity.dart';

class AyahWidget extends StatelessWidget {
  final AyahEntity ayah;
  final Function(AyahEntity) onAyahTap;

  const AyahWidget({super.key, required this.ayah, required this.onAyahTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => onAyahTap(ayah),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF153A52) : Colors.white,
          borderRadius: BorderRadius.circular(8.h),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ✅ النص العربي
            Text(
              ayah.text,
              style: AppTextStyles.surahName.copyWith(
                fontSize: 20.sp,
                color: isDark ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.right,
            ),
            // ✅ الترجمة (إذا كانت موجودة)
            if (ayah.translation != null && ayah.translation!.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : AppColors.goldenColor)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.h),
                  border: Border.all(
                    color: AppColors.goldenColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  ayah.translation!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isDark ? Colors.white70 : Colors.black87,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
            SizedBox(height: 8.h),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16.h),
                  ),
                  child: Text(
                    '${ayah.numberInSurah}',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                if (ayah.sajda) ...[
                  SizedBox(width: 8.w),
                  Icon(
                    Icons.mosque_outlined,
                    size: 20.w,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
