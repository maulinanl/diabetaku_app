import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/navigation/app_navigator.dart';
import '../../features/doctor/pages/doctor_notification_page.dart';
import '../../features/caregiver/pages/caregiver_notification_page.dart';
import '../../features/patient/pages/patient_notification_page.dart';
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
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: DarwinInitializationSettings(),
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        _handleLocalNotificationTap(response.payload);
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationData(message.data);
    });

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      Future.delayed(const Duration(milliseconds: 700), () {
        _handleNotificationData(initialMessage.data);
      });
    }

    final launchDetails =
        await _localNotifications.getNotificationAppLaunchDetails();

    final launchResponse = launchDetails?.notificationResponse;
    if (launchDetails?.didNotificationLaunchApp == true &&
        launchResponse?.payload != null) {
      Future.delayed(const Duration(milliseconds: 700), () {
        _handleLocalNotificationTap(launchResponse!.payload);
      });
    }

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

  static void _handleLocalNotificationTap(String? payload) {
    if (payload == null || payload.trim().isEmpty) return;

    try {
      final decoded = jsonDecode(payload);

      if (decoded is Map<String, dynamic>) {
        _handleNotificationData(decoded);
      } else if (decoded is Map) {
        _handleNotificationData(Map<String, dynamic>.from(decoded));
      }
    } catch (e) {
      print('GAGAL PARSE NOTIFICATION PAYLOAD: $e');
    }
  }

  static Future<void> _handleNotificationData(
    Map<String, dynamic> data, {
    int retry = 0,
  }) async {
    final notificationId = int.tryParse(
      (data['notification_id'] ?? data['id'] ?? '').toString(),
    );

    if (notificationId == null) {
      print('NOTIFICATION PAYLOAD TANPA notification_id: $data');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final roleId = prefs.getInt('role_id');

    if (roleId == null) {
      print('ROLE ID BELUM ADA, NOTIFICATION CLICK DIABAIKAN');
      return;
    }

    final navigator = AppNavigator.navigatorKey.currentState;

    if (navigator == null) {
      if (retry < 5) {
        Future.delayed(const Duration(milliseconds: 400), () {
          _handleNotificationData(data, retry: retry + 1);
        });
      }

      return;
    }

    Widget page;

    if (roleId == 2) {
      page = DoctorNotificationPage(initialNotificationId: notificationId);
    } else if (roleId == 4) {
      page = CaregiverNotificationPage(initialNotificationId: notificationId);
    } else {
      page = PatientNotificationPage(initialNotificationId: notificationId);
    }

    navigator.push(MaterialPageRoute(builder: (_) => page));
  }
}
