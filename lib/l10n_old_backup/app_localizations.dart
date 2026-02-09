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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
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
    Locale('zh'),
  ];

  String get allAzkar;
  String get azkarAndDuas;
  String get startYourAzkar;
  String get seeMore;
  String get favoriteAzkar;
  String get errorLoadingAzkar;

  // Azkar Details & Actions
  String get copyZekrSuccess;
  String get addToFavoritesSuccess;
  String get removeFromFavorites;
  String get zekrCopied;
  String get zekrShared;

  // Subscription Messages
  String get premiumOnlyFeature;
  String get subscribeToUnlock;
  String get lockedAzkarMessage;

  // Search & Filters
  String get searchResults;

  // Controls
  String get zoomIn;
  String get zoomOut;

  // Categories
  String get morningEveningAzkar;
  String get sleepAzkar;
  String get afterPrayerAzkar;
  String get morningAzkar;
  String get eveningAzkar;

  // Errors
  String get loadDataError;
  String get shareError;

  // Assistant Page
  String get assistantAppBarTitle;
  String get createNewChat;
  String get aiModelSelection;
  String get retryButton;
  String get creatingNewChatMessage;
  String get noActiveChatMessage;
  String get startNewChatMessage;
  String get pleaseWait;
  String get typingIndicator;

  // Subscription/Limit Messages
  String get dailyLimitReachedTitle;
  String get dailyLimitReachedMessage;
  String get upgradeToPremiumButton;
  String get featureAvailableForPremium;
  String get premiumFeatureTitle;
  String get premiumFeatureContent;
  String get okButton;
  String get upgradeNowButton;
  String get laterButton;
  String get questionsRemaining;

  // Model Selection
  String get chooseAiModelTitle;
  String get gpt4oMiniTitle;
  String get gpt4oMiniSubtitle;
  String get gpt4oTitle;
  String get gpt4oSubtitle;

  // Chat List Drawer
  String get conversationsTitle;
  String get newConversation;
  String get noConversationsMessage;
  String get newChatCreationMessage;

  // Time Formatting
  String get dayAgo;
  String get hourAgo;
  String get minuteAgo;
  String get now;

  // Input Bar
  String get typeMessageHint;
  String get pleaseWaitHint;

  String get emailLabel;
  String get emailRequiredError;
  String get passwordLabel;
  String get passwordRequiredError;
  String get loginButton;
  String get alreadyHaveAccount;
  String get createAccountLink;

  // Register Screen
  String get nameLabel;
  String get nameRequiredError;
  String get emailLabelRegister;
  String get emailRequiredErrorRegister;
  String get passwordLabelRegister;
  String get passwordRequiredErrorRegister;
  String get passwordMinLengthError;
  String get confirmPasswordLabel;
  String get confirmPasswordRequiredError;
  String get passwordsMismatchError;
  String get createAccountButton;
  String get orText;
  String get loginAsGuestButton;
  String get loginLinkText;
  String get noAccountText;
  String get countryLabel;
  String get searchHint;

  // Common
  String get loginSuccessMessage;
  String get guestLoginSuccessMessage;
  String get registerSuccessMessage;
  String get errorOccurred;

  // Auth Errors (يمكن إضافتها حسب الحاجة)
  String get invalidEmailError;
  String get userNotFoundError;
  String get wrongPasswordError;
  String get emailAlreadyInUseError;
  String get weakPasswordError;
  String get networkError;

  // Bookmarks Screen
  String get bookmarksTitle;
  String get deleteBookmarkSuccess;
  String get deleteBookmarkConfirmation;
  String get areYouSureDelete;
  String get cancel;
  String get delete;
  String get retry;
  String get noBookmarks;
  String get noBookmarksDescription;
  String get addBookmarkFromReading;

  // Add Bookmark Dialog
  String get addBookmarkTitle;
  String get verse;
  String get addNote;
  String get writeNoteHere;
  String get save;

  // Bookmark Card
  String get verseNumber;
  String get today;
  String get yesterday;
  String get daysAgo;
  String get weekAgo;
  String get weeksAgo;
  String get monthAgo;
  String get monthsAgo;
  String get yearAgo;
  String get yearsAgo;

  // Errors
  String get deleteBookmarkError;
  String get loadBookmarksError;

  // Error Messages
  String get tryAgain;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Mishkat Al-Hoda'**
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

  /// No description provided for @favoriteAzkarToast.
  ///
  /// In en, this message translates to:
  /// **'To praise your favorite Azkar'**
  String get favoriteAzkarToast;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

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

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

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

  /// No description provided for @ayahOptionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get ayahOptionLanguage;

  /// No description provided for @ayahOptionShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get ayahOptionShare;

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

  // New keys added manually with default English values
  String get worshipSectionTitle;
  String get prayerGuideSectionTitle;
  String get islamicServicesSectionTitle;
  String get hadiths;
  String get allahNames;
  String get ramadanFeatures;
  String get prayerAndQibla;
  String get locationAndMosques;
  String get audio;
  String get zakatCalculator;
  String get chatList;
  String get class_;
  String get premiumBookMessage;
  String get upgrade;
  String get selectBook;
  String get noHadithsAvailable;
  String get by;
  String get days;
  // searchResults is already defined around line 141
  String get ofWord;
  // hadithLoadError is already defined around line 1035
  String get hadithCopied;
  String get hadithRemovedFromFavorites;
  String get hadithAddedToFavorites;
  String get narrator;
  String get shareHadithText;
  String get scholarsEvaluation;
  String get hadithDetails;
  String get collectiveKhatma;

  String get ramadanMubarakFull;

  // Missing keys from Islamic Grid View and Hadith Details
  String get quranKareem;
  String get azkarAndAdiyah;
  String get khatma;
  String get liveBroadcastAndHaram;
  String get smartAssistant;
  String get maxZoom;

  // Restore 'off' to satisfy overrides in generated files, pointing to ofWord
  String get off => ofWord;

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
  String get ramadanKarim;
  String get todayDuaaHeader;
  String get greetYourLovedOnes;
  String get quranKarem;
  String get ramadanKarimGreeting;
  String get ramadanWirdCalculatorTitle;
  String get khatmaCountHint;
  String get khatmaCountExceededMessage;
  String get dailyWirdHeader;
  String get dailyAjzaaLabel;
  String get dailyPagesLabel;
  String get goToMushafButton;
  String get collectiveKhatmas;
  String get myKhatmas;
  String get joinByLink;
  String get searchKhatmaHint;
  String get createKhatma;
  String get loginRequiredMessage;
  String get loginToJoinMessage;
  String get noKhatmasAvailable;
  String get beFirstToCreate;
  String get createNewKhatma;
  String get joinByLinkTitle;
  String get pasteLinkHint;
  String get fetchKhatma;
  String get joinError;
  String get createKhatmaTitle;
  String get khatmaTitleLabel;
  String get khatmaTitleExample;
  String get khatmaTitleRequired;
  String get khatmaTypeLabel;
  String get public;
  String get publicDescription;
  String get private;
  String get privateDescription;
  String get dateRangeLabel;
  String get startDate;
  String get endDate;
  String get khatmaDuration;
  String get khatmaCreatedSuccess;
  String get khatmaDetails;
  String get copyLink;
  String get deleteKhatma;
  String get partReservedSuccess;
  String get partCompletedSuccess;
  String get deleteConfirmationTitle;
  String get deleteConfirmationMessage;
  String get reserveThisPart;
  String get completeThisPart;
  String get alreadyReservedPart;
  String get linkCopied;
  String get myCollectiveKhatmas;
  String get joinedKhatmasTab;
  String get createdKhatmasTab;
  String get noJoinedKhatmas;
  String get findAndJoinKhatma;
  String get participatedKhatmas;
  String get completedParts;
  String get noCreatedKhatmas;
  String get startCreatingKhatma;
  String get partNumber;
  String get completedStatus;
  String get inProgressStatus;
  String get publicType;
  String get privateType;
  String get createdBy;
  String get participants;
  String get completed;
  String get daysRemaining;
  String get completion;
  String get completedPartsLabel;
  String get reservedParts;
  String get availableParts;
  String get khatmaCompleted;
  String get availableForReservation;
  String get reservedForUser;
  String get partCompletedStatus;
  String get partCompleted;
  String get reserved;
  String get yourPart;
  String get available;
  String get confirmation;
  String get deleteAllConfirmation;
  String get deleteAll;
  String get favorites;
  String get deleteAllTooltip;
  String get hadithLoadError;
  String get noFavorites;
  String get deleteFromFavoritesTooltip;
  String get favoriteItemDescription;

  // Quran Audio
  String get quranAudio;
  String get quranRecitations;
  String get quranRecitationsDesc;
  String get quranRadio;
  String get quranRadioDesc;
  String get downloadedAudio;
  String get downloadedAudioDesc;
  String get reciters;
  String get searchRecitersHint;
  String get noResultsFound;
  String get reciterPremiumOnly;
  String get surahsCount;
  String get surahs;
  String get ayahsCount;
  String get noDownloadedAudio;
  String get deleteAudioTitle;
  String get deleteAudioConfirm;
  String get noStationsAvailable;
  String get liveRadio;
  String get offlineRadio;
  String get audioPlayer;
  String get downloadSuccess;
  String get fileAlreadyDownloaded;
  String get skipBack15s;
  String get skipForward15s;
  String get pause;
  String get play;
  String get playing;
  String get playbackCompleted;
  String get surahIndex;
  String get replay;
  String get audioLoadingError;
  // Hadith Details & Grades
  String get gradeLabel;
  String get scholarLabel;
  String get gradeSahih;
  String get gradeHasan;
  String get gradeDaif;
  String get gradeMawdu;
  String get gradeMaqbul;
  String get gradeEvaluation;

  // Navigation
  String get next;
  String get previous;

  // Hadith Info
  String get sourceLabel;
  String get hadithGradeLabel;

  // Hadith Books
  String get bookBukhari;
  String get bookMuslim;
  String get bookAbuDawud;
  String get bookTirmidhi;
  String get bookNasai;
  String get bookIbnMajah;
  String get bookMalik;
  String get bookNawawi;
  String get bookQudsi;
  String get bookDehlawi;

  // Qibla Direction
  String get qiblaDirection;
  String get locatingYourPosition;
  String get errorCalculatingQibla;
  String get compassAccessError;
  String get locationServicesDisabled;
  String get locationPermissionPermanentlyDenied;
  String get qiblaAngleFromNorth;
  String get facingQiblaNow;
  String get qibla;

  // New User Requested Keys - Qibla
  String get locationPermissionDeniedForeverTitle;
  String get errorCalculatingQiblaDirection;
  String get errorAccessingCompass;
  String get qiblaDirectionFromNorth;
  String get youAreFacingTheQibla;

  // Date Converter
  String get dateConverter;
  String get gregorianToHijri;
  String get pickGregorianDate;
  String get errorConvertingGregorianToHijri;
  String get hijriToGregorian;
  String get enterHijriDateHint;
  String get hijriDateExample;
  String get convert;
  String get dateHijriLabel;
  String get dateGregorianLabel;
  String get errorConvertingHijriToGregorian;

  // New User Requested Keys - Date Converter
  String get selectGregorianDate;
  String get enterHijriDate;
  String get errorConvertingHijriDate;
  String hijriToGregorianResult(String hijriDate, String gregorianDate);
  String get haramLiveTitle;
  String get chooseChannel;
  String get makkah;
  String get saudiChannel;
  String get quranChannel;
  String get madinah;
  String get madinahChannel;
  String get liveStreamTitle;
  String get initializing;
  String get loadingStream;
  String get playingStream;
  String get clickToPlay;
  String get openInBrowser;
  String get openInBrowserDescription;
  String get open;
  String get streamLoadFailed;
  String get retryAttempt;
  String get reload;
  String get importantNotice;
  String get copyrightNotice;
  String get copyrightRights;

  String get locationSettingsTitle;
  String get unknown;
  String get regionLabel;
  String get autoRefreshLocation;
  String get updating;
  String get refreshLocationNow;
  String get locationUpdatedSuccessfully;

  // Bottom Navigation
  String get home;
  String get settings;

  // Tasbeh View
  String get rememberAllah;
  String get rememberAllahDescription;
  String get mustLoginFirst;
  String get savedSuccessfully;
  String get saveFailed;
  String get subhanAllah;
  String get errorLoadingTasbehData;
  String get errorLoadingCounter;
  String get errorSavingTasbeh;
  String get errorSavingSelectedZikr;
  String get errorResettingCounter;

  String get notificationsTitle;
  String get athanNotification;
  String get preAthanNotification;
  String get khushooMode;
  String get collectiveKhatmaNotifications;
  String get remindMeOfAllah;
  String get minute;
  String get halfHour;
  String get hour;
  String get twoHours;
  String get premiumFeature;
  String get premiumFeatureDescription;
  String get upgradeNow;

  String get prayersAndMuezzinsTitle;
  String get selectMuezzin;
  String get notSpecified;
  String get playAthanSound;
  String get selectMuezzinDialogTitle;
  String get noRecitersAvailable;
  String get chooseFavoriteMuezzin;
  String get muezzinSelected;
  String get selectMuezzinFirst;
  String get playingMuezzinSound;

  String get quranSettingsTitle;
  String get favoriteTafsir;
  String get favoriteReciter;
  String get notAvailable;
  String get chooseTafsir;
  String get chooseReciter;
  String get notAvailableEnglish;
  String get settingsLoadError;
  String get generalTitle;
  String get language;
  String get arabic;
  String get english;
  String get french;
  String get indonesian;
  String get urdu;
  String get turkish;
  String get bengali;
  String get malay;
  String get persian;
  String get spanish;
  String get german;
  String get chinese;
  String get chooseLanguage;
  String get rateApp;
  String get aboutApp;
  String get privacyPolicy;
  String get updatingLanguage;
  String get languageUpdateError;

  String get appearanceTitle;
  String get darkMode;
  String get lightMode;
  String get alhamdulillah;
  String get allahuAkbar;
  String get laIlahaIllallah;
  String get astaghfirullah;
  String get reset;
  String get saving;

  String get accountAndSubscription;
  String get monthlySubscription;
  String get yearlySubscription;
  String get premiumSubscription;
  String get freeSubscription;
  String get accountStatus;
  String get expiresOn;
  String get manageSubscription;
  String get upgradeAccount;
  String get manage;
  String get subscribe;

  String get zakatDisclaimer;
  String get totalCash;
  String get doYouOwnGold;
  String get goldValue;
  String get goldGrams;
  String get gold24kPrice;
  String get requiredForNisaab;
  String get requiredForGoldValue;
  String get tradeValue;
  String get enableNisaab;
  String get calculateZakat;
  String get fieldRequired;
  String get enterValidNumber;

  String get licensedBroadcast;
  String get chooseKhatmaCount;
  String get chooseKhatmaCountHint;
  String get pagesPerDay;
  String get juzPerDay;
  String get hideSchedule;
  String get showDetailedSchedule;
  String get dayColumn;
  String get pagesColumn;
  String get surahsColumn;
  String pagesCountText(int count);

  String get yourDailyWird;
  String ayahsRangeText(int start, int end);
  String get pageNumber;
  String get currentJuz;
  String get readJuz;
  String get remainingPages;
  String get todayProgress;
  String get pagesUnit;
  String get khatmaPercentage;
  String get khatmaTrackingNote;
  String get continueReading;
  String get liveNow;
  String get nearbyMosques;
  String get pleaseWaitForMosquesToLoad;
  String get showOnMap;
  String get updateLocation;
  String get noNearbyMosquesInRange;
  String get map;
  String get myCurrentLocation;
  String get directions;
  String get openInMaps;
  String directionsApiError(String status, String errorMessage);

  String get benefits;
  String get explanation;
  String get forgotPassword;
  String get forgotPasswordTitle;
  String get forgotPasswordDescription;
  String get sendResetLink;
  String get backToLogin;
  String get checkSpamMessage;

  String get copyrightHadithNotice;
  String get wordsMeaning;
  String get aiGeneratedAnswersNeedReview;
  String get fourHours;

  String get appName;
  String get appDescription;
  String get version;
  String get mainFeatures;
  String get aboutAndRights;
  String get generalInfo;
  String get appFullDescription;
  String get intellectualRights;
  String get copyProhibition;
  String get contentSource;
  String get designProtection;
  String get legalInformation;
  String get dataCollection;
  String get locationDataCollect;
  String get accountDataStorage;
  String get noDataSharing;
  String get guestData;
  String get guestUsage;
  String get localStorage;
  String get accountConversion;
  String get security;
  String get sslEncryption;
  String get passwordEncryption;
  String get dataProtection;
  String get termsOfUse;
  String get acceptableUse;
  String get worshipUsage;
  String get respectIntellectualProperty;
  String get complyWithLaws;
  String get restrictions;
  String get illegalUsageProhibition;
  String get copyModifyProhibition;
  String get respectfulEnvironment;
  String get contactUs;
  String get appInquiry;
  String get welcomeQuestions;
  String get lastUpdate;
  String get compatibility;

  // وصف المميزات فقط
  String get quranDescription;
  String get hadithsDescription;
  String get azkarAndDua;
  String get azkarDescription;
  String get allahNamesDescription;
  String get khatmaTracker;
  String get khatmaDescription;
  String get prayerTimes;
  String get prayerTimesDescription;
  String get mosquesDescription;
  String get islamicAudio;
  String get audioDescription;
  String get liveBroadcast;
  String get broadcastDescription;
  String get assistantDescription;
  String get zakatDescription;
  String get dateConverterDescription;

  // قوائم المميزات
  List<String> get quranFeatures;
  List<String> get hadithFeatures;
  List<String> get azkarFeatures;
  List<String> get allahNamesFeatures;
  List<String> get khatmaFeatures;
  List<String> get prayerFeatures;
  List<String> get mosqueFeatures;
  List<String> get audioFeatures;
  List<String> get broadcastFeatures;
  List<String> get assistantFeatures;
  List<String> get zakatFeatures;
  List<String> get dateFeatures;
  List<String> get subscriptionFeatures;
  String get noProductsAvailable;
  String get mostSaving;
  String get deleteAccountWarning;
  String get areYouSureDeleteAccount;
  String get deleteAccountConsequences;
  String get allPersonalDataDeleted;
  String get activeSubscriptionCancelled;
  String get actionCannotUndone;
  String get needNewAccountToUseApp;
  String get deleteAccountSuccess;
  String get deleting;
  String get deleteAccount;
  String get deleteAccountAndAssociatedData;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'bn',
    'de',
    'en',
    'es',
    'fa',
    'fr',
    'id',
    'ms',
    'tr',
    'ur',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bn':
      return AppLocalizationsBn();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fa':
      return AppLocalizationsFa();
    case 'fr':
      return AppLocalizationsFr();
    case 'id':
      return AppLocalizationsId();
    case 'ms':
      return AppLocalizationsMs();
    case 'tr':
      return AppLocalizationsTr();
    case 'ur':
      return AppLocalizationsUr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
