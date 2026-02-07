import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer';

class MyFirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Singleton pattern
  static final MyFirebaseMessagingService _instance =
      MyFirebaseMessagingService._internal();

  factory MyFirebaseMessagingService() => _instance;

  MyFirebaseMessagingService._internal();

  Future<void> initialize() async {
    // Request notification permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    log('🔔 Notification permission: ${settings.authorizationStatus}');

    // Get and print the device token
    final token = await _firebaseMessaging.getToken();
    log('📱 FCM Token: $token');

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('📩 New message: ${message.notification?.title}');
    });

    // Handle when the app is opened from a terminated state via notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('📩 App opened from notification: ${message.notification?.title}');
    });
  }

  // Additional useful methods
  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  // Handle notification settings
  Future<NotificationSettings> getNotificationSettings() async {
    return await _firebaseMessaging.getNotificationSettings();
  }
}

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('📩 [Background] Message received: ${message.notification?.title}');
  log('Message data: ${message.data}');
}
