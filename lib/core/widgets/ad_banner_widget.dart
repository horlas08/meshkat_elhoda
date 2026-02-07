import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../features/subscription/presentation/bloc/subscription_bloc.dart';
import '../../../features/subscription/presentation/bloc/subscription_state.dart';
import '../services/admob_service.dart';

/// Widget لعرض إعلان بانر للمستخدمين المجانيين فقط
/// يتحقق تلقائياً من حالة الاشتراك ويعرض الإعلان فقط للمستخدمين المجانيين
class AdBannerWidget extends StatefulWidget {
  /// حجم الإعلان (افتراضي: banner عادي)
  final AdSize adSize;

  /// استخدام Adaptive Banner (يتكيف مع عرض الشاشة)
  final bool useAdaptiveBanner;

  /// المسافة الداخلية حول الإعلان
  final EdgeInsetsGeometry padding;

  /// لون الخلفية
  final Color? backgroundColor;

  /// إظهار حد حول الإعلان
  final bool showBorder;

  /// لون الحد
  final Color borderColor;

  const AdBannerWidget({
    super.key,
    this.adSize = AdSize.banner,
    this.useAdaptiveBanner = true,
    this.padding = const EdgeInsets.symmetric(vertical: 8.0),
    this.backgroundColor,
    this.showBorder = false,
    this.borderColor = Colors.grey,
  });

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isAdFailed = false;
  bool _isInitialized = false;
  final AdMobService _adMobService = AdMobService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // تحميل الإعلان مرة واحدة فقط
    if (!_isInitialized) {
      _isInitialized = true;
      _initializeAd();
    }
  }

  Future<void> _initializeAd() async {
    // التأكد من تهيئة AdMob
    if (!_adMobService.isInitialized) {
      try {
        await _adMobService.initialize();
      } catch (e) {
        if (mounted) {
          setState(() {
            _isAdFailed = true;
          });
        }
        return;
      }
    }

    // تحميل الإعلان
    _loadAd();
  }

  Future<void> _loadAd() async {
    if (widget.useAdaptiveBanner) {
      // استخدام Adaptive Banner
      final width = MediaQuery.of(context).size.width.toInt();
      _bannerAd = await _adMobService.createAdaptiveBannerAd(
        width: width,
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
              _isAdFailed = false;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
              _isAdFailed = true;
            });
          }
        },
      );
    } else {
      // استخدام Banner عادي
      _bannerAd = _adMobService.createBannerAd(
        adSize: widget.adSize,
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
              _isAdFailed = false;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
              _isAdFailed = true;
            });
          }
        },
      );
    }

    // تحميل الإعلان
    await _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        // التحقق فيما إذا كان المستخدم مشتركاً (Premium)
        // الافتراضي هو false (مجاني) حتى يثبت العكس
        bool isPremium = false;
        if (state is SubscriptionLoaded) {
          isPremium = state.subscription.isPremium;
        }

        // إذا كان المستخدم Premium، لا نعرض الإعلان
        if (isPremium) {
          return const SizedBox.shrink();
        }

        // إذا فشل تحميل الإعلان، لا نعرض شيء
        if (_isAdFailed || _bannerAd == null) {
          return const SizedBox.shrink();
        }

        // إذا لم يتم تحميل الإعلان بعد، نعرض مساحة فارغة بنفس الارتفاع
        if (!_isAdLoaded) {
          return Padding(
            padding: widget.padding,
            child: SizedBox(
              height: widget.adSize.height.toDouble(),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        // عرض الإعلان
        return Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            border: widget.showBorder
                ? Border.all(color: widget.borderColor, width: 1)
                : null,
          ),
          child: Center(
            child: SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
          ),
        );
      },
    );
  }
}
