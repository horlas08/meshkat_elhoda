
import 'package:flutter/material.dart';
import 'package:meshkat_elhoda/core/services/smart_dhikr_service.dart';
import 'package:meshkat_elhoda/core/services/prayer_notification_service_new.dart';
import 'package:meshkat_elhoda/core/services/flutter_athan_service.dart';
import 'package:meshkat_elhoda/core/services/athan_audio_service.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meshkat_elhoda/features/settings/data/models/notification_settings_model.dart';

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
            title: const Text("Print Cached Location / Settings"),
            subtitle: const Text("Shows stored lat/lng/language + notification settings"),
            trailing: const Icon(Icons.info_outline),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              final lat = prefs.getDouble('latitude');
              final lng = prefs.getDouble('longitude');
              final language = prefs.getString('language');
              final settingsJson = prefs.getString('NOTIFICATION_SETTINGS');

              final settings = settingsJson != null
                  ? NotificationSettingsModel.fromJson(settingsJson)
                  : const NotificationSettingsModel();

              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'lat=$lat, lng=$lng, lang=$language | Athan=${settings.isAthanEnabled}, PreAthan=${settings.isPreAthanEnabled}',
                  ),
                ),
              );
            },
          ),
          ListTile(
            title: const Text("Reschedule Prayer Notifications NOW"),
            subtitle: const Text("Uses cached lat/lng and current saved settings"),
            trailing: const Icon(Icons.refresh, color: Colors.orange),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              final lat = prefs.getDouble('latitude');
              final lng = prefs.getDouble('longitude');
              final language = prefs.getString('language') ?? 'ar';

              if (lat == null || lng == null) {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No cached latitude/longitude found. Set location first.'),
                  ),
                );
                return;
              }

              await PrayerNotificationService().rescheduleAll(
                latitude: lat,
                longitude: lng,
                language: language,
              );

              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Rescheduled prayer notifications for ($lat, $lng).'),
                ),
              );
            },
          ),
          ListTile(
            title: const Text("List Scheduled Notifications"),
            subtitle: const Text("Shows how many schedules are currently stored"),
            trailing: const Icon(Icons.list_alt),
            onTap: () async {
              final schedules = await AwesomeNotifications().listScheduledNotifications();
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Scheduled notifications count: ${schedules.length}'),
                ),
              );
            },
          ),
          ListTile(
            title: const Text("Check Notification Permission"),
            subtitle: const Text("Shows if notifications are allowed on this device"),
            trailing: const Icon(Icons.security),
            onTap: () async {
              final allowed = await AwesomeNotifications().isNotificationAllowed();
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Notifications allowed: $allowed')),
              );
            },
          ),
          ListTile(
            title: const Text("Schedule Simple Notification (1 min)"),
            subtitle: const Text("Non-precise schedule to test if alarms are blocked"),
            trailing: const Icon(Icons.schedule, color: Colors.blue),
            onTap: () async {
              final fireTime = DateTime.now().add(const Duration(minutes: 1));

              await AwesomeNotifications().createNotification(
                content: NotificationContent(
                  id: 99001,
                  channelKey: 'reminder_channel',
                  title: '⏱️ Simple Schedule Test',
                  body: 'If you see this, scheduling works (fire at ${fireTime.hour}:${fireTime.minute}).',
                  notificationLayout: NotificationLayout.Default,
                ),
                schedule: NotificationCalendar.fromDate(
                  date: fireTime,
                  allowWhileIdle: true,
                  preciseAlarm: false,
                ),
              );

              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Simple notification scheduled for 1 minute from now.')),
              );
            },
          ),
          ListTile(
            title: const Text("Schedule PRECISE Notification (1 min)"),
            subtitle: const Text("If this fails but simple works, exact alarms are blocked"),
            trailing: const Icon(Icons.gps_fixed, color: Colors.purple),
            onTap: () async {
              final fireTime = DateTime.now().add(const Duration(minutes: 1));

              await AwesomeNotifications().createNotification(
                content: NotificationContent(
                  id: 99002,
                  channelKey: 'reminder_channel',
                  title: '🎯 Precise Schedule Test',
                  body: 'Precise alarm test for ${fireTime.hour}:${fireTime.minute}.',
                  notificationLayout: NotificationLayout.Default,
                ),
                schedule: NotificationCalendar.fromDate(
                  date: fireTime,
                  allowWhileIdle: true,
                  preciseAlarm: true,
                ),
              );

              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Precise notification scheduled for 1 minute from now.')),
              );
            },
          ),
          ListTile(
            title: const Text("Schedule NATIVE Pre-Athan (1 min)"),
            subtitle: const Text("AlarmManager pre-athan reminder (terminate app to test)"),
            trailing: const Icon(Icons.notifications_active, color: Colors.deepOrange),
            onTap: () async {
              final fireTime = DateTime.now().add(const Duration(minutes: 1));
              await AthanAudioService().schedulePreAthanReminder(
                reminderId: 99101,
                triggerTime: fireTime,
                title: '⏳ Pre-Athan Test',
                body: 'If you see this after killing the app, native reminders work.',
              );

              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Native Pre-Athan scheduled for 1 minute from now.')),
              );
            },
          ),
          ListTile(
            title: const Text("Schedule NATIVE Athan (1 min)"),
            subtitle: const Text("AlarmManager athan + foreground service (terminate app to test)"),
            trailing: const Icon(Icons.alarm, color: Colors.teal),
            onTap: () async {
              final fireTime = DateTime.now().add(const Duration(minutes: 1));
              await AthanAudioService().scheduleAthan(
                prayerId: 99102,
                prayerTime: fireTime,
                prayerName: 'Dhuhr',
              );

              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Native Athan scheduled for 1 minute from now.')),
              );
            },
          ),
          ListTile(
            title: const Text("Open Athan Channel Settings"),
            subtitle: const Text("Make sure channel is not muted / volume not blocked"),
            trailing: const Icon(Icons.settings_applications),
            onTap: () async {
              await AwesomeNotifications().showNotificationConfigPage(
                channelKey: 'athan_ali_almula_regular_v3',
              );
            },
          ),
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
                  channelKey: 'athan_ali_almula_regular_v3',
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
              FlutterAthanService().playFullAthan(
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
