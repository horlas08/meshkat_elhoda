import 'package:flutter/foundation.dart'; // for kDebugMode
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/core/widgets/ad_banner_widget.dart';
import 'package:meshkat_elhoda/features/settings/presentation/widgets/account_and_subscription.dart';
import 'package:meshkat_elhoda/features/settings/presentation/widgets/notifications.dart';
import 'package:meshkat_elhoda/features/settings/presentation/widgets/prayers_and_muezzins.dart';
import 'package:meshkat_elhoda/features/settings/presentation/widgets/settings_genral.dart';
import 'package:meshkat_elhoda/features/settings/presentation/widgets/quran_settings.dart';
import 'package:meshkat_elhoda/features/settings/presentation/widgets/theme_option.dart';
import 'package:meshkat_elhoda/features/settings/presentation/pages/test_subscription_page.dart';
import 'package:meshkat_elhoda/features/settings/presentation/widgets/location_settings.dart';
import 'package:meshkat_elhoda/features/settings/presentation/widgets/delete_account_section.dart';
import 'package:meshkat_elhoda/features/prayer_times/presentation/bloc/prayer_times_bloc.dart';
import 'package:meshkat_elhoda/features/prayer_times/presentation/bloc/prayer_times_event.dart';

class SettingView extends StatefulWidget {
  const SettingView({super.key});

  @override
  State<SettingView> createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    context.read<PrayerTimesBloc>().add(LoadMuezzins());

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                child: Column(
                  children: [
                    Text(
                      'الإعدادات',
                      style: AppTextStyles.topHeadline.copyWith(
                        fontSize: 20.sp,
                        color: Theme.of(context).brightness == Brightness.light
                            ? AppColors.blacColor
                            : AppColors.whiteColor,
                      ),
                    ),

                    ThemeOption(),

                    Notifications(),

                    LocationSettings(),

                    PrayersAndMuezzins(),

                    QuranSettings(),

                    AccountAndSubscription(),

                    // زر اختبار الاشتراكات (للتطوير فقط - يختفي في Release)
                    if (kDebugMode)
                      Card(
                        margin: EdgeInsets.symmetric(vertical: 8.h),
                        child: ListTile(
                          leading: Icon(Icons.science, color: Colors.orange),
                          title: Text(
                            '🧪 اختبار الاشتراكات (Dev)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'صفحة اختبار نظام الشراء داخل التطبيق',
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TestSubscriptionPage(),
                              ),
                            );
                          },
                        ),
                      ),

                    SettingsGeneral(),

                    DeleteAccountSection(),

                    SizedBox(height: 32.h),

                    Text(
                      'الإصدار: 1.0.0 | Mishkat Al-Huda Pro © 2025',
                      style: AppTextStyles.surahName.copyWith(
                        color: AppColors.greyColor,
                        fontWeight: FontWeight.w300,
                        fontFamily: AppFonts.tajawal,
                      ),
                    ),

                    SizedBox(height: 33.h),

                    const AdBannerWidget(
                      useAdaptiveBanner: true,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
