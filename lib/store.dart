import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

String dayKey(DateTime d) => d.toIso8601String().substring(0, 10);
DateTime _d0(DateTime d) => DateTime(d.year, d.month, d.day);

class Store extends ChangeNotifier {
  List<String> identities = [];
  List<Habit> habits = [];
  Map<String, Map<String, Entry>> log = {};
  /// tarih -> alışkanlık -> sebep (Yorgun, Vakit yok, Unuttum, İsteksiz)
  Map<String, Map<String, String>> skips = {};
  /// hafta başlangıcı -> {iyi, zor, degisim}
  Map<String, Map<String, String>> reviews = {};
  /// Gelecekteki ben mektubu
  String letter = '';
  String startDate = '';
  // Koç ayarları
  String ollamaHost = 'http://10.0.2.2:11434';
  String ollamaModel = 'qwen2.5:7b';
  // Premium + kalori
  bool premium = false;
  Map<String, dynamic> bodyProfile = {};
  /// tarih -> öğün listesi {name, portion, kcal, p, c, f}
  Map<String, List<Map<String, dynamic>>> meals = {};
  Map<String, int> water = {};
  List<Map<String, dynamic>> bodyLog = [];
  List<Map<String, dynamic>> sessions = [];
  Map<String, String> aiText = {};
  // Bütçe
  Map<String, dynamic> budget = {};
  List<Map<String, dynamic>> expenses = [];
  List<Map<String, dynamic>> savingsGoals = [];

  bool get onboarded => habits.isNotEmpty;
  List<Habit> get active => habits.where((h) => !h.archived).toList();
  List<Habit> get todayHabits => active.where((h) => h.on(DateTime.now())).toList();

  int get daysSinceStart => startDate.isEmpty ? 0 : DateTime.now().difference(DateTime.parse(startDate)).inDays;
  bool get letterOpen => letter.isNotEmpty && daysSinceStart >= 90;

  /// Seviye sistemi: 3 slotla başlar, gücü %70'i geçen her alışkanlık 1 slot açar.
  int get maxSlots => 3 + active.where((h) => strength(h) >= 70).length;
  int get level => 1 + active.where((h) => strength(h) >= 70).length;

  // ---------- kalıcılık ----------
  Map<String, dynamic> toJson() => {
        'ids': identities,
        'habits': habits.map((h) => h.toJson()).toList(),
        'log': log.map((d, m) => MapEntry(d, m.map((k, e) => MapEntry(k, e.toJson())))),
        'skips': skips, 'reviews': reviews, 'letter': letter, 'start': startDate,
        'host': ollamaHost, 'model': ollamaModel,
        'premium': premium, 'body': bodyProfile, 'meals': meals,
        'water': water, 'bodyLog': bodyLog, 'sessions': sessions, 'aiText': aiText,
        'budget': budget, 'expenses': expenses, 'savings': savingsGoals,
      };

  void _fromJson(Map<String, dynamic> j) {
    identities = List<String>.from(j['ids'] ?? []);
    habits = ((j['habits'] ?? []) as List).map((e) => Habit.fromJson(e)).toList();
    log = ((j['log'] ?? {}) as Map<String, dynamic>).map((d, m) => MapEntry(d,
        (m as Map<String, dynamic>).map((k, e) => MapEntry(k, Entry.fromJson(e)))));
    skips = ((j['skips'] ?? {}) as Map<String, dynamic>).map((d, m) => MapEntry(d, Map<String, String>.from(m)));
    reviews = ((j['reviews'] ?? {}) as Map<String, dynamic>).map((d, m) => MapEntry(d, Map<String, String>.from(m)));
    letter = j['letter'] ?? '';
    startDate = j['start'] ?? (log.isEmpty ? '' : (log.keys.toList()..sort()).first);
    ollamaHost = j['host'] ?? ollamaHost;
    ollamaModel = j['model'] ?? ollamaModel;
    premium = j['premium'] ?? false;
    bodyProfile = Map<String, dynamic>.from(j['body'] ?? {});
    meals = ((j['meals'] ?? {}) as Map<String, dynamic>).map((d, l) =>
        MapEntry(d, (l as List).map((m) => Map<String, dynamic>.from(m)).toList()));
    water = Map<String, int>.from(j['water'] ?? {});
    bodyLog = ((j['bodyLog'] ?? []) as List).map((m) => Map<String, dynamic>.from(m)).toList();
    sessions = ((j['sessions'] ?? []) as List).map((m) => Map<String, dynamic>.from(m)).toList();
    aiText = Map<String, String>.from(j['aiText'] ?? {});
    budget = Map<String, dynamic>.from(j['budget'] ?? {});
    expenses = ((j['expenses'] ?? []) as List).map((m) => Map<String, dynamic>.from(m)).toList();
    savingsGoals = ((j['savings'] ?? []) as List).map((m) => Map<String, dynamic>.from(m)).toList();
  }

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('state');
    if (raw == null) return;
    _fromJson(jsonDecode(raw));
    notifyListeners();
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('state', jsonEncode(toJson()));
    notifyListeners();
  }

  String exportBackup() => jsonEncode(toJson());

  /// Yedekten geri yükler; hatalıysa false döner.
  bool importBackup(String raw) {
    try {
      _fromJson(jsonDecode(raw));
      _save();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> resetAll() async {
    identities = []; habits = []; log = {}; skips = {}; reviews = {}; letter = ''; startDate = '';
    bodyProfile = {}; meals = {}; water = {}; bodyLog = []; sessions = []; aiText = {}; budget = {}; expenses = []; savingsGoals = [];
    await _save();
  }

  // ---------- düzenleme ----------
  void setup(List<String> ids, List<Habit> hs, {String letterText = ''}) {
    identities = ids; habits = hs; letter = letterText; startDate = dayKey(DateTime.now());
    _save();
  }

  void addHabit(Habit h) { habits.add(h); _save(); }
  void updateHabit(Habit h) { habits = [for (final x in habits) x.key == h.key ? h : x]; _save(); }
  void deleteHabit(Habit h) {
    habits.removeWhere((x) => x.key == h.key);
    for (final m in log.values) { m.remove(h.key); }
    _save();
  }
  void moveHabit(int from, int to) {
    final h = habits.removeAt(from);
    habits.insert(to > from ? to - 1 : to, h);
    _save();
  }
  void setPremium(bool v) { premium = v; _save(); }
  void setBodyProfile(Map<String, dynamic> p) { bodyProfile = p; _save(); }
  void addMeal(Map<String, dynamic> m) { (meals[dayKey(DateTime.now())] ??= []).add(m); _save(); }
  void removeMeal(String day, int i) { meals[day]?.removeAt(i); _save(); }

  /// Kalori hedefinde kalınan gün "Fit" kimliğine 2 oy verir (hedef callback ile verilir).
  bool calorieOnTrack(String day, int target) {
    final t = (meals[day] ?? []).fold<double>(0, (a, m) => a + (m['kcal'] as num).toDouble());
    return t > 0 && t <= target * 1.05 && t >= target * .7;
  }

  void addWater(int ml) {
    final d = dayKey(DateTime.now());
    water[d] = ((water[d] ?? 0) + ml).clamp(0, 10000).toInt();
    _save();
  }
  void addBody(Map<String, dynamic> e) {
    bodyLog.removeWhere((x) => x['date'] == e['date']);
    bodyLog.add(e);
    bodyLog.sort((a, b) => (a['date'] as String).compareTo(b['date']));
    if (e['kilo'] != null && bodyProfile.isNotEmpty) bodyProfile['kilo'] = e['kilo'];
    _save();
  }
  void removeBody(int i) { bodyLog.removeAt(i); _save(); }
  void addSession(Map<String, dynamic> s) { sessions.add(s); _save(); }
  void setAiText(String k, String v) { aiText[k] = v; _save(); }
  bool get workedOutToday => sessions.any((s) => s['date'] == dayKey(DateTime.now()));

  /// Bir hareketin son kaydedilen ağırlığı
  num? lastWeight(String ex) {
    for (final s in sessions.reversed) {
      for (final x in (s['sets'] as List).reversed) {
        if (x['ex'] == ex && (x['w'] as num) > 0) return x['w'] as num;
      }
    }
    return null;
  }

  /// Geçen seansta tüm setler hedef tekrara ulaştıysa ağırlık artırma önerisi
  String? progressHint(dynamic e) {
    for (final s in sessions.reversed) {
      final l = (s['sets'] as List).where((x) => x['ex'] == e.name).toList();
      if (l.isEmpty) continue;
      final w = l.map((x) => x['w'] as num).reduce((a, b) => a > b ? a : b);
      final allHit = l.length >= e.sets && l.every((x) => (x['r'] as num) >= e.reps);
      if (!e.weighted) return allHit ? 'Geçen sefer hepsi tamam. Bugün +2 tekrar dene.' : null;
      return allHit ? 'Geçen sefer $w kg ile hepsi tamam. Bugün ${w + 2.5} kg dene.' : 'Geçen sefer $w kg. Aynı ağırlıkla tekrarları tamamla.';
    }
    return null;
  }

  void setBudget(Map<String, dynamic> b) { budget = b; _save(); }
  void addExpense(Map<String, dynamic> e) { expenses.add(e); _save(); }
  void addSavingsGoal(Map<String, dynamic> g) { savingsGoals.add(g); _save(); }
  void removeSavingsGoal(String id) { savingsGoals.removeWhere((g) => g['id'] == id); _save(); }
  void moveSavings(String id, num delta) {
    for (final g in savingsGoals) {
      if (g['id'] == id) g['saved'] = ((g['saved'] as num) + delta).clamp(0, double.infinity);
    }
    _save();
  }
  void removeExpense(String id) { expenses.removeWhere((e) => e['id'] == id); _save(); }

  /// Bugün günlük bütçe payının altında kalındı mı? (en az bir gün kayıt ve bütçe varsa)
  bool get budgetOnTrackToday {
    final inc = (budget['income'] ?? 0) as num;
    if (inc <= 0) return false;
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daily = (inc - ((budget['saving'] ?? 0) as num)) / daysInMonth;
    final today = dayKey(now);
    final spentToday = expenses.where((e) => e['date'] == today).fold<num>(0, (a, e) => a + (e['amt'] as num));
    final monthSpent = expenses.where((e) => (e['date'] as String).startsWith(today.substring(0, 7)))
        .fold<num>(0, (a, e) => a + (e['amt'] as num));
    return spentToday <= daily && monthSpent <= daily * now.day;
  }

  void setCoach(String host, String model) { ollamaHost = host; ollamaModel = model; _save(); }

  void mark(Habit h, int level, [num? value]) {
    final v = value ?? (level == 2 ? h.goal : h.mini);
    (log[dayKey(DateTime.now())] ??= {})[h.key] = Entry(v, v >= h.goal ? 2 : 1);
    _save();
  }

  void undo(Habit h) { log[dayKey(DateTime.now())]?.remove(h.key); _save(); }

  void setSkip(String day, Habit h, String reason) { (skips[day] ??= {})[h.key] = reason; _save(); }

  String weekKey([DateTime? d]) {
    final n = d ?? DateTime.now();
    return dayKey(n.subtract(Duration(days: n.weekday - 1)));
  }

  void saveReview(Map<String, String> r) { reviews[weekKey()] = r; _save(); }

  // ---------- hesaplar ----------
  /// Programa başlanan günden bugüne kadar, alışkanlığın planlı olduğu günler.
  List<DateTime> _scheduledDays(Habit h, {bool includeToday = true}) {
    if (startDate.isEmpty) return [];
    final out = <DateTime>[];
    var d = _d0(DateTime.parse(startDate));
    final end = _d0(DateTime.now());
    while (d.isBefore(end) || (includeToday && d == end)) {
      if (h.on(d)) out.add(d);
      d = d.add(const Duration(days: 1));
    }
    return out;
  }

  /// Dün planlı olup yapılmayan ve sebebi sorulmamış alışkanlıklar.
  List<Habit> missedYesterday() {
    final yd = _d0(DateTime.now()).subtract(const Duration(days: 1));
    final y = dayKey(yd);
    if (startDate.isEmpty || y.compareTo(startDate) < 0) return [];
    return active.where((h) => h.on(yd) && log[y]?[h.key] == null && skips[y]?[h.key] == null).toList();
  }

  /// Alışkanlık gücü: güç += (x - güç) * 0.08 ; x = 1 tam, 0.6 mini, 0 kaçırma.
  /// Bugün henüz yapılmadıysa ceza verilmez.
  int strength(Habit h) {
    double s = 0;
    final today = dayKey(DateTime.now());
    for (final d in _scheduledDays(h)) {
      final k = dayKey(d);
      final e = log[k]?[h.key];
      if (e == null && k == today) continue;
      final x = e == null ? 0.0 : (e.level == 2 ? 1.0 : 0.6);
      s += (x - s) * 0.08;
    }
    return (s * 100).round();
  }

  /// Planlı günlerde kesintisiz seri; planlı olmayan günler seriyi bozmaz.
  int streak(Habit h) {
    final days = _scheduledDays(h).reversed.toList();
    var n = 0;
    final today = dayKey(DateTime.now());
    for (final d in days) {
      final k = dayKey(d);
      if (log[k]?[h.key] != null) { n++; } else if (k != today) { break; }
    }
    return n;
  }

  int longestStreak(Habit h) {
    var best = 0, cur = 0;
    for (final d in _scheduledDays(h)) {
      if (log[dayKey(d)]?[h.key] != null) { cur++; if (cur > best) best = cur; } else { cur = 0; }
    }
    return best;
  }

  int totalDone(Habit h) => log.values.where((m) => m[h.key] != null).length;

  /// Son 30 planlı günde tamamlama oranı (0-100).
  int completion(Habit h) {
    final ds = _scheduledDays(h, includeToday: false);
    final last = ds.length > 30 ? ds.sublist(ds.length - 30) : ds;
    if (last.isEmpty) return 0;
    return (last.where((d) => log[dayKey(d)]?[h.key] != null).length * 100 / last.length).round();
  }

  /// Rutin adı -> sıralı alışkanlıklar (sadece bugün planlı olanlar)
  Map<String, List<Habit>> routinesToday() {
    final m = <String, List<Habit>>{};
    for (final h in todayHabits) {
      if (h.routine.isNotEmpty) (m[h.routine] ??= []).add(h);
    }
    return m;
  }

  List<String> get routineNames => {for (final h in active) if (h.routine.isNotEmpty) h.routine}.toList();

  /// Sorumluluk ortağıyla paylaşılacak kısa metin
  String shareText() {
    final b = StringBuffer('I Am Disiplin · Seviye $level · ${daysSinceStart + 1}. gün\n');
    for (final h in active) {
      b.writeln('• ${h.name}: 🔥${streak(h)} gün, güç %${strength(h)}, son 30 gün %${completion(h)}');
    }
    b.write('Kimliklerim: ${identities.join(", ")}');
    return b.toString();
  }

  /// Koça gönderilecek son 28 günün özeti
  String summary() {
    final b = StringBuffer('Kimlikler: ${identities.join(", ")}\n');
    final now = DateTime.now();
    for (final h in active) {
      final marks = List.generate(28, (i) {
        final d = now.subtract(Duration(days: 27 - i));
        if (!h.on(d)) return '-';
        final e = log[dayKey(d)]?[h.key];
        return e == null ? '0' : (e.level == 2 ? 'T' : 'M');
      }).join();
      b.writeln('${h.name} (${h.scheduleText}, hedef ${h.goal} ${h.unit}, min ${h.mini}): '
          'güç %${strength(h)}, seri ${streak(h)}, son28=$marks');
    }
    final reasons = <String, int>{};
    for (final m in skips.values) { for (final r in m.values) { reasons[r] = (reasons[r] ?? 0) + 1; } }
    if (reasons.isNotEmpty) b.writeln('Kaçırma sebepleri: $reasons');
    final r = reviews[weekKey()];
    if (r != null) b.writeln('Bu haftaki değerlendirme: $r');
    return b.toString();
  }
}
