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
import 'theme.dart';
import 'motivation.dart';
import 'plan.dart';

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
    try {
      await initReminders();
      // Motivasyon bildirimlerini her açılışta önümüzdeki 7 gün için tazele
      if (store.onboarded) await scheduleMotivation(await motivationCount(), store.identities);
    } catch (_) {}
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
        theme: ironTheme(),
        darkTheme: ironTheme(),
        themeMode: ThemeMode.dark,
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
          FilledButton(onPressed: () {
                store.setup(ids.toList(), chosen, letterText: letter.text.trim());
                scheduleMotivation(3, ids.toList()).catchError((_) {});
              },
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
                  PlanPage(key: UniqueKey()),
                  HealthPage(), // const değil: premium değişince yeniden çizilsin
                  ProgressPage(key: UniqueKey()),
                  MePage(key: UniqueKey()),
                ][tab])),
        bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (i) => setState(() => tab = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.today), label: 'Bugün'),
              NavigationDestination(icon: Icon(Icons.flag_outlined), label: 'Plan'),
              NavigationDestination(icon: Icon(Icons.local_fire_department_outlined), label: 'Yaşam'),
              NavigationDestination(icon: Icon(Icons.insights), label: 'İlerleme'),
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
    if (store.earnedToday) votes['Girişimci'] = (votes['Girişimci'] ?? 0) + 2;
    if (store.premium && store.budgetOnTrackToday) votes['Disiplinli'] = (votes['Disiplinli'] ?? 0) + 1;
    final routines = store.routinesToday();
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text('Seviye ${store.level} · ${store.daysSinceStart + 1}. gün', style: tt.labelLarge),
      Text('Bugün $done/${list.length}', style: tt.headlineMedium),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 4, children: [
        for (final i in {...store.identities, ...votes.keys}) Chip(label: Text('$i · ${votes[i] ?? 0} oy')),
      ]),
      const Text('Tam hedef 2 oy, minimum 1 oy. Her oy "ben buyum" demek.', style: TextStyle(fontSize: 12)),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(border: Border(left: BorderSide(color: Theme.of(context).colorScheme.primary, width: 4)),
            color: Theme.of(context).colorScheme.surfaceContainer),
        child: Text(quoteOfDay(store.identities), style: tt.titleMedium),
      ),
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
          subtitle: const Text('Beslenme, antrenman, vücut ve bütçe'),
          trailing: store.premium && kDebugMode ? TextButton(onPressed: () => store.setPremium(false), child: const Text('Kapat (test)')) : null),
      const ReminderTile(),
      const MotivationTile(),
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

/// Hazır şablonlar: tek dokunuşla formu doldurur.
class _Tpl {
  final String icon, name, unit, identity;
  final HabitType type;
  final num goal, mini;
  const _Tpl(this.icon, this.name, this.type, this.goal, this.mini, this.unit, this.identity);
}

const _templates = [
  _Tpl('🧘', 'Yoga', HabitType.dur, 60, 10, 'dk', 'Fit'),
  _Tpl('📖', 'Kitap oku', HabitType.dur, 30, 10, 'dk', 'Okuyan'),
  _Tpl('🏃', 'Koşu', HabitType.qty, 5, 1, 'km', 'Fit'),
  _Tpl('💪', 'Şınav', HabitType.qty, 50, 10, 'tekrar', 'Fit'),
  _Tpl('🗣', 'Yeni kelime', HabitType.qty, 30, 5, 'kelime', 'Dil bilen'),
  _Tpl('🎯', 'Derin çalışma', HabitType.dur, 90, 25, 'dk', 'Üreten'),
  _Tpl('🧠', 'Meditasyon', HabitType.dur, 15, 3, 'dk', 'Sakin zihin'),
  _Tpl('🧊', 'Soğuk duş', HabitType.bool_, 1, 1, '', 'Disiplinli'),
  _Tpl('✍', 'Günlük yaz', HabitType.bool_, 1, 1, '', 'Üreten'),
  _Tpl('📵', 'Telefonsuz saat', HabitType.dur, 60, 15, 'dk', 'Disiplinli'),
];

/// Yeni alışkanlık veya düzenleme. Silme seçilirse key '__delete__' olan bir Habit döner.
Future<Habit?> showHabitSheet(BuildContext context, List<String> ids, {Habit? existing}) {
  final ex = existing;
  final name = TextEditingController(text: ex?.name ?? ''),
      unit = TextEditingController(text: ex?.unit ?? ''),
      routine = TextEditingController(text: ex?.routine ?? '');
  var type = ex?.type ?? HabitType.dur;
  num goal = ex?.goal ?? 30, mini = ex?.mini ?? 10;
  final idList = ids.isEmpty ? ['Disiplinli'] : ids;
  var identity = ex != null && idList.contains(ex.identity) ? ex.identity : idList.first;
  final days = <int>{...(ex?.days ?? [1, 2, 3, 4, 5, 6, 7])};
  var confirmDelete = false;

  return showModalBottomSheet<Habit>(context: context, isScrollControlled: true, useSafeArea: true,
    builder: (ctx) => StatefulBuilder(builder: (ctx, set) {
      final tt = Theme.of(ctx).textTheme;
      final u = type == HabitType.bool_ ? '' : (unit.text.trim().isEmpty ? (type == HabitType.dur ? 'dk' : 'adet') : unit.text.trim());
      num step(num v) => type == HabitType.dur ? (v >= 60 ? 15 : 5) : (v >= 20 ? 5 : 1);
      final perYear = type == HabitType.bool_ ? days.length * 52
          : goal * days.length * 52 / (type == HabitType.dur && u == 'dk' ? 60 : 1);
      final yearText = type == HabitType.bool_ ? '${perYear.round()} gün'
          : type == HabitType.dur && u == 'dk' ? '${perYear.round()} saat' : '${perYear.round()} $u';

      Widget section(String t) => Padding(padding: const EdgeInsets.only(top: 18, bottom: 8),
          child: Text(t.toUpperCase(), style: tt.labelMedium));

      Widget stepper(String label, num v, void Function(num) onSet, Color c) => Expanded(child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: Iron.bg, border: Border.all(color: Iron.line), borderRadius: BorderRadius.circular(6)),
        child: Column(children: [
          Text(label.toUpperCase(), style: tt.labelSmall),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(icon: const Icon(Icons.remove), onPressed: () => set(() => onSet(v - step(v) < 1 ? 1 : v - step(v)))),
            Column(children: [
              Text('$v', style: tt.displaySmall?.copyWith(color: c, height: 1)),
              Text(u, style: tt.labelSmall),
            ]),
            IconButton(icon: const Icon(Icons.add), onPressed: () => set(() => onSet(v + step(v)))),
          ]),
        ]),
      ));

      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Center(child: Container(width: 40, height: 4, color: Iron.line)),
          const SizedBox(height: 12),
          Text(ex == null ? 'YENİ ALIŞKANLIK' : 'ALIŞKANLIĞI DÜZENLE', style: tt.headlineSmall),
          Text('Küçük eylem. Büyük kimlik.', style: TextStyle(color: Iron.steel)),

          if (ex == null) ...[
            section('Hızlı başla'),
            SizedBox(height: 74, child: ListView(scrollDirection: Axis.horizontal, children: [
              for (final t in _templates)
                Padding(padding: const EdgeInsets.only(right: 8), child: InkWell(
                  onTap: () => set(() {
                    name.text = t.name; type = t.type; goal = t.goal; mini = t.mini; unit.text = t.unit;
                    if (idList.contains(t.identity)) identity = t.identity;
                  }),
                  child: Container(width: 78,
                    decoration: BoxDecoration(color: name.text == t.name ? Iron.fire : Iron.bg,
                        border: Border.all(color: name.text == t.name ? Iron.fire : Iron.line),
                        borderRadius: BorderRadius.circular(6)),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(t.icon, style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 4),
                      Text(t.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                              color: name.text == t.name ? Colors.black : Iron.white)),
                    ])),
                )),
            ])),
          ],

          section('Ne yapacaksın?'),
          TextField(controller: name, onChanged: (_) => set(() {}),
              style: tt.titleLarge, decoration: const InputDecoration(hintText: 'örn. Yoga')),

          section('Nasıl ölçülür?'),
          SegmentedButton<HabitType>(
            style: SegmentedButton.styleFrom(selectedBackgroundColor: Iron.fire, selectedForegroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
            segments: const [
              ButtonSegment(value: HabitType.dur, icon: Icon(Icons.timer_outlined), label: Text('Süre')),
              ButtonSegment(value: HabitType.qty, icon: Icon(Icons.tag), label: Text('Miktar')),
              ButtonSegment(value: HabitType.bool_, icon: Icon(Icons.check), label: Text('Yaptım')),
            ], selected: {type}, onSelectionChanged: (v) => set(() => type = v.first)),

          if (type != HabitType.bool_) ...[
            section('Hedef ve kötü gün minimumu'),
            Row(children: [
              stepper('Hedef', goal, (v) { goal = v; if (mini > goal) mini = goal; }, Iron.fire),
              const SizedBox(width: 8),
              stepper('Kötü gün', mini, (v) => mini = v > goal ? goal : v, Iron.ember),
            ]),
            const SizedBox(height: 8),
            if (type == HabitType.dur)
              Wrap(spacing: 6, children: [
                for (final m in [10, 15, 20, 30, 45, 60, 90, 120])
                  ChoiceChip(label: Text('$m dk'), selected: goal == m,
                      onSelected: (_) => set(() { goal = m; unit.text = 'dk'; if (mini > goal) mini = (m / 4).round(); })),
              ])
            else
              TextField(controller: unit, onChanged: (_) => set(() {}),
                  decoration: const InputDecoration(labelText: 'Birim', hintText: 'km, sayfa, kelime, tekrar')),
          ],

          section('Hangi günler?'),
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (final p in <String, List<int>>{
              'Her gün': [1, 2, 3, 4, 5, 6, 7], 'Hafta içi': [1, 2, 3, 4, 5],
              'Hafta sonu': [6, 7], '3 gün': [1, 3, 5]}.entries)
              ActionChip(label: Text(p.key), onPressed: () => set(() { days..clear()..addAll(p.value); })),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            for (var d = 1; d <= 7; d++)
              Expanded(child: GestureDetector(
                onTap: () => set(() { if (!days.remove(d)) days.add(d); if (days.isEmpty) days.add(d); }),
                child: Container(height: 42, margin: const EdgeInsets.symmetric(horizontal: 2),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: days.contains(d) ? Iron.fire : Iron.bg,
                      border: Border.all(color: days.contains(d) ? Iron.fire : Iron.line),
                      borderRadius: BorderRadius.circular(4)),
                  child: Text(dayNames[d - 1].substring(0, 2).toUpperCase(),
                      style: TextStyle(fontWeight: FontWeight.w900, color: days.contains(d) ? Colors.black : Iron.steel))),
              )),
          ]),

          section('Hangi kimliğe oy veriyor?'),
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (final i in idList)
              ChoiceChip(label: Text(i), selected: identity == i, onSelected: (_) => set(() => identity = i)),
          ]),

          section('Rutin (isteğe bağlı)'),
          Wrap(spacing: 6, children: [
            for (final r in {'Sabah', 'Akşam', ...store.routineNames})
              ChoiceChip(label: Text(r), selected: routine.text == r,
                  onSelected: (v) => set(() => routine.text = v ? r : '')),
          ]),

          // Canlı kimlik önizlemesi
          Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF2A0E04), Iron.bg], begin: Alignment.topLeft, end: Alignment.bottomRight),
              border: Border.all(color: Iron.fire.withValues(alpha: .5)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('BU ALIŞKANLIK SENİ NEREYE GÖTÜRÜR', style: tt.labelMedium),
              const SizedBox(height: 8),
              Text(yearText.toUpperCase(), style: tt.displaySmall?.copyWith(color: Iron.fire)),
              Text('1 yılda, ${days.length == 7 ? "her gün" : "haftada ${days.length} gün"}', style: TextStyle(color: Iron.steel)),
              const SizedBox(height: 10),
              Text('${name.text.isEmpty ? "Bu alışkanlık" : name.text} → $identity kimliğine her gün +2 oy.'
                  '${type == HabitType.bool_ ? "" : " Kötü günde $mini $u yeter, seri bozulmaz."}',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ]),
          ),

          const SizedBox(height: 16),
          SizedBox(height: 52, child: FilledButton(onPressed: () {
            if (name.text.trim().isEmpty) return;
            final b = type == HabitType.bool_;
            Navigator.pop(ctx, Habit(
                key: ex?.key ?? 'h${DateTime.now().millisecondsSinceEpoch}',
                name: name.text.trim(), type: type, goal: b ? 1 : goal, mini: b ? 1 : mini,
                unit: b ? '' : u, identity: identity, days: (days.toList()..sort()), routine: routine.text.trim(),
                archived: ex?.archived ?? false));
          }, child: Text(ex == null ? 'BAŞLA' : 'KAYDET'))),
          if (ex != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                if (!confirmDelete) { set(() => confirmDelete = true); return; }
                Navigator.pop(ctx, ex.copyWithKey('__delete__'));
              },
              child: Text(confirmDelete ? 'Emin misin? Geçmişi de silinir. Tekrar dokun.' : 'Sil',
                  style: const TextStyle(color: Iron.blood)),
            ),
          ],
        ]),
      );
    }));
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

// ======================= MOTİVASYON BİLDİRİMLERİ =======================
class MotivationTile extends StatefulWidget {
  const MotivationTile({super.key});
  @override
  State<MotivationTile> createState() => _MotivationTileState();
}

class _MotivationTileState extends State<MotivationTile> {
  int count = 3;
  @override
  void initState() {
    super.initState();
    motivationCount().then((v) { if (mounted) setState(() => count = v); });
  }

  @override
  Widget build(BuildContext context) => ListTile(
        leading: const Icon(Icons.bolt),
        title: const Text('Motivasyon sözleri'),
        subtitle: Text(count == 0 ? 'Kapalı' : count == 3 ? 'Günde 3 kez: 09:00 · 14:00 · 20:00'
            : 'Günde 4 kez: 08:00 · 12:00 · 16:00 · 21:00'),
        trailing: SegmentedButton<int>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: 0, label: Text('Kapalı')),
            ButtonSegment(value: 3, label: Text('3')),
            ButtonSegment(value: 4, label: Text('4')),
          ],
          selected: {count},
          onSelectionChanged: (v) async {
            setState(() => count = v.first);
            await scheduleMotivation(count, store.identities);
            if (context.mounted) toast(context, count == 0 ? 'Motivasyon bildirimleri kapandı.' : 'Günde $count söz gelecek.');
          },
        ),
      );
}
