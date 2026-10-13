import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

final _n = FlutterLocalNotificationsPlugin();

Future<void> initReminders() async {
  tzdata.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
  await _n.initialize(const InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  ));
}

Future<TimeOfDay?> savedReminder() async {
  final p = await SharedPreferences.getInstance();
  final m = p.getInt('reminder');
  return m == null ? null : TimeOfDay(hour: m ~/ 60, minute: m % 60);
}

/// Her gün aynı saatte "Bugünkü oylarını ver" bildirimi.
Future<void> scheduleDaily(TimeOfDay t) async {
  final p = await SharedPreferences.getInstance();
  await p.setInt('reminder', t.hour * 60 + t.minute);
  await _n.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
  final now = tz.TZDateTime.now(tz.local);
  var at = tz.TZDateTime(tz.local, now.year, now.month, now.day, t.hour, t.minute);
  if (at.isBefore(now)) at = at.add(const Duration(days: 1));
  await _n.cancel(1);
  await _n.zonedSchedule(1, 'Bugün kim olacaksın?', 'Alışkanlıklarını işaretle, kimliğine oy ver.', at,
      const NotificationDetails(
        android: AndroidNotificationDetails('daily', 'Günlük hatırlatıcı', importance: Importance.high),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time);
}
