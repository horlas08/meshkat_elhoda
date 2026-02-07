import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/app_assets.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/location/presentation/bloc/location_bloc.dart';
import 'package:meshkat_elhoda/features/location/presentation/bloc/location_event.dart';
import 'package:meshkat_elhoda/features/location/presentation/bloc/location_state.dart';
import 'package:meshkat_elhoda/features/location/presentation/widgets/location_permission_dialog.dart';
import 'package:meshkat_elhoda/features/location/presentation/widgets/manual_location_dialog.dart';
import 'package:meshkat_elhoda/features/prayer_times/domain/entities/prayer_times_entity.dart';
import 'package:meshkat_elhoda/features/prayer_times/presentation/bloc/prayer_times_bloc.dart';
import 'package:meshkat_elhoda/features/prayer_times/presentation/bloc/prayer_times_event.dart';
import 'package:meshkat_elhoda/features/prayer_times/presentation/bloc/prayer_times_state.dart';

import 'package:meshkat_elhoda/features/prayer_times/presentation/views/qebla_direction_screen.dart';
import 'package:meshkat_elhoda/features/prayer_times/presentation/views/date_converter_view.dart';
import 'dart:async';

import 'package:meshkat_elhoda/features/quran_index/presentation/widgets/loading_widget.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';

class PrayerTimesView extends StatefulWidget {
  const PrayerTimesView({super.key});

  @override
  State<PrayerTimesView> createState() => _PrayerTimesViewState();
}

class _PrayerTimesViewState extends State<PrayerTimesView> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    context.read<LocationBloc>().add(LoadStoredLocation());
    context.read<PrayerTimesBloc>().add(LoadCachedPrayerTimes());

    // Update timer every second
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _getNextPrayerName(PrayerTimesEntity prayerTimes) {
    final now = DateTime.now();
    final currentTime = TimeOfDay.fromDateTime(now);
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;

    final prayers = [
      {'name': 'الفجر', 'time': prayerTimes.fajr},
      {'name': 'الظهر', 'time': prayerTimes.dhuhr},
      {'name': 'العصر', 'time': prayerTimes.asr},
      {'name': 'المغرب', 'time': prayerTimes.maghrib},
      {'name': 'العشاء', 'time': prayerTimes.isha},
    ];

    for (var prayer in prayers) {
      final parts = prayer['time']!.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1].split(' ')[0]);
      final prayerMinutes = hour * 60 + minute;

      if (currentMinutes < prayerMinutes) {
        return prayer['name']!;
      }
    }

    return 'الفجر';
  }

  bool _isNightPrayer(String prayerName) {
    return prayerName == 'المغرب' || prayerName == 'العشاء';
  }

  String _getRemainingTime(PrayerTimesEntity prayerTimes) {
    final now = DateTime.now();
    final currentTime = TimeOfDay.fromDateTime(now);
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;

    final prayers = [
      {'name': 'الفجر', 'time': prayerTimes.fajr},
      {'name': 'الظهر', 'time': prayerTimes.dhuhr},
      {'name': 'العصر', 'time': prayerTimes.asr},
      {'name': 'المغرب', 'time': prayerTimes.maghrib},
      {'name': 'العشاء', 'time': prayerTimes.isha},
    ];

    for (var prayer in prayers) {
      final parts = prayer['time']!.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1].split(' ')[0]);
      final prayerMinutes = hour * 60 + minute;

      if (currentMinutes < prayerMinutes) {
        final remaining = prayerMinutes - currentMinutes;
        final hours = remaining ~/ 60;
        final minutes = remaining % 60;
        final seconds = 60 - now.second;
        return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      }
    }

    // Calculate time until Fajr tomorrow
    final parts = prayerTimes.fajr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1].split(' ')[0]);
    final fajrMinutes = hour * 60 + minute;
    final remaining = (24 * 60 - currentMinutes) + fajrMinutes;
    final hours = remaining ~/ 60;
    final minutes = remaining % 60;
    final seconds = 60 - now.second;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? Color(0xff0a2f45)
          : AppColors.scaffoldBackgroundColor,
      body: MultiBlocListener(
        listeners: [
          BlocListener<LocationBloc, LocationState>(
            listener: (context, state) {
              if (state is LocationGranted) {
                context.read<PrayerTimesBloc>().add(
                  FetchPrayerTimes(location: state.location),
                );
              } else if (state is LocationDenied) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const LocationPermissionDialog(),
                );
              } else if (state is LocationInitial) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    context.read<LocationBloc>().add(
                      RequestLocationPermissionEvent(),
                    );
                  }
                });
              } else if (state is LocationError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.message,
                      style: TextStyle(
                        fontFamily: AppFonts.tajawal,
                        fontSize: 14.sp,
                      ),
                    ),
                    backgroundColor: Colors.red.shade500,
                    action: SnackBarAction(
                      label: AppLocalizations.of(
                        context,
                      )!.locationPermissionManualButton,
                      textColor: Colors.white,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const ManualLocationDialog(),
                        );
                      },
                    ),
                  ),
                );
              }
            },
          ),
          BlocListener<PrayerTimesBloc, PrayerTimesState>(
            listener: (context, state) {
              if (state is PrayerTimesError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.message,
                      style: TextStyle(
                        fontFamily: AppFonts.tajawal,
                        fontSize: 14.sp,
                      ),
                    ),
                    backgroundColor: Colors.red.shade500,
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<PrayerTimesBloc, PrayerTimesState>(
          builder: (context, state) {
            if (state is PrayerTimesLoading) {
              return const Center(child: QuranLottieLoading());
            }

            if (state is PrayerTimesLoaded && state.prayerTimes != null) {
              final prayerTimes = state.prayerTimes!;
              final nextPrayer = _getNextPrayerName(prayerTimes);
              final remainingTime = _getRemainingTime(prayerTimes);
              final dateInfo = prayerTimes.dateInfo.hijri;

              return Column(
                children: [
                  // Header with background image
                  Container(
                    height: 280.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30.r),
                        bottomRight: Radius.circular(30.r),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30.r),
                        bottomRight: Radius.circular(30.r),
                      ),
                      child: Stack(
                        children: [
                          // Background image
                          Positioned.fill(
                            child: Image.asset(
                              _isNightPrayer(nextPrayer)
                                  ? AppAssets.dark
                                  : AppAssets.light,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Gradient overlay
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.3),
                                    Colors.black.withOpacity(0.1),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Content
                          SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Back button
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 8.h,
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: () => Navigator.pop(context),
                                        icon: Icon(
                                          Icons.arrow_back_ios,
                                          color: Colors.white,
                                          size: 20.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 6.h),

                                // Next prayer name
                                Text(
                                  '$nextPrayer ${AppLocalizations.of(context)!.after}',
                                  style: TextStyle(
                                    fontFamily: AppFonts.tajawal,
                                    fontSize: 18.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                SizedBox(height: 4.h),

                                // Countdown timer
                                Text(
                                  remainingTime,
                                  style: TextStyle(
                                    fontFamily: AppFonts.tajawal,
                                    fontSize: 40.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),

                                SizedBox(height: 12.h),

                                // Qibla button
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => QiblaScreen(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20.w,
                                      vertical: 8.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF2C3E50),
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.qibla,
                                          style: TextStyle(
                                            fontFamily: AppFonts.tajawal,
                                            fontSize: 12.sp,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(width: 6.w),
                                        Container(
                                          padding: EdgeInsets.all(4.w),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.explore,
                                            color: Color(0xFF2C3E50),
                                            size: 14.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Date section + converter icon
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: 12.h,
                      horizontal: 16.w,
                    ),
                    color: isDark ? Color(0xff0a2f45) : Colors.white,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DateConverterView(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.calculate_outlined),
                          color: isDark ? Colors.white : AppColors.blacColor,
                          tooltip: AppLocalizations.of(context)!.dateConverter,
                        ),
                        const Spacer(),
                        Text(
                          '${dateInfo.weekday} ${dateInfo.day} ${dateInfo.month} ${dateInfo.year}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppFonts.tajawal,
                            fontSize: 16.sp,
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Prayer times list
                  Expanded(
                    child: Container(
                      color: isDark ? Color(0xff0a2f45) : Colors.white,
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          _buildPrayerTimeRow(
                            AppLocalizations.of(context)!.fajr,
                            prayerTimes.fajr,
                            Icons.wb_twilight,
                            Colors.orange.shade300,
                          ),
                          _buildPrayerTimeRow(
                            AppLocalizations.of(context)!.sunrise,
                            prayerTimes.sunrise,
                            Icons.wb_sunny,
                            Colors.yellow.shade600,
                          ),
                          _buildPrayerTimeRow(
                            AppLocalizations.of(context)!.duhr,
                            prayerTimes.dhuhr,
                            Icons.wb_sunny_outlined,
                            Colors.amber.shade400,
                          ),
                          _buildPrayerTimeRow(
                            AppLocalizations.of(context)!.asr,
                            prayerTimes.asr,
                            Icons.wb_cloudy,
                            Colors.orange.shade400,
                          ),
                          _buildPrayerTimeRow(
                            AppLocalizations.of(context)!.maghrib,
                            prayerTimes.maghrib,
                            Icons.nights_stay,
                            Colors.indigo.shade300,
                          ),
                          _buildPrayerTimeRow(
                            AppLocalizations.of(context)!.isha,
                            prayerTimes.isha,
                            Icons.nightlight,
                            Colors.indigo.shade400,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return const Center(child: QuranLottieLoading());
          },
        ),
      ),
    );
  }

  Widget _buildPrayerTimeRow(
    String name,
    String time,
    IconData icon,
    Color iconColor,
  ) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.grey[800]! : Colors.grey.shade200,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: iconColor, size: 20.sp),
              ),

              SizedBox(width: 16.w),

              // Prayer name
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontFamily: AppFonts.tajawal,
                    fontSize: 16.sp,
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Prayer time
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16.sp,
                    color: isDark ? Colors.grey[400] : Colors.grey.shade600,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    time,
                    style: TextStyle(
                      fontFamily: AppFonts.tajawal,
                      fontSize: 16.sp,
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
