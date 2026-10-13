enum HabitType { bool_, dur, qty }

class Habit {
  final String key, name, unit, identity;
  final HabitType type;
  final num goal, mini;
  /// Haftanın hangi günleri (1 = Pazartesi … 7 = Pazar)
  final List<int> days;
  /// Rutin adı (örn. "Sabah"); boşsa rutine bağlı değil
  final String routine;
  final bool archived;

  Habit({required this.key, required this.name, required this.type, required this.goal,
      required this.mini, required this.unit, required this.identity,
      this.days = const [1, 2, 3, 4, 5, 6, 7], this.routine = '', this.archived = false});

  Habit copyWith({String? name, HabitType? type, num? goal, num? mini, String? unit, String? identity,
          List<int>? days, String? routine, bool? archived}) =>
      Habit(key: key, name: name ?? this.name, type: type ?? this.type, goal: goal ?? this.goal,
          mini: mini ?? this.mini, unit: unit ?? this.unit, identity: identity ?? this.identity,
          days: days ?? this.days, routine: routine ?? this.routine, archived: archived ?? this.archived);

  bool on(DateTime d) => days.contains(d.weekday);

  String get scheduleText {
    if (days.length == 7) return 'Her gün';
    const n = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return 'Haftada ${days.length}: ${(List<int>.from(days)..sort()).map((d) => n[d - 1]).join(' ')}';
  }

  Map<String, dynamic> toJson() => {'key': key, 'name': name, 'type': type.index, 'goal': goal,
      'mini': mini, 'unit': unit, 'identity': identity, 'days': days, 'routine': routine, 'archived': archived};

  factory Habit.fromJson(Map<String, dynamic> j) => Habit(key: j['key'], name: j['name'],
      type: HabitType.values[j['type']], goal: j['goal'], mini: j['mini'], unit: j['unit'], identity: j['identity'],
      days: j['days'] == null ? const [1, 2, 3, 4, 5, 6, 7] : List<int>.from(j['days']),
      routine: j['routine'] ?? '', archived: j['archived'] ?? false);
}

/// level: 2 = tam hedef, 1 = minimum
class Entry {
  final num value;
  final int level;
  Entry(this.value, this.level);
  Map<String, dynamic> toJson() => {'v': value, 'l': level};
  factory Entry.fromJson(Map<String, dynamic> j) => Entry(j['v'], j['l']);
}
