import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';

/// خدمة إدارة إعلانات AdMob
/// تتعامل مع تحميل وعرض الإعلانات للمستخدمين المجانيين فقط
class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  final Logger _logger = Logger();

  // Banner Ad IDs
  static const String _bannerAdIdAndroid =
      'ca-app-pub-4204070072716559/5702555958';
  static const String _bannerAdIdIOS =
      'ca-app-pub-4204070072716559/4936157478'; // استبدل بـ iOS ID عند توفره

  // Test Ad IDs (للاختبار فقط)
  static const String _testBannerAdId =
      'ca-app-pub-3940256099942544/6300978111';

  bool _isInitialized = false;
  bool _useTestAds = false; // غير هذا إلى true للاختبار

  /// تهيئة AdMob SDK
  Future<void> initialize({bool useTestAds = false}) async {
    if (_isInitialized) {
      _logger.i('AdMob already initialized');
      return;
    }

    try {
      _useTestAds = useTestAds;
      await MobileAds.instance.initialize();
      _isInitialized = true;
      _logger.i('AdMob initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize AdMob: $e');
      rethrow;
    }
  }

  /// الحصول على Banner Ad ID المناسب للمنصة
  String get bannerAdUnitId {
    if (_useTestAds) {
      return _testBannerAdId;
    }

    if (Platform.isAndroid) {
      return _bannerAdIdAndroid;
    } else if (Platform.isIOS) {
      return _bannerAdIdIOS;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  /// إنشاء Banner Ad جديد
  /// [onAdLoaded] - callback عند تحميل الإعلان بنجاح
  /// [onAdFailedToLoad] - callback عند فشل تحميل الإعلان
  BannerAd createBannerAd({
    AdSize adSize = AdSize.banner,
    void Function(Ad ad)? onAdLoaded,
    void Function(Ad ad, LoadAdError error)? onAdFailedToLoad,
  }) {
    if (!_isInitialized) {
      throw StateError('AdMobService must be initialized before creating ads');
    }

    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          _logger.i('Banner ad loaded successfully');
          onAdLoaded?.call(ad);
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          _logger.e('Banner ad failed to load: ${error.message}');
          ad.dispose();
          onAdFailedToLoad?.call(ad, error);
        },
        onAdOpened: (Ad ad) {
          _logger.i('Banner ad opened');
        },
        onAdClosed: (Ad ad) {
          _logger.i('Banner ad closed');
        },
        onAdImpression: (Ad ad) {
          _logger.i('Banner ad impression recorded');
        },
      ),
    );
  }

  /// إنشاء Adaptive Banner Ad (يتكيف مع عرض الشاشة)
  /// [width] - عرض الشاشة المتاح
  Future<BannerAd?> createAdaptiveBannerAd({
    required int width,
    void Function(Ad ad)? onAdLoaded,
    void Function(Ad ad, LoadAdError error)? onAdFailedToLoad,
  }) async {
    if (!_isInitialized) {
      throw StateError('AdMobService must be initialized before creating ads');
    }

    try {
      final AdSize? adaptiveSize =
          await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);

      if (adaptiveSize == null) {
        _logger.e('Unable to get adaptive banner size');
        return null;
      }

      return BannerAd(
        adUnitId: bannerAdUnitId,
        size: adaptiveSize,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            _logger.i('Adaptive banner ad loaded successfully');
            onAdLoaded?.call(ad);
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            _logger.e('Adaptive banner ad failed to load: ${error.message}');
            ad.dispose();
            onAdFailedToLoad?.call(ad, error);
          },
          onAdOpened: (Ad ad) {
            _logger.i('Adaptive banner ad opened');
          },
          onAdClosed: (Ad ad) {
            _logger.i('Adaptive banner ad closed');
          },
          onAdImpression: (Ad ad) {
            _logger.i('Adaptive banner ad impression recorded');
          },
        ),
      );
    } catch (e) {
      _logger.e('Error creating adaptive banner ad: $e');
      return null;
    }
  }

  /// تحديث إعدادات الطلب (Request Configuration)
  void updateRequestConfiguration({
    List<String>? testDeviceIds,
    int? maxAdContentRating,
    bool? tagForChildDirectedTreatment,
    bool? tagForUnderAgeOfConsent,
  }) {
    final config = RequestConfiguration(
      testDeviceIds: testDeviceIds,
      tagForChildDirectedTreatment: tagForChildDirectedTreatment != null
          ? (tagForChildDirectedTreatment
                ? TagForChildDirectedTreatment.yes
                : TagForChildDirectedTreatment.no)
          : TagForChildDirectedTreatment.unspecified,
      tagForUnderAgeOfConsent: tagForUnderAgeOfConsent != null
          ? (tagForUnderAgeOfConsent
                ? TagForUnderAgeOfConsent.yes
                : TagForUnderAgeOfConsent.no)
          : TagForUnderAgeOfConsent.unspecified,
    );

    MobileAds.instance.updateRequestConfiguration(config);
    _logger.i('Request configuration updated');
  }

  /// التحقق من حالة التهيئة
  bool get isInitialized => _isInitialized;
}
