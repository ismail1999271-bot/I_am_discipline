import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

/// {k} = kullanıcının kimliklerinden biri
const _quotes = <String>[
  'Bugün attığın her adım, {k} biri olduğunun kanıtı.',
  'Motivasyon gelir gider. Sistem kalır.',
  'Kötü günde minimumu yap. Seri senin, bırakma.',
  'Bir gün değil, gün bir. Başla.',
  '{k} insanlar canları istediği için değil, karar verdikleri için yapar.',
  'Küçük ama her gün. Büyük sonuç böyle gelir.',
  'Zor olan başlamak. Gerisi 2 dakika.',
  'Bugünkü sen, yarınki senin temeli.',
  'Disiplin, istediğin şeyle şimdi istediğin şey arasında seçim yapmaktır.',
  'Kimse seni izlemiyor. İşte tam da bu yüzden önemli.',
  'Bahane de bir alışkanlıktır. Hangisini besleyeceğini sen seçersin.',
  'Yorgunsan dinlen. Ama vazgeçme.',
  'Mükemmel olma, tutarlı ol.',
  '1 yıl sonra bugün başladığın için teşekkür edeceksin.',
  'Her tekrar, {k} kimliğine bir oy.',
  'Düşmek sorun değil. Yerde kalmak sorun.',
  'Bugün de kazan. Sadece bir alışkanlıkla bile.',
  'Hedef değil, sistem seni götürür.',
  'Konfor alanı güzel ama orada hiçbir şey büyümez.',
  'Sen ne yapıyorsan, osun. Bugün ne oluyorsun?',
  'Ertelemek için mükemmel bir an yok. Yapmak için de yok. Yap.',
  '10 dakika bile sayılır. Sıfırdan iyidir.',
  'Gücün kas değil, karar.',
  'İstikrar, yeteneği her zaman yener.',
  'Akşam kendine "bugün de yaptım" diyebilmek için şimdi kalk.',
  'Zor günler güçlü insanları yapar. Güçlü insanlar kolay günleri.',
  'Hissetmeyi bekleme. Önce yap, his arkadan gelir.',
  'Bugün kimseyle yarışma. Dünkü kendini geç.',
  'Serini koru. O seri senin hikâyen.',
  '{k} biri bugün ne yapardı? Onu yap.',
  'Rahatsızlık, büyümenin sesidir.',
  'Küçük zaferler büyük kimlik kurar.',
  'Gelecekteki sen, şu anki kararını izliyor.',
  'Bir sayfa, bir set, bir adım. Hepsi sayılır.',
  'Başarı bir olay değil, bir rutin.',
  'Sözünü kendine tut. En önemli söz o.',
  'Bugün zor geliyorsa, minimum modunu aç. Bu da kazanmaktır.',
  'Durmadıkça ne kadar yavaş gittiğin önemli değil.',
  'Disiplinli olmak bir özellik değil, bir seçim. Bugün de seç.',
  'Uyumadan önce bir şey yap ki yarın daha güçlü uyan.',
];

const _titles = ['Hatırlatma', 'Bugünün sözü', 'Kimliğin', 'Devam', 'Güç', 'Disiplin'];

/// Bildirim saatleri: 3'lü ve 4'lü plan
const _slots3 = [9, 14, 20];
const _slots4 = [8, 12, 16, 21];

final _n = FlutterLocalNotificationsPlugin();

Future<int> motivationCount() async {
  final p = await SharedPreferences.getInstance();
  return p.getInt('motivation') ?? 3; // varsayılan: günde 3
}

/// count = 0 kapalı, 3 veya 4. Önümüzdeki 7 günü farklı sözlerle planlar.
/// Uygulama her açıldığında çağrılır, böylece sözler hiç bitmez.
Future<void> scheduleMotivation(int count, List<String> identities) async {
  final p = await SharedPreferences.getInstance();
  await p.setInt('motivation', count);
  if (kIsWeb) return;
  for (var id = 100; id < 140; id++) {
    await _n.cancel(id);
  }
  if (count == 0) return;
  await _n.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  final slots = count == 4 ? _slots4 : _slots3;
  final ids = identities.isEmpty ? ['disiplinli'] : identities.map((e) => e.toLowerCase()).toList();
  final now = tz.TZDateTime.now(tz.local);
  // Her gün farklı sözler: gün numarasına göre karıştır
  final rnd = Random(now.year * 1000 + now.month * 50 + now.day);
  final pool = List<String>.from(_quotes)..shuffle(rnd);
  var q = 0, id = 100;
  for (var d = 0; d < 7; d++) {
    for (final h in slots) {
      final at = tz.TZDateTime(tz.local, now.year, now.month, now.day + d, h, 0);
      if (at.isBefore(now)) continue;
      final text = pool[q % pool.length].replaceAll('{k}', ids[q % ids.length]);
      await _n.zonedSchedule(id++, _titles[q % _titles.length], text, at,
          const NotificationDetails(
            android: AndroidNotificationDetails('motivation', 'Motivasyon sözleri',
                channelDescription: 'Gün içinde kimliğini hatırlatan kısa sözler', importance: Importance.defaultImportance,
                styleInformation: BigTextStyleInformation('')),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
      q++;
    }
  }
}

/// Uygulama içinde göstermek için günün sözü
String quoteOfDay(List<String> identities) {
  final n = DateTime.now();
  final i = (n.year * 400 + n.month * 32 + n.day) % _quotes.length;
  final k = identities.isEmpty ? 'disiplinli' : identities[n.day % identities.length].toLowerCase();
  return _quotes[i].replaceAll('{k}', k);
}
