import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:awesome_notifications/awesome_notifications.dart'
    hide NotificationHandler;
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:meshkat_elhoda/core/services/in_app_purchase_service.dart';
import 'package:meshkat_elhoda/core/network/network_info.dart';
import 'package:meshkat_elhoda/core/services/prayer_notification_service_new.dart';
import 'package:meshkat_elhoda/core/services/background_service.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/features/assistant/data/datasources/assistant_local_data_source.dart';
import 'package:meshkat_elhoda/features/assistant/data/datasources/assistant_remote_data_source.dart';
import 'package:meshkat_elhoda/features/assistant/data/repositories/assistant_repository_impl.dart';
import 'package:meshkat_elhoda/features/assistant/domain/usecases/create_new_chat.dart';
import 'package:meshkat_elhoda/features/assistant/domain/usecases/get_chat_history.dart';
import 'package:meshkat_elhoda/features/assistant/domain/usecases/get_chat_list.dart';
import 'package:meshkat_elhoda/features/assistant/domain/usecases/send_message.dart';
import 'package:meshkat_elhoda/features/assistant/presentation/bloc/assistant_bloc.dart';
import 'package:meshkat_elhoda/features/auth/domain/usecases/reset_password.dart';
import 'package:meshkat_elhoda/features/azkar/presentation/bloc/azkar_bloc.dart';
import 'package:meshkat_elhoda/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:meshkat_elhoda/features/hadith/presentation/bloc/hadith_bloc.dart';
import 'package:meshkat_elhoda/features/mosques/data/datasources/mosques_local_data_source.dart';
import 'package:meshkat_elhoda/features/mosques/data/datasources/mosques_remote_data_source.dart';
import 'package:meshkat_elhoda/features/mosques/data/repositories/mosque_repository_impl.dart';
import 'package:meshkat_elhoda/features/mosques/domain/usecases/get_nearby_mosques.dart';
import 'package:meshkat_elhoda/features/mosques/presentation/bloc/mosque_bloc.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_event.dart';
import 'package:meshkat_elhoda/features/subscription/presentation/bloc/subscription_state.dart';
import 'package:meshkat_elhoda/features/quran_audio/presentation/bloc/quran_audio_cubit.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/widgets/loading_widget.dart';
import 'package:meshkat_elhoda/features/settings/presentation/cubit/theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meshkat_elhoda/core/utils/app_preferences.dart';
import 'package:meshkat_elhoda/features/auth/presentation/bloc/auth_state.dart';
import 'package:meshkat_elhoda/features/main_navigation/presentation/views/main_navigation_views.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meshkat_elhoda/core/network/firebase_service.dart';
import 'package:meshkat_elhoda/core/services/service_locator.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/features/auth/data/data_sources/auth_remote_data_source_impl.dart';
import 'package:meshkat_elhoda/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:meshkat_elhoda/features/auth/domain/usecases/register_as_guest.dart';
import 'package:meshkat_elhoda/features/auth/domain/usecases/sign_in_with_email_and_password.dart';
import 'package:meshkat_elhoda/features/auth/domain/usecases/sign_up_with_email_and_password.dart';
import 'package:meshkat_elhoda/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:meshkat_elhoda/features/auth/presentation/bloc/auth_event.dart';
import 'package:meshkat_elhoda/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:meshkat_elhoda/firebase_options.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/bloc/quran_bloc.dart';
import 'package:meshkat_elhoda/features/location/data/data_sources/location_local_data_source.dart';
import 'package:meshkat_elhoda/features/location/data/data_sources/location_remote_data_source.dart';
import 'package:meshkat_elhoda/features/location/data/repositories/location_repository_impl.dart';
import 'package:meshkat_elhoda/features/location/domain/usecases/get_current_location.dart';
import 'package:meshkat_elhoda/features/location/domain/usecases/get_location_from_city_country.dart';
import 'package:meshkat_elhoda/features/location/domain/usecases/get_stored_location.dart';
import 'package:meshkat_elhoda/features/location/domain/usecases/request_location_permission.dart';
import 'package:meshkat_elhoda/features/location/domain/usecases/save_location.dart';
import 'package:meshkat_elhoda/features/location/presentation/bloc/location_bloc.dart';
import 'package:meshkat_elhoda/features/location/presentation/bloc/location_event.dart'; // تأكد من وجود هذا الاستيراد
import 'package:meshkat_elhoda/features/prayer_times/presentation/bloc/prayer_times_bloc.dart';
import 'package:meshkat_elhoda/core/services/admob_service.dart';
import 'package:meshkat_elhoda/core/services/location_refresh_service.dart';
import 'features/prayer_times/presentation/bloc/prayer_times_state.dart';
import 'package:audio_service/audio_service.dart';
import 'package:meshkat_elhoda/core/services/meshkat_audio_handler.dart';
import 'package:meshkat_elhoda/features/settings/data/models/notification_settings_model.dart';
import 'package:meshkat_elhoda/features/quran_khatmah/presentation/bloc/khatmah_bloc.dart';
import 'package:meshkat_elhoda/core/services/notification_handler.dart';
import 'package:meshkat_elhoda/core/services/collective_khatma_notification_service.dart';
import 'package:meshkat_elhoda/features/collective_khatma/presentation/bloc/collective_khatma_bloc.dart';
import 'package:meshkat_elhoda/core/services/athan_audio_service.dart';
import 'package:meshkat_elhoda/core/services/smart_dhikr_service.dart';
import 'package:meshkat_elhoda/features/hajj_umrah/presentation/bloc/hajj_umrah_cubit.dart';
import 'package:meshkat_elhoda/features/prayer_times/presentation/views/athan_overlay_screen.dart';

import 'package:meshkat_elhoda/features/auth/presentation/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AwesomeNotifications().setListeners(
    onActionReceivedMethod: NotificationHandler.onActionReceivedMethod,
    onNotificationCreatedMethod:
        NotificationHandler.onNotificationCreatedMethod,
    onNotificationDisplayedMethod:
        NotificationHandler.onNotificationDisplayedMethod,
    onDismissActionReceivedMethod:
        NotificationHandler.onDismissActionReceivedMethod,
  );

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await configureDependencies();
  } catch (e) {
    log('❌ Core Init Error: $e');
  }

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(MyApp(sharedPreferences: sharedPreferences));

  // Initialize non-critical services asynchronously after the app frame is drawn.
  _initNonCriticalServices();
}

Future<void> _initNonCriticalServices() async {
  try {
    try {
      await getIt<AdMobService>().initialize(useTestAds: false);
    } catch (e) {
      log('⚠️ AdMob Error: $e');
    }

    final audioHandler = await AudioService.init(
      builder: () => MeshkatAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.meshkatelhoda.pro.audio',
        androidNotificationChannelName: 'Meshkat Audio',
        androidNotificationOngoing: true,
        notificationColor: Color(0xFFD4AF37),
      ),
    );
    getIt.registerSingleton<AudioHandler>(audioHandler);

    await PrayerNotificationService().initialize();
    await NotificationHandler().initialize();

    // Initialize Background Service (Location & Smart Dhikr) - MUST BE FIRST for WorkManager
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        await BackgroundService().initialize();
        await BackgroundService().registerPeriodicTasks();
      }
    } catch (e) {
      log('⚠️ Background Service Init Error: $e');
    }

    await SmartDhikrService().initialize();

    try {
      await getIt<InAppPurchaseService>().initialize();
    } catch (e) {
      log('⚠️ IAP Error: $e');
    }
  } catch (e) {
    log('❌ Non-critical Init Error: $e');
  }
}

class MyApp extends StatefulWidget {
  final SharedPreferences sharedPreferences;
  const MyApp({super.key, required this.sharedPreferences});

  @override
  State<MyApp> createState() => _MyAppState();
  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  bool _hasPolicyChecksRun = false;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _locale = _getLocaleFromDevice();
    _schedulePrayerNotificationsIfLocationExists();
  }

  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  // ✅ إضافة ديالوج الإفصاح عن الموقع (حل مشكلة رفض جوجل)
  Future<void> _showLocationDisclosureDialog() async {
    final navContext = _navigatorKey.currentContext;
    if (navContext == null) return;

    // ✅ التحقق من حالة إذن الموقع أولاً - لو ممنوح مش هنعرض الديالوج
    final permissionStatus = await Permission.location.status;
    if (permissionStatus.isGranted) {
      log('📍 Location permission already granted, skipping disclosure dialog');
      return;
    }

    final isRTL = _locale?.languageCode == 'ar';

    showDialog(
      context: navContext,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          isRTL ? '📍 تحسين دقة مواقيت الصلاة' : '📍 Location Precision',
        ),
        content: Text(
          isRTL
              ? 'يحتاج تطبيق مشكاة الهدى للوصول إلى موقعك الجغرافي حتى عندما يكون مغلقاً، وذلك لضمان دقة مواقيت الصلاة وتنبيهات الأذان واتجاه القبلة بناءً على مكانك الحالي.'
              : 'Mishkat Al-Hoda needs background location access to ensure accurate prayer times, Athan notifications, and Qibla direction based on your current location even when the app is closed.',
        ),
        actions: [

          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // استدعاء حدث طلب الموقع في الـ Bloc
              _navigatorKey.currentContext?.read<LocationBloc>().add(
                RequestLocationPermissionEvent(),
              );
            },
            child: Text(isRTL ? 'متابعة' : 'Continue'),
          ),
        ],
      ),
    );
  }

  Future<void> _checkBatteryOptimization() async {
    try {
      final isBatteryOptimized = await AthanAudioService().isBatteryOptimized();
      final hasDeclinedBefore =
          widget.sharedPreferences.getBool('declined_battery_optimization') ??
          false;

      if (isBatteryOptimized && !hasDeclinedBefore && mounted) {
        _showBatteryOptimizationDialog();
      }
    } catch (e) {
      log('⚠️ Battery check error: $e');
    }
  }

  void _showBatteryOptimizationDialog() {
    final navContext = _navigatorKey.currentContext;
    if (navContext == null) return;
    final isRTL = _locale?.languageCode == 'ar';

    showDialog(
      context: navContext,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          isRTL ? '🔋 تحسين أداء الإشعارات' : '🔋 Optimize Performance',
        ),
        content: Text(
          isRTL
              ? 'لضمان عمل الأذان في موعده، يُنصح بإعفاء التطبيق من تحسين البطارية.'
              : 'To ensure timely Athan, please exempt the app from battery optimization.',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await widget.sharedPreferences.setBool(
                'declined_battery_optimization',
                true,
              );
              Navigator.pop(dialogContext);
            },
            child: Text(isRTL ? 'لاحقاً' : 'Later'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await AthanAudioService().requestBatteryOptimizationExemption();
            },
            child: Text(isRTL ? 'السماح' : 'Allow'),
          ),
        ],
      ),
    );
  }

  // باقي الدوال المساعدة (تحديد اللغة، جدولة الإشعارات...) تظل كما هي في كودك الأصلي
  Future<void> _schedulePrayerNotificationsIfLocationExists() async {
    final double? lat = widget.sharedPreferences.getDouble('latitude');
    final double? lng = widget.sharedPreferences.getDouble('longitude');
    if (lat != null && lng != null) {
      final settingsJson = widget.sharedPreferences.getString(
        'NOTIFICATION_SETTINGS',
      );
      final settings = settingsJson != null
          ? NotificationSettingsModel.fromJson(settingsJson)
          : const NotificationSettingsModel();
      await PrayerNotificationService().scheduleTodayPrayers(
        latitude: lat,
        longitude: lng,
        language: widget.sharedPreferences.getString('language') ?? 'ar',
        settings: settings,
      );
    }
  }

  Locale _getLocaleFromDevice() {
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    const supported = [
      'ar',
      'en',
      'fr',
      'id',
      'ur',
      'tr',
      'bn',
      'ms',
      'fa',
      'es',
      'de',
      'zh',
    ];
    return supported.contains(deviceLocale.languageCode)
        ? deviceLocale
        : const Locale('en');
  }

  bool _isRTLLanguage(String? code) => ['ar', 'ur', 'fa'].contains(code);

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MultiBlocProvider(
          providers: [
            // تظل جميع الـ Bloc Providers كما هي في كودك الأصلي تماماً
            BlocProvider<AuthBloc>(
              create: (context) {
                final authRepo = AuthRepositoryImpl(
                  remoteDataSource: AuthRemoteDataSourceImpl(
                    firebaseService: FirebaseService(
                      auth: FirebaseAuth.instance,
                      firestore: FirebaseFirestore.instance,
                      storage: FirebaseStorage.instance,
                    ),
                    locationRemoteDataSource: LocationRemoteDataSourceImpl(),
                  ),
                );
                return AuthBloc(
                  signInWithEmailAndPassword: SignInWithEmailAndPassword(
                    authRepo,
                  ),
                  signUpWithEmailAndPassword: SignUpWithEmailAndPassword(
                    authRepo,
                  ),
                  registerAsGuest: RegisterAsGuest(authRepo),
                  resetPassword: ResetPassword(authRepo),
                )..add(AuthCheckRequested());
              },
            ),
            BlocProvider<QuranBloc>(
              create: (context) => QuranBloc(
                getAllSurahs: getIt(),
                getSurahByNumber: getIt(),
                getJuzSurahs: getIt(),
                getAyahTafsir: getIt(),
                getReciters: getIt(),
                saveLastPosition: getIt(),
                getLastPosition: getIt(),
                getAudioUrl: getIt(),
              ),
            ),
            BlocProvider<LocationBloc>(
              create: (context) {
                final repo = LocationRepositoryImpl(
                  remoteDataSource: LocationRemoteDataSourceImpl(),
                  localDataSource: LocationLocalDataSourceImpl(
                    sharedPreferences: widget.sharedPreferences,
                  ),
                );
                return LocationBloc(
                  requestLocationPermission: RequestLocationPermission(repo),
                  getCurrentLocation: GetCurrentLocation(repo),
                  getLocationFromCityCountry: GetLocationFromCityCountry(repo),
                  getStoredLocation: GetStoredLocation(repo),
                  saveLocation: SaveLocation(repo),
                  locationRefreshService: LocationRefreshService(
                    widget.sharedPreferences,
                  ),
                );
              },
            ),
            BlocProvider<PrayerTimesBloc>(
              create: (context) => getIt<PrayerTimesBloc>(),
            ),
            BlocProvider<HadithBloc>(create: (context) => getIt<HadithBloc>()),
            BlocProvider<AzkarBloc>(create: (context) => getIt<AzkarBloc>()),
            BlocProvider<MosqueBloc>(
              create: (context) => MosqueBloc(
                getNearbyMosques: GetNearbyMosques(
                  MosqueRepositoryImpl(
                    remoteDataSource: MosquesRemoteDataSourceImpl(
                      client: http.Client(),
                    ),
                    localDataSource: MosquesLocalDataSourceImpl(
                      sharedPreferences: widget.sharedPreferences,
                    ),
                    networkInfo: getIt<NetworkInfo>(),
                  ),
                ),
              ),
            ),
            BlocProvider<AssistantBloc>(
              create: (context) => AssistantBloc(
                getChatHistory: GetChatHistory(
                  AssistantRepositoryImpl(
                    remoteDataSource: AssistantRemoteDataSourceImpl(
                      client: http.Client(),
                    ),
                    localDataSource: AssistantLocalDataSourceImpl(
                      sharedPreferences: widget.sharedPreferences,
                    ),
                    firestore: FirebaseFirestore.instance,
                    auth: FirebaseAuth.instance,
                  ),
                ),
                createNewChat: CreateNewChat(getIt()),
                getChatList: GetChatList(getIt()),
                sendMessage: SendMessage(getIt()),
                localDataSource: getIt(),
              ),
            ),
            BlocProvider<QuranAudioBloc>(
              create: (context) => getIt<QuranAudioBloc>(),
            ),
            BlocProvider<FavoritesBloc>(
              create: (context) => getIt<FavoritesBloc>(),
            ),
            BlocProvider<SubscriptionBloc>(
              create: (context) =>
                  getIt<SubscriptionBloc>()..add(LoadSubscriptionEvent()),
            ),
            BlocProvider<ThemeCubit>(
              create: (context) => getIt<ThemeCubit>()..loadTheme(),
            ),
            BlocProvider<CollectiveKhatmaBloc>(
              create: (context) => getIt<CollectiveKhatmaBloc>(),
            ),
            BlocProvider<KhatmahBloc>(
              create: (context) => getIt<KhatmahBloc>(),
            ),
            BlocProvider<HajjUmrahCubit>(
              create: (context) => getIt<HajjUmrahCubit>(),
            ),
          ],
          child: BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              final isRTL = _isRTLLanguage(_locale?.languageCode);
              return MaterialApp(
                navigatorKey: _navigatorKey,
                debugShowCheckedModeBanner: false,
                locale: _locale,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                routes: {'/athanOverlay': (_) => const AthanOverlayScreen()},
                builder: (context, child) {
                  // ✅ تشغيل فحوصات السياسات (الموقع والبطارية) بعد فتح التطبيق
                  if (!_hasPolicyChecksRun) {
                    _hasPolicyChecksRun = true;
                    Future.delayed(const Duration(seconds: 3), () {
                      if (mounted) {
                        _showLocationDisclosureDialog(); // أولاً إفصاح الموقع
                        _checkBatteryOptimization(); // ثانياً تحسين البطارية
                      }
                    });
                  }
                  return BlocListener<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is Authenticated || state is Unauthenticated) {
                        context.read<SubscriptionBloc>().add(
                          LoadSubscriptionEvent(),
                        );
                      }
                    },
                    child: Directionality(
                      textDirection: isRTL
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      child: Builder(
                        builder: (ctx) {
                          // Sync native Athan action labels with current app language.
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            final l10n = AppLocalizations.of(ctx);
                            if (l10n == null) return;
                            AthanAudioService().syncNativeAthanActionLabels(
                              stopLabel: l10n.stop,
                              hideLabel: l10n.hide,
                              stopHint: l10n.adhanStopHint,
                            );
                          });
                          return child!;
                        },
                      ),
                    ),
                  );
                },
                themeMode: themeMode,
                theme: ThemeData(
                  fontFamily: isRTL ? 'Tajawal' : 'Roboto',
                  useMaterial3: true,
                  colorSchemeSeed: AppColors.goldenColor,
                ),
                darkTheme: ThemeData(
                  brightness: Brightness.dark,
                  fontFamily: isRTL ? 'Tajawal' : 'Roboto',
                  useMaterial3: true,
                  scaffoldBackgroundColor: const Color(0xff0A2F45),
                ),
                home: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return FutureBuilder<bool>(
                      future: AppPreferences.isOnboardingCompleted(),
                      builder: (context, snapshot) {
                        if (state is Authenticated) {
                          return const MainNavigationViews();
                        } else if (state is Unauthenticated) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Scaffold(
                              body: Center(child: QuranLottieLoading()),
                            );
                          }
                          final isOnboardingCompleted = snapshot.data ?? false;
                          return isOnboardingCompleted
                              ? const LoginScreen()
                              : const OnboardingScreen();
                        }
                        // Default loading state (AuthInitial or AuthLoading)
                        return const Scaffold(
                          body: Center(child: QuranLottieLoading()),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
