import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:i_am_disiplin/models/app_models.dart';
import 'package:i_am_disiplin/services/reminders.dart';
import 'package:i_am_disiplin/services/xp_engine.dart';
import 'package:i_am_disiplin/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStore extends ChangeNotifier {
  AppStore._();
  static final AppStore I = AppStore._();
  static final navKey = GlobalKey<NavigatorState>();

  static const _key = 'bd_state_v1';

  bool splashDone = false;
  String? gender;
  bool isPremium = false;
  int peakRank = 0;
  int? pendingPromotion;
  String themeId = 'acemi';
  DateTime start = DateTime.now();
  List<Habit> habits = [];
  Map<String, Set<String>> checks = {};
  List<AgendaItem> events = [];
  List<Notebook> notebooks = [];
  List<LifeGoal> goals = [];
  List<MoneyMove> money = [];
  List<FilmItem> films = [];
  List<FoodLog> foods = [];
  DietTargets diet = const DietTargets(kcal: 2200, protein: 150, carb: 220, fat: 70);

  XpResult get result => evaluate(
        start: start,
        asOf: DateTime.now(),
        habits: habits,
        checks: checks,
        goals: goals,
      );

  XpResult xpAt(DateTime day) => evaluate(
        start: start,
        asOf: day,
        habits: habits,
        checks: checks,
        goals: goals,
      );

  List<Habit> habitsOn(DateTime day) => habits.where((h) => scheduledOn(h, day)).toList();

  bool isChecked(String id, [DateTime? day]) {
    return (checks[dateKey(day ?? DateTime.now())] ?? <String>{}).contains(id);
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null && raw.isNotEmpty) {
      try {
        _read(jsonDecode(raw));
      } catch (e) {
        debugPrint('kayit okunamadi: $e');
      }
    }
    _recalc();
    notifyListeners();
  }

  void finishSplash() {
    splashDone = true;
    notifyListeners();
  }

  Future<void> setGender(String value) async {
    gender = value == 'kadin' ? 'kadin' : 'erkek';
    await _touch(schedule: false);
  }

  Future<void> setPremium(bool value) async {
    isPremium = value;
    await _touch(schedule: false);
  }

  Future<void> setTheme(String id) async {
    final skin = skinById(id);
    if (skin.minRank > peakRank) return;
    themeId = skin.id;
    await _touch(schedule: false);
  }

  void ackPromo() {
    if (pendingPromotion == null) return;
    pendingPromotion = null;
    notifyListeners();
    unawaited(_save());
  }

  Future<void> toggleHabit(String id, [DateTime? day]) async {
    final key = dateKey(day ?? DateTime.now());
    final set = checks.putIfAbsent(key, () => <String>{});
    if (!set.add(id)) set.remove(id);
    if (set.isEmpty) checks.remove(key);
    await _touch();
  }

  Future<void> saveHabit(Habit habit) async {
    final i = habits.indexWhere((h) => h.id == habit.id);
    if (i < 0) {
      habits.add(habit);
    } else {
      habits[i] = habit;
    }
    await _touch();
  }

  Future<void> deleteHabit(String id) async {
    habits.removeWhere((h) => h.id == id);
    await _touch();
  }

  Future<void> addPackHabits(List<Habit> drafts) async {
    final salt = newId();
    final today = dateKey(DateTime.now());
    for (var i = 0; i < drafts.length; i++) {
      habits.add(drafts[i].copyWith(id: '${salt}_$i', created: today));
    }
    await _touch();
  }

  Future<void> saveEvent(AgendaItem item) async {
    final i = events.indexWhere((e) => e.id == item.id);
    if (i < 0) {
      events.add(item);
    } else {
      events[i] = item;
    }
    await _touch(schedule: false);
  }

  Future<void> deleteEvent(String id) async {
    events.removeWhere((e) => e.id == id);
    await _touch(schedule: false);
  }

  List<AgendaItem> eventsOn(DateTime day) {
    final key = dateKey(day);
    return events.where((e) => e.date == key).toList();
  }

  Future<void> saveNotebook(Notebook note) async {
    final i = notebooks.indexWhere((n) => n.id == note.id);
    if (i < 0) {
      notebooks.insert(0, note);
    } else {
      notebooks[i] = note;
    }
    await _touch(schedule: false);
  }

  Future<void> deleteNotebook(String id) async {
    notebooks.removeWhere((n) => n.id == id);
    await _touch(schedule: false);
  }

  Future<void> saveGoal(LifeGoal goal) async {
    final i = goals.indexWhere((g) => g.id == goal.id);
    if (i < 0) {
      goals.add(goal);
    } else {
      goals[i] = goal;
    }
    await _touch(schedule: false);
  }

  Future<void> deleteGoal(String id) async {
    goals.removeWhere((g) => g.id == id);
    await _touch(schedule: false);
  }

  Future<void> addMoney(MoneyMove move) async {
    money.add(move);
    await _touch(schedule: false);
  }

  Future<void> deleteMoney(String id) async {
    money.removeWhere((m) => m.id == id);
    await _touch(schedule: false);
  }

  Future<void> saveFilm(FilmItem film) async {
    final i = films.indexWhere((f) => f.id == film.id);
    if (i < 0) {
      films.add(film);
    } else {
      films[i] = film;
    }
    await _touch(schedule: false);
  }

  Future<void> deleteFilm(String id) async {
    films.removeWhere((f) => f.id == id);
    await _touch(schedule: false);
  }

  Future<void> addFood(FoodLog log) async {
    foods.add(log);
    await _touch(schedule: false);
  }

  Future<void> deleteFood(String id) async {
    foods.removeWhere((f) => f.id == id);
    await _touch(schedule: false);
  }

  Future<void> setDiet(DietTargets value) async {
    diet = value;
    await _touch(schedule: false);
  }

  List<FoodLog> foodsOn(DateTime day) {
    final key = dateKey(day);
    return foods.where((f) => f.date == key).toList();
  }

  Future<void> reset() async {
    gender = null;
    isPremium = false;
    peakRank = 0;
    pendingPromotion = null;
    themeId = 'acemi';
    start = DateTime.now();
    habits = [];
    checks = {};
    events = [];
    notebooks = [];
    goals = [];
    money = [];
    films = [];
    foods = [];
    diet = const DietTargets(kcal: 2200, protein: 150, carb: 220, fat: 70);
    splashDone = false;
    await _save();
    await rescheduleAll(habits);
    notifyListeners();
  }

  void _recalc() {
    final idx = rankIndexFor(result.xp);
    if (idx > peakRank) {
      peakRank = idx;
      pendingPromotion = idx;
      if (idx >= 0 && idx < skins.length) themeId = skins[idx].id;
    }
    if (peakRank >= ranks.length) peakRank = ranks.length - 1;
    if (peakRank < 0) peakRank = 0;
  }

  Future<void> _touch({bool schedule = true}) async {
    _recalc();
    notifyListeners();
    await _save();
    if (schedule) await rescheduleAll(habits);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final checksJson = <String, List<String>>{};
    checks.forEach((k, v) => checksJson[k] = v.toList());
    final payload = {
      'gender': gender,
      'premium': isPremium,
      'peak': peakRank,
      'promo': pendingPromotion,
      'theme': themeId,
      'start': dateKey(start),
      'habits': habits.map((e) => e.toJson()).toList(),
      'checks': checksJson,
      'events': events.map((e) => e.toJson()).toList(),
      'notebooks': notebooks.map((e) => e.toJson()).toList(),
      'goals': goals.map((e) => e.toJson()).toList(),
      'money': money.map((e) => e.toJson()).toList(),
      'films': films.map((e) => e.toJson()).toList(),
      'foods': foods.map((e) => e.toJson()).toList(),
      'diet': diet.toJson(),
    };
    await prefs.setString(_key, jsonEncode(payload));
  }

  void _read(Object? data) {
    if (data is! Map) return;
    final m = Map<String, dynamic>.from(data);
    final g = m['gender']?.toString();
    gender = (g == 'kadin' || g == 'erkek') ? g : null;
    isPremium = m['premium'] == true;
    peakRank = (m['peak'] is num) ? (m['peak'] as num).toInt() : 0;
    pendingPromotion = (m['promo'] is num) ? (m['promo'] as num).toInt() : null;
    themeId = m['theme']?.toString() ?? 'acemi';
    final s = m['start']?.toString();
    if (s != null && s.isNotEmpty) {
      try {
        start = dateOnly(DateTime.parse(s));
      } catch (e) {
        start = DateTime.now();
      }
    }
    habits = _list(m['habits'], Habit.fromJson);
    events = _list(m['events'], AgendaItem.fromJson);
    notebooks = _list(m['notebooks'], Notebook.fromJson);
    goals = _list(m['goals'], LifeGoal.fromJson);
    money = _list(m['money'], MoneyMove.fromJson);
    films = _list(m['films'], FilmItem.fromJson);
    foods = _list(m['foods'], FoodLog.fromJson);
    diet = DietTargets.fromJson(m['diet']);
    checks = {};
    final rawChecks = m['checks'];
    if (rawChecks is Map) {
      rawChecks.forEach((key, value) {
        if (value is List) {
          checks[key.toString()] = value.map((e) => e.toString()).toSet();
        }
      });
    }
    if (peakRank < 0) peakRank = 0;
    if (peakRank >= ranks.length) peakRank = ranks.length - 1;
    if (!skins.any((s) => s.id == themeId)) themeId = 'acemi';
  }
}

List<T> _list<T>(Object? raw, T? Function(Object? item) parse) {
  if (raw is! List) return [];
  final out = <T>[];
  for (final item in raw) {
    final parsed = parse(item);
    if (parsed != null) out.add(parsed);
  }
  return out;
}
