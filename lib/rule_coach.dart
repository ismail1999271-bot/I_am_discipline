import 'models.dart';
import 'store.dart';

/// İnternet / Ollama gerektirmeyen yedek koç.
List<String> ruleCoach(Store s) {
  const g = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
  final tips = <String>[];
  final now = DateTime.now();
  for (final Habit h in s.active) {
    final miss = List.filled(7, 0), tot = List.filled(7, 0);
    var done = 0, mini = 0;
    for (var i = 1; i <= 28; i++) {
      final d = now.subtract(Duration(days: i));
      if (!h.on(d)) continue;
      final w = d.weekday - 1;
      tot[w]++;
      final e = s.log[dayKey(d)]?[h.key];
      if (e == null) { miss[w]++; } else { done++; if (e.level == 1) mini++; }
    }
    var wi = 0;
    for (var i = 1; i < 7; i++) { if (tot[i] > 0 && (tot[wi] == 0 || miss[i] / tot[i] > miss[wi] / tot[wi])) wi = i; }
    if (tot[wi] >= 2 && miss[wi] / tot[wi] >= .5) {
      tips.add('${h.name}: ${g[wi]} günleri genelde kaçırıyorsun. O gün saati değiştir ya da sadece minimumu hedefle.');
    }
    if (done > 0 && mini / done > .4) {
      tips.add('${h.name}: günlerin çoğu minimumda. Hedefi ${(h.goal * .7).round()} ${h.unit} yapmak seriyi güçlendirir.');
    }
    if (s.strength(h) >= 75) {
      tips.add('${h.name} artık kimliğinin parçası (%${s.strength(h)}). Yeni bir alışkanlık eklemeye hazırsın.');
    }
  }
  // Kaçırma sebeplerine göre öneri
  final count = <String, int>{};
  for (final m in s.skips.values) { for (final r in m.values) { count[r] = (count[r] ?? 0) + 1; } }
  if (count.isNotEmpty) {
    final top = count.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    const advice = {
      'Unuttum': 'En sık sebep "unuttum". Günlük hatırlatıcıyı aç veya alışkanlığı sabit bir ana bağla (kahveden sonra gibi).',
      'Vakit yok': 'En sık sebep "vakit yok". O günlerde sadece minimumu yap; seri ve kimlik korunur.',
      'Yorgun': 'En sık sebep "yorgunluk". Alışkanlığı günün daha erken saatine al.',
      'İsteksiz': 'En sık sebep "isteksizlik". Hedefi küçült ve sadece başlamayı hedefle: 2 dakika kuralı.',
    };
    tips.insert(0, advice[top] ?? 'Kaçırma sebeplerini işaretlemeye devam et.');
  }
  if (tips.isEmpty) tips.add('Henüz yeterli veri yok. Birkaç gün işaretle, desenleri bulayım.');
  return tips.take(3).toList();
}

/// Son 30 gün ortalamasıyla 1 yıllık toplam.
String yearProjection(Store s, Habit h) {
  final now = DateTime.now();
  num t = 0;
  for (var i = 0; i < 30; i++) { t += s.log[dayKey(now.subtract(Duration(days: i)))]?[h.key]?.value ?? 0; }
  final y = t / 30 * 365;
  if (h.type == HabitType.bool_) return '${y.round()} gün';
  if (h.unit == 'dk') return '${(y / 60).round()} saat';
  return '${y.round()} ${h.unit}';
}
