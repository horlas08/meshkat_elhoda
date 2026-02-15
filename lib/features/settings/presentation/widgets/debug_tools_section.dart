
import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/services/smart_dhikr_service.dart';
import 'package:meshkat_elhoda/core/services/prayer_notification_service_new.dart';
import 'package:meshkat_elhoda/core/services/flutter_athan_service.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class DebugToolsSection extends StatelessWidget {
  const DebugToolsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        leading: const Icon(Icons.bug_report, color: Colors.red),
        title: const Text(
          "🛠️ Debug / Developer Tools",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
        children: [
          ListTile(
            title: const Text("Run Smart Voice NOW"),
            subtitle: const Text("Plays random Dhikr immediately"),
            trailing: const Icon(Icons.play_circle_fill, color: Colors.green),
            onTap: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Playing Smart Dhikr...")),
              );
              // Force play regardless of settings
              await SmartDhikrService().triggerSmartDhikr(ignoreSettings: true);
            },
          ),
          ListTile(
            title: const Text("Run Full Athan NOW"),
            subtitle: const Text("Plays Athan immediately (fg/bg test)"),
            trailing: const Icon(Icons.mosque, color: Colors.green),
            onTap: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Playing Full Athan (Asr)...")),
              );
              
              // Trigger notification first (simulating real flow)
              await AwesomeNotifications().createNotification(
                content: NotificationContent(
                  id: 99999,
                  channelKey: 'athan_channel_v3', // Using the new silent channel
                  title: '🕌 Test Athan',
                  body: 'Testing Full Athan Playback',
                  notificationLayout: NotificationLayout.Default,
                  category: NotificationCategory.Reminder,
                  wakeUpScreen: true,
                  fullScreenIntent: false,
                  criticalAlert: true,
                  autoDismissible: false,
                  payload: {
                    'type': 'athan',
                    'prayer': 'Asr',
                    'play_full_athan': 'true',
                  },
                  actionType: ActionType.KeepOnTop,
                ),
                actionButtons: [
                  NotificationActionButton(
                    key: 'DISMISS',
                    label: '✓ Hide',
                    actionType: ActionType.DismissAction,
                  ),
                  NotificationActionButton(
                    key: 'STOP_ATHAN',
                    label: '⏹️ Stop',
                    actionType: ActionType.SilentAction,
                    isDangerousOption: true,
                  ),
                ],
              );

              // Play Athan
              await FlutterAthanService().playFullAthan(
                prayerName: 'Asr',
                // muezzinId will be auto-selected from prefs
              );
            },
          ),
          ListTile(
            title: const Text("Schedule Athan Test (1 min)"),
            subtitle: const Text("Tests Audio & Notifications"),
            trailing: const Icon(Icons.notifications_active),
            onTap: () async {
              await PrayerNotificationService().scheduleImmediateAthanTest();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Athan test scheduled for 1 min from now")),
              );
            },
          ),
          ListTile(
            title: const Text("Request Permissions"),
            subtitle: const Text("Fixes missing notification sound"),
            trailing: const Icon(Icons.perm_device_information),
            onTap: () async {
              // Using AwesomeNotifications directly to request full permissions
              await AwesomeNotifications().requestPermissionToSendNotifications(
                channelKey: null,
                permissions: [
                  NotificationPermission.Alert,
                  NotificationPermission.Sound,
                  NotificationPermission.Badge,
                  NotificationPermission.CriticalAlert,
                  NotificationPermission.OverrideDnD,
                  NotificationPermission.Provisional,
                  NotificationPermission.Vibration,
                  NotificationPermission.Car,
                  NotificationPermission.FullScreenIntent,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
