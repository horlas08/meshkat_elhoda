import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_ur.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bn'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fa'),
    Locale('fr'),
    Locale('id'),
    Locale('ms'),
    Locale('tr'),
    Locale('ur'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Mishkat Al-Hoda Pro'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @onboardingDescription1.
  ///
  /// In en, this message translates to:
  /// **'Start your spiritual journey with an app that brings together the Quran, Athkar, and Hadith in one place.'**
  String get onboardingDescription1;

  /// No description provided for @onboardingDescription2.
  ///
  /// In en, this message translates to:
  /// **'Listen to recitations from over 50 reciters, and easily save your last reading position.'**
  String get onboardingDescription2;

  /// No description provided for @onboardingDescription3.
  ///
  /// In en, this message translates to:
  /// **'Reminds you of Allah at every moment with daily Athkar and categorized supplications for your life.'**
  String get onboardingDescription3;

  /// No description provided for @onboardingDescription4.
  ///
  /// In en, this message translates to:
  /// **'Experience the spiritual atmosphere directly from Mecca and Medina, anytime and anywhere.'**
  String get onboardingDescription4;

  /// No description provided for @allAzkar.
  ///
  /// In en, this message translates to:
  /// **'All Azkar'**
  String get allAzkar;

  /// No description provided for @errorLoadingAzkar.
  ///
  /// In en, this message translates to:
  /// **'Error loading Azkar'**
  String get errorLoadingAzkar;

  /// No description provided for @azkarAndDuas.
  ///
  /// In en, this message translates to:
  /// **'Azkar & Duas'**
  String get azkarAndDuas;

  /// No description provided for @startYourAzkar.
  ///
  /// In en, this message translates to:
  /// **'Start your Azkar now'**
  String get startYourAzkar;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See more'**
  String get seeMore;

  /// No description provided for @favoriteAzkarToast.
  ///
  /// In en, this message translates to:
  /// **'To praise your favorite Azkar'**
  String get favoriteAzkarToast;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @favoriteAzkar.
  ///
  /// In en, this message translates to:
  /// **'Favorite Azkar'**
  String get favoriteAzkar;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// No description provided for @audioError.
  ///
  /// In en, this message translates to:
  /// **'Error playing audio'**
  String get audioError;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @ayahOptionShare.
  ///
  /// In en, this message translates to:
  /// **''**
  String get ayahOptionShare;

  /// No description provided for @ayahOptionLanguage.
  ///
  /// In en, this message translates to:
  /// **''**
  String get ayahOptionLanguage;

  /// No description provided for @smartMisbah.
  ///
  /// In en, this message translates to:
  /// **'Smart Misbah'**
  String get smartMisbah;

  /// No description provided for @startTasbeh.
  ///
  /// In en, this message translates to:
  /// **'Start Tasbeh'**
  String get startTasbeh;

  /// No description provided for @locationPermissionDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get locationPermissionDeniedTitle;

  /// No description provided for @locationPermissionDescription.
  ///
  /// In en, this message translates to:
  /// **'To show accurate prayer times, we need your location. You can:'**
  String get locationPermissionDescription;

  /// No description provided for @locationPermissionOptionAllow.
  ///
  /// In en, this message translates to:
  /// **'• Allow location access'**
  String get locationPermissionOptionAllow;

  /// No description provided for @locationPermissionOptionManual.
  ///
  /// In en, this message translates to:
  /// **'• Enter city and country manually'**
  String get locationPermissionOptionManual;

  /// No description provided for @locationPermissionManualButton.
  ///
  /// In en, this message translates to:
  /// **'Enter manually'**
  String get locationPermissionManualButton;

  /// No description provided for @locationPermissionAllowButton.
  ///
  /// In en, this message translates to:
  /// **'Allow location'**
  String get locationPermissionAllowButton;

  /// No description provided for @manualLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your location manually'**
  String get manualLocationTitle;

  /// No description provided for @manualLocationCityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get manualLocationCityLabel;

  /// No description provided for @manualLocationCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get manualLocationCountryLabel;

  /// No description provided for @manualLocationCityError.
  ///
  /// In en, this message translates to:
  /// **'Please enter the city'**
  String get manualLocationCityError;

  /// No description provided for @manualLocationCountryError.
  ///
  /// In en, this message translates to:
  /// **'Please enter the country'**
  String get manualLocationCountryError;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @manualLocationConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get manualLocationConfirmButton;

  /// No description provided for @readingModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading Mode'**
  String get readingModeTitle;

  /// No description provided for @readingModeVerticalTitle.
  ///
  /// In en, this message translates to:
  /// **'Vertical Scrolling'**
  String get readingModeVerticalTitle;

  /// No description provided for @readingModeVerticalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scroll up and down'**
  String get readingModeVerticalSubtitle;

  /// No description provided for @readingModeHorizontalTitle.
  ///
  /// In en, this message translates to:
  /// **'Page Flipping'**
  String get readingModeHorizontalTitle;

  /// No description provided for @readingModeHorizontalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Flip right and left'**
  String get readingModeHorizontalSubtitle;

  /// No description provided for @ayah.
  ///
  /// In en, this message translates to:
  /// **'Ayah'**
  String get ayah;

  /// No description provided for @ayahOptionAddBookmark.
  ///
  /// In en, this message translates to:
  /// **'Add Bookmark'**
  String get ayahOptionAddBookmark;

  /// No description provided for @ayahOptionPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get ayahOptionPlay;

  /// No description provided for @ayahOptionTafsir.
  ///
  /// In en, this message translates to:
  /// **'Tafsir'**
  String get ayahOptionTafsir;

  /// No description provided for @ayahOptionDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get ayahOptionDownload;

  /// No description provided for @bookmarkAddedMessage.
  ///
  /// In en, this message translates to:
  /// **'Bookmark added successfully'**
  String get bookmarkAddedMessage;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @page.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get page;

  /// No description provided for @juzSurahsTitle.
  ///
  /// In en, this message translates to:
  /// **'Juz Surahs'**
  String get juzSurahsTitle;

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorMessage;

  /// No description provided for @noSurahsInJuz.
  ///
  /// In en, this message translates to:
  /// **'No Surahs in this Juz'**
  String get noSurahsInJuz;

  /// No description provided for @bookmarkDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Bookmark deleted'**
  String get bookmarkDeletedMessage;

  /// No description provided for @noBookmarks.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks'**
  String get noBookmarks;

  /// No description provided for @addBookmarkHint.
  ///
  /// In en, this message translates to:
  /// **'Add a bookmark from the reading page'**
  String get addBookmarkHint;

  /// No description provided for @deleteBookmarkTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Bookmark'**
  String get deleteBookmarkTitle;

  /// No description provided for @deleteBookmarkContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this bookmark?'**
  String get deleteBookmarkContent;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @searchInSurahNames.
  ///
  /// In en, this message translates to:
  /// **'Search in Surah names'**
  String get searchInSurahNames;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// No description provided for @ayahLabel.
  ///
  /// In en, this message translates to:
  /// **'Ayah'**
  String get ayahLabel;

  /// No description provided for @surahLabel.
  ///
  /// In en, this message translates to:
  /// **'Surah'**
  String get surahLabel;

  /// No description provided for @audioLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading audio'**
  String get audioLoadError;

  /// No description provided for @audioLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading audio...'**
  String get audioLoading;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @hide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hide;

  /// No description provided for @adhanStopHint.
  ///
  /// In en, this message translates to:
  /// **'Tap here to stop the Adhan'**
  String get adhanStopHint;

  /// No description provided for @adhanTroubleshootNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Adhan not working?'**
  String get adhanTroubleshootNoticeTitle;

  /// No description provided for @adhanTroubleshootNoticeBody.
  ///
  /// In en, this message translates to:
  /// **'Tap here to fix device settings so Adhan works on time.'**
  String get adhanTroubleshootNoticeBody;

  /// No description provided for @adhanTroubleshootTitle.
  ///
  /// In en, this message translates to:
  /// **'Adhan alarm is not working?'**
  String get adhanTroubleshootTitle;

  /// No description provided for @adhanTroubleshootAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s this about?'**
  String get adhanTroubleshootAboutTitle;

  /// No description provided for @adhanTroubleshootAboutBody.
  ///
  /// In en, this message translates to:
  /// **'Some device settings can stop Adhan from working on time. Follow the tips below to keep your alarms reliable.'**
  String get adhanTroubleshootAboutBody;

  /// No description provided for @adhanTroubleshootAboutDeviceTitle.
  ///
  /// In en, this message translates to:
  /// **'About this device'**
  String get adhanTroubleshootAboutDeviceTitle;

  /// No description provided for @adhanTroubleshootAboutDeviceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please review the following settings on this device.'**
  String get adhanTroubleshootAboutDeviceSubtitle;

  /// No description provided for @adhanTroubleshootFixNow.
  ///
  /// In en, this message translates to:
  /// **'Fix now'**
  String get adhanTroubleshootFixNow;

  /// No description provided for @adhanTroubleshootCheckIt.
  ///
  /// In en, this message translates to:
  /// **'Check it'**
  String get adhanTroubleshootCheckIt;

  /// No description provided for @adhanTroubleshootAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get adhanTroubleshootAllow;

  /// No description provided for @adhanTroubleshootDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get adhanTroubleshootDone;

  /// No description provided for @adhanTroubleshootBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get adhanTroubleshootBack;

  /// No description provided for @adhanTroubleshootNote.
  ///
  /// In en, this message translates to:
  /// **'Note: If Adhan still does not work, re-check these settings again.'**
  String get adhanTroubleshootNote;

  /// No description provided for @adhanTroubleshootBackConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get adhanTroubleshootBackConfirmTitle;

  /// No description provided for @adhanTroubleshootBackConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Please check all settings carefully, otherwise Adhan may still not work. Do you want to go back now?'**
  String get adhanTroubleshootBackConfirmBody;

  /// No description provided for @adhanTroubleshootBackConfirmStay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get adhanTroubleshootBackConfirmStay;

  /// No description provided for @adhanTroubleshootBackConfirmGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get adhanTroubleshootBackConfirmGoBack;

  /// No description provided for @adhanTroubleshootFixOverlayTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow alarm pop-up / display over apps'**
  String get adhanTroubleshootFixOverlayTitle;

  /// No description provided for @adhanTroubleshootFixOverlayDesc.
  ///
  /// In en, this message translates to:
  /// **'Allow the app to show a pop-up when Adhan starts so you can stop or hide it easily.'**
  String get adhanTroubleshootFixOverlayDesc;

  /// No description provided for @adhanTroubleshootFixExactAlarmTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow exact alarms (Alarms & reminders)'**
  String get adhanTroubleshootFixExactAlarmTitle;

  /// No description provided for @adhanTroubleshootFixExactAlarmDesc.
  ///
  /// In en, this message translates to:
  /// **'Enable exact alarms for this app so prayer times, Suhoor, and Iftar reminders trigger on time even if the app is closed.'**
  String get adhanTroubleshootFixExactAlarmDesc;

  /// No description provided for @adhanTroubleshootFixAutostartTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-start'**
  String get adhanTroubleshootFixAutostartTitle;

  /// No description provided for @adhanTroubleshootFixAutostartDesc.
  ///
  /// In en, this message translates to:
  /// **'Enable auto-start for the app so Adhan works even when the app is closed.'**
  String get adhanTroubleshootFixAutostartDesc;

  /// No description provided for @adhanTroubleshootFixScreenOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Screen-off settings'**
  String get adhanTroubleshootFixScreenOffTitle;

  /// No description provided for @adhanTroubleshootFixScreenOffDesc.
  ///
  /// In en, this message translates to:
  /// **'Turn off any screen-off options that block notifications (sleep / push block / scheduled push).'**
  String get adhanTroubleshootFixScreenOffDesc;

  /// No description provided for @adhanTroubleshootFixBatterySaverTitle.
  ///
  /// In en, this message translates to:
  /// **'Battery Saver'**
  String get adhanTroubleshootFixBatterySaverTitle;

  /// No description provided for @adhanTroubleshootFixBatterySaverDesc.
  ///
  /// In en, this message translates to:
  /// **'Battery Saver may kill the app. Try turning it off during prayer times.'**
  String get adhanTroubleshootFixBatterySaverDesc;

  /// No description provided for @adhanTroubleshootFixBatteryOptimizationTitle.
  ///
  /// In en, this message translates to:
  /// **'Ignore battery optimization'**
  String get adhanTroubleshootFixBatteryOptimizationTitle;

  /// No description provided for @adhanTroubleshootFixBatteryOptimizationDesc.
  ///
  /// In en, this message translates to:
  /// **'Allow the app to ignore battery optimizations so it can run in the background.'**
  String get adhanTroubleshootFixBatteryOptimizationDesc;

  /// No description provided for @adhanTroubleshootFixNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get adhanTroubleshootFixNotificationsTitle;

  /// No description provided for @adhanTroubleshootFixNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Make sure notifications are allowed for this app.'**
  String get adhanTroubleshootFixNotificationsDesc;

  /// No description provided for @adhanTroubleshootFixAthanChannelTitle.
  ///
  /// In en, this message translates to:
  /// **'Athan channel: enable pop on screen'**
  String get adhanTroubleshootFixAthanChannelTitle;

  /// No description provided for @adhanTroubleshootFixAthanChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'Open the Athan notification channel and set it to High/Max importance and enable full-screen / pop on screen if available.'**
  String get adhanTroubleshootFixAthanChannelDesc;

  /// No description provided for @surahArrangementLabel.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get surahArrangementLabel;

  /// No description provided for @surahAyahsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Ayahs Count'**
  String get surahAyahsCountLabel;

  /// No description provided for @quranIndex.
  ///
  /// In en, this message translates to:
  /// **'Index'**
  String get quranIndex;

  /// No description provided for @quranParts.
  ///
  /// In en, this message translates to:
  /// **'Parts'**
  String get quranParts;

  /// No description provided for @quranBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get quranBookmarks;

  /// No description provided for @tafsirLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Loading Tafsir...'**
  String get tafsirLoadingMessage;

  /// No description provided for @tafsirOfAyah.
  ///
  /// In en, this message translates to:
  /// **'Tafsir of Ayah'**
  String get tafsirOfAyah;

  /// No description provided for @tafsirNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Tafsir Name'**
  String get tafsirNameLabel;

  /// No description provided for @tafsirErrorLog.
  ///
  /// In en, this message translates to:
  /// **'Error loading Tafsir'**
  String get tafsirErrorLog;

  /// No description provided for @part.
  ///
  /// In en, this message translates to:
  /// **'Part'**
  String get part;

  /// No description provided for @smart_assistant.
  ///
  /// In en, this message translates to:
  /// **'Smart Assistant'**
  String get smart_assistant;

  /// No description provided for @quran.
  ///
  /// In en, this message translates to:
  /// **'Holy Quran'**
  String get quran;

  /// No description provided for @current_khatma.
  ///
  /// In en, this message translates to:
  /// **'Your Current Khatma'**
  String get current_khatma;

  /// No description provided for @khatmat.
  ///
  /// In en, this message translates to:
  /// **'Khatmas'**
  String get khatmat;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @start_your_journey.
  ///
  /// In en, this message translates to:
  /// **'Start your journey with the Quran'**
  String get start_your_journey;

  /// No description provided for @mushaf.
  ///
  /// In en, this message translates to:
  /// **'Mushaf'**
  String get mushaf;

  /// No description provided for @new_khatma.
  ///
  /// In en, this message translates to:
  /// **'New Khatma'**
  String get new_khatma;

  /// No description provided for @haram_and_live.
  ///
  /// In en, this message translates to:
  /// **'Haram & Live Broadcast'**
  String get haram_and_live;

  /// No description provided for @choose_channel.
  ///
  /// In en, this message translates to:
  /// **'Choose the channel you want to watch now'**
  String get choose_channel;

  /// No description provided for @mecca.
  ///
  /// In en, this message translates to:
  /// **'Mecca'**
  String get mecca;

  /// No description provided for @saudi_channel.
  ///
  /// In en, this message translates to:
  /// **'Saudi Channel'**
  String get saudi_channel;

  /// No description provided for @licensed_broadcast.
  ///
  /// In en, this message translates to:
  /// **'This broadcast is licensed from official Saudi channels'**
  String get licensed_broadcast;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online now'**
  String get online;

  /// No description provided for @watch.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get watch;

  /// No description provided for @madina.
  ///
  /// In en, this message translates to:
  /// **'Al-Madina'**
  String get madina;

  /// No description provided for @madina_channel.
  ///
  /// In en, this message translates to:
  /// **'Madina Channel'**
  String get madina_channel;

  /// No description provided for @set_qibla.
  ///
  /// In en, this message translates to:
  /// **'Set Qibla Direction'**
  String get set_qibla;

  /// No description provided for @after.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get after;

  /// No description provided for @fajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get fajr;

  /// No description provided for @sunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunrise;

  /// No description provided for @duhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get duhr;

  /// No description provided for @asr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get asr;

  /// No description provided for @maghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get maghrib;

  /// No description provided for @isha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get isha;

  /// No description provided for @ramadanKarim.
  ///
  /// In en, this message translates to:
  /// **'Ramadan Mubarak'**
  String get ramadanKarim;

  /// No description provided for @todayDuaaHeader.
  ///
  /// In en, this message translates to:
  /// **'Today Duaa'**
  String get todayDuaaHeader;

  /// No description provided for @greetYourLovedOnes.
  ///
  /// In en, this message translates to:
  /// **'Greet your loved ones'**
  String get greetYourLovedOnes;

  /// No description provided for @quranKarem.
  ///
  /// In en, this message translates to:
  /// **'Quran Kareem'**
  String get quranKarem;

  /// No description provided for @ramadanKarimGreeting.
  ///
  /// In en, this message translates to:
  /// **'Ramadan Mubarak Greeting'**
  String get ramadanKarimGreeting;

  /// No description provided for @ramadanWirdCalculatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Ramadan Wird Calculator'**
  String get ramadanWirdCalculatorTitle;

  /// No description provided for @khatmaCountHint.
  ///
  /// In en, this message translates to:
  /// **'Khatma Count Hint'**
  String get khatmaCountHint;

  /// No description provided for @khatmaCountExceededMessage.
  ///
  /// In en, this message translates to:
  /// **'Khatma Count Exceeded Message'**
  String get khatmaCountExceededMessage;

  /// No description provided for @dailyWirdHeader.
  ///
  /// In en, this message translates to:
  /// **'Daily Wird Header'**
  String get dailyWirdHeader;

  /// No description provided for @dailyAjzaaLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily Ajzaa Label'**
  String get dailyAjzaaLabel;

  /// No description provided for @dailyPagesLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily Pages Label'**
  String get dailyPagesLabel;

  /// No description provided for @goToMushafButton.
  ///
  /// In en, this message translates to:
  /// **'Go To Mushaf Button'**
  String get goToMushafButton;

  /// No description provided for @worshipSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Worship Section'**
  String get worshipSectionTitle;

  /// No description provided for @prayerGuideSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer Guide'**
  String get prayerGuideSectionTitle;

  /// No description provided for @islamicServicesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Islamic Services'**
  String get islamicServicesSectionTitle;

  /// No description provided for @hadiths.
  ///
  /// In en, this message translates to:
  /// **'Hadiths'**
  String get hadiths;

  /// No description provided for @allahNames.
  ///
  /// In en, this message translates to:
  /// **'Names of Allah'**
  String get allahNames;

  /// No description provided for @ramadanFeatures.
  ///
  /// In en, this message translates to:
  /// **'Ramadan Features'**
  String get ramadanFeatures;

  /// No description provided for @prayerAndQibla.
  ///
  /// In en, this message translates to:
  /// **'Prayer & Qibla'**
  String get prayerAndQibla;

  /// No description provided for @locationAndMosques.
  ///
  /// In en, this message translates to:
  /// **'Location & Mosques'**
  String get locationAndMosques;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @zakatCalculator.
  ///
  /// In en, this message translates to:
  /// **'Zakat Calculator'**
  String get zakatCalculator;

  /// No description provided for @dateConverter.
  ///
  /// In en, this message translates to:
  /// **'Date Converter'**
  String get dateConverter;

  /// No description provided for @chatList.
  ///
  /// In en, this message translates to:
  /// **'Chat List'**
  String get chatList;

  /// No description provided for @classLabel.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get classLabel;

  /// No description provided for @class_.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get class_;

  /// No description provided for @premiumBookMessage.
  ///
  /// In en, this message translates to:
  /// **'This book is available for premium subscribers only.'**
  String get premiumBookMessage;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @selectBook.
  ///
  /// In en, this message translates to:
  /// **'Select Book'**
  String get selectBook;

  /// No description provided for @noHadithsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No hadiths available.'**
  String get noHadithsAvailable;

  /// No description provided for @by.
  ///
  /// In en, this message translates to:
  /// **'By'**
  String get by;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get searchResults;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get off;

  /// Auto-generated description for hadithLoadError
  ///
  /// In en, this message translates to:
  /// **'Failed to load hadith: {error}'**
  String hadithLoadError(String error);

  /// No description provided for @hadithCopied.
  ///
  /// In en, this message translates to:
  /// **'Hadith copied to clipboard'**
  String get hadithCopied;

  /// No description provided for @hadithRemovedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Hadith removed from favorites'**
  String get hadithRemovedFromFavorites;

  /// No description provided for @hadithAddedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Hadith added to favorites'**
  String get hadithAddedToFavorites;

  /// No description provided for @narrator.
  ///
  /// In en, this message translates to:
  /// **'Narrator'**
  String get narrator;

  /// No description provided for @shareHadithText.
  ///
  /// In en, this message translates to:
  /// **'Shared from Mishkat Al-Hoda Pro'**
  String get shareHadithText;

  /// No description provided for @scholarsEvaluation.
  ///
  /// In en, this message translates to:
  /// **'Scholars Evaluation'**
  String get scholarsEvaluation;

  /// No description provided for @hadithDetails.
  ///
  /// In en, this message translates to:
  /// **'Hadith Details'**
  String get hadithDetails;

  /// No description provided for @aiDisclaimerWarning.
  ///
  /// In en, this message translates to:
  /// **'⚠️ AI-generated answers should be reviewed from reliable sources'**
  String get aiDisclaimerWarning;

  /// No description provided for @subscriptionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Subscription activated successfully'**
  String get subscriptionSuccess;

  /// No description provided for @halalRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Halal Restaurants'**
  String get halalRestaurants;

  /// No description provided for @hisnAlMuslim.
  ///
  /// In en, this message translates to:
  /// **'Hisn Al-Muslim'**
  String get hisnAlMuslim;

  /// No description provided for @smartVoiceDhikr.
  ///
  /// In en, this message translates to:
  /// **'Smart Voice Dhikr'**
  String get smartVoiceDhikr;

  /// No description provided for @smartVoiceDescription.
  ///
  /// In en, this message translates to:
  /// **'Control your dhikr with voice commands'**
  String get smartVoiceDescription;

  /// No description provided for @zakatDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Note: This calculation is approximate and does not constitute a religious fatwa.\\nFor an accurate religious ruling, please consult knowledgeable scholars.'**
  String get zakatDisclaimer;

  /// No description provided for @totalCash.
  ///
  /// In en, this message translates to:
  /// **'Total Cash Money'**
  String get totalCash;

  /// No description provided for @doYouOwnGold.
  ///
  /// In en, this message translates to:
  /// **'Do you own gold?'**
  String get doYouOwnGold;

  /// No description provided for @goldValue.
  ///
  /// In en, this message translates to:
  /// **'Gold Value (if known directly)'**
  String get goldValue;

  /// No description provided for @goldGrams.
  ///
  /// In en, this message translates to:
  /// **'Gold Grams'**
  String get goldGrams;

  /// No description provided for @gold24kPrice.
  ///
  /// In en, this message translates to:
  /// **'24K Gold Price Per Gram'**
  String get gold24kPrice;

  /// No description provided for @requiredForNisaab.
  ///
  /// In en, this message translates to:
  /// **'Required for accurate Nisaab calculation (85 grams of gold)'**
  String get requiredForNisaab;

  /// No description provided for @requiredForGoldValue.
  ///
  /// In en, this message translates to:
  /// **'Required to calculate gold value from grams'**
  String get requiredForGoldValue;

  /// No description provided for @tradeValue.
  ///
  /// In en, this message translates to:
  /// **'Trade Goods Value'**
  String get tradeValue;

  /// No description provided for @enableNisaab.
  ///
  /// In en, this message translates to:
  /// **'Enable Nisaab Condition'**
  String get enableNisaab;

  /// No description provided for @calculateZakat.
  ///
  /// In en, this message translates to:
  /// **'Calculate Zakat'**
  String get calculateZakat;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @enterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get enterValidNumber;

  /// No description provided for @connectedNow.
  ///
  /// In en, this message translates to:
  /// **'Connected Now'**
  String get connectedNow;

  /// No description provided for @haramAndLive.
  ///
  /// In en, this message translates to:
  /// **'Haram & Live Broadcast'**
  String get haramAndLive;

  /// No description provided for @khatmahList.
  ///
  /// In en, this message translates to:
  /// **'Khatma List'**
  String get khatmahList;

  /// No description provided for @licensedMessage.
  ///
  /// In en, this message translates to:
  /// **'This broadcast is licensed from official Saudi channels'**
  String get licensedMessage;

  /// No description provided for @newKhatmah.
  ///
  /// In en, this message translates to:
  /// **'New Khatma'**
  String get newKhatmah;

  /// No description provided for @setQibla.
  ///
  /// In en, this message translates to:
  /// **'Set Qibla'**
  String get setQibla;

  /// No description provided for @startQuranJourney.
  ///
  /// In en, this message translates to:
  /// **'Start your Quran Journey'**
  String get startQuranJourney;

  /// No description provided for @yourCurrentKhatmah.
  ///
  /// In en, this message translates to:
  /// **'Your Current Khatma'**
  String get yourCurrentKhatmah;

  /// No description provided for @assistantAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get assistantAppBarTitle;

  /// No description provided for @createNewChat.
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get createNewChat;

  /// No description provided for @aiModelSelection.
  ///
  /// In en, this message translates to:
  /// **'AI Model Selection'**
  String get aiModelSelection;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get retryButton;

  /// No description provided for @creatingNewChatMessage.
  ///
  /// In en, this message translates to:
  /// **'Creating new chat...'**
  String get creatingNewChatMessage;

  /// No description provided for @noActiveChatMessage.
  ///
  /// In en, this message translates to:
  /// **'No active chat'**
  String get noActiveChatMessage;

  /// No description provided for @startNewChatMessage.
  ///
  /// In en, this message translates to:
  /// **'Start a new conversation by sending a message'**
  String get startNewChatMessage;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// No description provided for @typingIndicator.
  ///
  /// In en, this message translates to:
  /// **'Typing...'**
  String get typingIndicator;

  /// No description provided for @dailyLimitReachedTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Limit Reached'**
  String get dailyLimitReachedTitle;

  /// No description provided for @dailyLimitReachedMessage.
  ///
  /// In en, this message translates to:
  /// **'You have used {dailyCount} of {maxQuestions} questions today'**
  String dailyLimitReachedMessage(Object dailyCount, Object maxQuestions);

  /// No description provided for @upgradeToPremiumButton.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremiumButton;

  /// No description provided for @featureAvailableForPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium Feature'**
  String get featureAvailableForPremium;

  /// No description provided for @premiumFeatureTitle.
  ///
  /// In en, this message translates to:
  /// **'AI model selection is available only for premium subscribers'**
  String get premiumFeatureTitle;

  /// No description provided for @premiumFeatureContent.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to get:\\n• Advanced model selection\\n• Unlimited questions\\n• More detailed answers'**
  String get premiumFeatureContent;

  /// No description provided for @okButton.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okButton;

  /// No description provided for @upgradeNowButton.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Now'**
  String get upgradeNowButton;

  /// No description provided for @laterButton.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get laterButton;

  /// No description provided for @questionsRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining: {remaining}'**
  String questionsRemaining(Object remaining);

  /// No description provided for @chooseAiModelTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose AI Model'**
  String get chooseAiModelTitle;

  /// No description provided for @gpt4oMiniTitle.
  ///
  /// In en, this message translates to:
  /// **'GPT-4o Mini'**
  String get gpt4oMiniTitle;

  /// No description provided for @gpt4oMiniSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fast and balanced'**
  String get gpt4oMiniSubtitle;

  /// No description provided for @gpt4oTitle.
  ///
  /// In en, this message translates to:
  /// **'GPT-4o'**
  String get gpt4oTitle;

  /// No description provided for @gpt4oSubtitle.
  ///
  /// In en, this message translates to:
  /// **'More accurate and detailed'**
  String get gpt4oSubtitle;

  /// No description provided for @conversationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get conversationsTitle;

  /// No description provided for @newConversation.
  ///
  /// In en, this message translates to:
  /// **'New Conversation'**
  String get newConversation;

  /// No description provided for @noConversationsMessage.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet. Click + to create a new one'**
  String get noConversationsMessage;

  /// No description provided for @newChatCreationMessage.
  ///
  /// In en, this message translates to:
  /// **'Creating new chat...'**
  String get newChatCreationMessage;

  /// No description provided for @dayAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} day(s) ago'**
  String dayAgo(Object days);

  /// No description provided for @hourAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} hour(s) ago'**
  String hourAgo(Object hours);

  /// No description provided for @minuteAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minute(s) ago'**
  String minuteAgo(Object minutes);

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @typeMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get typeMessageHint;

  /// No description provided for @aiGeneratedAnswersNeedReview.
  ///
  /// In en, this message translates to:
  /// **'AI generated answers need to be reviewed'**
  String get aiGeneratedAnswersNeedReview;

  /// No description provided for @pleaseWaitHint.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWaitHint;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailRequiredError;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordRequiredError;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @createAccountLink.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountLink;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @nameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get nameRequiredError;

  /// No description provided for @emailLabelRegister.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabelRegister;

  /// No description provided for @emailRequiredErrorRegister.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailRequiredErrorRegister;

  /// No description provided for @passwordLabelRegister.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabelRegister;

  /// No description provided for @passwordRequiredErrorRegister.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordRequiredErrorRegister;

  /// No description provided for @passwordMinLengthError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLengthError;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordRequiredError;

  /// No description provided for @passwordsMismatchError.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsMismatchError;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountButton;

  /// No description provided for @orText.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orText;

  /// No description provided for @loginAsGuestButton.
  ///
  /// In en, this message translates to:
  /// **'Login as Guest'**
  String get loginAsGuestButton;

  /// No description provided for @loginLinkText.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginLinkText;

  /// No description provided for @noAccountText.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get noAccountText;

  /// No description provided for @countryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get countryLabel;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchHint;

  /// No description provided for @loginSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccessMessage;

  /// No description provided for @guestLoginSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Guest login successful'**
  String get guestLoginSuccessMessage;

  /// No description provided for @registerSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get registerSuccessMessage;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @invalidEmailError.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmailError;

  /// No description provided for @userNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFoundError;

  /// No description provided for @wrongPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Wrong password'**
  String get wrongPasswordError;

  /// No description provided for @emailAlreadyInUseError.
  ///
  /// In en, this message translates to:
  /// **'Email already in use'**
  String get emailAlreadyInUseError;

  /// No description provided for @weakPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak'**
  String get weakPasswordError;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get networkError;

  /// No description provided for @copyZekrSuccess.
  ///
  /// In en, this message translates to:
  /// **'Zekr copied to clipboard'**
  String get copyZekrSuccess;

  /// No description provided for @addToFavoritesSuccess.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites ✅'**
  String get addToFavoritesSuccess;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get removeFromFavorites;

  /// No description provided for @zekrCopied.
  ///
  /// In en, this message translates to:
  /// **'Zekr copied'**
  String get zekrCopied;

  /// No description provided for @zekrShared.
  ///
  /// In en, this message translates to:
  /// **'Zekr shared'**
  String get zekrShared;

  /// No description provided for @premiumOnlyFeature.
  ///
  /// In en, this message translates to:
  /// **'🔒 This zekr is for subscribers only'**
  String get premiumOnlyFeature;

  /// No description provided for @subscribeToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Subscribe now to unlock all azkar'**
  String get subscribeToUnlock;

  /// No description provided for @lockedAzkarMessage.
  ///
  /// In en, this message translates to:
  /// **'This section is for premium subscribers only'**
  String get lockedAzkarMessage;

  /// No description provided for @zoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom In'**
  String get zoomIn;

  /// No description provided for @zoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom Out'**
  String get zoomOut;

  /// No description provided for @morningEveningAzkar.
  ///
  /// In en, this message translates to:
  /// **'Morning and Evening Azkar'**
  String get morningEveningAzkar;

  /// No description provided for @sleepAzkar.
  ///
  /// In en, this message translates to:
  /// **'Sleep Azkar'**
  String get sleepAzkar;

  /// No description provided for @afterPrayerAzkar.
  ///
  /// In en, this message translates to:
  /// **'Azkar After Prayer'**
  String get afterPrayerAzkar;

  /// No description provided for @morningAzkar.
  ///
  /// In en, this message translates to:
  /// **'Morning Azkar'**
  String get morningAzkar;

  /// No description provided for @eveningAzkar.
  ///
  /// In en, this message translates to:
  /// **'Evening Azkar'**
  String get eveningAzkar;

  /// No description provided for @loadDataError.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get loadDataError;

  /// No description provided for @shareError.
  ///
  /// In en, this message translates to:
  /// **'Share error'**
  String get shareError;

  /// No description provided for @bookmarksTitle.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarksTitle;

  /// No description provided for @deleteBookmarkSuccess.
  ///
  /// In en, this message translates to:
  /// **'Bookmark deleted successfully'**
  String get deleteBookmarkSuccess;

  /// No description provided for @deleteBookmarkConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete Bookmark'**
  String get deleteBookmarkConfirmation;

  /// No description provided for @areYouSureDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this bookmark?'**
  String get areYouSureDelete;

  /// No description provided for @noBookmarksDescription.
  ///
  /// In en, this message translates to:
  /// **'Add a bookmark from the reading page'**
  String get noBookmarksDescription;

  /// No description provided for @addBookmarkFromReading.
  ///
  /// In en, this message translates to:
  /// **'Add a bookmark from the reading page'**
  String get addBookmarkFromReading;

  /// No description provided for @addBookmarkTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Bookmark'**
  String get addBookmarkTitle;

  /// No description provided for @verse.
  ///
  /// In en, this message translates to:
  /// **'Verse'**
  String get verse;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get addNote;

  /// No description provided for @writeNoteHere.
  ///
  /// In en, this message translates to:
  /// **'Write your note here...'**
  String get writeNoteHere;

  /// No description provided for @verseNumber.
  ///
  /// In en, this message translates to:
  /// **'Verse'**
  String get verseNumber;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(Object days);

  /// No description provided for @weekAgo.
  ///
  /// In en, this message translates to:
  /// **'A week ago'**
  String get weekAgo;

  /// No description provided for @weeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{weeks} weeks ago'**
  String weeksAgo(Object weeks);

  /// No description provided for @monthAgo.
  ///
  /// In en, this message translates to:
  /// **'A month ago'**
  String get monthAgo;

  /// No description provided for @monthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{months} months ago'**
  String monthsAgo(Object months);

  /// No description provided for @yearAgo.
  ///
  /// In en, this message translates to:
  /// **'A year ago'**
  String get yearAgo;

  /// No description provided for @yearsAgo.
  ///
  /// In en, this message translates to:
  /// **'{years} years ago'**
  String yearsAgo(Object years);

  /// No description provided for @deleteBookmarkError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting bookmark'**
  String get deleteBookmarkError;

  /// No description provided for @loadBookmarksError.
  ///
  /// In en, this message translates to:
  /// **'Error loading bookmarks'**
  String get loadBookmarksError;

  /// No description provided for @collectiveKhatmas.
  ///
  /// In en, this message translates to:
  /// **'Collective Khatmas'**
  String get collectiveKhatmas;

  /// No description provided for @myKhatmas.
  ///
  /// In en, this message translates to:
  /// **'My Khatmas'**
  String get myKhatmas;

  /// No description provided for @joinByLink.
  ///
  /// In en, this message translates to:
  /// **'Join by Link'**
  String get joinByLink;

  /// No description provided for @searchKhatmaHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a khatma...'**
  String get searchKhatmaHint;

  /// No description provided for @createKhatma.
  ///
  /// In en, this message translates to:
  /// **'Create Khatma'**
  String get createKhatma;

  /// No description provided for @loginRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Login required to access this feature'**
  String get loginRequiredMessage;

  /// No description provided for @loginToJoinMessage.
  ///
  /// In en, this message translates to:
  /// **'Login to join collective khatmas with Muslims around the world'**
  String get loginToJoinMessage;

  /// No description provided for @noKhatmasAvailable.
  ///
  /// In en, this message translates to:
  /// **'No khatmas available'**
  String get noKhatmasAvailable;

  /// No description provided for @beFirstToCreate.
  ///
  /// In en, this message translates to:
  /// **'Be the first to create a collective khatma!'**
  String get beFirstToCreate;

  /// No description provided for @createNewKhatma.
  ///
  /// In en, this message translates to:
  /// **'Create New Khatma'**
  String get createNewKhatma;

  /// No description provided for @joinByLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Join Khatma by Link'**
  String get joinByLinkTitle;

  /// No description provided for @pasteLinkHint.
  ///
  /// In en, this message translates to:
  /// **'Paste khatma link here'**
  String get pasteLinkHint;

  /// No description provided for @fetchKhatma.
  ///
  /// In en, this message translates to:
  /// **'Fetch Khatma'**
  String get fetchKhatma;

  /// No description provided for @joinError.
  ///
  /// In en, this message translates to:
  /// **'Error occurred while trying to join the khatma'**
  String get joinError;

  /// No description provided for @createKhatmaTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Collective Khatma'**
  String get createKhatmaTitle;

  /// No description provided for @khatmaTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Khatma Title'**
  String get khatmaTitleLabel;

  /// No description provided for @khatmaTitleExample.
  ///
  /// In en, this message translates to:
  /// **'Example: Ramadan Khatma'**
  String get khatmaTitleExample;

  /// No description provided for @khatmaTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter khatma title'**
  String get khatmaTitleRequired;

  /// No description provided for @khatmaTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Khatma Type'**
  String get khatmaTypeLabel;

  /// No description provided for @public.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get public;

  /// No description provided for @publicDescription.
  ///
  /// In en, this message translates to:
  /// **'Everyone can join'**
  String get publicDescription;

  /// No description provided for @private.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get private;

  /// No description provided for @privateDescription.
  ///
  /// In en, this message translates to:
  /// **'Invitation only'**
  String get privateDescription;

  /// No description provided for @dateRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Start and End Date'**
  String get dateRangeLabel;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// Auto-generated description for khatmaDuration
  ///
  /// In en, this message translates to:
  /// **'Khatma Duration: {days} days'**
  String khatmaDuration(String days);

  /// No description provided for @khatmaCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Khatma created successfully!'**
  String get khatmaCreatedSuccess;

  /// No description provided for @khatmaDetails.
  ///
  /// In en, this message translates to:
  /// **'Khatma Details'**
  String get khatmaDetails;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLink;

  /// No description provided for @deleteKhatma.
  ///
  /// In en, this message translates to:
  /// **'Delete Khatma'**
  String get deleteKhatma;

  /// No description provided for @partReservedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Part {number} reserved successfully'**
  String partReservedSuccess(Object number);

  /// No description provided for @partCompletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Part {number} completed successfully'**
  String partCompletedSuccess(Object number);

  /// No description provided for @deleteConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Khatma'**
  String get deleteConfirmationTitle;

  /// No description provided for @deleteConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this khatma? This action cannot be undone.'**
  String get deleteConfirmationMessage;

  /// No description provided for @reserveThisPart.
  ///
  /// In en, this message translates to:
  /// **'Reserve This Part'**
  String get reserveThisPart;

  /// No description provided for @completeThisPart.
  ///
  /// In en, this message translates to:
  /// **'Complete This Part'**
  String get completeThisPart;

  /// Auto-generated description for alreadyReservedPart
  ///
  /// In en, this message translates to:
  /// **'You already have a reserved part (Part {part})'**
  String alreadyReservedPart(String part);

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linkCopied;

  /// No description provided for @myCollectiveKhatmas.
  ///
  /// In en, this message translates to:
  /// **'My Collective Khatmas'**
  String get myCollectiveKhatmas;

  /// No description provided for @joinedKhatmasTab.
  ///
  /// In en, this message translates to:
  /// **'Joined Khatmas'**
  String get joinedKhatmasTab;

  /// No description provided for @createdKhatmasTab.
  ///
  /// In en, this message translates to:
  /// **'My Created Khatmas'**
  String get createdKhatmasTab;

  /// No description provided for @noJoinedKhatmas.
  ///
  /// In en, this message translates to:
  /// **'Haven\\\'t joined any khatmas yet'**
  String get noJoinedKhatmas;

  /// No description provided for @findAndJoinKhatma.
  ///
  /// In en, this message translates to:
  /// **'Search for a collective khatma and join it'**
  String get findAndJoinKhatma;

  /// No description provided for @participatedKhatmas.
  ///
  /// In en, this message translates to:
  /// **'Participated Khatmas'**
  String get participatedKhatmas;

  /// No description provided for @completedParts.
  ///
  /// In en, this message translates to:
  /// **'Completed Parts'**
  String get completedParts;

  /// No description provided for @noCreatedKhatmas.
  ///
  /// In en, this message translates to:
  /// **'Haven\\\'t created any khatmas yet'**
  String get noCreatedKhatmas;

  /// No description provided for @startCreatingKhatma.
  ///
  /// In en, this message translates to:
  /// **'Start creating a new collective khatma'**
  String get startCreatingKhatma;

  /// No description provided for @partNumber.
  ///
  /// In en, this message translates to:
  /// **'Part {number}'**
  String partNumber(Object number);

  /// No description provided for @completedStatus.
  ///
  /// In en, this message translates to:
  /// **'Completed ✓'**
  String get completedStatus;

  /// No description provided for @inProgressStatus.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgressStatus;

  /// No description provided for @publicType.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get publicType;

  /// No description provided for @privateType.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get privateType;

  /// No description provided for @createdBy.
  ///
  /// In en, this message translates to:
  /// **'Created by {name}'**
  String createdBy(Object name);

  /// No description provided for @participants.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get participants;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @daysRemaining.
  ///
  /// In en, this message translates to:
  /// **'Days Remaining'**
  String get daysRemaining;

  /// No description provided for @completion.
  ///
  /// In en, this message translates to:
  /// **'Completion'**
  String get completion;

  /// No description provided for @completedPartsLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed Parts'**
  String get completedPartsLabel;

  /// No description provided for @reservedParts.
  ///
  /// In en, this message translates to:
  /// **'Reserved Parts'**
  String get reservedParts;

  /// No description provided for @availableParts.
  ///
  /// In en, this message translates to:
  /// **'Available Parts'**
  String get availableParts;

  /// No description provided for @khatmaCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed ✓'**
  String get khatmaCompleted;

  /// No description provided for @availableForReservation.
  ///
  /// In en, this message translates to:
  /// **'Available for reservation'**
  String get availableForReservation;

  /// Auto-generated description for reservedForUser
  ///
  /// In en, this message translates to:
  /// **'Reserved for {user}'**
  String reservedForUser(String user);

  /// No description provided for @partCompletedStatus.
  ///
  /// In en, this message translates to:
  /// **'Completed ✓'**
  String get partCompletedStatus;

  /// No description provided for @partCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get partCompleted;

  /// No description provided for @reserved.
  ///
  /// In en, this message translates to:
  /// **'Reserved'**
  String get reserved;

  /// No description provided for @yourPart.
  ///
  /// In en, this message translates to:
  /// **'Your Part'**
  String get yourPart;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @confirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get confirmation;

  /// No description provided for @deleteAllConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete all favorites?'**
  String get deleteAllConfirmation;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAll;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @deleteAllTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete All Favorites'**
  String get deleteAllTooltip;

  /// No description provided for @noFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorite items'**
  String get noFavorites;

  /// No description provided for @deleteFromFavoritesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete from Favorites'**
  String get deleteFromFavoritesTooltip;

  /// Auto-generated description for favoriteItemDescription
  ///
  /// In en, this message translates to:
  /// **'Favorite item: {item}'**
  String favoriteItemDescription(String item);

  /// No description provided for @quranAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get quranAudio;

  /// No description provided for @quranRecitations.
  ///
  /// In en, this message translates to:
  /// **'Quran Recitations'**
  String get quranRecitations;

  /// No description provided for @quranRecitationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Listen to Quran recitations by renowned reciters'**
  String get quranRecitationsDesc;

  /// No description provided for @quranRadio.
  ///
  /// In en, this message translates to:
  /// **'Quran Radio'**
  String get quranRadio;

  /// No description provided for @quranRadioDesc.
  ///
  /// In en, this message translates to:
  /// **'Listen to live Quran radio stations'**
  String get quranRadioDesc;

  /// No description provided for @downloadedAudio.
  ///
  /// In en, this message translates to:
  /// **'Downloaded Audio'**
  String get downloadedAudio;

  /// No description provided for @downloadedAudioDesc.
  ///
  /// In en, this message translates to:
  /// **'Listen to downloaded recitations offline'**
  String get downloadedAudioDesc;

  /// No description provided for @reciters.
  ///
  /// In en, this message translates to:
  /// **'Reciters'**
  String get reciters;

  /// No description provided for @searchRecitersHint.
  ///
  /// In en, this message translates to:
  /// **'Search reciters...'**
  String get searchRecitersHint;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @reciterPremiumOnly.
  ///
  /// In en, this message translates to:
  /// **'🔒 This reciter is available for premium subscribers only'**
  String get reciterPremiumOnly;

  /// No description provided for @surahsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Surahs'**
  String surahsCount(Object count);

  /// No description provided for @surahs.
  ///
  /// In en, this message translates to:
  /// **'Surahs'**
  String get surahs;

  /// No description provided for @ayahsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Ayahs'**
  String ayahsCount(Object count);

  /// No description provided for @noDownloadedAudio.
  ///
  /// In en, this message translates to:
  /// **'No downloaded audio'**
  String get noDownloadedAudio;

  /// No description provided for @deleteAudioTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Audio'**
  String get deleteAudioTitle;

  /// No description provided for @deleteAudioConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this audio?'**
  String get deleteAudioConfirm;

  /// No description provided for @noStationsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No stations available'**
  String get noStationsAvailable;

  /// No description provided for @liveRadio.
  ///
  /// In en, this message translates to:
  /// **'🟢 Live'**
  String get liveRadio;

  /// No description provided for @offlineRadio.
  ///
  /// In en, this message translates to:
  /// **'⚫ Offline'**
  String get offlineRadio;

  /// No description provided for @audioPlayer.
  ///
  /// In en, this message translates to:
  /// **'Audio Player'**
  String get audioPlayer;

  /// No description provided for @downloadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Downloaded successfully'**
  String get downloadSuccess;

  /// No description provided for @fileAlreadyDownloaded.
  ///
  /// In en, this message translates to:
  /// **'File already downloaded'**
  String get fileAlreadyDownloaded;

  /// No description provided for @skipBack15s.
  ///
  /// In en, this message translates to:
  /// **'Skip back 15s'**
  String get skipBack15s;

  /// No description provided for @skipForward15s.
  ///
  /// In en, this message translates to:
  /// **'Skip forward 15s'**
  String get skipForward15s;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @playing.
  ///
  /// In en, this message translates to:
  /// **'Playing'**
  String get playing;

  /// No description provided for @playbackCompleted.
  ///
  /// In en, this message translates to:
  /// **'Playback Completed'**
  String get playbackCompleted;

  /// No description provided for @surahIndex.
  ///
  /// In en, this message translates to:
  /// **'Surah {current} of {total}'**
  String surahIndex(Object current, Object total);

  /// No description provided for @replay.
  ///
  /// In en, this message translates to:
  /// **'Replay'**
  String get replay;

  /// No description provided for @audioLoadingError.
  ///
  /// In en, this message translates to:
  /// **'Audio loading error'**
  String get audioLoadingError;

  /// No description provided for @bookBukhari.
  ///
  /// In en, this message translates to:
  /// **'Sahih Al-Bukhari'**
  String get bookBukhari;

  /// No description provided for @bookMuslim.
  ///
  /// In en, this message translates to:
  /// **'Sahih Muslim'**
  String get bookMuslim;

  /// No description provided for @bookAbuDawud.
  ///
  /// In en, this message translates to:
  /// **'Sunan Abu Dawud'**
  String get bookAbuDawud;

  /// No description provided for @bookTirmidhi.
  ///
  /// In en, this message translates to:
  /// **'Jami At-Tirmidhi'**
  String get bookTirmidhi;

  /// No description provided for @bookNasai.
  ///
  /// In en, this message translates to:
  /// **'Sunan An-Nasai'**
  String get bookNasai;

  /// No description provided for @bookIbnMajah.
  ///
  /// In en, this message translates to:
  /// **'Sunan Ibn Majah'**
  String get bookIbnMajah;

  /// No description provided for @bookMalik.
  ///
  /// In en, this message translates to:
  /// **'Muwatta Malik'**
  String get bookMalik;

  /// No description provided for @bookNawawi.
  ///
  /// In en, this message translates to:
  /// **'Forty Nawawi'**
  String get bookNawawi;

  /// No description provided for @bookQudsi.
  ///
  /// In en, this message translates to:
  /// **'Hadith Qudsi'**
  String get bookQudsi;

  /// No description provided for @bookDehlawi.
  ///
  /// In en, this message translates to:
  /// **'Forty Hadith Shah Waliullah Dehlawi'**
  String get bookDehlawi;

  /// No description provided for @ramadanMubarakFull.
  ///
  /// In en, this message translates to:
  /// **'Ramadan Mubarak, may Allah bring it back to us and you with blessings and mercy'**
  String get ramadanMubarakFull;

  /// No description provided for @ofWord.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get ofWord;

  /// No description provided for @gradeLabel.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get gradeLabel;

  /// No description provided for @scholarLabel.
  ///
  /// In en, this message translates to:
  /// **'Scholar'**
  String get scholarLabel;

  /// No description provided for @gradeSahih.
  ///
  /// In en, this message translates to:
  /// **'Sahih'**
  String get gradeSahih;

  /// No description provided for @gradeHasan.
  ///
  /// In en, this message translates to:
  /// **'Hasan'**
  String get gradeHasan;

  /// No description provided for @gradeDaif.
  ///
  /// In en, this message translates to:
  /// **'Daif'**
  String get gradeDaif;

  /// No description provided for @gradeMawdu.
  ///
  /// In en, this message translates to:
  /// **'Fabricated'**
  String get gradeMawdu;

  /// No description provided for @gradeMaqbul.
  ///
  /// In en, this message translates to:
  /// **'Acceptable'**
  String get gradeMaqbul;

  /// No description provided for @gradeEvaluation.
  ///
  /// In en, this message translates to:
  /// **'Evaluation'**
  String get gradeEvaluation;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @sourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get sourceLabel;

  /// No description provided for @hadithGradeLabel.
  ///
  /// In en, this message translates to:
  /// **'Hadith Grade'**
  String get hadithGradeLabel;

  /// No description provided for @qiblaDirection.
  ///
  /// In en, this message translates to:
  /// **'Qibla Direction'**
  String get qiblaDirection;

  /// No description provided for @locatingYourPosition.
  ///
  /// In en, this message translates to:
  /// **'Locating your position...'**
  String get locatingYourPosition;

  /// No description provided for @errorCalculatingQibla.
  ///
  /// In en, this message translates to:
  /// **'Error calculating Qibla'**
  String get errorCalculatingQibla;

  /// No description provided for @compassAccessError.
  ///
  /// In en, this message translates to:
  /// **'Error accessing compass'**
  String get compassAccessError;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services disabled'**
  String get locationServicesDisabled;

  /// No description provided for @locationPermissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission permanently denied'**
  String get locationPermissionPermanentlyDenied;

  /// No description provided for @qiblaAngleFromNorth.
  ///
  /// In en, this message translates to:
  /// **'Qibla angle from North'**
  String get qiblaAngleFromNorth;

  /// No description provided for @facingQiblaNow.
  ///
  /// In en, this message translates to:
  /// **'You are facing Qibla now'**
  String get facingQiblaNow;

  /// No description provided for @qibla.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get qibla;

  /// No description provided for @gregorianToHijri.
  ///
  /// In en, this message translates to:
  /// **'Gregorian to Hijri'**
  String get gregorianToHijri;

  /// No description provided for @pickGregorianDate.
  ///
  /// In en, this message translates to:
  /// **'Pick Gregorian Date'**
  String get pickGregorianDate;

  /// No description provided for @errorConvertingGregorianToHijri.
  ///
  /// In en, this message translates to:
  /// **'Error converting date'**
  String get errorConvertingGregorianToHijri;

  /// No description provided for @hijriToGregorian.
  ///
  /// In en, this message translates to:
  /// **'Hijri to Gregorian'**
  String get hijriToGregorian;

  /// No description provided for @enterHijriDateHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Hijri Date (DD/MM/YYYY)'**
  String get enterHijriDateHint;

  /// No description provided for @hijriDateExample.
  ///
  /// In en, this message translates to:
  /// **'Example: 01/09/1445'**
  String get hijriDateExample;

  /// No description provided for @convert.
  ///
  /// In en, this message translates to:
  /// **'Convert'**
  String get convert;

  /// No description provided for @dateHijriLabel.
  ///
  /// In en, this message translates to:
  /// **'Hijri Date'**
  String get dateHijriLabel;

  /// No description provided for @dateGregorianLabel.
  ///
  /// In en, this message translates to:
  /// **'Gregorian Date'**
  String get dateGregorianLabel;

  /// No description provided for @errorConvertingHijriToGregorian.
  ///
  /// In en, this message translates to:
  /// **'Error converting date'**
  String get errorConvertingHijriToGregorian;

  /// No description provided for @locationPermissionDeniedForeverTitle.
  ///
  /// In en, this message translates to:
  /// **'Location permission permanently denied, we cannot request permissions.'**
  String get locationPermissionDeniedForeverTitle;

  /// No description provided for @errorCalculatingQiblaDirection.
  ///
  /// In en, this message translates to:
  /// **'Error calculating Qibla direction'**
  String get errorCalculatingQiblaDirection;

  /// No description provided for @errorAccessingCompass.
  ///
  /// In en, this message translates to:
  /// **'Error accessing compass'**
  String get errorAccessingCompass;

  /// No description provided for @qiblaDirectionFromNorth.
  ///
  /// In en, this message translates to:
  /// **'Qibla angle from North'**
  String get qiblaDirectionFromNorth;

  /// No description provided for @youAreFacingTheQibla.
  ///
  /// In en, this message translates to:
  /// **'You are facing Qibla now'**
  String get youAreFacingTheQibla;

  /// No description provided for @selectGregorianDate.
  ///
  /// In en, this message translates to:
  /// **'Select Gregorian Date'**
  String get selectGregorianDate;

  /// No description provided for @enterHijriDate.
  ///
  /// In en, this message translates to:
  /// **'Enter Hijri Date (DD-MM-YYYY)'**
  String get enterHijriDate;

  /// No description provided for @errorConvertingHijriDate.
  ///
  /// In en, this message translates to:
  /// **'Error converting Hijri to Gregorian date'**
  String get errorConvertingHijriDate;

  /// No description provided for @haramLiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Haram and Live Stream'**
  String get haramLiveTitle;

  /// No description provided for @chooseChannel.
  ///
  /// In en, this message translates to:
  /// **'Choose the channel you want to watch now'**
  String get chooseChannel;

  /// No description provided for @makkah.
  ///
  /// In en, this message translates to:
  /// **'Makkah'**
  String get makkah;

  /// No description provided for @saudiChannel.
  ///
  /// In en, this message translates to:
  /// **'Saudi Channel'**
  String get saudiChannel;

  /// No description provided for @quranChannel.
  ///
  /// In en, this message translates to:
  /// **'Quran Channel'**
  String get quranChannel;

  /// No description provided for @madinah.
  ///
  /// In en, this message translates to:
  /// **'Madinah'**
  String get madinah;

  /// No description provided for @madinahChannel.
  ///
  /// In en, this message translates to:
  /// **'Madinah Channel'**
  String get madinahChannel;

  /// No description provided for @liveStreamTitle.
  ///
  /// In en, this message translates to:
  /// **'Live Stream'**
  String get liveStreamTitle;

  /// No description provided for @initializing.
  ///
  /// In en, this message translates to:
  /// **'Initializing...'**
  String get initializing;

  /// No description provided for @loadingStream.
  ///
  /// In en, this message translates to:
  /// **'Loading live stream...'**
  String get loadingStream;

  /// No description provided for @playingStream.
  ///
  /// In en, this message translates to:
  /// **'Playing stream...'**
  String get playingStream;

  /// No description provided for @clickToPlay.
  ///
  /// In en, this message translates to:
  /// **'Click the play button to start the stream'**
  String get clickToPlay;

  /// No description provided for @openInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in Browser'**
  String get openInBrowser;

  /// No description provided for @openInBrowserDescription.
  ///
  /// In en, this message translates to:
  /// **'The live stream will open in the device\\\'s external browser'**
  String get openInBrowserDescription;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @rememberAllah.
  ///
  /// In en, this message translates to:
  /// **'Remember Allah'**
  String get rememberAllah;

  /// No description provided for @rememberAllahDescription.
  ///
  /// In en, this message translates to:
  /// **'Remember Allah anytime, anywhere'**
  String get rememberAllahDescription;

  /// No description provided for @mustLoginFirst.
  ///
  /// In en, this message translates to:
  /// **'You must login first'**
  String get mustLoginFirst;

  /// No description provided for @savedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully ✅'**
  String get savedSuccessfully;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed'**
  String get saveFailed;

  /// No description provided for @subhanAllah.
  ///
  /// In en, this message translates to:
  /// **'Subhan Allah'**
  String get subhanAllah;

  /// No description provided for @errorLoadingTasbehData.
  ///
  /// In en, this message translates to:
  /// **'Error loading tasbih data'**
  String get errorLoadingTasbehData;

  /// No description provided for @errorLoadingCounter.
  ///
  /// In en, this message translates to:
  /// **'Error loading counter'**
  String get errorLoadingCounter;

  /// No description provided for @errorSavingTasbeh.
  ///
  /// In en, this message translates to:
  /// **'Error saving tasbih'**
  String get errorSavingTasbeh;

  /// No description provided for @errorSavingSelectedZikr.
  ///
  /// In en, this message translates to:
  /// **'Error saving selected zikr'**
  String get errorSavingSelectedZikr;

  /// No description provided for @errorResettingCounter.
  ///
  /// In en, this message translates to:
  /// **'Error resetting counter'**
  String get errorResettingCounter;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @streamLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load stream'**
  String get streamLoadFailed;

  /// No description provided for @retryAttempt.
  ///
  /// In en, this message translates to:
  /// **'Attempt'**
  String get retryAttempt;

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// No description provided for @importantNotice.
  ///
  /// In en, this message translates to:
  /// **'Important Notice'**
  String get importantNotice;

  /// Auto-generated description for copyrightNotice
  ///
  /// In en, this message translates to:
  /// **'The stream is broadcast from {channel} channel affiliated with the Broadcasting and Television Authority on YouTube platform. The application does not publish, store, or rebroadcast any content, and all rights are reserved to their owners.'**
  String copyrightNotice(String channel);

  /// No description provided for @copyrightRights.
  ///
  /// In en, this message translates to:
  /// **'© All rights reserved - General Presidency for the Affairs of the Two Holy Mosques'**
  String get copyrightRights;

  /// No description provided for @locationSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Settings'**
  String get locationSettingsTitle;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @regionLabel.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get regionLabel;

  /// No description provided for @autoRefreshLocation.
  ///
  /// In en, this message translates to:
  /// **'Auto-refresh location on startup'**
  String get autoRefreshLocation;

  /// No description provided for @updating.
  ///
  /// In en, this message translates to:
  /// **'Updating...'**
  String get updating;

  /// No description provided for @refreshLocationNow.
  ///
  /// In en, this message translates to:
  /// **'Refresh Location Now'**
  String get refreshLocationNow;

  /// No description provided for @locationUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Location updated successfully'**
  String get locationUpdatedSuccessfully;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @athanNotification.
  ///
  /// In en, this message translates to:
  /// **'Athan Notification'**
  String get athanNotification;

  /// No description provided for @athanOverlaySettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Adhan full-screen alarm screen'**
  String get athanOverlaySettingTitle;

  /// No description provided for @preAthanNotification.
  ///
  /// In en, this message translates to:
  /// **'5 Minutes Before Athan Alert'**
  String get preAthanNotification;

  /// No description provided for @suhoorAlarmTitle.
  ///
  /// In en, this message translates to:
  /// **'Suhoor alarm'**
  String get suhoorAlarmTitle;

  /// No description provided for @iftarAlarmTitle.
  ///
  /// In en, this message translates to:
  /// **'Iftar alarm'**
  String get iftarAlarmTitle;

  /// No description provided for @khushooMode.
  ///
  /// In en, this message translates to:
  /// **'Khushoo Mode (Silent during Prayer)'**
  String get khushooMode;

  /// No description provided for @collectiveKhatmaNotifications.
  ///
  /// In en, this message translates to:
  /// **'Collective Khatma Notifications'**
  String get collectiveKhatmaNotifications;

  /// No description provided for @remindMeOfAllah.
  ///
  /// In en, this message translates to:
  /// **'Remind Me of Allah'**
  String get remindMeOfAllah;

  /// No description provided for @minute.
  ///
  /// In en, this message translates to:
  /// **'Minute'**
  String get minute;

  /// No description provided for @halfHour.
  ///
  /// In en, this message translates to:
  /// **'Half Hour'**
  String get halfHour;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'Hour'**
  String get hour;

  /// No description provided for @twoHours.
  ///
  /// In en, this message translates to:
  /// **'Two Hours'**
  String get twoHours;

  /// No description provided for @fourHours.
  ///
  /// In en, this message translates to:
  /// **'Four Hours'**
  String get fourHours;

  /// No description provided for @premiumFeature.
  ///
  /// In en, this message translates to:
  /// **'Premium Feature'**
  String get premiumFeature;

  /// No description provided for @premiumFeatureDescription.
  ///
  /// In en, this message translates to:
  /// **'This feature is available only for premium subscribers.\\nUpgrade to enjoy all features!'**
  String get premiumFeatureDescription;

  /// No description provided for @upgradeNow.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Now'**
  String get upgradeNow;

  /// No description provided for @prayersAndMuezzinsTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayers and Muezzins'**
  String get prayersAndMuezzinsTitle;

  /// Auto-generated description for selectMuezzin
  ///
  /// In en, this message translates to:
  /// **'Select Muezzin: {muezzinName}'**
  String selectMuezzin(String muezzinName);

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not Specified'**
  String get notSpecified;

  /// No description provided for @playAthanSound.
  ///
  /// In en, this message translates to:
  /// **'Play Athan Sound'**
  String get playAthanSound;

  /// No description provided for @selectMuezzinDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Muezzin'**
  String get selectMuezzinDialogTitle;

  /// No description provided for @noRecitersAvailable.
  ///
  /// In en, this message translates to:
  /// **'No reciters available currently'**
  String get noRecitersAvailable;

  /// No description provided for @chooseFavoriteMuezzin.
  ///
  /// In en, this message translates to:
  /// **'Choose Favorite Muezzin'**
  String get chooseFavoriteMuezzin;

  /// Auto-generated description for muezzinSelected
  ///
  /// In en, this message translates to:
  /// **'Muezzin selected: {muezzinName}'**
  String muezzinSelected(String muezzinName);

  /// No description provided for @selectMuezzinFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a muezzin first'**
  String get selectMuezzinFirst;

  /// Auto-generated description for playingMuezzinSound
  ///
  /// In en, this message translates to:
  /// **'Playing muezzin sound: {muezzinName}'**
  String playingMuezzinSound(String muezzinName);

  /// No description provided for @quranSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quran Settings'**
  String get quranSettingsTitle;

  /// No description provided for @favoriteTafsir.
  ///
  /// In en, this message translates to:
  /// **'Favorite Tafsir'**
  String get favoriteTafsir;

  /// No description provided for @favoriteReciter.
  ///
  /// In en, this message translates to:
  /// **'Favorite Reciter'**
  String get favoriteReciter;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not Available'**
  String get notAvailable;

  /// No description provided for @chooseTafsir.
  ///
  /// In en, this message translates to:
  /// **'Choose Tafsir'**
  String get chooseTafsir;

  /// No description provided for @chooseReciter.
  ///
  /// In en, this message translates to:
  /// **'Choose Reciter'**
  String get chooseReciter;

  /// No description provided for @notAvailableEnglish.
  ///
  /// In en, this message translates to:
  /// **'Not Available'**
  String get notAvailableEnglish;

  /// No description provided for @settingsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading settings'**
  String get settingsLoadError;

  /// No description provided for @generalTitle.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @indonesian.
  ///
  /// In en, this message translates to:
  /// **'Indonesian'**
  String get indonesian;

  /// No description provided for @urdu.
  ///
  /// In en, this message translates to:
  /// **'Urdu'**
  String get urdu;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkish;

  /// No description provided for @bengali.
  ///
  /// In en, this message translates to:
  /// **'Bengali'**
  String get bengali;

  /// No description provided for @malay.
  ///
  /// In en, this message translates to:
  /// **'Malay'**
  String get malay;

  /// No description provided for @persian.
  ///
  /// In en, this message translates to:
  /// **'Persian'**
  String get persian;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get chinese;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @updatingLanguage.
  ///
  /// In en, this message translates to:
  /// **'Updating language...'**
  String get updatingLanguage;

  /// Auto-generated description for languageUpdateError
  ///
  /// In en, this message translates to:
  /// **'Error updating language: {error}'**
  String languageUpdateError(String error);

  /// No description provided for @appearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @alhamdulillah.
  ///
  /// In en, this message translates to:
  /// **'Alhamdulillah'**
  String get alhamdulillah;

  /// No description provided for @allahuAkbar.
  ///
  /// In en, this message translates to:
  /// **'Allahu Akbar'**
  String get allahuAkbar;

  /// No description provided for @laIlahaIllallah.
  ///
  /// In en, this message translates to:
  /// **'La Ilaha Illallah'**
  String get laIlahaIllallah;

  /// No description provided for @astaghfirullah.
  ///
  /// In en, this message translates to:
  /// **'Astaghfirullah'**
  String get astaghfirullah;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @accountAndSubscription.
  ///
  /// In en, this message translates to:
  /// **'Account & Subscription'**
  String get accountAndSubscription;

  /// No description provided for @monthlySubscription.
  ///
  /// In en, this message translates to:
  /// **'Monthly Subscription'**
  String get monthlySubscription;

  /// No description provided for @yearlySubscription.
  ///
  /// In en, this message translates to:
  /// **'Yearly Subscription'**
  String get yearlySubscription;

  /// No description provided for @premiumSubscription.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premiumSubscription;

  /// No description provided for @freeSubscription.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get freeSubscription;

  /// No description provided for @accountStatus.
  ///
  /// In en, this message translates to:
  /// **'Account Status'**
  String get accountStatus;

  /// No description provided for @expiresOn.
  ///
  /// In en, this message translates to:
  /// **'Expires On'**
  String get expiresOn;

  /// No description provided for @manageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get manageSubscription;

  /// No description provided for @upgradeAccount.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Account'**
  String get upgradeAccount;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @collectiveKhatma.
  ///
  /// In en, this message translates to:
  /// **'Collective Khatma'**
  String get collectiveKhatma;

  /// No description provided for @quranKareem.
  ///
  /// In en, this message translates to:
  /// **'Holy Quran'**
  String get quranKareem;

  /// No description provided for @azkarAndAdiyah.
  ///
  /// In en, this message translates to:
  /// **'Azkar & Supplications'**
  String get azkarAndAdiyah;

  /// No description provided for @khatma.
  ///
  /// In en, this message translates to:
  /// **'Khatma'**
  String get khatma;

  /// No description provided for @liveBroadcastAndHaram.
  ///
  /// In en, this message translates to:
  /// **'Live Broadcast & Haram'**
  String get liveBroadcastAndHaram;

  /// No description provided for @smartAssistant.
  ///
  /// In en, this message translates to:
  /// **'Smart Assistant'**
  String get smartAssistant;

  /// No description provided for @maxZoom.
  ///
  /// In en, this message translates to:
  /// **'Max Zoom'**
  String get maxZoom;

  /// No description provided for @licensedBroadcast.
  ///
  /// In en, this message translates to:
  /// **'This broadcast is licensed from official Saudi channels'**
  String get licensedBroadcast;

  /// No description provided for @chooseKhatmaCount.
  ///
  /// In en, this message translates to:
  /// **'Choose number of khatmas:'**
  String get chooseKhatmaCount;

  /// No description provided for @chooseKhatmaCountHint.
  ///
  /// In en, this message translates to:
  /// **'Select khatma count'**
  String get chooseKhatmaCountHint;

  /// No description provided for @pagesPerDay.
  ///
  /// In en, this message translates to:
  /// **'Page/Day'**
  String get pagesPerDay;

  /// No description provided for @juzPerDay.
  ///
  /// In en, this message translates to:
  /// **'Juz/Day'**
  String get juzPerDay;

  /// No description provided for @hideSchedule.
  ///
  /// In en, this message translates to:
  /// **'Hide Schedule'**
  String get hideSchedule;

  /// No description provided for @showDetailedSchedule.
  ///
  /// In en, this message translates to:
  /// **'Show Detailed Schedule'**
  String get showDetailedSchedule;

  /// No description provided for @dayColumn.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get dayColumn;

  /// No description provided for @pagesColumn.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get pagesColumn;

  /// No description provided for @surahsColumn.
  ///
  /// In en, this message translates to:
  /// **'Surahs'**
  String get surahsColumn;

  /// No description provided for @yourDailyWird.
  ///
  /// In en, this message translates to:
  /// **'Your Daily Wird'**
  String get yourDailyWird;

  /// No description provided for @pageNumber.
  ///
  /// In en, this message translates to:
  /// **'Page Number'**
  String get pageNumber;

  /// No description provided for @currentJuz.
  ///
  /// In en, this message translates to:
  /// **'Current Juz'**
  String get currentJuz;

  /// No description provided for @readJuz.
  ///
  /// In en, this message translates to:
  /// **'Read Juz'**
  String get readJuz;

  /// No description provided for @remainingPages.
  ///
  /// In en, this message translates to:
  /// **'Remaining Pages'**
  String get remainingPages;

  /// No description provided for @todayProgress.
  ///
  /// In en, this message translates to:
  /// **'Today\\\'s Progress'**
  String get todayProgress;

  /// No description provided for @pagesUnit.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get pagesUnit;

  /// No description provided for @khatmaPercentage.
  ///
  /// In en, this message translates to:
  /// **'Khatma Percentage'**
  String get khatmaPercentage;

  /// No description provided for @khatmaTrackingNote.
  ///
  /// In en, this message translates to:
  /// **'Khatma tracking works with \"Horizontal Flip\" mode only'**
  String get khatmaTrackingNote;

  /// No description provided for @continueReading.
  ///
  /// In en, this message translates to:
  /// **'Continue Reading'**
  String get continueReading;

  /// No description provided for @liveNow.
  ///
  /// In en, this message translates to:
  /// **'Live Now'**
  String get liveNow;

  /// No description provided for @nearbyMosques.
  ///
  /// In en, this message translates to:
  /// **'Nearby Mosques'**
  String get nearbyMosques;

  /// No description provided for @pleaseWaitForMosquesToLoad.
  ///
  /// In en, this message translates to:
  /// **'Please wait for mosques to load'**
  String get pleaseWaitForMosquesToLoad;

  /// No description provided for @showOnMap.
  ///
  /// In en, this message translates to:
  /// **'Show on Map'**
  String get showOnMap;

  /// No description provided for @updateLocation.
  ///
  /// In en, this message translates to:
  /// **'Update Location'**
  String get updateLocation;

  /// No description provided for @noNearbyMosquesInRange.
  ///
  /// In en, this message translates to:
  /// **'No nearby mosques in current range'**
  String get noNearbyMosquesInRange;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @myCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'My Current Location'**
  String get myCurrentLocation;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// No description provided for @openInMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Maps'**
  String get openInMaps;

  /// No description provided for @benefits.
  ///
  /// In en, this message translates to:
  /// **'Benefits'**
  String get benefits;

  /// No description provided for @explanation.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get explanation;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we will send you a link to reset your password'**
  String get forgotPasswordDescription;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @checkSpamMessage.
  ///
  /// In en, this message translates to:
  /// **'Note: Email may go to Spam folder, please check it'**
  String get checkSpamMessage;

  /// No description provided for @copyrightHadithNotice.
  ///
  /// In en, this message translates to:
  /// **'All rights reserved to the source. (HadeethEnc.com)'**
  String get copyrightHadithNotice;

  /// No description provided for @wordsMeaning.
  ///
  /// In en, this message translates to:
  /// **'Words Meaning'**
  String get wordsMeaning;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Mishkat Al-Hoda'**
  String get appName;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'Your comprehensive app for worship and Islamic knowledge'**
  String get appDescription;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get version;

  /// No description provided for @mainFeatures.
  ///
  /// In en, this message translates to:
  /// **'Main Features'**
  String get mainFeatures;

  /// No description provided for @aboutAndRights.
  ///
  /// In en, this message translates to:
  /// **'About App & Rights'**
  String get aboutAndRights;

  /// No description provided for @generalInfo.
  ///
  /// In en, this message translates to:
  /// **'General Information'**
  String get generalInfo;

  /// No description provided for @appFullDescription.
  ///
  /// In en, this message translates to:
  /// **'Mishkat Al-Hoda Pro is a comprehensive Islamic app aimed at facilitating worship and Islamic knowledge for Muslims worldwide.'**
  String get appFullDescription;

  /// No description provided for @intellectualRights.
  ///
  /// In en, this message translates to:
  /// **'Intellectual Rights'**
  String get intellectualRights;

  /// No description provided for @copyProhibition.
  ///
  /// In en, this message translates to:
  /// **'• Copying or distributing content without prior permission is prohibited'**
  String get copyProhibition;

  /// No description provided for @contentSource.
  ///
  /// In en, this message translates to:
  /// **'• Islamic content from reliable sources'**
  String get contentSource;

  /// No description provided for @designProtection.
  ///
  /// In en, this message translates to:
  /// **'• App design and programming are protected by copyright'**
  String get designProtection;

  /// No description provided for @legalInformation.
  ///
  /// In en, this message translates to:
  /// **'Legal Information'**
  String get legalInformation;

  /// No description provided for @dataCollection.
  ///
  /// In en, this message translates to:
  /// **'Data Collection'**
  String get dataCollection;

  /// No description provided for @locationDataCollect.
  ///
  /// In en, this message translates to:
  /// **'• We collect location data to provide accurate prayer times'**
  String get locationDataCollect;

  /// No description provided for @accountDataStorage.
  ///
  /// In en, this message translates to:
  /// **'• Account data is securely stored for backup'**
  String get accountDataStorage;

  /// No description provided for @noDataSharing.
  ///
  /// In en, this message translates to:
  /// **'• We do not share your personal data with third parties'**
  String get noDataSharing;

  /// No description provided for @guestData.
  ///
  /// In en, this message translates to:
  /// **'Guest Data'**
  String get guestData;

  /// No description provided for @guestUsage.
  ///
  /// In en, this message translates to:
  /// **'• The app can be used as a guest without registration'**
  String get guestUsage;

  /// No description provided for @localStorage.
  ///
  /// In en, this message translates to:
  /// **'• Guest data is stored locally on your device only'**
  String get localStorage;

  /// No description provided for @accountConversion.
  ///
  /// In en, this message translates to:
  /// **'• You can convert to a registered account at any time'**
  String get accountConversion;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @sslEncryption.
  ///
  /// In en, this message translates to:
  /// **'• We use SSL encryption for all communications'**
  String get sslEncryption;

  /// No description provided for @passwordEncryption.
  ///
  /// In en, this message translates to:
  /// **'• Passwords are stored in encrypted form'**
  String get passwordEncryption;

  /// No description provided for @dataProtection.
  ///
  /// In en, this message translates to:
  /// **'• We comply with global data protection standards'**
  String get dataProtection;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @acceptableUse.
  ///
  /// In en, this message translates to:
  /// **'Acceptable Use'**
  String get acceptableUse;

  /// No description provided for @worshipUsage.
  ///
  /// In en, this message translates to:
  /// **'• Use the app for worship and Islamic knowledge purposes'**
  String get worshipUsage;

  /// No description provided for @respectIntellectualProperty.
  ///
  /// In en, this message translates to:
  /// **'• Respect intellectual property rights of content'**
  String get respectIntellectualProperty;

  /// No description provided for @complyWithLaws.
  ///
  /// In en, this message translates to:
  /// **'• Comply with local and international laws'**
  String get complyWithLaws;

  /// No description provided for @restrictions.
  ///
  /// In en, this message translates to:
  /// **'Restrictions'**
  String get restrictions;

  /// No description provided for @illegalUsageProhibition.
  ///
  /// In en, this message translates to:
  /// **'• Use of the app for illegal purposes is not allowed'**
  String get illegalUsageProhibition;

  /// No description provided for @copyModifyProhibition.
  ///
  /// In en, this message translates to:
  /// **'• Copying or modifying content without permission is prohibited'**
  String get copyModifyProhibition;

  /// No description provided for @respectfulEnvironment.
  ///
  /// In en, this message translates to:
  /// **'• Maintain a respectful usage environment'**
  String get respectfulEnvironment;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @appInquiry.
  ///
  /// In en, this message translates to:
  /// **'Inquiry about Mishkat Al-Hoda App'**
  String get appInquiry;

  /// No description provided for @welcomeQuestions.
  ///
  /// In en, this message translates to:
  /// **'We welcome your questions and inquiries about the app'**
  String get welcomeQuestions;

  /// No description provided for @lastUpdate.
  ///
  /// In en, this message translates to:
  /// **'Last Update: December 10, 2025'**
  String get lastUpdate;

  /// No description provided for @compatibility.
  ///
  /// In en, this message translates to:
  /// **'Compatible with: iOS 13+ / Android 8+'**
  String get compatibility;

  /// No description provided for @quranDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete Quran reading with interpretation and recitation'**
  String get quranDescription;

  /// No description provided for @hadithsDescription.
  ///
  /// In en, this message translates to:
  /// **'Collection of authentic hadiths with explanation and classification'**
  String get hadithsDescription;

  /// No description provided for @azkarAndDua.
  ///
  /// In en, this message translates to:
  /// **'Azkar & Supplications'**
  String get azkarAndDua;

  /// No description provided for @azkarDescription.
  ///
  /// In en, this message translates to:
  /// **'Morning and evening remembrances and traditional supplications'**
  String get azkarDescription;

  /// No description provided for @allahNamesDescription.
  ///
  /// In en, this message translates to:
  /// **'Learn the Beautiful Names of Allah with meanings and virtues'**
  String get allahNamesDescription;

  /// No description provided for @khatmaTracker.
  ///
  /// In en, this message translates to:
  /// **'Khatma Tracker'**
  String get khatmaTracker;

  /// No description provided for @khatmaDescription.
  ///
  /// In en, this message translates to:
  /// **'Track your progress in completing the Quran'**
  String get khatmaDescription;

  /// No description provided for @prayerTimes.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get prayerTimes;

  /// No description provided for @prayerTimesDescription.
  ///
  /// In en, this message translates to:
  /// **'Accurate prayer times for your location'**
  String get prayerTimesDescription;

  /// No description provided for @mosquesDescription.
  ///
  /// In en, this message translates to:
  /// **'Discover mosques near your location'**
  String get mosquesDescription;

  /// No description provided for @islamicAudio.
  ///
  /// In en, this message translates to:
  /// **'Islamic Audio'**
  String get islamicAudio;

  /// No description provided for @audioDescription.
  ///
  /// In en, this message translates to:
  /// **'Quran, speeches, and lecture audios'**
  String get audioDescription;

  /// No description provided for @liveBroadcast.
  ///
  /// In en, this message translates to:
  /// **'Live Broadcast'**
  String get liveBroadcast;

  /// No description provided for @broadcastDescription.
  ///
  /// In en, this message translates to:
  /// **'Watch live broadcast from the Grand Mosque in Mecca'**
  String get broadcastDescription;

  /// No description provided for @assistantDescription.
  ///
  /// In en, this message translates to:
  /// **'Islamic-style answers to your questions'**
  String get assistantDescription;

  /// No description provided for @zakatDescription.
  ///
  /// In en, this message translates to:
  /// **'Calculate your Zakat accurately and easily'**
  String get zakatDescription;

  /// No description provided for @dateConverterDescription.
  ///
  /// In en, this message translates to:
  /// **'Convert between Hijri and Gregorian dates'**
  String get dateConverterDescription;

  /// No description provided for @noProductsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No products available currently'**
  String get noProductsAvailable;

  /// No description provided for @mostSaving.
  ///
  /// In en, this message translates to:
  /// **'Most Saving'**
  String get mostSaving;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: Delete Account'**
  String get deleteAccountWarning;

  /// No description provided for @areYouSureDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account?'**
  String get areYouSureDeleteAccount;

  /// No description provided for @deleteAccountConsequences.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Account Deletion Consequences:'**
  String get deleteAccountConsequences;

  /// No description provided for @allPersonalDataDeleted.
  ///
  /// In en, this message translates to:
  /// **'All your personal data will be deleted'**
  String get allPersonalDataDeleted;

  /// No description provided for @activeSubscriptionCancelled.
  ///
  /// In en, this message translates to:
  /// **'Active subscription will be cancelled'**
  String get activeSubscriptionCancelled;

  /// No description provided for @actionCannotUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone'**
  String get actionCannotUndone;

  /// No description provided for @needNewAccountToUseApp.
  ///
  /// In en, this message translates to:
  /// **'You will need to create a new account to use the app'**
  String get needNewAccountToUseApp;

  /// No description provided for @deleteAccountSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get deleteAccountSuccess;

  /// No description provided for @deleting.
  ///
  /// In en, this message translates to:
  /// **'Deleting...'**
  String get deleting;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountAndAssociatedData.
  ///
  /// In en, this message translates to:
  /// **'Delete your account and associated data'**
  String get deleteAccountAndAssociatedData;

  /// No description provided for @ofLabel.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get ofLabel;

  /// No description provided for @directionsApiError.
  ///
  /// In en, this message translates to:
  /// **'Error getting directions'**
  String get directionsApiError;

  /// No description provided for @quranFeatures.
  ///
  /// In en, this message translates to:
  /// **'Holy Quran'**
  String get quranFeatures;

  /// No description provided for @hadithFeatures.
  ///
  /// In en, this message translates to:
  /// **'Hadiths'**
  String get hadithFeatures;

  /// No description provided for @azkarFeatures.
  ///
  /// In en, this message translates to:
  /// **'Azkar & Duas'**
  String get azkarFeatures;

  /// No description provided for @allahNamesFeatures.
  ///
  /// In en, this message translates to:
  /// **'Names of Allah'**
  String get allahNamesFeatures;

  /// No description provided for @khatmaFeatures.
  ///
  /// In en, this message translates to:
  /// **'Khatma Tracking'**
  String get khatmaFeatures;

  /// No description provided for @prayerFeatures.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times & Qibla'**
  String get prayerFeatures;

  /// No description provided for @mosqueFeatures.
  ///
  /// In en, this message translates to:
  /// **'Nearby Mosques'**
  String get mosqueFeatures;

  /// No description provided for @audioFeatures.
  ///
  /// In en, this message translates to:
  /// **'Islamic Audio'**
  String get audioFeatures;

  /// No description provided for @broadcastFeatures.
  ///
  /// In en, this message translates to:
  /// **'Live Broadcast'**
  String get broadcastFeatures;

  /// No description provided for @assistantFeatures.
  ///
  /// In en, this message translates to:
  /// **'Smart Assistant'**
  String get assistantFeatures;

  /// No description provided for @zakatFeatures.
  ///
  /// In en, this message translates to:
  /// **'Zakat Calculator'**
  String get zakatFeatures;

  /// No description provided for @dateFeatures.
  ///
  /// In en, this message translates to:
  /// **'Date Converter'**
  String get dateFeatures;

  /// No description provided for @subscriptionFeatures.
  ///
  /// In en, this message translates to:
  /// **'Premium Subscription'**
  String get subscriptionFeatures;

  /// No description provided for @hijriToGregorianResult.
  ///
  /// In en, this message translates to:
  /// **'Gregorian: {gregorianDate}\nHijri: {hijriDate}'**
  String hijriToGregorianResult(String hijriDate, String gregorianDate);

  /// No description provided for @ayahsRangeText.
  ///
  /// In en, this message translates to:
  /// **'Ayah {start} - {end}'**
  String ayahsRangeText(Object start, Object end);

  /// No description provided for @pagesCountText.
  ///
  /// In en, this message translates to:
  /// **'{count} Pages'**
  String pagesCountText(Object count);

  /// No description provided for @inviteLink.
  ///
  /// In en, this message translates to:
  /// **'Invite Link: {link}'**
  String inviteLink(Object link);

  /// No description provided for @featureRemoveAds.
  ///
  /// In en, this message translates to:
  /// **'Remove Ads'**
  String get featureRemoveAds;

  /// No description provided for @featureUnlockReciters.
  ///
  /// In en, this message translates to:
  /// **'Unlock All Reciters'**
  String get featureUnlockReciters;

  /// No description provided for @featureDownloadContent.
  ///
  /// In en, this message translates to:
  /// **'Download Content'**
  String get featureDownloadContent;

  /// No description provided for @noNearbyRestaurantsInRange.
  ///
  /// In en, this message translates to:
  /// **'No halal restaurants nearby'**
  String get noNearbyRestaurantsInRange;

  /// No description provided for @pleaseWaitForRestaurantsToLoad.
  ///
  /// In en, this message translates to:
  /// **'Please wait while restaurant data is loading'**
  String get pleaseWaitForRestaurantsToLoad;

  /// No description provided for @hajjAndUmrahGuide.
  ///
  /// In en, this message translates to:
  /// **'Hajj & Umrah Guide'**
  String get hajjAndUmrahGuide;

  /// No description provided for @zakatTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount: {amount}'**
  String zakatTotalAmount(Object amount);

  /// No description provided for @zakatDueAmount.
  ///
  /// In en, this message translates to:
  /// **'Zakat Due: {amount} (2.5%)'**
  String zakatDueAmount(Object amount);

  /// No description provided for @zakatBelowNisaab.
  ///
  /// In en, this message translates to:
  /// **'Likely no Zakat is due as the amount is below Nisaab ({nisaab}). Please consult a scholar.'**
  String zakatBelowNisaab(Object nisaab);

  /// No description provided for @zakatNisaabAlert.
  ///
  /// In en, this message translates to:
  /// **'\n\n* Alert: Nisaab check skipped (Gold price missing).'**
  String get zakatNisaabAlert;

  /// No description provided for @zakatIntroduction.
  ///
  /// In en, this message translates to:
  /// **'No significant amount entered.'**
  String get zakatIntroduction;

  /// No description provided for @weatherThunderTitle.
  ///
  /// In en, this message translates to:
  /// **'Thunder Supplication'**
  String get weatherThunderTitle;

  /// No description provided for @weatherThunderBody.
  ///
  /// In en, this message translates to:
  /// **'Glory be to Him whom thunder praises with His praise, and the angels from the fear of Him.'**
  String get weatherThunderBody;

  /// No description provided for @weatherRainTitle.
  ///
  /// In en, this message translates to:
  /// **'Rain Supplication'**
  String get weatherRainTitle;

  /// No description provided for @weatherRainBody.
  ///
  /// In en, this message translates to:
  /// **'O Allah, (make it) a beneficial downpour.'**
  String get weatherRainBody;

  /// No description provided for @weatherWindTitle.
  ///
  /// In en, this message translates to:
  /// **'Wind Supplication'**
  String get weatherWindTitle;

  /// No description provided for @weatherWindBody.
  ///
  /// In en, this message translates to:
  /// **'O Allah, I ask You for the good of it, and the good of what it contains, and the good of what it is sent with. I seek refuge in You from the evil of it, and the evil of what it contains, and the evil of what it is sent with.'**
  String get weatherWindBody;

  /// No description provided for @weatherHeatTitle.
  ///
  /// In en, this message translates to:
  /// **'Severe Heat Supplication'**
  String get weatherHeatTitle;

  /// No description provided for @weatherHeatBody.
  ///
  /// In en, this message translates to:
  /// **'La ilaha illa Allah, how hot is this day! O Allah, protect me from the heat of Hellfire.'**
  String get weatherHeatBody;

  /// No description provided for @weatherColdTitle.
  ///
  /// In en, this message translates to:
  /// **'Severe Cold Supplication'**
  String get weatherColdTitle;

  /// No description provided for @weatherColdBody.
  ///
  /// In en, this message translates to:
  /// **'La ilaha illa Allah, how cold is this day! O Allah, protect me from the bitter cold of Hellfire.'**
  String get weatherColdBody;

  /// No description provided for @umrahRituals.
  ///
  /// In en, this message translates to:
  /// **'Umrah Rituals'**
  String get umrahRituals;

  /// No description provided for @hajjRituals.
  ///
  /// In en, this message translates to:
  /// **'Hajj Rituals'**
  String get hajjRituals;

  /// No description provided for @stepsLabel.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get stepsLabel;

  /// No description provided for @supplicationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Supplications'**
  String get supplicationsLabel;

  /// No description provided for @stageCompletedLabel.
  ///
  /// In en, this message translates to:
  /// **'Stage Completed'**
  String get stageCompletedLabel;

  /// No description provided for @islamicCalendar.
  ///
  /// In en, this message translates to:
  /// **'Islamic Calendar'**
  String get islamicCalendar;

  /// No description provided for @hijriCalendar.
  ///
  /// In en, this message translates to:
  /// **'Hijri'**
  String get hijriCalendar;

  /// No description provided for @gregorianCalendar.
  ///
  /// In en, this message translates to:
  /// **'Gregorian'**
  String get gregorianCalendar;

  /// No description provided for @islamicEvents.
  ///
  /// In en, this message translates to:
  /// **'Islamic Events'**
  String get islamicEvents;

  /// No description provided for @eventRamadanStart.
  ///
  /// In en, this message translates to:
  /// **'Ramadan Start'**
  String get eventRamadanStart;

  /// No description provided for @eventLaylatAlQadr.
  ///
  /// In en, this message translates to:
  /// **'Laylat al-Qadr'**
  String get eventLaylatAlQadr;

  /// No description provided for @eventEidAlFitr.
  ///
  /// In en, this message translates to:
  /// **'Eid al-Fitr'**
  String get eventEidAlFitr;

  /// No description provided for @eventHajj.
  ///
  /// In en, this message translates to:
  /// **'Hajj'**
  String get eventHajj;

  /// No description provided for @eventEidAlAdha.
  ///
  /// In en, this message translates to:
  /// **'Eid al-Adha'**
  String get eventEidAlAdha;

  /// No description provided for @eventAlHijra.
  ///
  /// In en, this message translates to:
  /// **'Islamic New Year'**
  String get eventAlHijra;

  /// No description provided for @eventAshura.
  ///
  /// In en, this message translates to:
  /// **'Ashura'**
  String get eventAshura;

  /// No description provided for @eventMawlidAlNabi.
  ///
  /// In en, this message translates to:
  /// **'Mawlid al-Nabi'**
  String get eventMawlidAlNabi;

  /// No description provided for @eventLaylatAlMiraj.
  ///
  /// In en, this message translates to:
  /// **'Laylat al-Miraj'**
  String get eventLaylatAlMiraj;

  /// No description provided for @eventLaylatAlBaraat.
  ///
  /// In en, this message translates to:
  /// **'Laylat al-Baraat'**
  String get eventLaylatAlBaraat;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'bn', 'de', 'en', 'es', 'fa', 'fr', 'id', 'ms', 'tr', 'ur', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'bn': return AppLocalizationsBn();
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fa': return AppLocalizationsFa();
    case 'fr': return AppLocalizationsFr();
    case 'id': return AppLocalizationsId();
    case 'ms': return AppLocalizationsMs();
    case 'tr': return AppLocalizationsTr();
    case 'ur': return AppLocalizationsUr();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
