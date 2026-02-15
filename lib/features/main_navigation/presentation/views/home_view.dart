import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/location/presentation/bloc/location_bloc.dart';
import 'package:meshkat_elhoda/features/location/presentation/bloc/location_event.dart';
import 'package:meshkat_elhoda/features/location/presentation/bloc/location_state.dart';
import 'package:meshkat_elhoda/features/main_navigation/presentation/widgets/date_details_widget.dart';
import 'package:meshkat_elhoda/features/main_navigation/presentation/widgets/home_header_section.dart';
import 'package:meshkat_elhoda/features/main_navigation/presentation/widgets/islamic_gridview.dart';
import 'package:meshkat_elhoda/features/main_navigation/presentation/widgets/welcome_text.dart';
import 'package:meshkat_elhoda/features/prayer_times/domain/entities/prayer_times_entity.dart';
import 'package:meshkat_elhoda/features/prayer_times/domain/entities/next_prayer_info.dart';
import 'package:meshkat_elhoda/features/prayer_times/presentation/bloc/prayer_times_bloc.dart';
import 'package:meshkat_elhoda/features/prayer_times/presentation/bloc/prayer_times_event.dart';
import 'package:meshkat_elhoda/features/prayer_times/presentation/bloc/prayer_times_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';
import 'package:meshkat_elhoda/core/services/weather_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  CalendarType _calendarType = CalendarType.hijri;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Start animation
    _animationController.forward();

    // ✅ التحقق من حالة البيانات عند البدء وتشغيل منطق الموقع
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prayerState = context.read<PrayerTimesBloc>().state;
      final locationState = context.read<LocationBloc>().state;

      // إذا الموقع متاح، نبدأ التحديثات فوراً
      if (locationState is LocationGranted) {
        context.read<LocationBloc>().add(StartLocationUpdates());
      }

      // إذا لم تكن مواقيت الصلاة محملة، نحاول تحميل الموقع
      if (prayerState is! PrayerTimesLoaded ||
          prayerState.prayerTimes == null) {
        if (locationState is LocationInitial) {
          context.read<LocationBloc>().add(LoadStoredLocation());
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // دالة لتحديد الصلاة التالية وحساب الوقت المتبقي بشكل صحيح
  NextPrayerInfo _getNextPrayerInfo(PrayerTimesEntity prayerTimes) {
    final now = DateTime.now();

    // تحويل أوقات الصلاة إلى DateTime لليوم الحالي
    DateTime _timeOfDayToDateTime(TimeOfDay time) {
      return DateTime(now.year, now.month, now.day, time.hour, time.minute);
    }

    final prayers = [
      _parsePrayerTime(prayerTimes.fajr, AppLocalizations.of(context)!.fajr),
      _parsePrayerTime(prayerTimes.dhuhr, AppLocalizations.of(context)!.duhr),
      _parsePrayerTime(prayerTimes.asr, AppLocalizations.of(context)!.asr),
      _parsePrayerTime(
        prayerTimes.maghrib,
        AppLocalizations.of(context)!.maghrib,
      ),
      _parsePrayerTime(prayerTimes.isha, AppLocalizations.of(context)!.isha),
    ];

    // ترتيب الصلوات حسب الوقت
    prayers.sort(
      (a, b) => (a.time.hour * 60 + a.time.minute).compareTo(
        b.time.hour * 60 + b.time.minute,
      ),
    );

    // إيجاد أول صلاة يكون وقتها بعد الآن
    PrayerTime? nextPrayer;
    DateTime? nextPrayerDateTime;

    for (final p in prayers) {
      final prayerDateTime = _timeOfDayToDateTime(p.time);
      if (prayerDateTime.isAfter(now)) {
        nextPrayer = p;
        nextPrayerDateTime = prayerDateTime;
        break;
      }
    }

    // إذا كانت كل الصلوات قد مضت اليوم، نجعل الصلاة التالية هي أول صلاة في اليوم التالي
    nextPrayer ??= prayers.first;
    nextPrayerDateTime ??= _timeOfDayToDateTime(
      prayers.first.time,
    ).add(const Duration(days: 1));

    final remainingDuration = nextPrayerDateTime.difference(now);
    final totalMinutes = remainingDuration.inMinutes;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    return NextPrayerInfo(
      prayerName: nextPrayer.name,
      prayerTime: _formatTime(nextPrayer.time),
      remainingTime:
          '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}',
      isNightPrayer: nextPrayer.name == 'المغرب' || nextPrayer.name == 'العشاء',
    );
  }

  PrayerTime _parsePrayerTime(String timeString, String name) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1].split(' ')[0]);

    return PrayerTime(
      time: TimeOfDay(hour: hour, minute: minute),
      name: name,
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  // ✅ جلب اسم المستخدم من Firestore
  Future<String> _getUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return 'ضيف';

      // Try displayName first (for new users)
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        return user.displayName!;
      }

      // Fallback to Firestore (for existing users)
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data()?['name'] != null) {
        final name = doc.data()!['name'] as String;
        // Update displayName for future use
        await user.updateDisplayName(name);
        return name;
      }

      // Last fallback: email
      return user.email?.split('@').first ?? 'ضيف';
    } catch (e) {
      print('Error fetching user name: $e');
      return 'ضيف';
    }
  }

  Future<void> _onRefresh() async {
    final locationState = context.read<LocationBloc>().state;

    if (locationState is LocationGranted) {
      context.read<PrayerTimesBloc>().add(
        FetchPrayerTimes(location: locationState.location),
      );
    } else {
      context.read<LocationBloc>().add(RequestLocationPermissionEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationBloc, LocationState>(
      listener: (context, state) {
        if (state is LocationGranted) {
          // ✅ تم الحصول على الموقع -> جلب مواقيت الصلاة
          context.read<PrayerTimesBloc>().add(
            FetchPrayerTimes(location: state.location),
          );
          // Start foreground location updates
          context.read<LocationBloc>().add(StartLocationUpdates());

          // Check Weather for Thunder Notification
          WeatherService().checkWeatherAndNotify();
        } else if (state is LocationInitial) {
          // ✅ لا يوجد موقع مخزن -> طلب الإذن بعد مهلة قصيرة
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              context.read<LocationBloc>().add(
                RequestLocationPermissionEvent(),
              );
            }
          });
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16.h),

                        // Date Details with Calendar Type Toggle
                        BlocBuilder<PrayerTimesBloc, PrayerTimesState>(
                          builder: (context, state) {
                            if (state is PrayerTimesLoaded &&
                                state.prayerTimes != null) {
                              final dateInfo = state.prayerTimes!.dateInfo;
                              final isHijri =
                                  _calendarType == CalendarType.hijri;
                              final currentDate =
                                  (isHijri
                                          ? dateInfo.hijri
                                          : dateInfo.gregorian)
                                      as dynamic;

                              return DateDetailsWidget(
                                day: currentDate.weekday,
                                date: currentDate.day,
                                month: currentDate.month,
                                year: isHijri
                                    ? '${currentDate.year} هـ'
                                    : currentDate.year,
                                onTap: () {
                                  setState(() {
                                    _calendarType = isHijri
                                        ? CalendarType.gregorian
                                        : CalendarType.hijri;
                                  });
                                  context.read<PrayerTimesBloc>().add(
                                    SwitchCalendarType(type: _calendarType),
                                  );
                                },
                              );
                            }
                            // ✅ حالة التحميل - بيانات واقعية
                            return DateDetailsWidget(
                              day: '...',
                              date: '--',
                              month: '...',
                              year: '----',
                              onTap: () {},
                            );
                          },
                        ),

                        SizedBox(height: 20.h),

                        // Welcome Text with Firebase User Name from Firestore
                        FutureBuilder<String>(
                          future: _getUserName(),
                          builder: (context, snapshot) {
                            final userName = snapshot.data ?? 'ضيف';
                            return WelcomeText(userName: userName);
                          },
                        ),

                        SizedBox(height: 20.h),

                        // HomeHeaderSection مع تمرير بيانات الصلاة التالية
                        BlocBuilder<PrayerTimesBloc, PrayerTimesState>(
                          builder: (context, prayerState) {
                            return BlocBuilder<LocationBloc, LocationState>(
                              builder: (context, locationState) {
                                String? locationString;
                                if (locationState is LocationGranted) {
                                  final country =
                                      locationState.location.country;
                                  final city = locationState.location.city;
                                  if (country != null && city != null) {
                                    locationString = '$country, $city';
                                  } else {
                                    locationString = country ?? city;
                                  }
                                }

                                if (prayerState is PrayerTimesLoaded &&
                                    prayerState.prayerTimes != null) {
                                  final nextPrayerInfo = _getNextPrayerInfo(
                                    prayerState.prayerTimes!,
                                  );
                                  return HomeHeaderSection(
                                    nextPrayerInfo: nextPrayerInfo,
                                    location: locationString,
                                  );
                                }
                                // ✅ حالة التحميل - بيانات واقعية
                                return HomeHeaderSection(
                                  nextPrayerInfo: NextPrayerInfo(
                                    prayerName: '...',
                                    prayerTime: '--:--',
                                    remainingTime: '--:--',
                                    isNightPrayer: false,
                                  ),
                                  location: locationString,
                                );
                              },
                            );
                          },
                        ),

                        SizedBox(height: 20.h),

                        // Refactored Khatmah Section
                        SizedBox(height: 10.h),

                        SizedBox(height: 34.h),

                        // Islamic Grid مع التصميم الجديد
                        IslamicGrid(),

                        SizedBox(height: 20.h), // مسافة إضافية في الأسفل
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
