import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:meshkat_elhoda/core/utils/app_assets.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/core/services/location_refresh_service.dart';
import 'package:meshkat_elhoda/features/location/presentation/bloc/location_bloc.dart';
import 'package:meshkat_elhoda/features/location/presentation/bloc/location_event.dart';
import 'package:meshkat_elhoda/features/location/presentation/bloc/location_state.dart';
import 'package:meshkat_elhoda/features/settings/presentation/widgets/settings_title.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationSettings extends StatefulWidget {
  const LocationSettings({super.key});

  @override
  State<LocationSettings> createState() => _LocationSettingsState();
}

class _LocationSettingsState extends State<LocationSettings> {
  final GlobalKey<SettingTitleState> _titleKey = GlobalKey<SettingTitleState>();
  late LocationRefreshService _locationRefreshService;
  bool _isAutoRefreshEnabled = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _initLocationService();
  }

  Future<void> _initLocationService() async {
    final prefs = await SharedPreferences.getInstance();
    _locationRefreshService = LocationRefreshService(prefs);
    setState(() {
      _isAutoRefreshEnabled = _locationRefreshService.isAutoRefreshEnabled;
    });
  }

  Future<void> _toggleAutoRefresh(bool value) async {
    await _locationRefreshService.setAutoRefresh(value);
    setState(() {
      _isAutoRefreshEnabled = value;
    });
  }

  Future<void> _manualRefresh() async {
    // ✅ التحقق من إذن الموقع أولاً
    final permissionStatus = await Permission.location.status;
    if (!permissionStatus.isGranted) {
      // عرض ديالوج الإفصاح عن الموقع
      await _showLocationDisclosureDialog();
      return;
    }

    setState(() {
      _isRefreshing = true;
    });

    // طلب تحديث الموقع بشكل إجباري
    context.read<LocationBloc>().add(
      const RefreshLocationIfNeeded(forceRefresh: true),
    );

    // انتظار ثانيتين ثم إيقاف مؤشر التحميل
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });

      final s = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            s.locationUpdatedSuccessfully,
            style: TextStyle(fontFamily: AppFonts.tajawal),
          ),
          backgroundColor: AppColors.goldenColor,
        ),
      );
    }
  }

  // ✅ دالة عرض ديالوج الإفصاح عن الموقع
  Future<void> _showLocationDisclosureDialog() async {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.location_on, color: AppColors.goldenColor, size: 28.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                isArabic ? 'تحسين دقة مواقيت الصلاة' : 'Location Precision',
                style: TextStyle(
                  fontFamily: AppFonts.tajawal,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          isArabic
              ? 'يحتاج تطبيق مشكاة الهدى للوصول إلى موقعك الجغرافي لضمان دقة مواقيت الصلاة وتنبيهات الأذان واتجاه القبلة بناءً على مكانك الحالي.'
              : 'Mishkat Al-Hoda needs location access to ensure accurate prayer times, Athan notifications, and Qibla direction based on your current location.',
          style: TextStyle(
            fontFamily: AppFonts.tajawal,
            fontSize: 14.sp,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              isArabic ? 'لاحقاً' : 'Later',
              style: TextStyle(
                fontFamily: AppFonts.tajawal,
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              // طلب إذن الموقع
              context.read<LocationBloc>().add(
                RequestLocationPermissionEvent(),
              );
              // انتظار قليل للسماح للنظام بالتعامل مع الطلب
              await Future.delayed(const Duration(milliseconds: 500));
              // إعادة التحقق وتحديث الموقع إذا تم منح الإذن
              final newStatus = await Permission.location.status;
              if (newStatus.isGranted && mounted) {
                _manualRefresh();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldenColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              isArabic ? 'السماح' : 'Allow',
              style: TextStyle(
                fontFamily: AppFonts.tajawal,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;

    return Column(
      children: [
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            showTrailingIcon: false,
            onExpansionChanged: (expanded) {
              _titleKey.currentState?.setExpanded(expanded);
            },
            childrenPadding: EdgeInsets.symmetric(horizontal: 12.w),
            title: SettingTitle(
              key: _titleKey,
              title: s.locationSettingsTitle,
              iconPath: AppAssets.locationIcon,
            ),
            children: [
              // عرض الموقع الحالي
              BlocBuilder<LocationBloc, LocationState>(
                builder: (context, state) {
                  if (state is LocationGranted) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).dividerColor.withOpacity(0.5),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                s.countryLabel,
                                style: AppTextStyles.surahName.copyWith(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: AppFonts.tajawal,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                ),
                              ),
                              Text(
                                state.location.country ?? s.unknown,
                                style: AppTextStyles.surahName.copyWith(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: AppFonts.tajawal,
                                  color: AppColors.goldenColor,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: Divider(height: 1, thickness: 0.5),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                s.regionLabel,
                                style: AppTextStyles.surahName.copyWith(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: AppFonts.tajawal,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                ),
                              ),
                              Text(
                                state.location.city ?? s.unknown,
                                style: AppTextStyles.surahName.copyWith(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: AppFonts.tajawal,
                                  color: AppColors.goldenColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // تبديل التحديث التلقائي
              SizedBox(
                height: 40.h,
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    s.autoRefreshLocation,
                    style: AppTextStyles.surahName.copyWith(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      fontFamily: AppFonts.tajawal,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  value: _isAutoRefreshEnabled,
                  activeColor: AppColors.goldenColor,
                  onChanged: _toggleAutoRefresh,
                ),
              ),

              SizedBox(height: 8.h),

              // زر التحديث اليدوي
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isRefreshing ? null : _manualRefresh,
                  icon: _isRefreshing
                      ? SizedBox(
                          width: 16.w,
                          height: 16.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Icon(Icons.refresh, size: 18.sp),
                  label: Text(
                    _isRefreshing ? s.updating : s.refreshLocationNow,
                    style: AppTextStyles.surahName.copyWith(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: AppFonts.tajawal,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldenColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 14.h),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}
