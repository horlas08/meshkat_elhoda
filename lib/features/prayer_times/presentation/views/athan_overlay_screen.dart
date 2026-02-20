import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meshkat_elhoda/core/services/athan_audio_service.dart';

class AthanOverlayScreen extends StatefulWidget {
  const AthanOverlayScreen({super.key});

  @override
  State<AthanOverlayScreen> createState() => _AthanOverlayScreenState();
}

class _AthanOverlayScreenState extends State<AthanOverlayScreen> with TickerProviderStateMixin {
  static const MethodChannel _channel = MethodChannel('com.meshkatelhoda.pro/athan_overlay');

  String _title = 'حان وقت الصلاة';
  String _body = '';
  String _prayerName = '';

  late final AnimationController _pulseController;
  late final AnimationController _bgController;
  late final Animation<double> _bgScaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);

    _bgScaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeInOutSine),
    );

    _channel.setMethodCallHandler((call) async {
      if (!mounted) return;
      if (call.method == 'setOverlayData') {
        final args = (call.arguments as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
        setState(() {
          _title = (args['title'] as String?)?.trim().isNotEmpty == true ? args['title'] as String : _title;
          _body = (args['body'] as String?) ?? _body;
          _prayerName = (args['prayerName'] as String?) ?? _prayerName;
        });
      }
    });

    unawaited(_requestInitialData());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  Future<void> _requestInitialData() async {
    try {
      final res = await _channel.invokeMethod<Map>('getOverlayData');
      if (!mounted) return;
      final args = res?.cast<String, dynamic>() ?? <String, dynamic>{};
      setState(() {
        _title = (args['title'] as String?)?.trim().isNotEmpty == true ? args['title'] as String : _title;
        _body = (args['body'] as String?) ?? _body;
        _prayerName = (args['prayerName'] as String?) ?? _prayerName;
      });
    } catch (_) {}
  }

  Future<void> _stopAndClose() async {
    try {
      await AthanAudioService().stopAthan();
    } catch (_) {}

    if (!mounted) return;
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = View.of(context).platformDispatcher.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFF0B1B2B),
      body: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Animated Background
            AnimatedBuilder(
              animation: _bgScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _bgScaleAnimation.value,
                  child: Image.asset(
                    'assets/images/islamic_athan_bg.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: const Color(0xFF0B1B2B));
                    },
                  ),
                );
              },
            ),
            
            // Dark Gradient / Glassmorphism Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0B1B2B).withOpacity(0.5),
                    const Color(0xFF0B1B2B).withOpacity(0.85),
                    const Color(0xFF0B1B2B),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(),
                        
                        // Decorative Top Element
                        Icon(
                          Icons.mosque_rounded,
                          size: 48,
                          color: const Color(0xFFFFD36E).withOpacity(0.8),
                        ),
                        const SizedBox(height: 24),

                        // Title
                        Text(
                          _title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: const Color(0xFFFFD36E),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                color: const Color(0xFFFFD36E).withOpacity(0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Prayer Name with Pulse Animation
                        if (_prayerName.trim().isNotEmpty)
                          Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Pulsing Rings
                                ...List.generate(2, (index) {
                                  return AnimatedBuilder(
                                    animation: _pulseController,
                                    builder: (context, child) {
                                      final progress = (_pulseController.value + (index * 0.5)) % 1.0;
                                      return Opacity(
                                        opacity: 1.0 - progress,
                                        child: Transform.scale(
                                          scale: 1.0 + (progress * 0.5),
                                          child: Container(
                                            height: 80,
                                            width: 140,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(40),
                                              border: Border.all(
                                                color: const Color(0xFFFFD36E).withOpacity(0.5),
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }),
                                
                                // Prayer Name Plate
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFD36E).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: const Color(0xFFFFD36E).withOpacity(0.3),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFFD36E).withOpacity(0.1),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    _prayerName,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (_prayerName.trim().isNotEmpty) const SizedBox(height: 24),
                        
                        // Body Text
                        if (_body.trim().isNotEmpty)
                          Text(
                            _body,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: const Color(0xFFE6E6E6).withOpacity(0.9),
                              height: 1.5,
                              fontSize: 18,
                            ),
                          ),
                        
                        const Spacer(),

                        // Action Buttons
                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _stopAndClose,
                                icon: const Icon(Icons.volume_off_rounded, color: Color(0xFF0B1B2B)),
                                label: const Text(
                                  'إيقاف الأذان',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFD36E),
                                  foregroundColor: const Color(0xFF0B1B2B),
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 8,
                                  shadowColor: const Color(0xFFFFD36E).withOpacity(0.3),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _stopAndClose,
                                icon: const Icon(Icons.close_rounded),
                                label: const Text(
                                  'إغلاق الشاشة',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFE6E6E6),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  side: BorderSide(
                                    color: const Color(0xFFE6E6E6).withOpacity(0.5), 
                                    width: 1.5
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
