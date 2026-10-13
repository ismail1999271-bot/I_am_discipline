import 'models.dart';
import 'store.dart';

class Rozet {
  final String title, desc; final bool earned; final double progress;
  Rozet(this.title, this.desc, this.earned, this.progress);
}

/// Seviyeler: kimliğin adım adım güçlenmesi.
const _levels = [
  (7, 'Başlangıç', 'ilk hafta'),
  (21, 'Tutarlı', '21 gün'),
  (66, 'Alışkanlık', '66 gün, otomatikleşme eşiği'),
  (100, 'Kimlik', '100 gün'),
];

List<Rozet> badgesFor(Store s) {
  final out = <Rozet>[];
  for (final Habit h in s.active) {
    final best = s.longestStreak(h), total = s.totalDone(h);
    for (final (n, t, d) in _levels) {
      final v = n <= 21 ? best : total;
      out.add(Rozet('${h.identity}: $t', '${h.name} · ${n <= 21 ? "$n günlük seri" : "toplam $d"}',
          v >= n, (v / n).clamp(0, 1).toDouble()));
    }
  }
  out.sort((a, b) => (b.earned ? 1 : 0).compareTo(a.earned ? 1 : 0));
  return out;
}
