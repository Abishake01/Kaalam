import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class AlarmScheduler {
  static final FlutterLocalNotificationsPlugin _fln = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _fln.initialize(settings);
  }

  static Future<bool> requestPermissions() async {
    // Android permissions are granted at install; iOS needs explicit
    final ios = await _fln.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    return ios ?? true;
  }

  static Future<void> cancelAll() async {
    await _fln.cancelAll();
  }

  static Future<void> scheduleAlarm({
    required DateTime at,
    String title = 'Kaalam',
    String body = 'Good morning! It\'s time to wake up.',
    bool playSound = true,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'kaalam_alarm_channel',
      'Kaalam Alarms',
      channelDescription: 'Scheduled wake-up alarms',
      importance: Importance.max,
      priority: Priority.high,
      // Use default alarm sound; provide custom raw sound later if desired.
      sound: null,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
    );

    const iosDetails = DarwinNotificationDetails(
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
      categoryIdentifier: 'alarm',
    );

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    final tzDateTime = tz.TZDateTime.from(at, tz.local);

    await _fln.zonedSchedule(
      1001, // fixed id for single alarm; extend to multiple if needed
      title,
      body,
      tzDateTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      // Single-shot schedule; do not match components for repetition.
    );
  }
}
