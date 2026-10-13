import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models.dart';
import 'store.dart';
import 'coach.dart';
import 'rule_coach.dart';
import 'reminder.dart';
import 'timer_page.dart';
import 'badges.dart';
import 'calorie.dart';
import 'health.dart';

final store = Store();
final coach = Coach();

const identitiesAll = ['Okuyan', 'Fit', 'Dil bilen', 'Üreten', 'Sakin zihin', 'Girişimci', 'Disiplinli'];
const dayNames = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

final packs = <String, List<Habit>>{
  'Okuma + Dil + Hareket': [
    Habit(key: 'h0', name: 'Kitap oku', type: HabitType.dur, goal: 30, mini: 10, unit: 'dk', identity: 'Okuyan', routine: 'Akşam'),
    Habit(key: 'h1', name: 'Yeni kelime', type: HabitType.qty, goal: 50, mini: 10, unit: 'kelime', identity: 'Dil bilen', routine: 'Akşam'),
    Habit(key: 'h2', name: 'Koşu', type: HabitType.qty, goal: 5, mini: 1, unit: 'km', identity: 'Fit', days: [1, 3, 5, 6]),
  ],
  'Sabah rutini': [
    Habit(key: 'h0', name: 'Meditasyon', type: HabitType.dur, goal: 10, mini: 2, unit: 'dk', identity: 'Sakin zihin', routine: 'Sabah'),
    Habit(key: 'h1', name: 'Yoga', type: HabitType.dur, goal: 60, mini: 10, unit: 'dk', identity: 'Fit', routine: 'Sabah'),
    Habit(key: 'h2', name: 'Soğuk duş', type: HabitType.bool_, goal: 1, mini: 1, unit: '', identity: 'Sakin zihin', routine: 'Sabah'),
  ],
  'Girişimci': [
    Habit(key: 'h0', name: 'Derin çalışma', type: HabitType.dur, goal: 90, mini: 25, unit: 'dk', identity: 'Üreten', days: [1, 2, 3, 4, 5]),
    Habit(key: 'h1', name: 'İş kitabı oku', type: HabitType.qty, goal: 20, mini: 5, unit: 'sayfa', identity: 'Girişimci'),
    Habit(key: 'h2', name: 'Günlük yaz', type: HabitType.bool_, goal: 1, mini: 1, unit: '', identity: 'Üreten', routine: 'Akşam'),
  ],
};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await store.load();
  if (!kIsWeb) {
    try { await initReminders(); } catch (_) {}
  }
  runApp(const App());
}

void toast(BuildContext context, String msg) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'I Am Disiplin',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: const Color(0xFF1F6B52), useMaterial3: true),
        darkTheme: ThemeData(colorSchemeSeed: const Color(0xFF1F6B52), brightness: Brightness.dark, useMaterial3: true),
        home: ListenableBuilder(listenable: store,
            builder: (_, __) => store.onboarded ? const Home() : const Onboarding()),
      );
}

// ======================= ONBOARDING =======================
class Onboarding extends StatefulWidget {
  const Onboarding({super.key});
  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  int step = 0;
  final ids = <String>{};
  String? pack;
  final custom = <Habit>[];
  final letter = TextEditingController();

  List<Habit> get chosen => packs[pack] ?? custom;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pages = [
      // 1. Kimlik
      [
        Text('Adım 1 / 3', style: tt.labelMedium),
        Text('Nasıl bir insan olmak istiyorsun?', style: tt.headlineSmall),
        const Text('Birkaç kimlik seç. Her alışkanlık bunlardan birine oy verecek.'),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final i in identitiesAll)
            FilterChip(label: Text(i), selected: ids.contains(i),
                onSelected: (v) => setState(() => v ? ids.add(i) : ids.remove(i))),
        ]),
        const SizedBox(height: 24),
        FilledButton(onPressed: ids.isEmpty ? null : () => setState(() => step = 1), child: const Text('Devam')),
      ],
      // 2. Program
      [
        Text('Adım 2 / 3', style: tt.labelMedium),
        Text('Programını kur', style: tt.headlineSmall),
        const Text('En fazla 3 alışkanlıkla başla. Güçlendikçe yeni slot açılır.'),
        RadioGroup<String>(
          groupValue: pack,
          onChanged: (v) => setState(() { pack = v; }),
          child: Column(children: [
            for (final p in packs.keys)
              RadioListTile<String>(value: p, title: Text(p),
                  subtitle: Text(packs[p]!.map((h) => h.name).join(' · '))),
            RadioListTile<String>(value: '_custom', title: const Text('Kendim oluşturacağım'),
                subtitle: Text(custom.isEmpty ? 'Kendi alışkanlıklarını ekle' : custom.map((h) => h.name).join(' · '))),
          ]),
        ),
        if (pack == '_custom')
          OutlinedButton.icon(
              onPressed: custom.length >= 3 ? null : () async {
                final h = await showHabitSheet(context, ids.toList());
                if (h != null) setState(() => custom.add(h));
              },
              icon: const Icon(Icons.add), label: Text('Alışkanlık ekle (${custom.length}/3)')),
        const SizedBox(height: 24),
        Row(children: [
          TextButton(onPressed: () => setState(() => step = 0), child: const Text('Geri')),
          const Spacer(),
          FilledButton(onPressed: chosen.isEmpty ? null : () => setState(() => step = 2), child: const Text('Devam')),
        ]),
      ],
      // 3. Mektup
      [
        Text('Adım 3 / 3', style: tt.labelMedium),
        Text('90 gün sonraki sana bir mektup', style: tt.headlineSmall),
        const Text('Neden başladığını yaz. 90. gün açılacak. İstersen boş bırak.'),
        const SizedBox(height: 12),
        TextField(controller: letter, maxLines: 6,
            decoration: const InputDecoration(border: OutlineInputBorder(),
                hintText: 'Sevgili ben, bugün başlıyorum çünkü...')),
        const SizedBox(height: 24),
        Row(children: [
          TextButton(onPressed: () => setState(() => step = 1), child: const Text('Geri')),
          const Spacer(),
          FilledButton(onPressed: () => store.setup(ids.toList(), chosen, letterText: letter.text.trim()),
              child: const Text('Başla')),
        ]),
      ],
    ];
    return Scaffold(body: SafeArea(child: ListView(padding: const EdgeInsets.all(20), children: pages[step])));
  }
}

// ======================= HOME =======================
class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int tab = 0;

  Future<void> addHabit() async {
    if (store.active.length >= store.maxSlots) {
      toast(context, 'Şu an ${store.maxSlots} slotun dolu. Bir alışkanlığın gücü %70\'i geçince yeni slot açılır.');
      return;
    }
    final h = await showHabitSheet(context, store.identities);
    if (h != null) store.addHabit(h);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        floatingActionButton: tab == 0 ? FloatingActionButton(onPressed: addHabit, child: const Icon(Icons.add)) : null,
        body: SafeArea(child: ListenableBuilder(listenable: store,
            builder: (_, __) => [
                  TodayPage(key: UniqueKey()),
                  HealthPage(), // const değil: premium değişince yeniden çizilsin
                  ProgressPage(key: UniqueKey()),
                  const CoachPage(),
                  MePage(key: UniqueKey()),
                ][tab])),
        bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (i) => setState(() => tab = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.today), label: 'Bugün'),
              NavigationDestination(icon: Icon(Icons.favorite_outline), label: 'Sağlık'),
              NavigationDestination(icon: Icon(Icons.insights), label: 'İlerleme'),
              NavigationDestination(icon: Icon(Icons.psychology), label: 'Koç'),
              NavigationDestination(icon: Icon(Icons.person_outline), label: 'Ben'),
            ]),
      );
}

// ======================= BUGÜN =======================
class TodayPage extends StatelessWidget {
  const TodayPage({super.key});
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final today = store.log[dayKey(DateTime.now())] ?? {};
    final list = store.todayHabits;
    final rest = store.active.where((h) => !h.on(DateTime.now())).toList();
    final done = list.where((h) => today[h.key] != null).length;
    final votes = <String, int>{};
    for (final h in list) {
      final e = today[h.key];
      if (e != null) votes[h.identity] = (votes[h.identity] ?? 0) + e.level;
    }
    if (store.premium && store.bodyProfile.isNotEmpty &&
        store.calorieOnTrack(dayKey(DateTime.now()), calorieTarget(store.bodyProfile))) {
      votes['Fit'] = (votes['Fit'] ?? 0) + 2;
    }
    if (store.premium && store.workedOutToday) votes['Fit'] = (votes['Fit'] ?? 0) + 2;
    final routines = store.routinesToday();
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text('Seviye ${store.level} · ${store.daysSinceStart + 1}. gün', style: tt.labelLarge),
      Text('Bugün $done/${list.length}', style: tt.headlineMedium),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 4, children: [
        for (final i in {...store.identities, ...votes.keys}) Chip(label: Text('$i · ${votes[i] ?? 0} oy')),
      ]),
      const Text('Tam hedef 2 oy, minimum 1 oy. Her oy "ben buyum" demek.', style: TextStyle(fontSize: 12)),
      const SizedBox(height: 8),
      if (store.letterOpen) const LetterCard(),
      for (final h in store.missedYesterday()) SkipCard(h),
      if (DateTime.now().weekday == DateTime.sunday && store.reviews[store.weekKey()] == null) const ReviewCard(),
      for (final r in routines.entries)
        Card(child: ListTile(
          leading: const Icon(Icons.playlist_play),
          title: Text('${r.key} rutini'),
          subtitle: Text(r.value.map((h) => h.name).join(' → ')),
          trailing: FilledButton.tonal(
              onPressed: r.value.every((h) => today[h.key] != null) ? null
                  : () => Navigator.push(context, MaterialPageRoute(builder: (_) => RoutinePage(r.key, r.value))),
              child: Text(r.value.every((h) => today[h.key] != null) ? 'Bitti' : 'Başlat')),
        )),
      for (final h in list) HabitCard(h, today[h.key]),
      if (list.isEmpty) const Padding(padding: EdgeInsets.all(24),
          child: Text('Bugün planlı alışkanlık yok. Dinlenmek de sistemin parçası.', textAlign: TextAlign.center)),
      if (rest.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8),
          child: Text('Bugün dinleniyor: ${rest.map((h) => h.name).join(', ')}', style: tt.bodySmall)),
      const SizedBox(height: 80),
    ]);
  }
}

class HabitCard extends StatefulWidget {
  final Habit h;
  final Entry? e;
  const HabitCard(this.h, this.e, {super.key});
  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  final ctrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final h = widget.h, e = widget.e;
    final cs = Theme.of(context).colorScheme;
    return Card(child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onLongPress: () => editHabit(context, h),
      child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(h.name, style: Theme.of(context).textTheme.titleMedium)),
          Text(h.identity, style: Theme.of(context).textTheme.labelSmall),
        ]),
        Text('${h.type == HabitType.bool_ ? "Evet/Hayır" : "${h.goal} ${h.unit} · min ${h.mini}"}'
            ' · 🔥 ${store.streak(h)} · güç %${store.strength(h)}',
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        if (e != null)
          Row(children: [
            Chip(label: Text(e.level == 2 ? 'Tamam · 2 oy' : 'Minimum · 1 oy'),
                backgroundColor: e.level == 2 ? cs.primaryContainer : cs.tertiaryContainer),
            if (h.type != HabitType.bool_) Padding(padding: const EdgeInsets.only(left: 8), child: Text('${e.value} ${h.unit}')),
            const Spacer(),
            TextButton(onPressed: () => store.undo(h), child: const Text('Geri al')),
          ])
        else
          Row(children: [
            if (h.type != HabitType.bool_)
              SizedBox(width: 84, child: TextField(controller: ctrl, keyboardType: TextInputType.number,
                  decoration: InputDecoration(hintText: '${h.goal}', suffixText: h.unit, isDense: true))),
            if (h.type == HabitType.dur)
              IconButton(tooltip: 'Sayaç', icon: const Icon(Icons.timer_outlined),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TimerPage(h)))),
            const Spacer(),
            OutlinedButton(onPressed: () => store.mark(h, 1), child: const Text('Mini')),
            const SizedBox(width: 8),
            FilledButton(onPressed: () => store.mark(h, 2, num.tryParse(ctrl.text)), child: const Text('Yaptım')),
          ]),
      ])),
    ));
  }
}

// ======================= RUTİN =======================
class RoutinePage extends StatefulWidget {
  final String name;
  final List<Habit> habits;
  const RoutinePage(this.name, this.habits, {super.key});
  @override
  State<RoutinePage> createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  int i = 0;
  List<Habit> get todo => widget.habits.where((h) => store.log[dayKey(DateTime.now())]?[h.key] == null).toList();

  @override
  void initState() {
    super.initState();
    final first = todo.isEmpty ? null : todo.first;
    i = first == null ? widget.habits.length : widget.habits.indexOf(first);
  }

  void next() => setState(() => i++);

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    if (i >= widget.habits.length) {
      return Scaffold(appBar: AppBar(title: Text('${widget.name} rutini')),
          body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.emoji_events, size: 72),
            Text('Rutin tamam!', style: tt.headlineSmall),
            const SizedBox(height: 16),
            FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Kapat')),
          ])));
    }
    final h = widget.habits[i];
    return Scaffold(
      appBar: AppBar(title: Text('${widget.name} rutini · ${i + 1}/${widget.habits.length}')),
      body: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        LinearProgressIndicator(value: i / widget.habits.length),
        const Spacer(),
        Text(h.name, style: tt.displaySmall, textAlign: TextAlign.center),
        Text(h.type == HabitType.bool_ ? h.identity : '${h.goal} ${h.unit} · kötü günde ${h.mini} ${h.unit}',
            textAlign: TextAlign.center),
        const Spacer(),
        if (h.type == HabitType.dur)
          OutlinedButton.icon(icon: const Icon(Icons.timer_outlined), label: const Text('Sayaçla yap'),
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => TimerPage(h)));
                if (store.log[dayKey(DateTime.now())]?[h.key] != null) next();
              }),
        const SizedBox(height: 8),
        FilledButton(onPressed: () { store.mark(h, 2); next(); }, child: const Text('Yaptım')),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: () { store.mark(h, 1); next(); }, child: const Text('Minimumu yaptım')),
        TextButton(onPressed: next, child: const Text('Şimdilik atla')),
      ])),
    );
  }
}

// ======================= İLERLEME =======================
class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final now = DateTime.now();
    final hs = store.active;
    // Isı haritası: sütun = hafta, satır = gün
    final start = DateTime(now.year, now.month, now.day).subtract(Duration(days: 83 - (7 - now.weekday)));
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text('Son 12 hafta', style: tt.titleLarge),
      const SizedBox(height: 8),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(children: [for (final n in dayNames) SizedBox(height: 22, child: Text(n, style: tt.labelSmall))]),
        const SizedBox(width: 6),
        for (var w = 0; w < 12; w++)
          Expanded(child: Column(children: [
            for (var d = 0; d < 7; d++)
              Builder(builder: (_) {
                final day = start.add(Duration(days: w * 7 + d));
                final planned = hs.where((h) => h.on(day)).toList();
                final m = store.log[dayKey(day)] ?? {};
                final sc = planned.isEmpty ? 0.0
                    : planned.fold<double>(0, (a, h) => a + (m[h.key] == null ? 0 : m[h.key]!.level / 2)) / planned.length;
                final future = day.isAfter(now);
                return Container(height: 18, margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(3),
                        color: future ? Colors.transparent
                            : sc == 0 ? cs.surfaceContainerHighest : cs.primary.withValues(alpha: .25 + sc * .75)));
              }),
          ])),
      ]),
      const SizedBox(height: 20),
      Text('Alışkanlık gücü', style: tt.titleLarge),
      for (final h in hs)
        ListTile(contentPadding: EdgeInsets.zero, title: Text(h.name),
            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 4),
              LinearProgressIndicator(value: store.strength(h) / 100),
              const SizedBox(height: 4),
              Text('${h.scheduleText} · son 30 planlı günde %${store.completion(h)} · en uzun seri ${store.longestStreak(h)}'),
            ]),
            trailing: Text('%${store.strength(h)}', style: tt.titleMedium)),
      const SizedBox(height: 20),
      Text('Bu tempoyla 1 yılda', style: tt.titleLarge),
      for (final h in hs)
        ListTile(contentPadding: EdgeInsets.zero, title: Text(h.name),
            trailing: Text(yearProjection(store, h), style: const TextStyle(fontWeight: FontWeight.bold))),
      const SizedBox(height: 20),
      Text('Rozetler', style: tt.titleLarge),
      for (final b in badgesFor(store).take(12))
        ListTile(contentPadding: EdgeInsets.zero,
          leading: Icon(b.earned ? Icons.military_tech : Icons.lock_outline, color: b.earned ? cs.primary : cs.outline),
          title: Text(b.title),
          subtitle: b.earned ? Text(b.desc) : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(b.desc), const SizedBox(height: 4), LinearProgressIndicator(value: b.progress)]),
        ),
    ]);
  }
}

// ======================= KOÇ =======================
class CoachPage extends StatefulWidget {
  const CoachPage({super.key});
  @override
  State<CoachPage> createState() => _CoachPageState();
}

class _CoachPageState extends State<CoachPage> {
  String? text;
  bool busy = false;

  Future<void> ask() async {
    setState(() => busy = true);
    var t = await coach.advise(store.summary(), host: store.ollamaHost, model: store.ollamaModel);
    if (t.startsWith('Ollama') || t.startsWith('Koç yanıt')) {
      t = 'AI koça ulaşılamadı, çevrimdışı analiz:\n• ${ruleCoach(store).join('\n• ')}';
    }
    if (!mounted) return;
    setState(() { text = t; busy = false; });
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: store, builder: (_, __) =>
      ListView(padding: const EdgeInsets.all(16), children: [
        Text('Koç', style: Theme.of(context).textTheme.headlineSmall),
        const Text('Verilerine bakıp sistemini ayarlamana yardım eder.'),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hızlı tespitler', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              for (final t in ruleCoach(store)) Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('• $t')),
            ]))),
        const SizedBox(height: 12),
        FilledButton.icon(onPressed: busy ? null : ask, icon: const Icon(Icons.auto_awesome),
            label: Text(busy ? 'Düşünüyor…' : 'AI ile haftalık analiz')),
        if (text != null) Card(child: Padding(padding: const EdgeInsets.all(12), child: SelectableText(text!))),
        const SizedBox(height: 8),
        Text('Model: ${store.ollamaModel} · ${store.ollamaHost}', style: Theme.of(context).textTheme.bodySmall),
      ]));
}

// ======================= BEN =======================
class MePage extends StatelessWidget {
  const MePage({super.key});

  Future<void> _import(BuildContext context) async {
    final c = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Yedekten geri yükle'),
      content: TextField(controller: c, maxLines: 6, decoration: const InputDecoration(hintText: 'Yedek metnini yapıştır')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Geri yükle')),
      ],
    ));
    if (ok != true || !context.mounted) return;
    toast(context, store.importBackup(c.text.trim()) ? 'Yedek geri yüklendi.' : 'Bu metin geçerli bir yedek değil.');
  }

  Future<void> _reset(BuildContext context) async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Her şeyi sil?'),
      content: const Text('Tüm alışkanlıklar ve geçmiş silinir. Önce yedek almanı öneririm.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sil')),
      ],
    ));
    if (ok == true) await store.resetAll();
  }

  Future<void> _coachSettings(BuildContext context) async {
    final host = TextEditingController(text: store.ollamaHost), model = TextEditingController(text: store.ollamaModel);
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('AI koç ayarı'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: host, decoration: const InputDecoration(labelText: 'Ollama adresi')),
        TextField(controller: model, decoration: const InputDecoration(labelText: 'Model')),
        const SizedBox(height: 8),
        const Text('Android emülatör: http://10.0.2.2:11434\nGerçek telefon: http://BILGISAYAR-IP:11434',
            style: TextStyle(fontSize: 12)),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Kaydet')),
      ],
    ));
    if (ok == true) store.setCoach(host.text.trim(), model.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final archived = store.habits.where((h) => h.archived).toList();
    final left = 90 - store.daysSinceStart;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text('Ben', style: tt.headlineSmall),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Ben ${store.identities.join(", ").toLowerCase()} biriyim.', style: tt.titleLarge),
        const SizedBox(height: 4),
        Text('Seviye ${store.level} · ${store.active.length}/${store.maxSlots} slot · ${store.daysSinceStart + 1}. gün'),
      ]))),
      if (store.letter.isNotEmpty)
        store.letterOpen ? const LetterCard()
            : Card(child: ListTile(leading: const Icon(Icons.mail_lock_outlined),
                title: const Text('Gelecekteki ben mektubu'), subtitle: Text('$left gün sonra açılacak'))),
      const SizedBox(height: 12),
      Text('Alışkanlıklarım', style: tt.titleMedium),
      const Text('Düzenlemek için dokun. Sıra rutinlerdeki sırayı belirler.', style: TextStyle(fontSize: 12)),
      for (var i = 0; i < store.habits.length; i++)
        if (!store.habits[i].archived)
          ListTile(contentPadding: EdgeInsets.zero,
            title: Text(store.habits[i].name),
            subtitle: Text('${store.habits[i].scheduleText}'
                '${store.habits[i].routine.isEmpty ? "" : " · ${store.habits[i].routine} rutini"}'),
            onTap: () => editHabit(context, store.habits[i]),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(icon: const Icon(Icons.arrow_upward), tooltip: 'Yukarı',
                  onPressed: i == 0 ? null : () => store.moveHabit(i, i - 1)),
              IconButton(icon: const Icon(Icons.archive_outlined), tooltip: 'Arşivle',
                  onPressed: () => store.updateHabit(store.habits[i].copyWith(archived: true))),
            ])),
      if (archived.isNotEmpty) ...[
        const SizedBox(height: 8),
        Text('Arşiv', style: tt.titleSmall),
        for (final h in archived)
          ListTile(contentPadding: EdgeInsets.zero, title: Text(h.name),
              trailing: TextButton(onPressed: () {
                if (store.active.length >= store.maxSlots) {
                  toast(context, 'Slotların dolu. Önce bir alışkanlığı arşivle.');
                } else {
                  store.updateHabit(h.copyWith(archived: false));
                }
              }, child: const Text('Geri al'))),
      ],
      const Divider(height: 32),
      ListTile(leading: const Icon(Icons.workspace_premium_outlined),
          title: Text(store.premium ? 'Premium aktif' : 'Premium\'a geç'),
          subtitle: const Text('Beslenme koçu, antrenman, vücut takibi'),
          trailing: store.premium && kDebugMode ? TextButton(onPressed: () => store.setPremium(false), child: const Text('Kapat (test)')) : null),
      const ReminderTile(),
      ListTile(leading: const Icon(Icons.share_outlined), title: const Text('İlerlememi paylaş'),
          subtitle: const Text('Sorumluluk ortağına gönder'),
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: store.shareText()));
            if (context.mounted) toast(context, 'Kopyalandı. WhatsApp\'a yapıştırabilirsin.');
          }),
      ListTile(leading: const Icon(Icons.psychology_outlined), title: const Text('AI koç ayarı'),
          subtitle: Text(store.ollamaModel), onTap: () => _coachSettings(context)),
      ListTile(leading: const Icon(Icons.backup_outlined), title: const Text('Yedek al'),
          subtitle: const Text('Panoya kopyalar; notlarına veya e-postana kaydet'),
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: store.exportBackup()));
            if (context.mounted) toast(context, 'Yedek panoya kopyalandı.');
          }),
      ListTile(leading: const Icon(Icons.restore), title: const Text('Yedekten geri yükle'), onTap: () => _import(context)),
      ListTile(leading: Icon(Icons.delete_forever_outlined, color: Theme.of(context).colorScheme.error),
          title: const Text('Her şeyi sıfırla'), onTap: () => _reset(context)),
      const SizedBox(height: 24),
    ]);
  }
}

class LetterCard extends StatelessWidget {
  const LetterCard({super.key});
  @override
  Widget build(BuildContext context) => Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('90 gün önceki senden bir mektup', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(store.letter),
      ])));
}

// ======================= ALIŞKANLIK FORMU =======================
Future<void> editHabit(BuildContext context, Habit h) async {
  final r = await showHabitSheet(context, store.identities, existing: h);
  if (r == null) return;
  if (r.key == '__delete__') {
    store.deleteHabit(h);
  } else {
    store.updateHabit(r);
  }
}

/// Yeni alışkanlık veya düzenleme. Silme seçilirse key '__delete__' olan bir Habit döner.
Future<Habit?> showHabitSheet(BuildContext context, List<String> ids, {Habit? existing}) {
  final ex = existing;
  final name = TextEditingController(text: ex?.name ?? ''),
      goal = TextEditingController(text: ex == null ? '' : '${ex.goal}'),
      mini = TextEditingController(text: ex == null ? '' : '${ex.mini}'),
      unit = TextEditingController(text: ex?.unit ?? ''),
      routine = TextEditingController(text: ex?.routine ?? '');
  var type = ex?.type ?? HabitType.dur;
  final idList = ids.isEmpty ? ['Disiplinli'] : ids;
  var identity = ex != null && idList.contains(ex.identity) ? ex.identity : idList.first;
  final days = <int>{...(ex?.days ?? [1, 2, 3, 4, 5, 6, 7])};
  var confirmDelete = false;

  return showModalBottomSheet<Habit>(context: context, isScrollControlled: true, useSafeArea: true,
    builder: (ctx) => StatefulBuilder(builder: (ctx, set) => SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(ex == null ? 'Yeni alışkanlık' : 'Alışkanlığı düzenle', style: Theme.of(ctx).textTheme.titleLarge),
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Ad (örn. Yoga)')),
        const SizedBox(height: 12),
        SegmentedButton<HabitType>(segments: const [
          ButtonSegment(value: HabitType.dur, label: Text('Süre')),
          ButtonSegment(value: HabitType.qty, label: Text('Miktar')),
          ButtonSegment(value: HabitType.bool_, label: Text('Evet/Hayır')),
        ], selected: {type}, onSelectionChanged: (v) => set(() => type = v.first)),
        if (type != HabitType.bool_) Row(children: [
          Expanded(child: TextField(controller: goal, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Hedef'))),
          const SizedBox(width: 8),
          Expanded(child: TextField(controller: mini, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Kötü gün min.'))),
          const SizedBox(width: 8),
          Expanded(child: TextField(controller: unit, decoration: InputDecoration(
              labelText: 'Birim', hintText: type == HabitType.dur ? 'dk' : 'km'))),
        ]),
        const SizedBox(height: 12),
        const Text('Hangi günler?'),
        Wrap(spacing: 4, children: [
          for (var d = 1; d <= 7; d++)
            FilterChip(label: Text(dayNames[d - 1]), selected: days.contains(d),
                onSelected: (v) => set(() { if (v) { days.add(d); } else if (days.length > 1) { days.remove(d); } })),
        ]),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(initialValue: identity,
            decoration: const InputDecoration(labelText: 'Hangi kimliğe oy veriyor?'),
            items: [for (final i in idList) DropdownMenuItem(value: i, child: Text(i))],
            onChanged: (v) => identity = v ?? identity),
        TextField(controller: routine, decoration: const InputDecoration(
            labelText: 'Rutin (isteğe bağlı)', hintText: 'Sabah, Akşam...')),
        Wrap(spacing: 6, children: [
          for (final r in {'Sabah', 'Akşam', ...store.routineNames})
            ActionChip(label: Text(r), onPressed: () => set(() => routine.text = r)),
        ]),
        const SizedBox(height: 16),
        FilledButton(onPressed: () {
          if (name.text.trim().isEmpty) return;
          final b = type == HabitType.bool_;
          final g = b ? 1 : (num.tryParse(goal.text) ?? 1);
          var m = b ? 1 : (num.tryParse(mini.text) ?? g);
          if (m > g) m = g;
          Navigator.pop(ctx, Habit(
              key: ex?.key ?? 'h${DateTime.now().millisecondsSinceEpoch}',
              name: name.text.trim(), type: type, goal: g, mini: m,
              unit: b ? '' : (unit.text.trim().isEmpty ? (type == HabitType.dur ? 'dk' : '') : unit.text.trim()),
              identity: identity, days: (days.toList()..sort()), routine: routine.text.trim(),
              archived: ex?.archived ?? false));
        }, child: Text(ex == null ? 'Ekle' : 'Kaydet')),
        if (ex != null) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              if (!confirmDelete) { set(() => confirmDelete = true); return; }
              Navigator.pop(ctx, ex.copyWithKey('__delete__'));
            },
            child: Text(confirmDelete ? 'Emin misin? Geçmişi de silinir. Tekrar dokun.' : 'Sil',
                style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
          ),
        ],
      ]))));
}

extension on Habit {
  Habit copyWithKey(String k) => Habit(key: k, name: name, type: type, goal: goal, mini: mini, unit: unit, identity: identity);
}

// ======================= HATIRLATICI =======================
class ReminderTile extends StatefulWidget {
  const ReminderTile({super.key});
  @override
  State<ReminderTile> createState() => _ReminderTileState();
}

class _ReminderTileState extends State<ReminderTile> {
  TimeOfDay? t;
  @override
  void initState() {
    super.initState();
    savedReminder().then((v) { if (mounted) setState(() => t = v); });
  }

  @override
  Widget build(BuildContext context) => ListTile(
        leading: const Icon(Icons.notifications_outlined),
        title: const Text('Günlük hatırlatıcı'),
        subtitle: Text(t == null ? 'Kapalı' : 'Her gün ${t!.format(context)}'),
        onTap: () async {
          final v = await showTimePicker(context: context, initialTime: t ?? const TimeOfDay(hour: 8, minute: 0));
          if (v == null) return;
          await scheduleDaily(v);
          if (mounted) setState(() => t = v);
        },
      );
}

// ======================= KAÇIRMA SEBEBİ =======================
class SkipCard extends StatelessWidget {
  final Habit h;
  const SkipCard(this.h, {super.key});
  @override
  Widget build(BuildContext context) {
    final y = dayKey(DateTime.now().subtract(const Duration(days: 1)));
    return Card(color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Dün "${h.name}" olmadı. Ne oldu?'),
        const Text('Suçlama yok, sadece sistemi ayarlıyoruz.', style: TextStyle(fontSize: 12)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [
          for (final r in ['Yorgun', 'Vakit yok', 'Unuttum', 'İsteksiz'])
            ActionChip(label: Text(r), onPressed: () => store.setSkip(y, h, r)),
        ]),
      ])));
  }
}

// ======================= HAFTALIK DEĞERLENDİRME =======================
class ReviewCard extends StatefulWidget {
  const ReviewCard({super.key});
  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  final good = TextEditingController(), hard = TextEditingController(), change = TextEditingController();
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Haftalık değerlendirme', style: Theme.of(context).textTheme.titleMedium),
        const Text('2 dakika. Sistemi sen yönetiyorsun.', style: TextStyle(fontSize: 12)),
        TextField(controller: good, decoration: const InputDecoration(labelText: 'Bu hafta ne iyi gitti?')),
        TextField(controller: hard, decoration: const InputDecoration(labelText: 'Ne zorladı?')),
        TextField(controller: change, decoration: const InputDecoration(labelText: 'Gelecek hafta neyi değiştiriyorsun?')),
        const SizedBox(height: 8),
        FilledButton(onPressed: () => store.saveReview({'iyi': good.text, 'zor': hard.text, 'degisim': change.text}),
            child: const Text('Kaydet')),
      ])));
}
