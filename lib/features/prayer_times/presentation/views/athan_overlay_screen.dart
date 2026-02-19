import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meshkat_elhoda/core/services/athan_audio_service.dart';

class AthanOverlayScreen extends StatefulWidget {
  const AthanOverlayScreen({super.key});

  @override
  State<AthanOverlayScreen> createState() => _AthanOverlayScreenState();
}

class _AthanOverlayScreenState extends State<AthanOverlayScreen> {
  static const MethodChannel _channel = MethodChannel('com.meshkatelhoda.pro/athan_overlay');

  String _title = 'حان وقت الصلاة';
  String _body = '';
  String _prayerName = '';

  @override
  void initState() {
    super.initState();

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

    return Scaffold(
      backgroundColor: const Color(0xFF0B1B2B),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFFFFD36E),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_prayerName.trim().isNotEmpty)
                    Text(
                      _prayerName,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: const Color(0xFFE6E6E6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (_prayerName.trim().isNotEmpty) const SizedBox(height: 8),
                  if (_body.trim().isNotEmpty)
                    Text(
                      _body,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFFE6E6E6),
                        height: 1.35,
                      ),
                    ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _stopAndClose,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD36E),
                            foregroundColor: const Color(0xFF0B1B2B),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('إيقاف'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _stopAndClose,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFE6E6E6),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Color(0xFFE6E6E6), width: 1.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('إخفاء'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
