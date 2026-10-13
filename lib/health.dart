import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'calorie.dart';
import 'store.dart';
import 'workout_db.dart';
import 'main.dart' show store, toast;

/// Premium "Sağlık" sekmesi: Beslenme · Antrenman · Vücut
class HealthPage extends StatelessWidget {
  const HealthPage({super.key});
  @override
  Widget build(BuildContext context) {
    if (!store.premium) return const Paywall();
    return DefaultTabController(length: 3, child: Column(children: [
      const TabBar(tabs: [Tab(text: 'Beslenme'), Tab(text: 'Antrenman'), Tab(text: 'Vücut')]),
      Expanded(child: TabBarView(children: [
        ListenableBuilder(listenable: store, builder: (_, __) => const NutritionTab()),
        ListenableBuilder(listenable: store, builder: (_, __) => const WorkoutTab()),
        ListenableBuilder(listenable: store, builder: (_, __) => const BodyTab()),
      ])),
    ]));
  }
}

/// Ollama'ya düz metin isteği
Future<String?> askAi(String prompt) async {
  try {
    final r = await http.post(Uri.parse('${store.ollamaHost}/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'model': store.ollamaModel, 'prompt': prompt, 'stream': false}))
        .timeout(const Duration(seconds: 180));
    if (r.statusCode != 200) return null;
    return (jsonDecode(utf8.decode(r.bodyBytes))['response'] as String).trim();
  } catch (_) {
    return null;
  }
}

// ======================= BESLENME =======================
class NutritionTab extends StatefulWidget {
  const NutritionTab({super.key});
  @override
  State<NutritionTab> createState() => _NutritionTabState();
}

class _NutritionTabState extends State<NutritionTab> {
  bool busy = false;

  Future<void> makePlan() async {
    if (store.bodyProfile.isEmpty) { toast(context, 'Önce Kalori bölümünden bilgilerini gir.'); return; }
    setState(() => busy = true);
    final t = calorieTarget(store.bodyProfile);
    final res = await askAi('''Bir beslenme koçusun (diyetisyen değilsin). Türkçe yaz.
Günlük yaklaşık $t kcal hedefe uygun, Türk mutfağından, 7 günlük sade bir yemek planı hazırla.
Her gün: Kahvaltı, Öğle, Akşam, 1 Ara öğün. Her öğünün yanına yaklaşık kcal yaz.
Ekonomik ve kolay bulunan malzemeler kullan. Sonunda haftalık alışveriş listesini madde madde ver.
Kişi: ${store.bodyProfile}''');
    if (!mounted) return;
    setState(() => busy = false);
    if (res == null) { toast(context, 'AI\'a ulaşılamadı. Koç ayarını kontrol et.'); return; }
    store.setAiText('mealPlan', res);
  }

  Future<void> fridge() async {
    final c = TextEditingController();
    final txt = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Buzdolabında ne var?'),
      content: TextField(controller: c, autofocus: true, maxLines: 3,
          decoration: const InputDecoration(hintText: 'örn. yumurta, domates, biber, yoğurt, bulgur')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
        FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: const Text('Tarif öner')),
      ],
    ));
    if (txt == null || txt.isEmpty) return;
    setState(() => busy = true);
    final target = store.bodyProfile.isEmpty ? 600 : (calorieTarget(store.bodyProfile) / 3).round();
    final res = await askAi('''Türkçe yaz. Elimde şunlar var: $txt.
Bunlarla yapılabilecek, yaklaşık $target kcal civarı 2 kolay tarif öner.
Her tarif: ad, malzemeler, 4-5 adımlık yapılış, yaklaşık kcal ve protein.''');
    if (!mounted) return;
    setState(() => busy = false);
    if (res == null) { toast(context, 'AI\'a ulaşılamadı.'); return; }
    await showDialog(context: context, builder: (ctx) => AlertDialog(
        title: const Text('Tarif önerileri'),
        content: SingleChildScrollView(child: SelectableText(res)),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Kapat'))]));
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final day = dayKey(DateTime.now());
    final kg = (store.bodyProfile['kilo'] ?? 70) as num;
    final waterGoal = (kg * 33 / 250).round() * 250; // 33 ml/kg, 250 ml'ye yuvarlanmış
    final water = store.water[day] ?? 0;
    return ListView(padding: const EdgeInsets.all(16), children: [
      // Su
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.water_drop_outlined),
          const SizedBox(width: 8),
          Expanded(child: Text('Su: ${(water / 1000).toStringAsFixed(2)} / ${(waterGoal / 1000).toStringAsFixed(2)} L', style: tt.titleMedium)),
        ]),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: (water / waterGoal).clamp(0, 1).toDouble(), minHeight: 8),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [
          for (final ml in [200, 250, 500])
            ActionChip(label: Text('+$ml ml'), onPressed: () => store.addWater(ml)),
          ActionChip(label: const Text('Geri al'), onPressed: water == 0 ? null : () => store.addWater(-250)),
        ]),
      ]))),
      // Kalori ekranı
      const CalorieSection(),
      const Divider(height: 32),
      Text('AI beslenme koçu', style: tt.titleLarge),
      const Text('Planlar yaklaşık değerlerdir, tıbbi tavsiye değildir.', style: TextStyle(fontSize: 12)),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: FilledButton.icon(onPressed: busy ? null : makePlan, icon: const Icon(Icons.calendar_month),
            label: Text(busy ? 'Hazırlanıyor…' : 'Haftalık plan'))),
        const SizedBox(width: 8),
        Expanded(child: OutlinedButton.icon(onPressed: busy ? null : fridge, icon: const Icon(Icons.kitchen),
            label: const Text('Buzdolabı'))),
      ]),
      if ((store.aiText['mealPlan'] ?? '').isNotEmpty)
        Card(child: ExpansionTile(title: const Text('Bu haftanın planı'),
            children: [Padding(padding: const EdgeInsets.all(16), child: SelectableText(store.aiText['mealPlan']!))])),
      const SizedBox(height: 24),
    ]);
  }
}

// ======================= ANTRENMAN =======================
class WorkoutTab extends StatefulWidget {
  const WorkoutTab({super.key});
  @override
  State<WorkoutTab> createState() => _WorkoutTabState();
}

class _WorkoutTabState extends State<WorkoutTab> {
  bool busy = false;

  Future<void> aiProgram() async {
    String goal = 'Kas kazanmak', place = 'Ev', days = '3';
    final ok = await showDialog<bool>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, set) => AlertDialog(
      title: const Text('Kişisel program'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<String>(initialValue: goal, decoration: const InputDecoration(labelText: 'Hedef'),
            items: [for (final g in ['Kas kazanmak', 'Yağ yakmak', 'Kondisyon', 'Esneklik']) DropdownMenuItem(value: g, child: Text(g))],
            onChanged: (v) => goal = v ?? goal),
        DropdownButtonFormField<String>(initialValue: place, decoration: const InputDecoration(labelText: 'Nerede'),
            items: [for (final g in ['Ev', 'Salon', 'Açık hava']) DropdownMenuItem(value: g, child: Text(g))],
            onChanged: (v) => place = v ?? place),
        DropdownButtonFormField<String>(initialValue: days, decoration: const InputDecoration(labelText: 'Haftada kaç gün'),
            items: [for (final g in ['2', '3', '4', '5']) DropdownMenuItem(value: g, child: Text(g))],
            onChanged: (v) => days = v ?? days),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Oluştur')),
      ],
    )));
    if (ok != true) return;
    setState(() => busy = true);
    final res = await askAi('''Bir antrenman asistanısın (lisanslı antrenör değilsin). Türkçe yaz.
Hedef: $goal. Yer: $place. Haftada $days gün. Kişi: ${store.bodyProfile}.
Haftalık bir program hazırla: her gün için hareketler, set x tekrar, dinlenme süresi.
Isınma ve soğumayı ekle. 4 haftada nasıl ilerleneceğini kısaca yaz. Ağrı olursa durması gerektiğini belirt.''');
    if (!mounted) return;
    setState(() => busy = false);
    if (res == null) { toast(context, 'AI\'a ulaşılamadı.'); return; }
    store.setAiText('program', res);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final sessions = store.sessions.reversed.take(5).toList();
    final week = store.sessions.where((s) =>
        DateTime.now().difference(DateTime.parse(s['date'])).inDays < 7).length;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text('Bu hafta $week antrenman', style: tt.headlineSmall),
      const SizedBox(height: 8),
      Text('Programlar', style: tt.titleMedium),
      for (final p in programs)
        Card(child: ExpansionTile(
          title: Text(p.name),
          subtitle: Text('${p.desc} · ${p.level}'),
          children: [
            for (final d in p.days)
              ListTile(
                title: Text(d.name),
                subtitle: Text(d.exercises.map((e) => '${e.name} ${e.sets}x${e.reps}${e.unit == "tekrar" ? "" : " ${e.unit}"}').join(' · ')),
                trailing: FilledButton.tonal(child: const Text('Başla'),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SessionPage(p, d)))),
              ),
          ],
        )),
      const SizedBox(height: 12),
      FilledButton.icon(onPressed: busy ? null : aiProgram, icon: const Icon(Icons.auto_awesome),
          label: Text(busy ? 'Hazırlanıyor…' : 'AI ile kişisel program')),
      if ((store.aiText['program'] ?? '').isNotEmpty)
        Card(child: ExpansionTile(title: const Text('Kişisel programım'),
            children: [Padding(padding: const EdgeInsets.all(16), child: SelectableText(store.aiText['program']!))])),
      const SizedBox(height: 16),
      Text('Son antrenmanlar', style: tt.titleMedium),
      if (sessions.isEmpty) const Text('Henüz kayıt yok. Bir programdan "Başla" de.'),
      for (final s in sessions)
        ListTile(contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.fitness_center),
            title: Text('${s['program']} · ${s['day']}'),
            subtitle: Text('${s['date']} · ${(s['sets'] as List).length} set · ${s['minutes']} dk')),
      const SizedBox(height: 24),
    ]);
  }
}

/// Antrenman seansı: set kaydı, dinlenme sayacı, ilerleme önerisi.
class SessionPage extends StatefulWidget {
  final Program program;
  final ProgramDay day;
  const SessionPage(this.program, this.day, {super.key});
  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  final started = DateTime.now();
  /// egzersiz -> set listesi {w, r, done}
  late final Map<String, List<Map<String, dynamic>>> sets;
  Timer? rest;
  int restLeft = 0;

  @override
  void initState() {
    super.initState();
    sets = {
      for (final e in widget.day.exercises)
        e.name: List.generate(e.sets, (_) => {'w': store.lastWeight(e.name) ?? 0, 'r': e.reps, 'done': false}),
    };
  }

  @override
  void dispose() { rest?.cancel(); super.dispose(); }

  void startRest([int sec = 90]) {
    rest?.cancel();
    setState(() => restLeft = sec);
    rest = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => restLeft--);
      if (restLeft <= 0) { t.cancel(); HapticFeedbackHelper.done(); }
    });
  }

  void finish() {
    final done = <Map<String, dynamic>>[];
    sets.forEach((ex, l) {
      for (final s in l) {
        if (s['done'] == true) done.add({'ex': ex, 'w': s['w'], 'r': s['r']});
      }
    });
    if (done.isEmpty) { Navigator.pop(context); return; }
    store.addSession({'date': dayKey(DateTime.now()), 'program': widget.program.name, 'day': widget.day.name,
      'minutes': math.max(1, DateTime.now().difference(started).inMinutes), 'sets': done});
    toast(context, 'Antrenman kaydedildi. Fit kimliğine +2 oy.');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(widget.day.name), actions: [TextButton(onPressed: finish, child: const Text('Bitir'))]),
      bottomNavigationBar: restLeft > 0 ? Container(
        color: cs.primaryContainer,
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        child: Row(children: [
          const Icon(Icons.timer_outlined),
          const SizedBox(width: 8),
          Expanded(child: Text('Dinlenme: ${restLeft ~/ 60}:${(restLeft % 60).toString().padLeft(2, '0')}', style: tt.titleMedium)),
          TextButton(onPressed: () => setState(() => restLeft += 30), child: const Text('+30 sn')),
          TextButton(onPressed: () { rest?.cancel(); setState(() => restLeft = 0); }, child: const Text('Geç')),
        ]),
      ) : null,
      body: ListView(padding: const EdgeInsets.all(16), children: [
        for (final e in widget.day.exercises) ...[
          Text(e.name, style: tt.titleMedium),
          if (store.progressHint(e) != null)
            Text(store.progressHint(e)!, style: TextStyle(color: cs.primary, fontSize: 12)),
          for (var i = 0; i < sets[e.name]!.length; i++)
            Row(children: [
              SizedBox(width: 48, child: Text('Set ${i + 1}')),
              if (e.weighted) ...[
                SizedBox(width: 72, child: TextFormField(
                    initialValue: '${sets[e.name]![i]['w']}', keyboardType: TextInputType.number,
                    decoration: const InputDecoration(suffixText: 'kg', isDense: true),
                    onChanged: (v) => sets[e.name]![i]['w'] = num.tryParse(v) ?? 0)),
                const SizedBox(width: 8),
              ],
              SizedBox(width: 72, child: TextFormField(
                  initialValue: '${sets[e.name]![i]['r']}', keyboardType: TextInputType.number,
                  decoration: InputDecoration(suffixText: e.unit, isDense: true),
                  onChanged: (v) => sets[e.name]![i]['r'] = num.tryParse(v) ?? 0)),
              const Spacer(),
              Checkbox(value: sets[e.name]![i]['done'] == true, onChanged: (v) {
                setState(() => sets[e.name]![i]['done'] = v ?? false);
                if (v == true) startRest(e.unit == 'tekrar' && e.weighted ? 120 : 60);
              }),
            ]),
          const Divider(height: 24),
        ],
        FilledButton(onPressed: finish, child: const Text('Antrenmanı bitir ve kaydet')),
        const SizedBox(height: 8),
        const Text('Ağrı hissedersen dur. Bu uygulama bir antrenörün yerini tutmaz.', style: TextStyle(fontSize: 11)),
      ]),
    );
  }
}

class HapticFeedbackHelper {
  /// Dinlenme bitti titreşimi
  static void done() => HapticFeedback.heavyImpact();
}

// ======================= VÜCUT =======================
class BodyTab extends StatelessWidget {
  const BodyTab({super.key});

  Future<void> addEntry(BuildContext context) async {
    final kg = TextEditingController(), bel = TextEditingController(), kalca = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Ölçüm ekle'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: kg, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Kilo (kg)')),
        TextField(controller: bel, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Bel (cm, isteğe bağlı)')),
        TextField(controller: kalca, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Kalça (cm, isteğe bağlı)')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Kaydet')),
      ],
    ));
    if (ok != true) return;
    final k = num.tryParse(kg.text.replaceAll(',', '.'));
    if (k == null) return;
    store.addBody({'date': dayKey(DateTime.now()), 'kilo': k,
      'bel': num.tryParse(bel.text.replaceAll(',', '.')), 'kalca': num.tryParse(kalca.text.replaceAll(',', '.'))});
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final log = store.bodyLog;
    final weights = [for (final e in log) (e['kilo'] as num).toDouble()];
    final first = log.isEmpty ? null : log.first, last = log.isEmpty ? null : log.last;
    String diff(String k) {
      if (first == null || first[k] == null || last![k] == null) return '-';
      final d = (last[k] as num) - (first[k] as num);
      return '${d > 0 ? "+" : ""}${d.toStringAsFixed(1)}';
    }
    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(children: [
        Expanded(child: Text('Vücut', style: tt.headlineSmall)),
        FilledButton.icon(onPressed: () => addEntry(context), icon: const Icon(Icons.add), label: const Text('Ölçüm')),
      ]),
      const SizedBox(height: 12),
      if (log.isEmpty)
        const Text('Haftada bir, aynı saatte tartılman en doğru sonucu verir. İlk ölçümünü ekle.')
      else ...[
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${last!['kilo']} kg', style: tt.headlineMedium),
          Text('Başlangıçtan beri: kilo ${diff('kilo')} kg · bel ${diff('bel')} cm · kalça ${diff('kalca')} cm'),
          const SizedBox(height: 16),
          if (weights.length >= 2)
            SizedBox(height: 160, child: CustomPaint(size: Size.infinite,
                painter: LinePainter(weights, Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.outlineVariant))),
        ]))),
        const SizedBox(height: 8),
        for (var i = log.length - 1; i >= 0; i--)
          ListTile(contentPadding: EdgeInsets.zero, dense: true,
              title: Text('${log[i]['date']} · ${log[i]['kilo']} kg'),
              subtitle: Text([if (log[i]['bel'] != null) 'bel ${log[i]['bel']}', if (log[i]['kalca'] != null) 'kalça ${log[i]['kalca']}'].join(' · ')),
              trailing: IconButton(icon: const Icon(Icons.close), onPressed: () => store.removeBody(i))),
      ],
    ]);
  }
}

class LinePainter extends CustomPainter {
  final List<double> v;
  final Color line, grid;
  LinePainter(this.v, this.line, this.grid);
  @override
  void paint(Canvas c, Size s) {
    final mn = v.reduce(math.min) - 1, mx = v.reduce(math.max) + 1;
    final g = Paint()..color = grid..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) { final y = s.height * i / 3; c.drawLine(Offset(0, y), Offset(s.width, y), g); }
    Offset pt(int i) => Offset(s.width * i / (v.length - 1), s.height * (1 - (v[i] - mn) / (mx - mn)));
    final path = Path()..moveTo(pt(0).dx, pt(0).dy);
    for (var i = 1; i < v.length; i++) { path.lineTo(pt(i).dx, pt(i).dy); }
    c.drawPath(path, Paint()..color = line..strokeWidth = 2.5..style = PaintingStyle.stroke);
    c.drawCircle(pt(v.length - 1), 4, Paint()..color = line);
  }
  @override
  bool shouldRepaint(covariant LinePainter o) => o.v != v;
}
