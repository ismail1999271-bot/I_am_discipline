import 'package:i_am_disiplin/models/app_models.dart';

class RankTier {
  final String name;
  final int xp;
  final String line;
  const RankTier(this.name, this.xp, this.line);
}

const ranks = <RankTier>[
  RankTier('Acemi', 0, 'Başladın. Bahane bitti.'),
  RankTier('Er', 500, 'Bahane bitti. Artık ersin.'),
  RankTier('Onbaşı', 1500, 'Üç gün kaçmak rütbe düşürmez. Karakter düşürür.'),
  RankTier('Çavuş', 3500, 'Emir bekleyen değil, emri veren ol.'),
  RankTier('Astsubay', 7000, 'Disiplin duygudur, his değil. Karar ver.'),
  RankTier('Teğmen', 12000, 'Sıradan günler efsaneyi öldürür. Sen öldürme.'),
  RankTier('Yüzbaşı', 20000, 'Komuta kendinden başlar.'),
  RankTier('Binbaşı', 32000, 'Zayıf günün bahanesi yok. Planın var.'),
  RankTier('Albay', 50000, 'Kalabalık uyur. Sen bitirirsin.'),
  RankTier('Komutan', 75000, 'Artık kaçacak yerin yok. Zirvedesin.'),
  RankTier('Efsane', 110000, 'İsim değil. İz bırakırsın.'),
];

class XpResult {
  final int xp;
  final int streak;
  final int todayDone;
  final int todayTotal;
  const XpResult(this.xp, this.streak, this.todayDone, this.todayTotal);
}

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

String dateKey(DateTime d) {
  final x = dateOnly(d);
  final m = x.month.toString().padLeft(2, '0');
  final day = x.day.toString().padLeft(2, '0');
  return '${x.year}-$m-$day';
}

bool scheduledOn(Habit h, DateTime day) {
  final d = dateOnly(day);
  final created = dateOnly(DateTime.parse(h.created));
  if (d.isBefore(created)) return false;
  if (h.days.isEmpty) return false;
  return h.days.contains(d.weekday);
}

int rankIndexFor(int xp) {
  var i = 0;
  for (var k = 0; k < ranks.length; k++) {
    if (xp >= ranks[k].xp) i = k;
  }
  return i;
}

int multNum(int streak) {
  if (streak >= 90) return 20;
  if (streak >= 30) return 15;
  if (streak >= 7) return 12;
  return 10;
}

String multLabel(int streak) {
  if (streak >= 90) return 'x2';
  if (streak >= 30) return 'x1.5';
  if (streak >= 7) return 'x1.2';
  return 'x1';
}

int _scaled(int base, int streak) => base * multNum(streak) ~/ 10;

XpResult evaluate({
  required DateTime start,
  required DateTime asOf,
  required List<Habit> habits,
  required Map<String, Set<String>> checks,
  required List<LifeGoal> goals,
}) {
  final today = dateOnly(asOf);
  final from = dateOnly(start);
  if (today.isBefore(from)) {
    return const XpResult(0, 0, 0, 0);
  }

  var xp = 0;
  var streak = 0;
  var missRun = 0;
  var todayDone = 0;
  var todayTotal = 0;

  for (var d = from; !d.isAfter(today); d = d.add(const Duration(days: 1))) {
    final scheduled = habits.where((h) => scheduledOn(h, d)).toList();
    final isToday = d == today;
    if (scheduled.isEmpty) continue;

    final doneIds = checks[dateKey(d)] ?? <String>{};
    final done = scheduled.where((h) => doneIds.contains(h.id)).toList();
    if (isToday) {
      todayDone = done.length;
      todayTotal = scheduled.length;
    }
    final allDone = done.length == scheduled.length;
    final anyDone = done.isNotEmpty;

    if (!isToday && !anyDone) {
      streak = 0;
      missRun += 1;
      if (missRun == 3) {
        xp -= 100;
        missRun = 0;
      }
      continue;
    }

    if (anyDone) missRun = 0;

    final streakFor = allDone ? streak + 1 : streak;
    for (final h in done) {
      xp += _scaled(h.hard ? 20 : 10, streakFor);
    }
    if (allDone) {
      xp += _scaled(50, streakFor);
      streak = streakFor;
    } else if (!isToday) {
      streak = 0;
    }
  }

  for (final g in goals) {
    if (g.horizon == 'aylik' && g.target > 0 && g.current >= g.target) {
      xp += 500;
    }
  }
  if (xp < 0) xp = 0;
  return XpResult(xp, streak, todayDone, todayTotal);
}

int habitStreak(Habit h, Map<String, Set<String>> checks, DateTime asOf) {
  var streak = 0;
  var d = dateOnly(asOf);
  final created = dateOnly(DateTime.parse(h.created));
  if (scheduledOn(h, d)) {
    final done = (checks[dateKey(d)] ?? <String>{}).contains(h.id);
    if (!done) d = d.subtract(const Duration(days: 1));
  }
  while (!d.isBefore(created)) {
    if (!scheduledOn(h, d)) {
      d = d.subtract(const Duration(days: 1));
      continue;
    }
    final done = (checks[dateKey(d)] ?? <String>{}).contains(h.id);
    if (!done) break;
    streak += 1;
    d = d.subtract(const Duration(days: 1));
  }
  return streak;
}
