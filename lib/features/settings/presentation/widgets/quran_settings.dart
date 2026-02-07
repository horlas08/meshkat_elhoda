import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/utils/app_assets.dart';
import 'package:meshkat_elhoda/features/settings/presentation/widgets/setting_item.dart';
import 'package:meshkat_elhoda/features/settings/presentation/widgets/settings_title.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/bloc/quran_settings_cubit.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/bloc/quran_settings_state.dart';
import 'package:meshkat_elhoda/features/quran_index/domain/entities/quran_edition_entity.dart';
import 'package:meshkat_elhoda/core/services/service_locator.dart';
import 'package:meshkat_elhoda/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:meshkat_elhoda/features/auth/presentation/bloc/auth_state.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_state.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/pages/subscription_page.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';

// Free tafsirs per language
const Map<String, String> freeTafsirs = {
  'ar': 'ar.muyassar', // التفسير الميسر
  'en': 'en.asad', // Muhammad Asad - most popular
  'fr': 'fr.hamidullah',
  'id': 'id.indonesian',
  'ur': 'ur.ahmedali',
  'tr': 'tr.yazir',
  'bn': 'bn.bengali',
  'ms': 'ms.malay',
  'fa': 'fa.makarem',
  'es': 'es.cortes',
  'de': 'de.bubenheim',
  'zh': 'zh.majian',
};

// Free reciters per language
const Map<String, String> freeReciters = {
  'ar': 'ar.alafasy', // مشاري العفاسي - الأشهر
  'en': 'en.walk',
  'fr': 'ar.alafasy',
  'id': 'ar.alafasy',
  'ur': 'ar.alafasy',
  'tr': 'ar.alafasy',
  'bn': 'ar.alafasy',
  'ms': 'ar.alafasy',
  'fa': 'ar.alafasy',
  'es': 'ar.alafasy',
  'de': 'ar.alafasy',
  'zh': 'ar.alafasy',
};

class QuranSettings extends StatefulWidget {
  const QuranSettings({super.key});

  @override
  State<QuranSettings> createState() => _QuranSettingsState();
}

class _QuranSettingsState extends State<QuranSettings> {
  late QuranSettingsCubit _cubit;
  bool _isInitialized = false;
  String _currentLanguage = 'ar';
  final GlobalKey<SettingTitleState> _titleKey = GlobalKey<SettingTitleState>();

  @override
  void initState() {
    super.initState();
    _cubit = getIt<QuranSettingsCubit>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _loadSettings();
      _isInitialized = true;
    }
  }

  void _loadSettings() {
    final authState = context.read<AuthBloc>().state;
    String language = 'ar';
    if (authState is Authenticated) {
      language = authState.user.language;
    }
    _currentLanguage = language;
    _cubit.loadSettings(language);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) {
          // Reload settings when language changes
          if (authState is Authenticated) {
            if (authState.user.language != _currentLanguage) {
              _currentLanguage = authState.user.language;
              _cubit.loadSettings(_currentLanguage);
              // ✅ إجبار إعادة بناء الواجهة فوراً
              if (mounted) {
                setState(() {});
              }
            }
          }
        },
        child: Column(
          children: [
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                showTrailingIcon: false,
                onExpansionChanged: (expanded) {
                  _titleKey.currentState?.setExpanded(expanded);
                },
                title: SettingTitle(
                  key: _titleKey,
                  title: s.quranSettingsTitle,
                  iconPath: AppAssets.quran,
                ),
                children: [
                  BlocBuilder<QuranSettingsCubit, QuranSettingsState>(
                    builder: (context, state) {
                      if (state is QuranSettingsLoading) {
                        return const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(strokeWidth: 3),
                            ),
                          ),
                        );
                      } else if (state is QuranSettingsLoaded) {
                        // Find selected tafsir safely
                        QuranEditionEntity? foundTafsir;
                        try {
                          foundTafsir = state.availableTafsirs.firstWhere(
                            (e) => e.identifier == state.selectedTafsirId,
                          );
                        } catch (e) {
                          foundTafsir = state.availableTafsirs.isNotEmpty
                              ? state.availableTafsirs.first
                              : null;
                        }

                        // Find selected reciter safely
                        QuranEditionEntity? foundReciter;
                        try {
                          foundReciter = state.availableReciters.firstWhere(
                            (e) => e.identifier == state.selectedReciterId,
                          );
                        } catch (e) {
                          foundReciter = state.availableReciters.isNotEmpty
                              ? state.availableReciters.first
                              : null;
                        }

                        final selectedTafsir =
                            foundTafsir ??
                            QuranEditionEntity(
                              identifier: '',
                              language: '',
                              name: s.notAvailable,
                              englishName: s.notAvailableEnglish,
                              format: '',
                              type: '',
                            );

                        final selectedReciter =
                            foundReciter ??
                            QuranEditionEntity(
                              identifier: '',
                              language: '',
                              name: s.notAvailable,
                              englishName: s.notAvailableEnglish,
                              format: '',
                              type: '',
                            );

                        return Column(
                          children: [
                            SettingItem(
                              iconData: Icons.menu_book,
                              title: s.favoriteTafsir,
                              subtitle: selectedTafsir.name,
                              onTap: () => _showSelectionDialog(
                                context,
                                s.chooseTafsir,
                                state.availableTafsirs,
                                state.selectedTafsirId,
                                (id) => _cubit.changeTafsir(id),
                                freeTafsirs[_currentLanguage] ?? '',
                              ),
                            ),
                            SettingItem(
                              iconData: Icons.mic,
                              title: s.favoriteReciter,
                              subtitle: selectedReciter.name,
                              onTap: () => _showSelectionDialog(
                                context,
                                s.chooseReciter,
                                state.availableReciters,
                                state.selectedReciterId,
                                (id) => _cubit.changeReciter(id),
                                freeReciters[_currentLanguage] ?? '',
                              ),
                            ),
                          ],
                        );
                      } else if (state is QuranSettingsError) {
                        final s = AppLocalizations.of(context)!;
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 48,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                s.settingsLoadError,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                state.message,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: _loadSettings,
                                icon: const Icon(Icons.refresh),
                                label: Text(s.retry),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }

  void _showSelectionDialog(
    BuildContext context,
    String title,
    List<dynamic> items,
    String selectedId,
    Function(String) onSelect,
    String freeItemId,
  ) {
    final s = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) =>
          BlocBuilder<SubscriptionBloc, SubscriptionState>(
            builder: (context, subscriptionState) {
              final isPremium =
                  subscriptionState is SubscriptionLoaded &&
                  subscriptionState.subscription.isPremium;

              return AlertDialog(
                title: Text(title),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = item.identifier == selectedId;
                      final isFree = item.identifier == freeItemId;
                      final isLocked = !isPremium && !isFree;

                      return GestureDetector(
                        onTap: isLocked
                            ? () {
                                Navigator.pop(dialogContext);
                                _showPremiumDialog(context);
                              }
                            : null,
                        child: RadioListTile<String>(
                          title: Row(
                            children: [
                              Expanded(child: Text(item.name)),
                              if (isLocked)
                                Icon(
                                  Icons.lock,
                                  color: AppColors.goldenColor,
                                  size: 20.sp,
                                ),
                            ],
                          ),
                          subtitle: Text(item.englishName),
                          value: item.identifier,
                          groupValue: selectedId,
                          selected: isSelected,
                          onChanged: isLocked
                              ? null
                              : (value) {
                                  if (value != null) {
                                    onSelect(value);
                                    Navigator.pop(dialogContext);
                                  }
                                },
                        ),
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(s.cancel),
                  ),
                ],
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
        backgroundColor: AppColors.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.star, color: AppColors.goldenColor),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                s.premiumFeature,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.blacColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          s.premiumFeatureDescription,
          style: TextStyle(fontSize: 14.sp, color: AppColors.blacColor),
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
