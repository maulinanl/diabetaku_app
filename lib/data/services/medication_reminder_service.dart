import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'api_service.dart';

class MedicationReminderService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'diabetaku_medication_reminder';
  static const String _channelName = 'Reminder Minum Obat';
  static const String _channelDescription =
      'Alarm lokal untuk mengingatkan pasien minum obat sesuai resep aktif.';

  static const String _scheduledIdsKey = 'medication_reminder_notification_ids';
  static const String _ownerPatientIdKey = 'medication_reminder_patient_id';
  static const int _scheduleHorizonDays = 14;

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await requestNotificationPermission();

    _initialized = true;
  }

  static Future<void> requestNotificationPermission() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
  }

  static void _onNotificationTap(NotificationResponse response) {
    debugPrint('MEDICATION REMINDER PAYLOAD: ${response.payload}');
  }

  static Future<void> syncMedicationReminders() async {
    await init();

    final prefs = await SharedPreferences.getInstance();
    final patientId = prefs.getInt('patient_id');

    if (patientId == null) {
      await cancelAllMedicationReminders();
      return;
    }

    final ownerPatientId = prefs.getInt(_ownerPatientIdKey);
    if (ownerPatientId != null && ownerPatientId != patientId) {
      await cancelAllMedicationReminders();
    }

    final schedules = await ApiService.getActivePrescriptionSchedules(patientId);

    await _cancelSavedMedicationReminders(removeStorage: false);

    final scheduledIds = <int>[];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final horizonEnd = today.add(const Duration(days: _scheduleHorizonDays));

    for (final item in schedules) {
      final prescriptionId = _asInt(item['prescription_id']);
      final scheduleId = _asInt(item['prescription_schedule_id']);

      if (prescriptionId == null || scheduleId == null) continue;

      final reminderTime = _parseTime(
        item['reminder_time'] ?? item['default_reminder_time'],
      );

      if (reminderTime == null) continue;

      final validFrom = _dateOnly(_parseDate(item['start_date'])) ?? today;
      final validUntil =
          _dateOnly(_parseDate(item['end_date'])) ?? horizonEnd;

      var targetDay = validFrom.isAfter(today) ? validFrom : today;
      final lastDay = validUntil.isBefore(horizonEnd) ? validUntil : horizonEnd;

      while (!targetDay.isAfter(lastDay)) {
        final scheduleDateTime = DateTime(
          targetDay.year,
          targetDay.month,
          targetDay.day,
          reminderTime.hour,
          reminderTime.minute,
        );

        if (scheduleDateTime.isAfter(now)) {
          final notificationId = _notificationId(
            patientId: patientId,
            prescriptionId: prescriptionId,
            scheduleId: scheduleId,
            date: targetDay,
          );

          await _scheduleMedicationNotification(
            id: notificationId,
            item: item,
            dateTime: scheduleDateTime,
          );

          scheduledIds.add(notificationId);
        }

        targetDay = targetDay.add(const Duration(days: 1));
      }
    }

    await prefs.setStringList(
      _scheduledIdsKey,
      scheduledIds.map((id) => id.toString()).toList(),
    );
    await prefs.setInt(_ownerPatientIdKey, patientId);

    debugPrint('MEDICATION REMINDERS SCHEDULED: ${scheduledIds.length}');
  }

  static Future<void> cancelAllMedicationReminders() async {
    await init();
    await _cancelSavedMedicationReminders(removeStorage: true);
  }

  static Future<void> _cancelSavedMedicationReminders({
    required bool removeStorage,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final savedIds = prefs.getStringList(_scheduledIdsKey) ?? <String>[];

    for (final rawId in savedIds) {
      final id = int.tryParse(rawId);
      if (id == null) continue;

      try {
        await _plugin.cancel(id: id);
      } catch (e) {
        debugPrint('CANCEL MEDICATION REMINDER ERROR: $e');
      }
    }

    if (removeStorage) {
      await prefs.remove(_scheduledIdsKey);
      await prefs.remove(_ownerPatientIdKey);
    }
  }

  static Future<void> _scheduleMedicationNotification({
    required int id,
    required Map<String, dynamic> item,
    required DateTime dateTime,
  }) async {
    final medicationName = _text(item['medication_name'], fallback: 'Obat');
    final dosage = _text(item['dosage']);
    final dosePerSession = _text(item['dose_per_session']);
    final sessionName = _text(item['session_name'], fallback: 'Jadwal minum');
    final mealRule = _text(item['meal_rule']);

    final bodyParts = <String>[
      if (dosage != '-') dosage,
      if (dosePerSession != '-') dosePerSession,
      sessionName,
      if (mealRule != '-') mealRule,
    ];

    final payload = jsonEncode({
      'type': 'medication_reminder',
      'patient_id': item['patient_id'],
      'prescription_id': item['prescription_id'],
      'prescription_schedule_id': item['prescription_schedule_id'],
      'medication_name': medicationName,
    });

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Reminder minum obat',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _plugin.zonedSchedule(
      id: id,
      title: 'Waktunya minum obat',
      body: '$medicationName — ${bodyParts.join(' • ')}',
      scheduledDate: tz.TZDateTime.from(dateTime, tz.local),
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }

  static _ReminderTime? _parseTime(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();
    if (text.isEmpty || text == '-') return null;

    final parts = text.split(':');
    if (parts.length < 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    return _ReminderTime(hour, minute);
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();
    if (text.isEmpty || text == '-') return null;

    return DateTime.tryParse(text);
  }

  static DateTime? _dateOnly(DateTime? value) {
    if (value == null) return null;
    return DateTime(value.year, value.month, value.day);
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  static String _text(dynamic value, {String fallback = '-'}) {
    if (value == null) return fallback;

    final text = value.toString().trim();
    if (text.isEmpty || text == '-') return fallback;

    return text;
  }

  static int _notificationId({
    required int patientId,
    required int prescriptionId,
    required int scheduleId,
    required DateTime date,
  }) {
    final key =
        '$patientId-$prescriptionId-$scheduleId-${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';

    return 100000 + (key.hashCode & 0x7fffffff) % 2000000000;
  }
}

class _ReminderTime {
  final int hour;
  final int minute;

  const _ReminderTime(this.hour, this.minute);
}
