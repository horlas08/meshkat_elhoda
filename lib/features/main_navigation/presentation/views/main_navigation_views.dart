import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/utils/app_assets.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:meshkat_elhoda/features/islamic_calendar/presentation/pages/islamic_calendar_screen.dart';
import 'package:meshkat_elhoda/features/main_navigation/presentation/views/home_view.dart';
import 'package:meshkat_elhoda/features/settings/presentation/views/setting_view.dart';
import 'package:meshkat_elhoda/features/tasbeh/presentation/widget/custom_icon.dart';
import 'package:meshkat_elhoda/features/location/presentation/bloc/location_bloc.dart';
import 'package:meshkat_elhoda/features/location/presentation/bloc/location_event.dart';
import 'package:meshkat_elhoda/features/prayer_times/presentation/bloc/prayer_times_bloc.dart';
import 'package:meshkat_elhoda/features/prayer_times/presentation/bloc/prayer_times_event.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';

class MainNavigationViews extends StatefulWidget {
  const MainNavigationViews({super.key});

  @override
  State<MainNavigationViews> createState() => _MainNavigationViewsState();
}

class _MainNavigationViewsState extends State<MainNavigationViews>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Widget> views = const [
    HomeView(),
    FavoritesExampleScreen(),
    IslamicCalendarScreen(),
    SettingView(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Start animation on init
    _animationController.forward();

    context.read<LocationBloc>().add(LoadStoredLocation());
    context.read<PrayerTimesBloc>().add(LoadCachedPrayerTimes());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double widthScreen = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: views[currentIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xff0A2F45) : AppColors.primaryColor,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? Colors.white12
                  : AppColors.blacColor.withValues(alpha: .25),
              width: 1.h,
            ),
          ),
        ),

        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // استبدل النصوص بهذه:
                bottomNavItem(
                  0,
                  AppAssets.home,
                  AppLocalizations.of(context)!.home,
                  isDark,
                ),
                bottomNavItem(
                  1,
                  AppAssets.saved,
                  AppLocalizations.of(context)!.favorites,
                  isDark,
                ),
                bottomNavItem(
                  2,
                  AppAssets.history,
                  AppLocalizations.of(context)!.islamicCalendar,
                  isDark,
                ),
                bottomNavItem(
                  3,
                  AppAssets.setting,
                  AppLocalizations.of(context)!.settings,
                  isDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomNavItem(int index, String iconPath, String label, bool isDark) {
    final isSelected = currentIndex == index;
    final selectedColor = const Color(0xFFD4AF37);
    final unselectedColor = isDark ? Colors.white54 : AppColors.greyColor;

    return InkWell(
      onTap: () {
        if (currentIndex != index) {
          // Reset and restart animation on tab change
          _animationController.reset();
          setState(() {
            currentIndex = index;
          });
          _animationController.forward();
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIcon(
              iconPath: iconPath,
              height: 24.h,
              width: 24.w,
              color: isSelected ? selectedColor : unselectedColor,
            ),

            SizedBox(height: 8.h),

            Text(
              label,
              style: AppTextStyles.surahName.copyWith(
                color: isSelected ? selectedColor : unselectedColor,
                fontFamily: AppFonts.tajawal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
