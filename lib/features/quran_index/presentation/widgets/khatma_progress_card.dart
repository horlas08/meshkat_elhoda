import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';

import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/bloc/khatma_progress_bloc.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/bloc/khatma_progress_event.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/bloc/khatma_progress_state.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/screens/surah_screen.dart';
import 'package:intl/intl.dart' as intl;

class KhatmaProgressCard extends StatelessWidget {
  const KhatmaProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KhatmaProgressBloc, KhatmaProgressState>(
      builder: (context, state) {
        if (state is! KhatmaLoaded) {
          return const SizedBox.shrink();
        }

        final progress = state.progress;
        final percentage = progress.progressPercentage;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      AppColors.darkGrey.withOpacity(0.35),
                      AppColors.darkGrey.withOpacity(0.25),
                    ]
                  : [
                      AppColors.goldenColor.withOpacity(0.9),
                      AppColors.secondaryColor.withOpacity(0.7),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.goldenColor.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/quran.svg',
                        width: 24.w,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'ختمتي',
                        style: AppTextStyles.surahName.copyWith(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.tajawal,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'آخر قراءة: ${intl.DateFormat('yyyy-MM-dd').format(progress.lastUpdated)}',
                          style: AppTextStyles.surahName.copyWith(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontFamily: AppFonts.tajawal,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (context.mounted) {
                            context.read<KhatmaProgressBloc>().add(
                              LoadKhatmaProgress(),
                            );
                          }
                        },
                        icon: const Icon(Icons.refresh),
                        color: Colors.white,
                        tooltip: 'تحديث البيانات',
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInfoItem('الجزء', '${progress.currentJuz}'),
                  _buildInfoItem('الصفحة', '${progress.currentPage}'),
                ],
              ),
              SizedBox(height: 16.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'نسبة الإنجاز',
                        style: AppTextStyles.surahName.copyWith(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontFamily: AppFonts.tajawal,
                        ),
                      ),
                      Text(
                        '${(percentage * 100).toStringAsFixed(1)}%',
                        style: AppTextStyles.surahName.copyWith(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.tajawal,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                      minHeight: 6.h,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.white.withOpacity(0.9),
                      size: 14.sp,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        'تتبع الختمة يعمل في وضع التقليب الأفقي • اختر السورة التالية يدوياً',
                        style: AppTextStyles.surahName.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 10.sp,
                          fontFamily: AppFonts.tajawal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SurahScreen(
                          initialPage: progress.currentPage,
                          forceHorizontalMode: true,
                        ),
                      ),
                    ).then((_) {
                      if (context.mounted) {
                        context.read<KhatmaProgressBloc>().add(
                          LoadKhatmaProgress(),
                        );
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.goldenColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'متابعة القراءة',
                    style: AppTextStyles.surahName.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.goldenColor,
                      fontFamily: AppFonts.tajawal,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.surahName.copyWith(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            fontFamily: AppFonts.tajawal,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.surahName.copyWith(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }
}
