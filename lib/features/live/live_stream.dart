import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/features/quran_index/presentation/widgets/loading_widget.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:meshkat_elhoda/core/utils/app_colors.dart';
import 'package:meshkat_elhoda/core/utils/app_text_styles.dart';
import 'package:meshkat_elhoda/core/utils/size_utils.dart';
import 'package:meshkat_elhoda/core/widgets/islamic_appbar.dart';
import 'dart:developer' as developer;

class MakkahLiveStreamWebView extends StatefulWidget {
  final String url;
  final String channelName;
  final String copyrightNotice;
  final String copyrightRights;
  const MakkahLiveStreamWebView({
    super.key,
    required this.url,
    required this.channelName,
    required this.copyrightNotice,
    required this.copyrightRights,
  });

  @override
  State<MakkahLiveStreamWebView> createState() =>
      _MakkahLiveStreamWebViewState();
}

class _MakkahLiveStreamWebViewState extends State<MakkahLiveStreamWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isPlaying = false;
  String _loadingStatus = '';
  int _retryCount = 0;
  final int _maxRetries = 3;
  String _liveStreamUrl = '';

  @override
  void initState() {
    super.initState();
    _liveStreamUrl = widget.url; // ✅ تعيين الرابط أولاً
    _initializeWebView(); // ثم التهيئة
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadingStatus.isEmpty) {
      _loadingStatus = AppLocalizations.of(context)!.initializing;
    }
  }

  void _initializeWebView() {
    developer.log('🎬 بدء تحميل البث المباشر', name: 'LiveStream');
    developer.log('🔗 الرابط: $_liveStreamUrl', name: 'LiveStream');

    final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            developer.log('🚀 بدء تحميل الصفحة: $url', name: 'LiveStream');
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
                _loadingStatus = AppLocalizations.of(context)!.loadingStream;
              });
            }
          },
          onPageFinished: (String url) {
            developer.log('✅ انتهاء تحميل الصفحة: $url', name: 'LiveStream');
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
              _autoPlayVideo();
            }
          },
          onWebResourceError: (WebResourceError error) {
            developer.log(
              '❌ خطأ في تحميل الصفحة: ${error.errorCode} - ${error.description}',
              name: 'LiveStream',
            );
            // تجاهل أخطاء الموارد الثانوية - فقط الأخطاء الحرجة
            if (error.errorType == WebResourceErrorType.hostLookup ||
                error.errorType == WebResourceErrorType.connect ||
                error.errorType == WebResourceErrorType.timeout) {
              if (mounted) {
                final s = AppLocalizations.of(context)!;
                setState(() {
                  _isLoading = false;
                  _hasError = true;
                  _loadingStatus =
                      '${s.streamLoadFailed} - خطأ ${error.errorCode}';
                });
                _handleRetry();
              }
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(_liveStreamUrl));

    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (_controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
  }

  void _autoPlayVideo() {
    developer.log('🔍 محاولة التشغيل التلقائي', name: 'LiveStream');

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _executePlayScript();
      }
    });
  }

  void _executePlayScript() {
    final s = AppLocalizations.of(context)!;
    final script = """
      (function() {
        try {
          console.log('🎯 بدء script التشغيل...');
          
          // محاولة 1: البحث عن فيديو وتشغيله مباشرة
          const videos = document.querySelectorAll('video');
          console.log('🎥 عدد مقاطع الفيديو الموجودة:', videos.length);
          
          for (let video of videos) {
            if (video.readyState >= 2) {
              console.log('▶️ محاولة تشغيل الفيديو:', video);
              video.play().then(() => {
                console.log('✅ تم تشغيل الفيديو بنجاح');
              }).catch(error => {
                console.log('❌ خطأ في تشغيل الفيديو:', error);
              });
              
              video.controls = false;
              video.setAttribute('playsinline', '');
              video.setAttribute('webkit-playsinline', '');
              return 'success';
            }
          }
          
          // محاولة 2: النقر على زر التشغيل
          const playButtons = [
            '.ytp-large-play-button',
            '.ytp-play-button',
            '.html5-main-video',
            'button[aria-label*="تشغيل"]',
            'button[aria-label*="Play"]',
            '.ytp-button',
            '.html5-video-player'
          ];
          
          for (let selector of playButtons) {
            const button = document.querySelector(selector);
            if (button) {
              console.log('🔄 النقر على زر:', selector);
              button.click();
              return 'success';
            }
          }
          
          // محاولة 3: تشغيل عبر واجهة برمجة التطبيقات
          if (typeof player !== 'undefined' && player.playVideo) {
            console.log('🎮 استخدام واجهة برمجة التطبيقات');
            player.playVideo();
            return 'success';
          }
          
          console.log('❌ لم يتم العثور على عناصر تشغيل');
          return 'not_found';
          
        } catch (error) {
          console.log('💥 خطأ في script التشغيل:', error);
          return 'error';
        }
      })();
    """;

    _controller
        .runJavaScriptReturningResult(script)
        .then((result) {
          developer.log('📜 نتيجة script التشغيل: $result', name: 'LiveStream');

          if (mounted) {
            // تحقق من النتيجة بشكل أفضل
            final resultStr = result.toString().toLowerCase();
            final isSuccess =
                resultStr.contains('success') ||
                resultStr.contains('true') ||
                result == true;

            setState(() {
              _isPlaying = isSuccess;
              if (_isPlaying) {
                _loadingStatus = s.playingStream;
                _retryCount = 0; // إعادة تعيين العداد عند النجاح
              } else {
                _loadingStatus = s.clickToPlay;
              }
            });

            // إعادة المحاولة فقط إذا فشل التشغيل فعلياً
            if (!_isPlaying &&
                _retryCount < _maxRetries &&
                resultStr != 'success') {
              _retryAutoPlay();
            }
          }
        })
        .catchError((error) {
          developer.log('❌ خطأ في تنفيذ script: $error', name: 'LiveStream');
          if (mounted) {
            setState(() {
              _loadingStatus = s.clickToPlay;
            });
          }
        });
  }

  void _retryAutoPlay() {
    _retryCount++;
    developer.log(
      '🔄 إعادة المحاولة ($_retryCount/$_maxRetries)',
      name: 'LiveStream',
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_isPlaying) {
        _executePlayScript();
      }
    });
  }

  void _playVideo() {
    final s = AppLocalizations.of(context)!;
    developer.log('▶️ محاولة تشغيل يدوي للفيديو', name: 'LiveStream');

    setState(() {
      _isLoading = true;
      _loadingStatus = s.playingStream;
    });

    _executePlayScript();
  }

  void _handleRetry() {
    if (_retryCount < _maxRetries) {
      _retryCount++;
      developer.log(
        '🔄 إعادة تحميل البث ($_retryCount/$_maxRetries)',
        name: 'LiveStream',
      );
      Future.delayed(const Duration(seconds: 3), _reloadStream);
    }
  }

  void _reloadStream() {
    final s = AppLocalizations.of(context)!;
    developer.log('🔄 إعادة تحميل البث', name: 'LiveStream');
    setState(() {
      _isLoading = true;
      _hasError = false;
      _retryCount = 0;
      _loadingStatus = s.reload;
    });
    _controller.reload();
  }

  void _openInExternalBrowser() {
    final s = AppLocalizations.of(context)!;
    developer.log('🌐 فتح البث في المتصفح', name: 'LiveStream');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.openInBrowser, textAlign: TextAlign.right),
        content: Text(s.openInBrowserDescription, textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              url_launcher.launch(widget.url);
            },
            child: Text(s.open),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    final liveTitle = '${s.liveStreamTitle} - ${widget.channelName}';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              IslamicAppbar(
                title: liveTitle,
                fontSize: 18.sp,
                onTap: () => Navigator.pop(context),
              ),

              if (_isLoading) _buildLoadingBar(),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 250.h,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            WebViewWidget(controller: _controller),

                            if (_isLoading) _buildLoadingOverlay(),

                            if (_hasError) _buildErrorOverlay(),

                            if (!_isPlaying && !_isLoading && !_hasError)
                              _buildPlayButtonOverlay(),
                          ],
                        ),
                      ),

                      SizedBox(height: 16.h),
                      _buildLoadingInfo(),
                      SizedBox(height: 16.h),
                      _buildControlButtons(),
                      SizedBox(height: 16.h),
                      _buildCopyrightInfo(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingBar() {
    return LinearProgressIndicator(
      backgroundColor: Colors.grey[300],
      valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkRed),
    );
  }

  Widget _buildLoadingOverlay() {
    final s = AppLocalizations.of(context)!;
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QuranLottieLoading(),
            SizedBox(height: 16.h),
            Text(
              _loadingStatus,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_retryCount > 0) ...[
              SizedBox(height: 8.h),
              Text(
                '${s.retryAttempt} $_retryCount ${s.off} $_maxRetries',
                style: TextStyle(color: Colors.grey[400], fontSize: 12.sp),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButtonOverlay() {
    return GestureDetector(
      onTap: _playVideo,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: AppColors.darkRed.withOpacity(0.8),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 50.w,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorOverlay() {
    final s = AppLocalizations.of(context)!;
    return Container(
      color: Colors.black.withOpacity(0.9),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48.w),
              SizedBox(height: 16.h),
              Text(
                s.streamLoadFailed,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                _loadingStatus,
                style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _reloadStream,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkRed,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(s.reload),
                  ),
                  SizedBox(width: 12.w),
                  OutlinedButton(
                    onPressed: _openInExternalBrowser,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white),
                    ),
                    child: Text(s.openInBrowser),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingInfo() {
    final s = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: _hasError ? Colors.red[50] : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: _hasError ? Colors.red[100]! : Theme.of(context).dividerColor,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _hasError
                ? Icons.error
                : _isPlaying
                ? Icons.play_circle_filled
                : Icons.info,
            color: _hasError
                ? Colors.red
                : _isPlaying
                ? Colors.green
                : Colors.blueGrey[600],
            size: 16.w,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              _loadingStatus,
              style: TextStyle(
                color: _hasError
                    ? Colors.red
                    : _isPlaying
                    ? Colors.green
                    : Theme.of(context).textTheme.bodyMedium?.color ??
                          Colors.blueGrey[700],
                fontSize: 12.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    final s = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _reloadStream,
            icon: Icon(Icons.refresh, size: 18.w),
            label: Text(s.reload),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkRed,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _openInExternalBrowser,
            icon: Icon(Icons.open_in_browser, size: 18.w),
            label: Text(s.openInBrowser),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.darkRed,
              side: BorderSide(color: AppColors.darkRed),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCopyrightInfo() {
    final s = AppLocalizations.of(context)!;
    final copyrightText = widget.copyrightNotice;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                s.importantNotice,
                style: AppTextStyles.zekr.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color:
                      Theme.of(context).textTheme.bodyLarge?.color ??
                      Colors.blueGrey[800],
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.copyright_rounded,
                color: Colors.blueGrey[600],
                size: 18.w,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            copyrightText,
            style: AppTextStyles.zekr.copyWith(
              fontSize: 14.sp,
              color:
                  Theme.of(context).textTheme.bodyMedium?.color ??
                  Colors.blueGrey[700],
              height: 1.5,
            ),
            textAlign: TextAlign.right,
          ),
          SizedBox(height: 8.h),
          Text(
            widget.copyrightRights,
            style: AppTextStyles.zekr.copyWith(
              fontSize: 12.sp,
              color:
                  Theme.of(context).textTheme.bodySmall?.color ??
                  Colors.blueGrey[600],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}
