import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/services/athan_audio_service.dart';
import 'package:meshkat_elhoda/l10n/app_localizations.dart';

class AdhanTroubleshootView extends StatefulWidget {
  const AdhanTroubleshootView({super.key});

  @override
  State<AdhanTroubleshootView> createState() => _AdhanTroubleshootViewState();
}

class _AdhanTroubleshootViewState extends State<AdhanTroubleshootView> {
  String? _deviceInfo;
  bool _batteryOptimizationGranted = false;
  bool _exactAlarmGranted = true;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
    _loadBatteryOptimizationState();
    _loadExactAlarmState();
  }

  Future<void> _loadDeviceInfo() async {
    try {
      final info = await AthanAudioService().getDeviceInfo();
      if (!mounted) return;
      setState(() {
        _deviceInfo = info;
      });
    } catch (e) {
      log('Failed to load device info: $e');
    }
  }

  Future<void> _loadBatteryOptimizationState() async {
    try {
      final isOptimized = await AthanAudioService().isBatteryOptimized();
      if (!mounted) return;
      setState(() {
        _batteryOptimizationGranted = !isOptimized;
      });
    } catch (_) {
      // ignore
    }
  }

  Future<void> _loadExactAlarmState() async {
    try {
      final granted = await AthanAudioService().canScheduleExactAlarms();
      if (!mounted) return;
      setState(() {
        _exactAlarmGranted = granted;
      });
    } catch (_) {
      // ignore
    }
  }

  Future<bool> _confirmBack() async {
    final l10n = AppLocalizations.of(context)!;

    final res = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.adhanTroubleshootBackConfirmTitle),
          content: Text(l10n.adhanTroubleshootBackConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.adhanTroubleshootBackConfirmStay),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.adhanTroubleshootBackConfirmGoBack),
            ),
          ],
        );
      },
    );

    return res ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _confirmBack();
        if (!context.mounted) return;
        if (shouldPop) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.adhanTroubleshootTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final shouldPop = await _confirmBack();
              if (!context.mounted) return;
              if (shouldPop) Navigator.of(context).pop();
            },
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.adhanTroubleshootAboutTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.adhanTroubleshootAboutBody,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _sectionTitle(l10n.adhanTroubleshootAboutDeviceTitle),
            const SizedBox(height: 8),
            _infoCard(
              icon: Icons.phone_android,
              title: _deviceInfo ?? l10n.loading,
              subtitle: l10n.adhanTroubleshootAboutDeviceSubtitle,
            ),
            const SizedBox(height: 18),
            _fixRow(
              icon: Icons.layers,
              title: l10n.adhanTroubleshootFixOverlayTitle,
              desc: l10n.adhanTroubleshootFixOverlayDesc,
              buttonText: l10n.adhanTroubleshootFixNow,
              onPressed: () async {
                await AthanAudioService().openOverlayPermissionSettings();
              },
            ),
            _fixRow(
              icon: Icons.alarm,
              title: l10n.adhanTroubleshootFixExactAlarmTitle,
              desc: l10n.adhanTroubleshootFixExactAlarmDesc,
              buttonText:
                  _exactAlarmGranted ? l10n.adhanTroubleshootDone : l10n.adhanTroubleshootAllow,
              onPressed: _exactAlarmGranted
                  ? null
                  : () async {
                      await AthanAudioService().requestExactAlarmPermission();
                      await _loadExactAlarmState();
                    },
            ),
            _fixRow(
              icon: Icons.play_circle_outline,
              title: l10n.adhanTroubleshootFixAutostartTitle,
              desc: l10n.adhanTroubleshootFixAutostartDesc,
              buttonText: l10n.adhanTroubleshootCheckIt,
              onPressed: () async {
                await AthanAudioService().openAutoStartSettings();
              },
            ),
            _fixRow(
              icon: Icons.nightlight_outlined,
              title: l10n.adhanTroubleshootFixScreenOffTitle,
              desc: l10n.adhanTroubleshootFixScreenOffDesc,
              buttonText: l10n.adhanTroubleshootCheckIt,
              onPressed: () async {
                await AthanAudioService().openAdvancedScreenOffSettings();
              },
            ),
            _fixRow(
              icon: Icons.battery_alert_outlined,
              title: l10n.adhanTroubleshootFixBatterySaverTitle,
              desc: l10n.adhanTroubleshootFixBatterySaverDesc,
              buttonText: l10n.adhanTroubleshootCheckIt,
              onPressed: () async {
                await AthanAudioService().openBatterySaverSettings();
              },
            ),
            _fixRow(
              icon: Icons.battery_full,
              title: l10n.adhanTroubleshootFixBatteryOptimizationTitle,
              desc: l10n.adhanTroubleshootFixBatteryOptimizationDesc,
              buttonText: _batteryOptimizationGranted
                  ? l10n.adhanTroubleshootDone
                  : l10n.adhanTroubleshootAllow,
              onPressed: _batteryOptimizationGranted
                  ? null
                  : () async {
                      await AthanAudioService().requestBatteryOptimizationExemption();
                      await _loadBatteryOptimizationState();
                    },
            ),
            _fixRow(
              icon: Icons.notifications_none,
              title: l10n.adhanTroubleshootFixNotificationsTitle,
              desc: l10n.adhanTroubleshootFixNotificationsDesc,
              buttonText: l10n.adhanTroubleshootCheckIt,
              onPressed: () async {
                await AthanAudioService().openAppNotificationSettings();
              },
            ),
            _fixRow(
              icon: Icons.notifications_active_outlined,
              title: l10n.adhanTroubleshootFixAthanChannelTitle,
              desc: l10n.adhanTroubleshootFixAthanChannelDesc,
              buttonText: l10n.adhanTroubleshootCheckIt,
              onPressed: () async {
                await AthanAudioService().openAthanNotificationChannelSettings();
              },
            ),
            const SizedBox(height: 18),
            Text(
              l10n.adhanTroubleshootNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () async {
                final shouldPop = await _confirmBack();
                if (!context.mounted) return;
                if (shouldPop) Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back),
              label: Text(
                l10n.adhanTroubleshootBack,
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fixRow({
    required IconData icon,
    required String title,
    required String desc,
    required String buttonText,
    required VoidCallback? onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(desc, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 10),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: ElevatedButton(
                    onPressed: onPressed,
                    child: Text(buttonText),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
