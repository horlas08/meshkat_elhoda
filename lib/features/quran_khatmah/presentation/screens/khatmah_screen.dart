import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/widgets/loading_widget.dart';
import 'package:meshkat_elhoda/features/quran_khatmah/presentation/bloc/khatmah_bloc.dart';
import 'package:meshkat_elhoda/features/quran_khatmah/presentation/bloc/khatmah_event.dart';
import 'package:meshkat_elhoda/features/quran_khatmah/presentation/bloc/khatmah_state.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/screens/surah_screen.dart';

import '../../../../l10n/app_localizations.dart';

class KhatmahScreen extends StatefulWidget {
  const KhatmahScreen({super.key});

  @override
  State<KhatmahScreen> createState() => _KhatmahScreenState();
}

class _KhatmahScreenState extends State<KhatmahScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure data is loaded when screen opens
    context.read<KhatmahBloc>().add(LoadKhatmah());
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          localizations?.yourDailyWird ?? 'وردك اليومي',
          style: AppTextStyles.surahName.copyWith(
            fontFamily: AppFonts.tajawal,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<KhatmahBloc, KhatmahState>(
        builder: (context, state) {
          if (state is KhatmahLoading) {
            return Center(child: QuranLottieLoading());
          } else if (state is KhatmahError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    localizations?.errorOccurred ?? 'حدث خطأ: ${state.message}',
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<KhatmahBloc>().add(LoadKhatmah()),
                    child: Text(localizations?.tryAgain ?? 'إعادة المحاولة'),
                  ),
                ],
              ),
            );
          } else if (state is KhatmahReflecting) {
            return _buildContent(context, state);
          }

          return const Center(child: QuranLottieLoading());
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, KhatmahReflecting state) {
    final localizations = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = state.progress;
    final details = state.pageDetails;

    // Calculate percentage (Assuming 604 pages in Quran)
    final double percentage = (progress.currentPage / 604);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // Main Card
          Container(
            padding: EdgeInsets.all(24.w),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [AppColors.darkGrey, AppColors.darkGrey.withOpacity(0.8)]
                    : [AppColors.goldenColor, AppColors.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.goldenColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header: Surah Name
                Text(
                  details.surahName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.quran,
                  ),
                ),
                Text(
                  localizations?.ayahsRangeText(
                        details.ayahs.first.numberInSurah,
                        details.ayahs.last.numberInSurah,
                      ) ??
                      'آية ${details.ayahs.first.numberInSurah} - ${details.ayahs.last.numberInSurah}',
                  style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                ),

                SizedBox(height: 32.h),

                // Stats Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Wrap(
                      spacing: 16.w,
                      runSpacing: 16.h,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildStatBox(
                          localizations?.pageNumber ?? 'رقم الصفحة',
                          '${progress.currentPage}',
                          Icons.menu_book,
                        ),
                        _buildStatBox(
                          localizations?.currentJuz ?? 'الجزء الحالي',
                          '${details.juz}',
                          Icons.pie_chart,
                        ),
                        _buildStatBox(
                          localizations?.readJuz ?? 'أجزاء مقروءة',
                          '${details.juz - 1}',
                          Icons.check_circle_outline,
                        ),
                        _buildStatBox(
                          localizations?.remainingPages ?? 'صفحة متبقية',
                          '${604 - progress.currentPage}',
                          Icons.hourglass_empty,
                        ),
                        _buildStatBox(
                          localizations?.todayProgress ?? 'انجاز اليوم',
                          '${progress.currentPage - progress.dailyStartPage} ${localizations?.pagesUnit ?? 'صفحة'}',
                          Icons.today,
                        ),
                      ],
                    );
                  },
                ),

                SizedBox(height: 32.h),

                // Custom Linear Progress
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(percentage * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          localizations?.khatmaPercentage ?? 'نسبة الختم',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontFamily: AppFonts.tajawal,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Stack(
                      children: [
                        Container(
                          height: 8.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        // Animated container for smooth progress
                        LayoutBuilder(
                          builder: (context, box) {
                            return Container(
                              height: 8.h,
                              width: box.maxWidth * percentage,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                // Note
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.white70,
                        size: 16.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        localizations?.khatmaTrackingNote ??
                            'تتبع الختمة يعمل مع وضع "التقليب الأفقي" فقط',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontFamily: AppFonts.tajawal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 32.h),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SurahScreen(
                      initialPage: progress.currentPage,
                      forceHorizontalMode: true,
                      isKhatmah: true, // New flag to track only this session
                    ),
                  ),
                ).then((_) {
                  if (context.mounted) {
                    context.read<KhatmahBloc>().add(LoadKhatmah());
                  }
                });
              },
              icon: const Icon(Icons.menu_book_rounded),
              label: Text(
                localizations?.continueReading ?? 'متابعة القراءة',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.tajawal,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? AppColors.goldenColor
                    : AppColors.goldenColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white30),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11.sp,
              fontFamily: AppFonts.tajawal,
            ),
          ),
        ],
      ),
    );
  }
}
