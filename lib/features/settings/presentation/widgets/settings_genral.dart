import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meshkat_elhoda/core/utils/app_assets.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_fonts.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/pages/subscription_page.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:meshkat_elhoda/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:meshkat_elhoda/features/auth/presentation/bloc/auth_event.dart';
import 'package:meshkat_elhoda/features/auth/presentation/bloc/auth_state.dart';
import 'package:meshkat_elhoda/features/onboarding/presentation/screens/features_overview_screen.dart';
import 'package:meshkat_elhoda/features/settings/presentation/widgets/setting_item.dart';
import 'package:meshkat_elhoda/features/settings/presentation/widgets/settings_title.dart';
import 'package:meshkat_elhoda/main.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_state.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_event.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';

class SettingsGeneral extends StatefulWidget {
  const SettingsGeneral({super.key});

  @override
  State<SettingsGeneral> createState() => _SettingsGeneralState();
}

class _SettingsGeneralState extends State<SettingsGeneral> {
  // قائمة اللغات المدعومة
  static const Map<String, String> supportedLanguages = {
    'ar': 'العربية',
    'en': 'English',
    'fr': 'Français',
    'id': 'Bahasa Indonesia',
    'ur': 'اردو',
    'tr': 'Türkçe',
    'bn': 'বাংলা',
    'fa': 'فارسی',
    'es': 'Español',
    'de': 'Deutsch',
    'zh': '中文',
  };
  final GlobalKey<SettingTitleState> _titleKey = GlobalKey<SettingTitleState>();

  @override
  void initState() {
    super.initState();
    // تحميل بيانات الاشتراك
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionBloc>().add(LoadSubscriptionEvent());
    });
  }

  void _showLanguageDialog(BuildContext context, String currentLanguage) {
    final s = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          // ✅ الحصول على اللغة الحالية من AuthBloc مباشرة
          String selectedLanguage = currentLanguage;
          if (authState is Authenticated) {
            selectedLanguage = authState.user.language;
          }

          return BlocBuilder<SubscriptionBloc, SubscriptionState>(
            builder: (context, subscriptionState) {
              // التحقق من حالة الاشتراك
              final isPremium =
                  subscriptionState is SubscriptionLoaded &&
                  subscriptionState.subscription.isPremium;

              return AlertDialog(
                title: Text(s.chooseLanguage),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: supportedLanguages.length,
                    itemBuilder: (context, index) {
                      final languageCode = supportedLanguages.keys.elementAt(
                        index,
                      );
                      final languageName = supportedLanguages[languageCode]!;
                      final isSelected = languageCode == selectedLanguage;

                      return ListTile(
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                languageName,
                                style: TextStyle(
                                  fontFamily: AppFonts.tajawal,
                                ),
                              ),
                            ),
                          ],
                        ),
                        leading: Radio<String>(
                          value: languageCode,
                          groupValue: selectedLanguage,
                          onChanged: (value) {
                            if (value != null && value != selectedLanguage) {
                              Navigator.pop(dialogContext);
                              _changeLanguage(context, value);
                            }
                          },
                        ),
                        selected: isSelected,
                        onTap: () {
                          if (languageCode != selectedLanguage) {
                            Navigator.pop(dialogContext);
                            _changeLanguage(context, languageCode);
                          }
                        },
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
              style: TextStyle(fontSize: 16.sp, fontFamily: AppFonts.tajawal),
            ),
          ],
        ),
        content: Text(
          s.premiumFeatureDescription,
          style: TextStyle(fontSize: 14.sp, fontFamily: AppFonts.tajawal),
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

  void _changeLanguage(BuildContext context, String newLanguage) async {
    final s = AppLocalizations.of(context)!;

    // حفظ reference للـ BuildContext والـ MyApp state قبل إغلاق الـ dialog
    final navigatorContext = Navigator.of(context).context;
    final myAppState = MyApp.of(context);
    final authBloc = context.read<AuthBloc>();

    // عرض مؤشر التحميل
    showDialog(
      context: navigatorContext,
      barrierDismissible: false,
      builder: (loadingContext) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(loadingContext).brightness == Brightness.dark
                  ? const Color(0xFF153A52)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.goldenColor,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  s.updatingLanguage,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color:
                        Theme.of(loadingContext).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // تحديث اللغة في Firebase
      authBloc.add(UpdateLanguageRequested(newLanguage));

      // انتظار حتى يتم تحديث حالة AuthBloc
      await Future.delayed(const Duration(milliseconds: 1200));

      // تحديث اللغة في التطبيق
      myAppState?.setLocale(Locale(newLanguage));

      // إغلاق مؤشر التحميل
      if (navigatorContext.mounted) {
        Navigator.of(navigatorContext).pop();
      }

      // ✅ إعادة تحميل التاب كاملة لتطبيق تغيير اللغة
      await Future.delayed(const Duration(milliseconds: 100));
      if (navigatorContext.mounted) {
        Navigator.of(navigatorContext).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      // في حالة حدوث خطأ، إغلاق مؤشر التحميل وعرض رسالة خطأ
      if (navigatorContext.mounted) {
        Navigator.of(navigatorContext).pop();
        ScaffoldMessenger.of(navigatorContext).showSnackBar(
          SnackBar(
            content: Text(
              s.languageUpdateError(e.toString()),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String currentLanguage = 'ar'; // القيمة الافتراضية

        if (state is Authenticated) {
          currentLanguage = state.user.language;
        }

        return Column(
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
                  title: s.generalTitle,
                  iconPath: AppAssets.settings,
                ),
                children: [
                  SettingItem(
                    iconData: Icons.language,
                    title: s.language,
                    subtitle: supportedLanguages[currentLanguage] ?? s.arabic,
                    onTap: () => _showLanguageDialog(context, currentLanguage),
                  ),
                  SettingItem(
                    iconData: Icons.star_border_outlined,
                    title: s.rateApp,
                    onTap: () async {
                      final url = Uri.parse(
                        'https://play.google.com/store/apps/details?id=com.meshkatelhoda.pro',
                      );
                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                  ),
                  SettingItem(
                    iconData: Icons.info_outline,
                    title: s.aboutApp,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FeaturesOverviewScreen(),
                        ),
                      );
                    },
                  ),
                  SettingItem(
                    iconData: Icons.lock_outline,
                    title: s.privacyPolicy,
                    onTap: () async {
                      final url = Uri.parse(
                        'https://waleedd2369.github.io/Waleedd2369/',
                      );
                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
          ],
        );
      },
    );
  }
}
