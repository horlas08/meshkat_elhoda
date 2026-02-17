import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/services/service_locator.dart';
import 'package:meshkat_elhoda/core/utils/app_assets.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/settings/presentation/cubit/notification_settings_cubit.dart';
import 'package:meshkat_elhoda/features/settings/data/models/notification_settings_model.dart';
import 'package:meshkat_elhoda/features/settings/presentation/widgets/settings_title.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_state.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_event.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/pages/subscription_page.dart';
import 'package:meshkat_elhoda/core/services/smart_dhikr_service.dart';
import 'package:meshkat_elhoda/features/quran_audio/presentation/screens/audio_main_screen.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
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

    return BlocProvider(
      create: (_) => getIt<NotificationSettingsCubit>(),
      child: Column(
        children: [
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: BlocBuilder<SubscriptionBloc, SubscriptionState>(
              builder: (context, subscriptionState) {
                // التحقق من حالة الاشتراك
                final isPremium =
                    subscriptionState is SubscriptionLoaded &&
                    subscriptionState.subscription.isPremium;

                return BlocBuilder<
                  NotificationSettingsCubit,
                  NotificationSettingsModel
                >(
                  builder: (context, settings) {
                    return ExpansionTile(
                      showTrailingIcon: false,
                      onExpansionChanged: (expanded) {
                        _titleKey.currentState?.setExpanded(expanded);
                      },
                      childrenPadding: EdgeInsets.symmetric(horizontal: 12.w),
                      title: SettingTitle(
                        key: _titleKey,
                        title: s.notificationsTitle,
                        iconPath: AppAssets.notifications,
                      ),
                      children: [
                        // 1. إشعار الأذان (مدفوع)
                        _buildCheckboxTile(
                          context,
                          title: s.athanNotification,
                          value: settings.isAthanEnabled,
                          isPremium: isPremium,
                          isLocked: !isPremium,
                          onChanged: (value) {
                            if (!isPremium) {
                              _showPremiumDialog(context);
                              return;
                            }
                            if (value != null) {
                              context
                                  .read<NotificationSettingsCubit>()
                                  .toggleAthanNotification(value);
                            }
                          },
                        ),

                        _buildCheckboxTile(
                          context,
                          title: s.athanOverlaySettingTitle,
                          value: settings.isAthanOverlayEnabled,
                          isPremium: isPremium,
                          isLocked: !isPremium,
                          onChanged: (value) {
                            if (!isPremium) {
                              _showPremiumDialog(context);
                              return;
                            }
                            if (value != null) {
                              context
                                  .read<NotificationSettingsCubit>()
                                  .toggleAthanOverlay(value);
                            }
                          },
                        ),

                        // 2. إشعار قبل الأذان بـ 5 دقائق (مجاني)
                        _buildCheckboxTile(
                          context,
                          title: s.preAthanNotification,
                          value: settings.isPreAthanEnabled,
                          isPremium: isPremium,
                          isLocked: false,
                          onChanged: (value) {
                            if (value != null) {
                              context
                                  .read<NotificationSettingsCubit>()
                                  .togglePreAthanNotification(value);
                            }
                          },
                        ),

                        // 3. أذكار الصباح والمساء (مجاني)
                        _buildCheckboxTile(
                          context,
                          title: s.morningEveningAzkar,
                          value: settings.isAzkarSabahMasaEnabled,
                          isPremium: isPremium,
                          isLocked: false,
                          onChanged: (value) {
                            if (value != null) {
                              context
                                  .read<NotificationSettingsCubit>()
                                  .toggleAzkarSabahMasa(value);
                            }
                          },
                        ),

                        _buildCheckboxTile(
                          context,
                          title: s.suhoorAlarmTitle,
                          value: settings.isSuhoorAlarmEnabled,
                          isPremium: isPremium,
                          isLocked: false,
                          onChanged: (value) {
                            if (value != null) {
                              context
                                  .read<NotificationSettingsCubit>()
                                  .toggleSuhoorAlarm(value);
                            }
                          },
                        ),

                        _buildCheckboxTile(
                          context,
                          title: s.iftarAlarmTitle,
                          value: settings.isIftarAlarmEnabled,
                          isPremium: isPremium,
                          isLocked: false,
                          onChanged: (value) {
                            if (value != null) {
                              context
                                  .read<NotificationSettingsCubit>()
                                  .toggleIftarAlarm(value);
                            }
                          },
                        ),

                        // 4. وضع الخشوع (مجاني)
                        _buildCheckboxTile(
                          context,
                          title: s.khushooMode,
                          value: settings.isKhushooModeEnabled,
                          isPremium: isPremium,
                          isLocked: false,
                          onChanged: (value) {
                            if (value != null) {
                              context
                                  .read<NotificationSettingsCubit>()
                                  .toggleKhushooMode(value);
                            }
                          },
                        ),

                        // 5. إشعارات الختمة الجماعية (مدفوع)
                        _buildCheckboxTile(
                          context,
                          title: s.collectiveKhatmaNotifications,
                          value: settings.isCollectiveKhatmaEnabled,
                          isPremium: isPremium,
                          isLocked: !isPremium,
                          onChanged: (value) {
                            if (!isPremium) {
                              _showPremiumDialog(context);
                              return;
                            }
                            if (value != null) {
                              context
                                  .read<NotificationSettingsCubit>()
                                  .toggleCollectiveKhatma(value);
                            }
                          },
                        ),

                        // 6. ذكرني بالله (مدفوع مع خيارات التكرار)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCheckboxTile(
                              context,
                              title: s.remindMeOfAllah,
                              value: settings.isZikrAllahEnabled,
                              isPremium: isPremium,
                              isLocked: !isPremium,
                              onChanged: (value) {
                                if (!isPremium) {
                                  _showPremiumDialog(context);
                                  return;
                                }
                                if (value != null) {
                                  context
                                      .read<NotificationSettingsCubit>()
                                      .toggleZikrAllah(value);
                                }
                              },
                            ),
                            // خيارات الفترة الزمنية في سطر منفصل
                            if (settings.isZikrAllahEnabled && isPremium)
                              Padding(
                                padding: EdgeInsets.only(
                                  right: 32.w,
                                  bottom: 8.h,
                                ),
                                child: Wrap(
                                  spacing: 8.w,
                                  runSpacing: 8.h,
                                  children: [
                                    _buildIntervalChip(
                                      context,
                                      label: s.halfHour,
                                      minutes: 30,
                                      isSelected:
                                          settings.zikrIntervalMinutes == 30,
                                      onSelected: () {
                                        context
                                            .read<NotificationSettingsCubit>()
                                            .setZikrInterval(30);
                                      },
                                    ),
                                    _buildIntervalChip(
                                      context,
                                      label: s.hour,
                                      minutes: 60,
                                      isSelected:
                                          settings.zikrIntervalMinutes == 60,
                                      onSelected: () {
                                        context
                                            .read<NotificationSettingsCubit>()
                                            .setZikrInterval(60);
                                      },
                                    ),
                                    _buildIntervalChip(
                                      context,
                                      label: s.twoHours,
                                      minutes: 120,
                                      isSelected:
                                          settings.zikrIntervalMinutes == 120,
                                      onSelected: () {
                                        context
                                            .read<NotificationSettingsCubit>()
                                            .setZikrInterval(120);
                                      },
                                    ),
                                    _buildIntervalChip(
                                      context,
                                      label: s.fourHours,
                                      minutes: 240,
                                      isSelected:
                                          settings.zikrIntervalMinutes == 240,
                                      onSelected: () {
                                        context
                                            .read<NotificationSettingsCubit>()
                                            .setZikrInterval(240);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),

                        // 7. الأذكار الصوتية الذكية (مدفوع)
                        _buildCheckboxTile(
                          context,
                          title: s.smartVoiceDhikr,
                          value: settings.isSmartVoiceEnabled,
                          isPremium: isPremium,
                          isLocked: !isPremium,
                          onChanged: (value) {
                            if (!isPremium) {
                              _showPremiumDialog(context);
                              return;
                            }
                            if (value != null) {
                              if (value == true) {
                                () async {
                                  final isReady = await SmartDhikrService().isDhikrPackFullyDownloaded();
                                  if (!isReady) {
                                    // ignore: use_build_context_synchronously
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const AudioMainScreen(),
                                      ),
                                    );
                                    final isReadyAfter = await SmartDhikrService().isDhikrPackFullyDownloaded();
                                    if (!isReadyAfter) {
                                      // ignore: use_build_context_synchronously
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(s.downloadedAudio)),
                                      );
                                      return;
                                    }
                                  }
                                  // ignore: use_build_context_synchronously
                                  context
                                      .read<NotificationSettingsCubit>()
                                      .toggleSmartVoice(true);
                                }();
                              } else {
                                context
                                    .read<NotificationSettingsCubit>()
                                    .toggleSmartVoice(false);
                              }
                            }
                          },
                        ),
                        if (settings.isSmartVoiceEnabled && isPremium)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  right: 32.w,
                                  bottom: 8.h,
                                  left: 32.w,
                                ),
                                child: Text(
                                  s.smartVoiceDescription,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.grey,
                                    fontFamily: AppFonts.tajawal,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  right: 32.w,
                                  bottom: 8.h,
                                ),
                                child: Wrap(
                                  spacing: 8.w,
                                  runSpacing: 8.h,
                                  children: [
                                    _buildIntervalChip(
                                      context,
                                      label: s.halfHour,
                                      minutes: 30,
                                      isSelected:
                                          settings.smartVoiceIntervalMinutes ==
                                          30,
                                      onSelected: () {
                                        context
                                            .read<NotificationSettingsCubit>()
                                            .setSmartVoiceInterval(30);
                                      },
                                    ),
                                    _buildIntervalChip(
                                      context,
                                      label: s.hour,
                                      minutes: 60,
                                      isSelected:
                                          settings.smartVoiceIntervalMinutes ==
                                          60,
                                      onSelected: () {
                                        context
                                            .read<NotificationSettingsCubit>()
                                            .setSmartVoiceInterval(60);
                                      },
                                    ),
                                    _buildIntervalChip(
                                      context,
                                      label: s.twoHours,
                                      minutes: 120,
                                      isSelected:
                                          settings.smartVoiceIntervalMinutes ==
                                          120,
                                      onSelected: () {
                                        context
                                            .read<NotificationSettingsCubit>()
                                            .setSmartVoiceInterval(120);
                                      },
                                    ),
                                    _buildIntervalChip(
                                      context,
                                      label: s.fourHours,
                                      minutes: 240,
                                      isSelected:
                                          settings.smartVoiceIntervalMinutes ==
                                          240,
                                      onSelected: () {
                                        context
                                            .read<NotificationSettingsCubit>()
                                            .setSmartVoiceInterval(240);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                        SizedBox(height: 14.h),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile(
    BuildContext context, {
    required String title,
    required bool value,
    required bool isPremium,
    required bool isLocked,
    required ValueChanged<bool?> onChanged,
  }) {
    return SizedBox(
      height: 40.h,
      child: CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        title: Row(
          children: [
            Text(
              title,
              style: AppTextStyles.surahName.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                fontFamily: AppFonts.tajawal,
                color: isLocked
                    ? Colors.grey
                    : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            if (isLocked) ...[
              SizedBox(width: 8.w),
              Icon(Icons.lock, size: 14.sp, color: AppColors.goldenColor),
            ],
          ],
        ),
        value: value,
        activeColor: AppColors.goldenColor,
        onChanged: isLocked ? null : onChanged,
      ),
    );
  }

  Widget _buildIntervalChip(
    BuildContext context, {
    required String label,
    required int minutes,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontFamily: AppFonts.tajawal,
          color: isSelected ? Colors.white : AppColors.goldenColor,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.goldenColor,
      backgroundColor: Colors.white,
      side: BorderSide(color: AppColors.goldenColor),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      onSelected: (_) => onSelected(),
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
            Text(s.premiumFeature),
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
