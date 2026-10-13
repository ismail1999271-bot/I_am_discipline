import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'food_db.dart';
import 'store.dart';
import 'main.dart' show store, toast;

/// Mifflin-St Jeor ile günlük kalori hedefi.
int calorieTarget(Map<String, dynamic> p) {
  final w = (p['kilo'] ?? 75).toDouble(), h = (p['boy'] ?? 175).toDouble(), a = (p['yas'] ?? 30).toDouble();
  final male = (p['cinsiyet'] ?? 'Erkek') == 'Erkek';
  final bmr = 10 * w + 6.25 * h - 5 * a + (male ? 5 : -161);
  const act = {'Hareketsiz': 1.2, 'Az aktif': 1.375, 'Orta aktif': 1.55, 'Çok aktif': 1.725};
  final tdee = bmr * (act[p['aktivite']] ?? 1.375);
  final goal = p['hedef'] ?? 'Korumak';
  // Güvenli aralık: en fazla 500 kcal açık/fazla, alt sınır 1500 (erkek) / 1200 (kadın)
  var t = goal == 'Kilo vermek' ? tdee - 500 : goal == 'Kilo almak' ? tdee + 300 : tdee;
  final floor = male ? 1500 : 1200;
  if (t < floor) t = floor.toDouble();
  return t.round();
}


class Paywall extends StatelessWidget {
  const Paywall({super.key});
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    Widget row(IconData i, String t, String s) => ListTile(leading: Icon(i, color: cs.primary), title: Text(t), subtitle: Text(s));
    return ListView(padding: const EdgeInsets.all(20), children: [
      Icon(Icons.workspace_premium, size: 56, color: cs.primary),
      Text('Premium', style: tt.headlineMedium, textAlign: TextAlign.center),
      const Text('Cebindeki beslenme koçu ve antrenman asistanı.', textAlign: TextAlign.center),
      const SizedBox(height: 16),
      row(Icons.restaurant, 'Yemek kalori hesabı', '55+ Türk yemeği, porsiyon bazlı'),
      row(Icons.track_changes, 'Kişisel kalori hedefi', 'Boy, kilo, yaş ve aktiviteye göre'),
      row(Icons.pie_chart_outline, 'Protein, karbonhidrat, yağ', 'Günlük makro dağılımı'),
      row(Icons.auto_awesome, 'Yazarak kalori tahmini', '"2 dilim pide ve ayran" yaz, AI hesaplasın'),
      row(Icons.water_drop_outlined, 'Su takibi', 'Kilona göre günlük hedef'),
      row(Icons.calendar_month, 'AI haftalık yemek planı', 'Hedef kalorine göre Türk mutfağı menüsü + alışveriş listesi'),
      row(Icons.kitchen, 'Buzdolabında ne var?', 'Elindeki malzemeyle tarif önerisi'),
      row(Icons.fitness_center, 'Antrenman programları', 'Ev, salon, 0→5 km koşu, yoga'),
      row(Icons.timer_outlined, 'Set kaydı ve dinlenme sayacı', 'Geçen seansa göre "+2,5 kg dene" önerisi'),
      row(Icons.auto_awesome_motion, 'AI kişisel antrenman programı', 'Hedef, yer ve gün sayına göre'),
      row(Icons.monitor_weight_outlined, 'Kilo ve ölçü takibi', 'Grafikle değişimini gör'),
      row(Icons.how_to_reg, 'Fit kimliğine oy', 'Antrenman ve kalori hedefi günleri +2 oy'),
      const SizedBox(height: 16),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        Text('₺59,99 / ay', style: tt.headlineSmall),
        const Text('veya ₺399,99 / yıl (%44 indirim) · 7 gün ücretsiz dene'),
      ]))),
      const SizedBox(height: 12),
      FilledButton(
          onPressed: () => toast(context, 'Ödeme sistemi mağaza yayınından önce bağlanacak.'),
          child: const Text('7 gün ücretsiz başla')),
      const SizedBox(height: 8),
      // Geliştirme sırasında test için. Yayın öncesi kaldırılacak.
      TextButton(onPressed: () => store.setPremium(true), child: const Text('Test için premium aç')),
    ]);
  }
}

class CalorieSection extends StatelessWidget {
  const CalorieSection({super.key});
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    if (store.bodyProfile.isEmpty) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SizedBox(height: 12),
        Text('Kalori hedefini belirleyelim', style: tt.headlineSmall),
        const Text('Birkaç bilgiyle günlük hedefini hesaplarım.'),
        const SizedBox(height: 16),
        FilledButton(onPressed: () => editProfile(context), child: const Text('Bilgilerimi gir')),
      ]);
    }
    final day = dayKey(DateTime.now());
    final meals = store.meals[day] ?? [];
    final target = calorieTarget(store.bodyProfile);
    double sum(String k) => meals.fold(0.0, (a, m) => a + (m[k] as num).toDouble());
    final kcal = sum('kcal'), p = sum('p'), c = sum('c'), f = sum('f');
    final left = target - kcal;
    final ratio = (kcal / target).clamp(0, 1.2).toDouble();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(child: Text('Kalori', style: tt.titleLarge)),
        IconButton(onPressed: () => editProfile(context), icon: const Icon(Icons.tune), tooltip: 'Hedef ayarı'),
      ]),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${kcal.round()} / $target kcal', style: tt.headlineSmall),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: ratio > 1 ? 1 : ratio, minHeight: 10,
            color: kcal > target * 1.1 ? cs.error : cs.primary),
        const SizedBox(height: 8),
        Text(left >= 0 ? '${left.round()} kcal kaldı' : '${(-left).round()} kcal fazla',
            style: TextStyle(color: left >= 0 ? null : cs.error)),
        const SizedBox(height: 12),
        Row(children: [
          _macro('Protein', p, target * .25 / 4, cs.primary),
          _macro('Karb.', c, target * .45 / 4, cs.tertiary),
          _macro('Yağ', f, target * .30 / 9, cs.secondary),
        ]),
      ]))),
      Row(children: [
        Expanded(child: FilledButton.icon(onPressed: () => addFood(context), icon: const Icon(Icons.search), label: const Text('Yemek ekle'))),
        const SizedBox(width: 8),
        Expanded(child: OutlinedButton.icon(onPressed: () => aiMeal(context), icon: const Icon(Icons.auto_awesome), label: const Text('Yazarak ekle'))),
      ]),
      const SizedBox(height: 12),
      for (var i = 0; i < meals.length; i++)
        Dismissible(
          key: ValueKey('$day-$i-${meals[i]['name']}'),
          onDismissed: (_) => store.removeMeal(day, i),
          background: Container(color: cs.errorContainer),
          child: ListTile(
            title: Text(meals[i]['name']),
            subtitle: Text('${meals[i]['portion']} · P ${(meals[i]['p'] as num).round()} · K ${(meals[i]['c'] as num).round()} · Y ${(meals[i]['f'] as num).round()}'),
            trailing: Text('${(meals[i]['kcal'] as num).round()} kcal'),
          ),
        ),
      if (meals.isEmpty) const Padding(padding: EdgeInsets.all(24),
          child: Text('Henüz öğün yok. Silmek için kaydırabilirsin.', textAlign: TextAlign.center)),
      const SizedBox(height: 8),
      Text('Son 7 gün', style: tt.titleMedium),
      for (var d = 6; d >= 0; d--)
        Builder(builder: (_) {
          final k = dayKey(DateTime.now().subtract(Duration(days: d)));
          final t = (store.meals[k] ?? []).fold(0.0, (a, m) => a + (m['kcal'] as num).toDouble());
          return ListTile(dense: true, contentPadding: EdgeInsets.zero, title: Text(k),
              subtitle: LinearProgressIndicator(value: (t / target).clamp(0, 1).toDouble()),
              trailing: Text(t == 0 ? '-' : '${t.round()}'));
        }),
      const Text('Değerler yaklaşıktır, tıbbi tavsiye değildir.', style: TextStyle(fontSize: 11)),
    ]);
  }

  Widget _macro(String n, double v, double goal, Color col) => Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$n ${v.round()}/${goal.round()} g', style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        LinearProgressIndicator(value: goal == 0 ? 0 : (v / goal).clamp(0, 1).toDouble(), color: col),
      ]));
}

Future<void> editProfile(BuildContext context) async {
  final p = Map<String, dynamic>.from(store.bodyProfile);
  final kilo = TextEditingController(text: '${p['kilo'] ?? ''}'),
      boy = TextEditingController(text: '${p['boy'] ?? ''}'),
      yas = TextEditingController(text: '${p['yas'] ?? ''}');
  var cins = p['cinsiyet'] ?? 'Erkek', akt = p['aktivite'] ?? 'Az aktif', hedef = p['hedef'] ?? 'Korumak';
  await showModalBottomSheet(context: context, isScrollControlled: true, useSafeArea: true,
    builder: (ctx) => StatefulBuilder(builder: (ctx, set) => SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        Text('Bilgilerim', style: Theme.of(ctx).textTheme.titleLarge),
        Row(children: [
          Expanded(child: TextField(controller: kilo, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Kilo (kg)'))),
          const SizedBox(width: 8),
          Expanded(child: TextField(controller: boy, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Boy (cm)'))),
          const SizedBox(width: 8),
          Expanded(child: TextField(controller: yas, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Yaş'))),
        ]),
        const SizedBox(height: 12),
        SegmentedButton<String>(segments: const [ButtonSegment(value: 'Erkek', label: Text('Erkek')), ButtonSegment(value: 'Kadın', label: Text('Kadın'))],
            selected: {cins}, onSelectionChanged: (v) => set(() => cins = v.first)),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(initialValue: akt, decoration: const InputDecoration(labelText: 'Aktivite'),
            items: [for (final a in ['Hareketsiz', 'Az aktif', 'Orta aktif', 'Çok aktif']) DropdownMenuItem(value: a, child: Text(a))],
            onChanged: (v) => akt = v ?? akt),
        DropdownButtonFormField<String>(initialValue: hedef, decoration: const InputDecoration(labelText: 'Hedef'),
            items: [for (final a in ['Kilo vermek', 'Korumak', 'Kilo almak']) DropdownMenuItem(value: a, child: Text(a))],
            onChanged: (v) => hedef = v ?? hedef),
        const SizedBox(height: 16),
        FilledButton(onPressed: () {
          final k = num.tryParse(kilo.text), b = num.tryParse(boy.text), y = num.tryParse(yas.text);
          if (k == null || b == null || y == null) return;
          store.setBodyProfile({'kilo': k, 'boy': b, 'yas': y, 'cinsiyet': cins, 'aktivite': akt, 'hedef': hedef});
          Navigator.pop(ctx);
        }, child: const Text('Kaydet')),
      ]))));
}

Future<void> addFood(BuildContext context) async {
  var q = '';
  await showModalBottomSheet(context: context, isScrollControlled: true, useSafeArea: true,
    builder: (ctx) => StatefulBuilder(builder: (ctx, set) {
      final list = foods.where((f) => f.name.toLowerCase().contains(q.toLowerCase())).toList();
      return Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SizedBox(height: MediaQuery.of(ctx).size.height * .8, child: Column(children: [
          Padding(padding: const EdgeInsets.all(16), child: TextField(autofocus: true,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Yemek ara'),
              onChanged: (v) => set(() => q = v))),
          Expanded(child: ListView(children: [
            for (final f in list)
              ListTile(title: Text(f.name), subtitle: Text('${f.portion} · ${f.kcal.round()} kcal'),
                  onTap: () async {
                    final mult = await _portion(ctx, f);
                    if (mult == null) return;
                    store.addMeal({'name': f.name, 'portion': mult == 1 ? f.portion : '${mult}x ${f.portion}',
                      'kcal': f.kcal * mult, 'p': f.p * mult, 'c': f.c * mult, 'f': f.f * mult});
                    if (ctx.mounted) Navigator.pop(ctx);
                  }),
            if (list.isEmpty) const ListTile(title: Text('Bulunamadı. "Yazarak ekle" ile AI\'a sorabilirsin.')),
          ])),
        ])));
    }));
}

Future<double?> _portion(BuildContext context, Food f) => showDialog<double>(context: context, builder: (ctx) => SimpleDialog(
      title: Text('${f.name} · kaç porsiyon?'),
      children: [
        for (final m in [0.5, 1.0, 1.5, 2.0, 3.0])
          SimpleDialogOption(onPressed: () => Navigator.pop(ctx, m),
              child: Text('${m == m.roundToDouble() ? m.round() : m} × ${f.portion} = ${(f.kcal * m).round()} kcal')),
      ],
    ));

/// Serbest metinden AI ile kalori tahmini (Ollama). JSON döndürmesi istenir.
Future<void> aiMeal(BuildContext context) async {
  final c = TextEditingController();
  final text = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
    title: const Text('Ne yedin?'),
    content: TextField(controller: c, autofocus: true, maxLines: 3,
        decoration: const InputDecoration(hintText: 'örn. 2 dilim kıymalı pide ve 1 ayran')),
    actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
      FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: const Text('Hesapla')),
    ],
  ));
  if (text == null || text.isEmpty || !context.mounted) return;
  toast(context, 'Hesaplanıyor…');
  final prompt = '''Kullanıcının yediği öğünün yaklaşık besin değerlerini hesapla.
Sadece şu biçimde JSON döndür, başka hiçbir şey yazma:
{"kcal": sayı, "p": protein_gram, "c": karbonhidrat_gram, "f": yağ_gram}
Öğün: $text''';
  try {
    final r = await http.post(Uri.parse('${store.ollamaHost}/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'model': store.ollamaModel, 'prompt': prompt, 'stream': false, 'format': 'json'}))
        .timeout(const Duration(seconds: 90));
    final j = jsonDecode(jsonDecode(utf8.decode(r.bodyBytes))['response']);
    store.addMeal({'name': text, 'portion': 'AI tahmini', 'kcal': (j['kcal'] as num).toDouble(),
      'p': (j['p'] as num).toDouble(), 'c': (j['c'] as num).toDouble(), 'f': (j['f'] as num).toDouble()});
    if (context.mounted) toast(context, 'Eklendi: ${(j['kcal'] as num).round()} kcal');
  } catch (_) {
    if (context.mounted) toast(context, 'AI\'a ulaşılamadı. Listeden eklemeyi dene.');
  }
}
