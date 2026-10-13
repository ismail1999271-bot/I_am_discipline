import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'models.dart';
import 'store.dart';
import 'theme.dart';
import 'budget.dart' show tl;
import 'main.dart' show store, toast, CoachPage;

/// Yaşam alanları (yaşam çarkının eksenleri)
const lifeAreas = <String, IconData>{
  'Dil': Icons.translate,
  'Vücut': Icons.fitness_center,
  'Tasarruf': Icons.savings_outlined,
  'Ek gelir': Icons.trending_up,
  'Zihin': Icons.psychology_outlined,
  'Kariyer': Icons.work_outline,
};

/// Kimlik → yaşam alanı eşlemesi (alışkanlık gücünü çarka yansıtmak için)
const _identityArea = {
  'Dil bilen': 'Dil', 'Fit': 'Vücut', 'Okuyan': 'Zihin', 'Sakin zihin': 'Zihin',
  'Üreten': 'Kariyer', 'Girişimci': 'Ek gelir', 'Disiplinli': 'Tasarruf',
};

/// metric: manual | savings | income | weight | workouts | habit
class GoalTemplate {
  final String area, title, metric, unit, why;
  final num target;
  final List<String> months;
  const GoalTemplate(this.area, this.title, this.metric, this.target, this.unit, this.why, this.months);
}

const goalTemplates = <GoalTemplate>[
  GoalTemplate('Dil', '1 yılda yeni bir dil konuş', 'habit', 6000, 'kelime',
      'Günde 20 kelime + her gün 15 dk dinleme = 1 yılda B1 seviyesi.', [
    'Alfabe, telaffuz, en sık 300 kelime',
    'Temel cümle kalıpları, 600 kelime',
    'Şimdiki/geçmiş zaman, 1000 kelime',
    'Her gün 15 dk dizi/podcast (altyazılı)',
    'Kendinle konuşma: günde 5 dk sesli anlatım',
    'İlk online konuşma partneri / ders',
    'Altyazısız kısa videolar, 3000 kelime',
    'Haftada 2 konuşma seansı',
    'Basit kitap/hikâye oku',
    'Günlük hayatını o dilde yaz (5 cümle)',
    'B1 deneme sınavı çöz, eksikleri kapat',
    '10 dakikalık sohbet: hedefe ulaştın',
  ]),
  GoalTemplate('Vücut', 'Vücudumu dönüştür', 'workouts', 150, 'antrenman',
      'Haftada 3 antrenman = yılda ~150. Kilo değil, tutarlılık hedefi.', [
    'Haftada 2 antrenman, form öğren',
    'Haftada 3 antrenmana çık',
    'Su ve uyku düzeni: günde 2,5 L, 7 saat',
    'Protein hedefine her gün ulaş',
    'İlk ölçüm karşılaştırması (bel, kilo)',
    'Ağırlıkları %10 artır',
    '30 dk kesintisiz kardiyo',
    'Şeker/hazır gıdayı yarıya indir',
    '5 km yürü/koş',
    'Yeni program: üst/alt bölge',
    'Fotoğraf ve ölçü karşılaştırması',
    'Yılın en güçlü hali: kişisel rekor günü',
  ]),
  GoalTemplate('Tasarruf', 'Yıllık birikim hedefi', 'savings', 60000, '₺',
      'Gelirin %20\'si her ay ilk gün birikime. Önce kendine öde.', [
    'Tüm harcamaları 1 ay boyunca kaydet',
    'Gereksiz abonelikleri iptal et',
    'Acil durum fonunu başlat',
    'Market listesiyle alışveriş, israfı kes',
    'Kredi kartı borcunu kapat / azalt',
    'Acil durum fonu 1 ay gidere ulaşsın',
    'Faturaları karşılaştır, tarife düşür',
    'Birikimi ayrı hesaba otomatik aktar',
    'Acil durum fonu 3 ay gidere ulaşsın',
    'Bir hedef birikimi aç (tatil, araba)',
    'Yıl sonu harcamalarını önceden planla',
    'Yıllık birikim hedefi tamam',
  ]),
  GoalTemplate('Ek gelir', 'Ek gelir kaynağı kur', 'income', 5000, '₺/ay',
      'Yıl sonunda maaş dışında her ay düzenli gelen bir kaynak.', [
    'Becerilerini listele, 3 fikir seç',
    'Bir fikri seç, piyasayı araştır',
    'Beceriyi geliştir: günde 1 saat',
    'Portfolyo / ilk ürün / profil oluştur',
    'İlk müşteri veya ilk satış',
    'Fiyatını belirle, 3 müşteriye ulaş',
    'Aylık 1.000 ₺ ek gelir',
    'Süreçleri hızlandır, şablon oluştur',
    'Aylık 2.500 ₺ ek gelir',
    'Tavsiye / yorum topla, görünürlüğü artır',
    'Aylık 4.000 ₺ ek gelir',
    'Aylık 5.000 ₺: düzenli gelir kaynağı',
  ]),
  GoalTemplate('Zihin', 'Yılda 24 kitap', 'habit', 24, 'kitap',
      'Günde 30 dk okuma ≈ ayda 2 kitap.', [
    'Okuma listesi: 24 kitap seç', '2 kitap', '4 kitap', '6 kitap', '8 kitap', '10 kitap',
    '12 kitap: yarı yol', '14 kitap', '16 kitap', '18 kitap', '21 kitap', '24 kitap 🏆',
  ]),
  GoalTemplate('Kariyer', 'Kariyerimde bir basamak çık', 'manual', 100, '%',
      'Yeni beceri + görünürlük + doğru zamanda talep.', [
    'Hedef pozisyonu/rolü netleştir',
    'Eksik becerileri listele',
    'Bir kurs/sertifika başlat',
    'Haftada 5 saat derin çalışma',
    'Kursu bitir',
    'Gerçek bir projede uygula',
    'CV ve LinkedIn güncelle',
    'Yöneticinle hedef görüşmesi',
    'Sektörden 5 kişiyle tanış',
    'Başarılarını belgeleyip sun',
    'Terfi / zam / yeni iş görüşmesi',
    'Yeni basamak 🏆',
  ]),
];

// ---------- ilerleme hesapları ----------
double goalProgress(Map<String, dynamic> g) {
  final target = (g['target'] as num).toDouble();
  if (target <= 0) return 0;
  return (goalValue(g) / target).clamp(0, 1).toDouble();
}

double goalValue(Map<String, dynamic> g) {
  final year = '${DateTime.now().year}';
  switch (g['metric']) {
    case 'savings':
      return store.savingsGoals.fold<double>(0, (a, s) => a + (s['saved'] as num));
    case 'income':
      // son ayın ek geliri, hedef aylık
      final mk = dayKey(DateTime.now()).substring(0, 7);
      final m = store.incomes.where((e) => (e['date'] as String).startsWith(mk)).fold<double>(0, (a, e) => a + (e['amt'] as num));
      return m;
    case 'workouts':
      return store.sessions.where((s) => (s['date'] as String).startsWith(year)).length.toDouble();
    case 'habit':
      final key = g['habit'] as String?;
      if (key == null) return ((g['manual'] ?? 0) as num).toDouble();
      double t = 0;
      store.log.forEach((d, m) { if (d.startsWith(year) && m[key] != null) t += m[key]!.value; });
      final div = ((g['per'] ?? 1) as num).toDouble(); // örn. 30 dk = 1 birim değil; per ile bölünür
      return t / (div == 0 ? 1 : div);
    default:
      return ((g['manual'] ?? 0) as num).toDouble();
  }
}

/// Yaşam çarkı skoru (0-1): alandaki hedeflerin ilerlemesi + ilgili alışkanlıkların gücü + aylık adımlar
Map<String, double> lifeScores() {
  final out = <String, double>{};
  for (final a in lifeAreas.keys) {
    final parts = <double>[];
    for (final g in store.yearGoals.where((g) => g['area'] == a)) {
      parts.add(goalProgress(g));
      final done = (g['done'] as List).where((x) => x == true).length;
      final dueMonths = DateTime.now().month;
      parts.add((done / dueMonths).clamp(0, 1).toDouble());
    }
    for (final h in store.active) {
      if (_identityArea[h.identity] == a) parts.add(store.strength(h) / 100);
    }
    if (a == 'Tasarruf' && (store.budget['income'] ?? 0) != 0) parts.add(store.budgetOnTrackToday ? .8 : .3);
    out[a] = parts.isEmpty ? 0 : parts.reduce((x, y) => x + y) / parts.length;
  }
  return out;
}

// ======================= PLAN SAYFASI =======================
class PlanPage extends StatelessWidget {
  const PlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final now = DateTime.now();
    final scores = lifeScores();
    final yearPct = now.difference(DateTime(now.year)).inDays / (DateTime(now.year + 1).difference(DateTime(now.year)).inDays);
    final goals = store.yearGoals;
    final avg = scores.values.isEmpty ? 0.0 : scores.values.reduce((a, b) => a + b) / scores.length;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text('${now.year} PLANI', style: tt.headlineMedium),
      Text('Yılın %${(yearPct * 100).round()}\'i geride. Kalan ${DateTime(now.year + 1).difference(now).inDays} gün.',
          style: const TextStyle(color: Iron.steel)),
      const SizedBox(height: 6),
      ClipRRect(borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(value: yearPct, minHeight: 4, color: Iron.steel)),
      const SizedBox(height: 20),

      // Yaşam çarkı
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Iron.surface, border: Border.all(color: Iron.line), borderRadius: BorderRadius.circular(6)),
        child: Column(children: [
          Row(children: [
            Expanded(child: Text('YAŞAM ÇARKI', style: tt.labelMedium)),
            Text('GENEL %${(avg * 100).round()}', style: tt.titleMedium?.copyWith(color: Iron.fire)),
          ]),
          const SizedBox(height: 8),
          AspectRatio(aspectRatio: 1.15, child: CustomPaint(painter: RadarPainter(scores))),
          const SizedBox(height: 4),
          Text(_weakest(scores), textAlign: TextAlign.center, style: const TextStyle(color: Iron.steel, fontSize: 12)),
        ]),
      ),
      const SizedBox(height: 20),

      Row(children: [
        Expanded(child: Text('YILLIK HEDEFLER', style: tt.labelMedium)),
        TextButton.icon(onPressed: () => _addGoal(context), icon: const Icon(Icons.add), label: const Text('HEDEF')),
      ]),
      if (goals.isEmpty)
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Bu yıl kim olacaksın?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 6),
          const Text('Bir hedef seç; ben 12 aya bölüp her ayın adımını vereyim. Günlük alışkanlıkların bu hedefi otomatik ilerletir.'),
          const SizedBox(height: 12),
          FilledButton(onPressed: () => _addGoal(context), child: const Text('İLK HEDEFİMİ SEÇ')),
        ]))),
      for (final g in goals) GoalCard(g),

      if (goals.any((g) => g['metric'] == 'income')) ...[
        const SizedBox(height: 20),
        IncomeSection(),
      ],
      const SizedBox(height: 20),
      Card(child: ListTile(
        leading: const Icon(Icons.psychology, color: Iron.fire),
        title: const Text('Koç'),
        subtitle: const Text('Desenlerini analiz et, sistemini ayarla'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(), body: const CoachPage()))),
      )),
      const SizedBox(height: 80),
    ]);
  }

  String _weakest(Map<String, double> s) {
    if (s.values.every((v) => v == 0)) return 'Hedef ve alışkanlık ekledikçe çark dolacak.';
    final w = s.entries.reduce((a, b) => a.value <= b.value ? a : b);
    return 'En zayıf alanın: ${w.key}. Bu ay oraya küçük bir alışkanlık ekle.';
  }

  Future<void> _addGoal(BuildContext context) async {
    final used = store.yearGoals.map((g) => g['title']).toSet();
    await showModalBottomSheet(context: context, isScrollControlled: true, useSafeArea: true,
      builder: (ctx) => ListView(padding: const EdgeInsets.all(20), shrinkWrap: true, children: [
        Text('YILLIK HEDEF SEÇ', style: Theme.of(ctx).textTheme.headlineSmall),
        const SizedBox(height: 12),
        for (final t in goalTemplates)
          if (!used.contains(t.title))
            Card(child: ListTile(
              leading: Icon(lifeAreas[t.area], color: Iron.fire),
              title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text(t.why),
              onTap: () async {
                Navigator.pop(ctx);
                await _configure(context, t);
              },
            )),
      ]));
  }

  Future<void> _configure(BuildContext context, GoalTemplate t) async {
    final target = TextEditingController(text: '${t.target}');
    String? habit;
    num per = 1;
    final candidates = store.active.where((h) => h.type != HabitType.bool_).toList();
    final ok = await showDialog<bool>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, set) => AlertDialog(
      title: Text(t.title),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        TextField(controller: target, keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Yıllık hedef', suffixText: t.unit)),
        if (t.metric == 'habit') ...[
          const SizedBox(height: 12),
          const Text('Hangi alışkanlık bu hedefi ilerletsin?', style: TextStyle(fontSize: 12)),
          DropdownButtonFormField<String?>(
            initialValue: habit,
            items: [
              const DropdownMenuItem(value: null, child: Text('Elle gireceğim')),
              for (final h in candidates) DropdownMenuItem(value: h.key, child: Text('${h.name} (${h.unit})')),
            ],
            onChanged: (v) => set(() {
              habit = v;
              final h = candidates.where((x) => x.key == v).firstOrNull;
              // Kitap hedefi + dakika ölçülen alışkanlık: ~6 saat (360 dk) = 1 kitap
              per = (t.unit == 'kitap' && h?.unit == 'dk') ? 360 : (t.unit == 'kitap' && h?.unit == 'sayfa') ? 250 : 1;
            }),
          ),
          if (per > 1) Text('Hesap: her $per ${candidates.firstWhere((x) => x.key == habit).unit} = 1 ${t.unit}',
              style: const TextStyle(fontSize: 12, color: Iron.steel)),
        ],
        const SizedBox(height: 12),
        Text(_metricHint(t.metric), style: const TextStyle(fontSize: 12, color: Iron.steel)),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Başla')),
      ],
    )));
    final v = num.tryParse(target.text);
    if (ok != true || v == null || v <= 0) return;
    store.addYearGoal({
      'id': DateTime.now().microsecondsSinceEpoch.toString(), 'area': t.area, 'title': t.title,
      'metric': t.metric, 'target': v, 'unit': t.unit, 'habit': habit, 'per': per, 'manual': 0,
      'months': t.months, 'done': List.filled(12, false),
    });
    if (context.mounted) toast(context, '${t.title}: 12 aylık yol haritası hazır.');
  }

  String _metricHint(String m) => switch (m) {
        'savings' => 'İlerleme, Yaşam > Bütçe > Birikim hesabındaki toplamdan otomatik gelir.',
        'income' => 'Ek gelirini bu sayfadan kaydet; hedef bu ayki toplamla karşılaştırılır.',
        'workouts' => 'Yaşam > Antrenman\'da kaydettiğin her seans otomatik sayılır.',
        'habit' => 'Seçtiğin alışkanlığın bu yılki toplamı otomatik sayılır.',
        _ => 'İlerlemeyi aylık adımları işaretleyerek ve elle güncelleyerek takip edersin.',
      };
}

// ======================= HEDEF KARTI =======================
class GoalCard extends StatelessWidget {
  final Map<String, dynamic> g;
  const GoalCard(this.g, {super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final p = goalProgress(g);
    final v = goalValue(g);
    final month = DateTime.now().month;
    final done = List<bool>.from(g['done']);
    final months = List<String>.from(g['months']);
    final expected = month / 12;
    final ahead = p >= expected;
    return Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        SizedBox(width: 78, height: 78, child: CustomPaint(painter: RingPainter(p, expected),
            child: Center(child: Text('%${(p * 100).round()}', style: tt.titleLarge?.copyWith(color: Iron.fire))))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(lifeAreas[g['area']], size: 14, color: Iron.steel),
            const SizedBox(width: 4),
            Text((g['area'] as String).toUpperCase(), style: tt.labelSmall),
          ]),
          Text(g['title'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 4),
          Text(g['unit'] == '₺' || g['unit'] == '₺/ay' ? '${tl(v)} / ${tl(g['target'])}${g['unit'] == '₺/ay' ? ' (bu ay)' : ''}'
              : '${v.round()} / ${g['target']} ${g['unit']}', style: const TextStyle(color: Iron.steel)),
          Text(ahead ? 'Plandan öndesin 🔥' : 'Plan: bu ay sonu %${(expected * 100).round()}',
              style: TextStyle(color: ahead ? Iron.fire : Iron.ember, fontSize: 12, fontWeight: FontWeight.w700)),
        ])),
        PopupMenuButton<String>(
          onSelected: (s) async {
            if (s == 'del') store.removeYearGoal(g['id']);
            if (s == 'set') {
              final c = TextEditingController(text: '${g['manual'] ?? 0}');
              final n = await showDialog<num>(context: context, builder: (ctx) => AlertDialog(
                title: const Text('İlerlemeyi güncelle'),
                content: TextField(controller: c, keyboardType: TextInputType.number, decoration: InputDecoration(suffixText: g['unit'])),
                actions: [FilledButton(onPressed: () => Navigator.pop(ctx, num.tryParse(c.text)), child: const Text('Kaydet'))],
              ));
              if (n != null) store.updateYearGoal(g['id'], {'manual': n});
            }
          },
          itemBuilder: (_) => [
            if (g['metric'] == 'manual' || (g['metric'] == 'habit' && g['habit'] == null))
              const PopupMenuItem(value: 'set', child: Text('İlerlemeyi güncelle')),
            const PopupMenuItem(value: 'del', child: Text('Hedefi sil')),
          ],
        ),
      ]),
      const SizedBox(height: 14),
      // 12 aylık şerit
      Row(children: [
        for (var i = 0; i < 12; i++)
          Expanded(child: GestureDetector(
            onTap: () => store.toggleGoalMonth(g['id'], i),
            child: Container(height: 22, margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: done[i] ? Iron.fire : i + 1 < month ? const Color(0xFF3A1708) : Iron.bg,
                border: Border.all(color: i + 1 == month ? Iron.white : Iron.line, width: i + 1 == month ? 1.5 : 1),
                borderRadius: BorderRadius.circular(2)),
              alignment: Alignment.center,
              child: Text('${i + 1}', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900,
                  color: done[i] ? Colors.black : Iron.steel))),
          )),
      ]),
      const SizedBox(height: 10),
      Container(
        width: double.infinity, padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Iron.bg, border: const Border(left: BorderSide(color: Iron.fire, width: 3))),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${month}. AYIN ADIMI', style: tt.labelSmall),
            Text(months[month - 1], style: const TextStyle(fontWeight: FontWeight.w700)),
          ])),
          Checkbox(value: done[month - 1], onChanged: (_) => store.toggleGoalMonth(g['id'], month - 1)),
        ]),
      ),
      if (month < 12) Padding(padding: const EdgeInsets.only(top: 6),
          child: Text('Sonraki ay: ${months[month]}', style: const TextStyle(color: Iron.steel, fontSize: 12))),
    ])));
  }
}

// ======================= EK GELİR =======================
class IncomeSection extends StatelessWidget {
  const IncomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final now = DateTime.now();
    final monthly = List<double>.generate(12, (i) {
      final mk = '${now.year}-${(i + 1).toString().padLeft(2, '0')}';
      return store.incomes.where((e) => (e['date'] as String).startsWith(mk)).fold<double>(0, (a, e) => a + (e['amt'] as num));
    });
    final year = monthly.reduce((a, b) => a + b);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Iron.surface, border: Border.all(color: Iron.line), borderRadius: BorderRadius.circular(6)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('EK GELİR ${now.year}', style: tt.labelMedium)),
          Text(tl(year), style: tt.titleLarge?.copyWith(color: Iron.fire)),
        ]),
        const SizedBox(height: 12),
        SizedBox(height: 120, child: CustomPaint(size: Size.infinite, painter: BarsPainter(monthly, now.month - 1))),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: FilledButton.icon(onPressed: () => _add(context), icon: const Icon(Icons.add), label: const Text('GELİR EKLE'))),
        ]),
        for (final e in store.incomes.reversed.take(5))
          ListTile(contentPadding: EdgeInsets.zero, dense: true,
              title: Text(e['src']), subtitle: Text(e['date']),
              trailing: Text('+${tl(e['amt'])}', style: const TextStyle(color: Iron.fire, fontWeight: FontWeight.w900)),
              onLongPress: () => store.removeIncome(e['id'])),
      ]),
    );
  }

  Future<void> _add(BuildContext context) async {
    final amt = TextEditingController(), src = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Ek gelir'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: amt, autofocus: true, keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Tutar', suffixText: '₺')),
        TextField(controller: src, decoration: const InputDecoration(labelText: 'Kaynak', hintText: 'Freelance, satış, ders...')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Kaydet')),
      ],
    ));
    final v = num.tryParse(amt.text);
    if (ok != true || v == null || v <= 0) return;
    store.addIncome({'id': DateTime.now().microsecondsSinceEpoch.toString(), 'date': dayKey(DateTime.now()),
      'amt': v, 'src': src.text.trim().isEmpty ? 'Ek gelir' : src.text.trim()});
    if (context.mounted) toast(context, '+${tl(v)}. Girişimci kimliğine oy!');
  }
}

// ======================= ÇİZİMLER =======================
class RadarPainter extends CustomPainter {
  final Map<String, double> s;
  RadarPainter(this.s);

  @override
  void paint(Canvas c, Size size) {
    final keys = s.keys.toList();
    final n = keys.length;
    final center = Offset(size.width / 2, size.height / 2 + 4);
    final r = math.min(size.width, size.height) / 2 - 34;
    Offset pt(int i, double v) {
      final a = -math.pi / 2 + 2 * math.pi * i / n;
      return center + Offset(math.cos(a), math.sin(a)) * r * v;
    }
    final grid = Paint()..color = Iron.line..style = PaintingStyle.stroke..strokeWidth = 1;
    for (final lv in [.25, .5, .75, 1.0]) {
      final p = Path()..moveTo(pt(0, lv).dx, pt(0, lv).dy);
      for (var i = 1; i < n; i++) { p.lineTo(pt(i, lv).dx, pt(i, lv).dy); }
      p.close();
      c.drawPath(p, grid);
    }
    for (var i = 0; i < n; i++) { c.drawLine(center, pt(i, 1), grid); }
    // Veri alanı
    final data = Path();
    for (var i = 0; i < n; i++) {
      final v = math.max(.04, s[keys[i]]!);
      final o = pt(i, v);
      i == 0 ? data.moveTo(o.dx, o.dy) : data.lineTo(o.dx, o.dy);
    }
    data.close();
    c.drawPath(data, Paint()..color = Iron.fire.withValues(alpha: .28));
    c.drawPath(data, Paint()..color = Iron.fire..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeJoin = StrokeJoin.round);
    for (var i = 0; i < n; i++) {
      c.drawCircle(pt(i, math.max(.04, s[keys[i]]!)), 4, Paint()..color = Iron.fire);
      // Etiket
      final tp = TextPainter(
        text: TextSpan(children: [
          TextSpan(text: '${keys[i].toUpperCase()}\n', style: const TextStyle(color: Iron.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: .8)),
          TextSpan(text: '%${(s[keys[i]]! * 100).round()}', style: const TextStyle(color: Iron.fire, fontSize: 11, fontWeight: FontWeight.w800)),
        ]),
        textAlign: TextAlign.center, textDirection: TextDirection.ltr)..layout();
      final lp = pt(i, 1.0) + (pt(i, 1.0) - center) / r * 20;
      tp.paint(c, lp - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant RadarPainter o) => true;
}

class RingPainter extends CustomPainter {
  final double v, expected;
  RingPainter(this.v, this.expected);

  @override
  void paint(Canvas c, Size s) {
    final rect = Offset.zero & s;
    final r = rect.deflate(5);
    c.drawArc(r, 0, 2 * math.pi, false, Paint()..color = Iron.line..style = PaintingStyle.stroke..strokeWidth = 8);
    c.drawArc(r, -math.pi / 2, 2 * math.pi * v, false,
        Paint()..color = Iron.fire..style = PaintingStyle.stroke..strokeWidth = 8..strokeCap = StrokeCap.butt);
    // Plan işareti: yılın bu noktasında olman gereken yer
    final a = -math.pi / 2 + 2 * math.pi * expected;
    final cen = rect.center, rad = r.width / 2;
    c.drawLine(cen + Offset(math.cos(a), math.sin(a)) * (rad - 7), cen + Offset(math.cos(a), math.sin(a)) * (rad + 7),
        Paint()..color = Iron.white..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant RingPainter o) => o.v != v;
}

class BarsPainter extends CustomPainter {
  final List<double> v;
  final int current;
  BarsPainter(this.v, this.current);

  @override
  void paint(Canvas c, Size s) {
    final mx = v.reduce(math.max);
    final w = s.width / 12;
    const labels = ['O', 'Ş', 'M', 'N', 'M', 'H', 'T', 'A', 'E', 'E', 'K', 'A'];
    for (var i = 0; i < 12; i++) {
      final h = mx == 0 ? 0.0 : (v[i] / mx) * (s.height - 18);
      final rect = Rect.fromLTWH(i * w + w * .18, s.height - 16 - h, w * .64, h);
      c.drawRect(rect, Paint()..color = i == current ? Iron.fire : i < current ? const Color(0xFF7A2A0C) : Iron.line);
      final tp = TextPainter(text: TextSpan(text: labels[i],
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: i == current ? Iron.fire : Iron.steel)),
          textDirection: TextDirection.ltr)..layout();
      tp.paint(c, Offset(i * w + w / 2 - tp.width / 2, s.height - 13));
    }
    if (mx == 0) {
      final tp = TextPainter(text: const TextSpan(text: 'İlk ek gelirini kaydet', style: TextStyle(color: Iron.steel, fontSize: 12)),
          textDirection: TextDirection.ltr)..layout();
      tp.paint(c, Offset(s.width / 2 - tp.width / 2, s.height / 2 - 14));
    }
  }

  @override
  bool shouldRepaint(covariant BarsPainter o) => true;
}
