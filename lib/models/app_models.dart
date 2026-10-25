class Habit {
  final String id;
  final String name;
  final String icon;
  final bool hard;
  final List<int> days;
  final String? reminder;
  final String created;

  const Habit({
    required this.id,
    required this.name,
    required this.icon,
    required this.hard,
    required this.days,
    required this.reminder,
    required this.created,
  });

  Habit copyWith({
    String? id,
    String? name,
    String? icon,
    bool? hard,
    List<int>? days,
    String? reminder,
    bool clearReminder = false,
    String? created,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      hard: hard ?? this.hard,
      days: days ?? this.days,
      reminder: clearReminder ? null : (reminder ?? this.reminder),
      created: created ?? this.created,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'hard': hard,
        'days': days,
        'reminder': reminder,
        'created': created,
      };

  static Habit? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(raw);
    final id = m['id']?.toString() ?? '';
    final name = m['name']?.toString() ?? '';
    if (id.isEmpty || name.isEmpty) return null;
    final days = <int>[];
    final rawDays = m['days'];
    if (rawDays is List) {
      for (final d in rawDays) {
        final n = d is num ? d.toInt() : int.tryParse('$d');
        if (n != null && n >= 1 && n <= 7) days.add(n);
      }
    }
    return Habit(
      id: id,
      name: name,
      icon: m['icon']?.toString() ?? 'flag',
      hard: m['hard'] == true,
      days: days,
      reminder: m['reminder']?.toString(),
      created: m['created']?.toString() ?? '1970-01-01',
    );
  }
}

class AgendaItem {
  final String id;
  final String date;
  final String category;
  final String title;
  final String note;
  final String? time;

  const AgendaItem({
    required this.id,
    required this.date,
    required this.category,
    required this.title,
    required this.note,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'category': category,
        'title': title,
        'note': note,
        'time': time,
      };

  static AgendaItem? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(raw);
    final id = m['id']?.toString() ?? '';
    final title = m['title']?.toString() ?? '';
    if (id.isEmpty || title.isEmpty) return null;
    return AgendaItem(
      id: id,
      date: m['date']?.toString() ?? '',
      category: m['category']?.toString() ?? 'is',
      title: title,
      note: m['note']?.toString() ?? '',
      time: m['time']?.toString(),
    );
  }
}

class Notebook {
  final String id;
  final String title;
  final String body;
  final String updated;

  const Notebook({
    required this.id,
    required this.title,
    required this.body,
    required this.updated,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'updated': updated,
      };

  static Notebook? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(raw);
    final id = m['id']?.toString() ?? '';
    if (id.isEmpty) return null;
    return Notebook(
      id: id,
      title: m['title']?.toString() ?? 'Defter',
      body: m['body']?.toString() ?? '',
      updated: m['updated']?.toString() ?? '',
    );
  }
}

class LifeGoal {
  final String id;
  final String kind;
  final String horizon;
  final String title;
  final double target;
  final double current;
  final String unit;

  const LifeGoal({
    required this.id,
    required this.kind,
    required this.horizon,
    required this.title,
    required this.target,
    required this.current,
    required this.unit,
  });

  double get ratio => target <= 0 ? 0 : (current / target).clamp(0, 1);

  LifeGoal copyWith({double? current, double? target, String? title}) {
    return LifeGoal(
      id: id,
      kind: kind,
      horizon: horizon,
      title: title ?? this.title,
      target: target ?? this.target,
      current: current ?? this.current,
      unit: unit,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind,
        'horizon': horizon,
        'title': title,
        'target': target,
        'current': current,
        'unit': unit,
      };

  static LifeGoal? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(raw);
    final id = m['id']?.toString() ?? '';
    if (id.isEmpty) return null;
    return LifeGoal(
      id: id,
      kind: m['kind']?.toString() ?? 'birikim',
      horizon: m['horizon']?.toString() ?? 'aylik',
      title: m['title']?.toString() ?? 'Hedef',
      target: _num(m['target']),
      current: _num(m['current']),
      unit: m['unit']?.toString() ?? '',
    );
  }
}

class MoneyMove {
  final String id;
  final String date;
  final bool income;
  final double amount;
  final String note;

  const MoneyMove({
    required this.id,
    required this.date,
    required this.income,
    required this.amount,
    required this.note,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'income': income,
        'amount': amount,
        'note': note,
      };

  static MoneyMove? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(raw);
    final id = m['id']?.toString() ?? '';
    if (id.isEmpty) return null;
    return MoneyMove(
      id: id,
      date: m['date']?.toString() ?? '',
      income: m['income'] == true,
      amount: _num(m['amount']),
      note: m['note']?.toString() ?? '',
    );
  }
}

class FilmItem {
  final String id;
  final String title;
  final bool watched;
  final int rating;
  final String note;

  const FilmItem({
    required this.id,
    required this.title,
    required this.watched,
    required this.rating,
    required this.note,
  });

  FilmItem copyWith({bool? watched, int? rating, String? note}) {
    return FilmItem(
      id: id,
      title: title,
      watched: watched ?? this.watched,
      rating: rating ?? this.rating,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'watched': watched,
        'rating': rating,
        'note': note,
      };

  static FilmItem? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(raw);
    final id = m['id']?.toString() ?? '';
    final title = m['title']?.toString() ?? '';
    if (id.isEmpty || title.isEmpty) return null;
    return FilmItem(
      id: id,
      title: title,
      watched: m['watched'] == true,
      rating: _num(m['rating']).round().clamp(0, 10),
      note: m['note']?.toString() ?? '',
    );
  }
}

class FoodLog {
  final String id;
  final String date;
  final String name;
  final double kcal;
  final double protein;
  final double carb;
  final double fat;

  const FoodLog({
    required this.id,
    required this.date,
    required this.name,
    required this.kcal,
    required this.protein,
    required this.carb,
    required this.fat,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'name': name,
        'kcal': kcal,
        'protein': protein,
        'carb': carb,
        'fat': fat,
      };

  static FoodLog? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(raw);
    final id = m['id']?.toString() ?? '';
    if (id.isEmpty) return null;
    return FoodLog(
      id: id,
      date: m['date']?.toString() ?? '',
      name: m['name']?.toString() ?? 'Yemek',
      kcal: _num(m['kcal']),
      protein: _num(m['protein']),
      carb: _num(m['carb']),
      fat: _num(m['fat']),
    );
  }
}

class DietTargets {
  final double kcal;
  final double protein;
  final double carb;
  final double fat;

  const DietTargets({
    required this.kcal,
    required this.protein,
    required this.carb,
    required this.fat,
  });

  Map<String, dynamic> toJson() => {
        'kcal': kcal,
        'protein': protein,
        'carb': carb,
        'fat': fat,
      };

  static DietTargets fromJson(Object? raw) {
    if (raw is! Map) {
      return const DietTargets(kcal: 2200, protein: 150, carb: 220, fat: 70);
    }
    final m = Map<String, dynamic>.from(raw);
    return DietTargets(
      kcal: _num(m['kcal']) <= 0 ? 2200 : _num(m['kcal']),
      protein: _num(m['protein']) <= 0 ? 150 : _num(m['protein']),
      carb: _num(m['carb']) <= 0 ? 220 : _num(m['carb']),
      fat: _num(m['fat']) <= 0 ? 70 : _num(m['fat']),
    );
  }
}

double _num(Object? v) {
  if (v is num) return v.toDouble();
  return double.tryParse('$v') ?? 0;
}

int _seq = 0;

String newId() {
  _seq += 1;
  return '${DateTime.now().microsecondsSinceEpoch}_$_seq';
}

const dayLabels = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

const iconKeys = [
  'alarm',
  'fitness',
  'run',
  'book',
  'language',
  'self',
  'water',
  'bed',
  'edit',
  'psych',
  'sun',
  'bolt',
  'air',
  'flag',
];

const kindLabels = {
  'birikim': 'Birikim',
  'butce': 'Aylık bütçe',
  'dil': 'Dil',
  'vucut': 'Vücut',
  'yan_gelir': 'Yan gelir',
};

const categoryLabels = {
  'spor': 'Spor',
  'yemek': 'Yemek',
  'uyku': 'Uyku',
  'is': 'İş',
};
