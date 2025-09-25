import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../firebase_options.dart';
import '../routes/app_routes.dart';

@pragma('vm:entry-point') // required for background FCM handler in release
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Handle background data if needed.
}

/// Optional: background tap handler for local notifications (Android 12L+)
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse r) {
  // Keep light. Navigation is safer once app is in foreground.
  // You could stash r.payload to disk and read it on init if needed.
}

class PushService {
  static final _flnp = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'general',
    'General',
    description: 'App notifications',
    importance: Importance.defaultImportance,
  );

  static Future<void> init() async {
    // Firebase core
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Background messages
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Local notifications (for foreground banners) + TAP handlers
    await _flnp.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_stat_notification'),
        iOS: DarwinInitializationSettings(),
      ),
      // 👇 user taps a local notification while app is in foreground
      onDidReceiveNotificationResponse: (NotificationResponse r) {
        _openNotificationPage();
      },
      // 👇 (optional) Android background tap on local notification
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Android channel (safe no-op on iOS)
    await _flnp
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // Permissions (iOS + Android 13+)
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission(alert: true, badge: true, sound: true);
    await fcm.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true,
    );

    // Subscribe every device to a common topic (optional)
    await fcm.subscribeToTopic('all-users');

    // --- FCM TAP HANDLERS (OS-shown notifications) ---

    // 1) App opened from TERMINATED by tapping a push
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _openNotificationPage();
    }

    // 2) App in BACKGROUND → brought to FOREGROUND via tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage m) {
      _openNotificationPage();
    });

    // --- Foreground push → show a local banner and handle tap via initialize callback above ---
    FirebaseMessaging.onMessage.listen((msg) {
      final n = msg.notification;
      if (n == null) return;

      // We could pass a payload, but we always open /notification anyway.
      _flnp.show(
        n.hashCode,
        n.title,
        n.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id, _channel.name,
            channelDescription: _channel.description,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        // payload: json.encode({"route": AppRoutes.notification}), // not required now
      );
    });
  }

  static void _openNotificationPage() {
    // Use offAllNamed() if you want to clear the stack instead of pushing.
    if (Get.currentRoute == AppRoutes.notification) return;
    Get.toNamed(AppRoutes.notification);
  }
}
