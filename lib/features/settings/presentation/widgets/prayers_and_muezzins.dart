import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/utils/app_assets.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/features/settings/presentation/widgets/setting_item.dart';
import 'package:meshkat_elhoda/features/settings/presentation/widgets/settings_title.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/pages/subscription_page.dart';
import 'package:meshkat_elhoda/features/tasbeh/presentation/widget/custom_icon.dart';
import 'package:meshkat_elhoda/features/prayer_times/presentation/bloc/prayer_times_bloc.dart';
import 'package:meshkat_elhoda/features/prayer_times/presentation/bloc/prayer_times_state.dart';
import 'package:meshkat_elhoda/features/prayer_times/presentation/bloc/prayer_times_event.dart';
import 'package:meshkat_elhoda/features/prayer_times/domain/entities/muezzin.dart';
import 'package:meshkat_elhoda/core/services/athan_audio_service.dart';
import 'package:meshkat_elhoda/core/services/flutter_athan_service.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_state.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_event.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';

class PrayersAndMuezzins extends StatefulWidget {
  const PrayersAndMuezzins({super.key});

  @override
  State<PrayersAndMuezzins> createState() => _PrayersAndMuezzinsState();
}

class _PrayersAndMuezzinsState extends State<PrayersAndMuezzins> {
  final GlobalKey<SettingTitleState> _titleKey = GlobalKey<SettingTitleState>();

  @override
  void initState() {
    super.initState();
    // تحميل بيانات الاشتراك
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionBloc>().add(LoadSubscriptionEvent());
    });
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
            title: SettingTitle(
              key: _titleKey,
              title: s.prayersAndMuezzinsTitle,
              iconPath: AppAssets.mosque,
            ),
            children: [
              BlocBuilder<PrayerTimesBloc, PrayerTimesState>(
                builder: (context, state) {
                  String currentMuezzinName = s.notSpecified;

                  if (state is PrayerTimesLoaded &&
                      state.muezzins.isNotEmpty &&
                      state.selectedMuezzinId != null) {
                    final selectedMuezzin = state.muezzins
                        .cast<Muezzin>()
                        .firstWhere(
                          (m) => m.id == state.selectedMuezzinId,
                          orElse: () => state.muezzins.first,
                        );
                    currentMuezzinName = selectedMuezzin.name;
                  }

                  return SettingItem(
                    iconWidget: CustomIcon(
                      iconPath: AppAssets.down,
                      color: AppColors.goldenColor,
                    ),
                    title: s.selectMuezzin.replaceFirst(
                      '{0}',
                      currentMuezzinName,
                    ),
                    onTap: () => _showMuezzinDialog(context),
                  );
                },
              ),

              BlocBuilder<PrayerTimesBloc, PrayerTimesState>(
                builder: (context, state) {
                  return SettingItem(
                    iconWidget: SoundIcon(
                      onPlayToggle: () async {
                        final s = AppLocalizations.of(context)!;

                        if (state is PrayerTimesLoaded &&
                            state.muezzins.isNotEmpty &&
                            state.selectedMuezzinId != null) {
                          final selectedMuezzin = state.muezzins
                              .cast<Muezzin>()
                              .firstWhere(
                                (m) => m.id == state.selectedMuezzinId,
                                orElse: () => state.muezzins.first,
                              );

                          // تشغيل صوت الأذان المختار فقط (بدون إشعار)
                          await FlutterAthanService().playFullAthan(
                            prayerName: 'Dhuhr', // للاختبار نستخدم صوت عادي
                            muezzinId: selectedMuezzin.id,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                s.playingMuezzinSound.replaceFirst(
                                  '{0}',
                                  selectedMuezzin.name,
                                ),
                                style: AppTextStyles.surahName,
                                textAlign: TextAlign.center,
                              ),
                              backgroundColor: AppColors.goldenColor,
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                          );
                          return true; // يعني التشغيل بدأ
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                s.selectMuezzinFirst,
                                style: AppTextStyles.surahName,
                                textAlign: TextAlign.center,
                              ),
                              backgroundColor: AppColors.errorColor,
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                          );
                          return false; // لم يبدأ التشغيل
                        }
                      },
                    ),
                    title: s.playAthanSound,
                  );
                },
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }

  void _showMuezzinDialog(BuildContext context) {
    final s = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => BlocBuilder<SubscriptionBloc, SubscriptionState>(
        builder: (context, subscriptionState) {
          // التحقق من حالة الاشتراك
          final isPremium =
              subscriptionState is SubscriptionLoaded &&
              subscriptionState.subscription.isPremium;

          return BlocBuilder<PrayerTimesBloc, PrayerTimesState>(
            builder: (context, state) {
              if (state is! PrayerTimesLoaded || state.muezzins.isEmpty) {
                return AlertDialog(
                  backgroundColor: AppColors.blacColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  title: Text(
                    s.selectMuezzinDialogTitle,
                    style: AppTextStyles.topHeadline.copyWith(fontSize: 18.sp),
                    textAlign: TextAlign.center,
                  ),
                  content: Text(
                    s.noRecitersAvailable,
                    style: AppTextStyles.surahName,
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return AlertDialog(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                title: Row(
                  children: [
                    Icon(Icons.mic, color: AppColors.goldenColor, size: 24.sp),
                    SizedBox(width: 8.w),
                    Text(
                      s.chooseFavoriteMuezzin,
                      style: AppTextStyles.topHeadline.copyWith(
                        fontSize: 18.sp,
                      ),
                    ),
                  ],
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.muezzins.length,
                    itemBuilder: (context, index) {
                      final muezzin = state.muezzins[index];
                      final isSelected = muezzin.id == state.selectedMuezzinId;

                      // قفل جميع المؤذنين ماعدا Ali Almula للمستخدمين المجانيين
                      final isLocked =
                          muezzin.name != 'Ali Almula' && !isPremium;

                      return Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.goldenColor.withOpacity(0.1)
                              : (isLocked
                                    ? AppColors.greyColor.withOpacity(0.02)
                                    : AppColors.greyColor.withOpacity(0.05)),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.goldenColor
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 4.h,
                          ),
                          leading: Container(
                            padding: EdgeInsets.all(8.sp),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.goldenColor
                                  : (isLocked
                                        ? AppColors.greyColor.withOpacity(0.1)
                                        : AppColors.greyColor.withOpacity(0.2)),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSelected
                                  ? Icons.check
                                  : (isLocked ? Icons.lock : Icons.person),
                              color: isSelected
                                  ? AppColors.blacColor
                                  : (isLocked
                                        ? AppColors.goldenColor
                                        : AppColors.goldenColor),
                              size: 20.sp,
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  muezzin.name,
                                  style: AppTextStyles.surahName.copyWith(
                                    color: isLocked
                                        ? Colors.grey
                                        : (isSelected
                                              ? AppColors.goldenColor
                                              : AppColors.blacColor),
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontFamily: AppFonts.tajawal,
                                  ),
                                ),
                              ),
                              if (isLocked) ...[
                                SizedBox(width: 8.w),
                                Icon(
                                  Icons.lock,
                                  size: 16.sp,
                                  color: AppColors.goldenColor,
                                ),
                              ],
                            ],
                          ),
                          onTap: () {
                            if (isLocked) {
                              _showPremiumDialog(context);
                              return;
                            }

                            context.read<PrayerTimesBloc>().add(
                              SetMuezzin(muezzin.id),
                            );
                            Navigator.of(dialogContext).pop();

                            // Show confirmation snackbar
                            final s = AppLocalizations.of(context)!;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  s.muezzinSelected.replaceFirst(
                                    '{0}',
                                    muezzin.name,
                                  ),
                                  style: AppTextStyles.surahName,
                                  textAlign: TextAlign.center,
                                ),
                                backgroundColor: AppColors.goldenColor,
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showPremiumDialog(BuildContext context) {
    final s = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.star, color: AppColors.goldenColor),
            SizedBox(width: 8.w),
            Text(
              s.premiumFeature,
              style: AppTextStyles.topHeadline.copyWith(
                fontSize: 16.sp,
                fontFamily: AppFonts.tajawal,
              ),
            ),
          ],
        ),
        content: Text(
          s.premiumFeatureDescription,
          style: AppTextStyles.surahName.copyWith(
            fontSize: 14.sp,
            fontFamily: AppFonts.tajawal,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(s.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blacColor,
            ),
            child: Text(s.upgradeNow),
          ),
        ],
      ),
    );
  }
}

class SoundIcon extends StatefulWidget {
  const SoundIcon({super.key, this.onPlayToggle});
  final Future<bool> Function()?
  onPlayToggle; // returns true if playing, false if stopped

  @override
  State<SoundIcon> createState() => _SoundIconState();
}

class _SoundIconState extends State<SoundIcon> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (_isPlaying) {
          // إيقاف الأذان
          await AthanAudioService().stopAthan();
          setState(() {
            _isPlaying = false;
          });
        } else {
          // تشغيل الأذان
          final result = await widget.onPlayToggle?.call();
          setState(() {
            _isPlaying = result ?? true;
          });
        }
      },
      child: Icon(
        _isPlaying ? Icons.stop : Icons.volume_up,
        size: 18.sp,
        color: _isPlaying ? Colors.red : AppColors.goldenColor,
      ),
    );
  }
}
