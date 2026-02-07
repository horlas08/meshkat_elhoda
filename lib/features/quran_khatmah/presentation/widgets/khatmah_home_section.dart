import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/quran_khatmah/presentation/bloc/khatmah_bloc.dart';
import 'package:meshkat_elhoda/features/quran_khatmah/presentation/bloc/khatmah_event.dart';
import 'package:meshkat_elhoda/features/quran_khatmah/presentation/bloc/khatmah_state.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/screens/surah_screen.dart'; // Reusing existing screen
import 'package:intl/intl.dart' as intl;

class KhatmahHomeSection extends StatelessWidget {
  const KhatmahHomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KhatmahBloc, KhatmahState>(
      builder: (context, state) {
        if (state is KhatmahLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is KhatmahError) {
          return Center(
            child: Text('Error: ${state.message}'),
          ); // Simple error for now
        } else if (state is KhatmahReflecting) {
          return _buildContent(context, state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContent(BuildContext context, KhatmahReflecting state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = state.progress;
    final details = state.pageDetails;

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 8.h,
      ), // Consistent margins logic handled by parent usually
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppColors.darkGrey.withOpacity(0.5),
                  AppColors.darkGrey.withOpacity(0.35),
                ]
              : [
                  AppColors.goldenColor.withOpacity(0.9),
                  AppColors.secondaryColor.withOpacity(0.8),
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
          // Row 1: Header
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
                    'وردك اليومي',
                    style: AppTextStyles.surahName.copyWith(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFonts.tajawal,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  intl.DateFormat('yyyy-MM-dd').format(progress.lastUpdated),
                  style: TextStyle(color: Colors.white, fontSize: 10.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Row 2: Main Info (Sura, Hizb)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      details.surahName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppFonts.quran,
                      ),
                    ),
                    Text(
                      'آياتها: ${details.totalAyahsInSurah}',
                      style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildInfoBadge('الحزب', '${details.hizb}'),
                  SizedBox(height: 4.h),
                  _buildInfoBadge('الجزء', '${details.juz}'),
                ],
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Row 3: Audio Controls
          Container(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    context.read<KhatmahBloc>().add(PauseAudio());
                  },
                  icon: Icon(Icons.pause_rounded, color: Colors.white),
                  tooltip: 'Pause',
                ),

                // Play/Pause Big Button
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: IconButton(
                    onPressed: () {
                      context.read<KhatmahBloc>().add(ToggleAudio());
                    },
                    icon: Icon(
                      state.isPlaying ? Icons.pause : Icons.play_arrow_rounded,
                      color: AppColors.goldenColor,
                      size: 32.sp,
                    ),
                  ),
                ),

                IconButton(
                  onPressed: () {
                    context.read<KhatmahBloc>().add(NextAyahAudio());
                  },
                  icon: Icon(Icons.skip_next_rounded, color: Colors.white),
                  tooltip: 'Next Ayah',
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Row 4: Continue Reading Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to reading screen
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
                    context.read<KhatmahBloc>().add(LoadKhatmah());
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
                'متابعة القراءة - ص ${progress.currentPage}',
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
  }

  Widget _buildInfoBadge(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(color: Colors.white70, fontSize: 10.sp),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}
