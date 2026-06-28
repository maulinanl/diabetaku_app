import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'api_service.dart';

class PushNotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'diabetaku_high_importance',
    'DiabetAku Notifications',
    description: 'Notifikasi penting dari DiabetAku',
    importance: Importance.high,
  );

  static Future<void> init() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: DarwinInitializationSettings(),
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        print('NOTIFICATION CLICKED PAYLOAD: ${response.payload}');
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('NOTIFICATION OPENED: ${message.data}');
    });

    final token = await FirebaseMessaging.instance.getToken();
    print('FCM TOKEN DEVICE: $token');

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print('FCM TOKEN REFRESHED: $newToken');

      final isLoggingOut = await ApiService.isLoggingOut();

      if (isLoggingOut) {
        print('USER SEDANG LOGOUT, FCM TOKEN TIDAK DIKIRIM KE BACKEND');
        return;
      }

      final authToken = await ApiService.getToken();

      if (authToken == null) {
        print('USER BELUM LOGIN, FCM TOKEN TIDAK DIKIRIM KE BACKEND');
        return;
      }

      try {
        await ApiService.saveFcmToken(newToken);
      } catch (e) {
        print('GAGAL SIMPAN REFRESHED FCM TOKEN: $e');
      }
    });
  }

  static Future<void> registerTokenToBackend() async {
    final isLoggingOut = await ApiService.isLoggingOut();

    if (isLoggingOut) {
      print('USER SEDANG LOGOUT, REGISTER FCM DIBATALKAN');
      return;
    }

    final authToken = await ApiService.getToken();

    if (authToken == null) {
      print('USER BELUM LOGIN, REGISTER FCM DIBATALKAN');
      return;
    }

    final token = await FirebaseMessaging.instance.getToken();

    print('REGISTER FCM TOKEN TO BACKEND: $token');

    if (token == null) return;

    await ApiService.saveFcmToken(token);
  }

  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;

    final title = notification?.title ?? message.data['title'] ?? 'DiabetAku';

    final body =
        notification?.body ??
        message.data['body'] ??
        message.data['message'] ??
        '';

    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }
}
