import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:i_am_disiplin/models/app_models.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

final _plugin = FlutterLocalNotificationsPlugin();
bool _ready = false;

Future<void> initReminders() async {
  if (kIsWeb) return; // web'de bildirim yok, uygulama yine çalışır
  tzdata.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const darwin = DarwinInitializationSettings();
  const init = InitializationSettings(android: android, iOS: darwin);
  await _plugin.initialize(init);
  final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  await androidPlugin?.requestNotificationsPermission();
  _ready = true;
}

int _nid(String id) => id.hashCode & 0x3fffffff;

Future<void> rescheduleAll(List<Habit> habits) async {
  if (!_ready) return;
  try {
    await _plugin.cancelAll();
    for (final h in habits) {
      final reminder = h.reminder;
      if (reminder == null || !reminder.contains(':')) continue;
      final parts = reminder.split(':');
      final hh = int.tryParse(parts[0]);
      final mm = int.tryParse(parts.length > 1 ? parts[1] : '');
      if (hh == null || mm == null) continue;
      final now = tz.TZDateTime.now(tz.local);
      var when = tz.TZDateTime(tz.local, now.year, now.month, now.day, hh, mm);
      if (!when.isAfter(now)) when = when.add(const Duration(days: 1));
      await _plugin.zonedSchedule(
        _nid(h.id),
        'Ben Disiplinim',
        '${h.name} — bahane yok.',
        when,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'habit',
            'Alışkanlık',
            channelDescription: 'Günlük alışkanlık hatırlatmaları',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  } catch (e) {
    debugPrint('hatirlatma atlandi: $e');
  }
}
