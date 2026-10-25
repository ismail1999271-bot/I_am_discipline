import 'package:flutter_test/flutter_test.dart';
import 'package:i_am_disiplin/models/app_models.dart';
import 'package:i_am_disiplin/services/xp_engine.dart';

Habit easy() => const Habit(
      id: 'a',
      name: 'Su',
      icon: 'water',
      hard: false,
      days: [1, 2, 3, 4, 5, 6, 7],
      reminder: null,
      created: '2026-01-01',
    );

void main() {
  test('rütbe eşikleri', () {
    expect(rankIndexFor(0), 0);
    expect(rankIndexFor(499), 0);
    expect(rankIndexFor(500), 1);
    expect(rankIndexFor(109999), 9);
    expect(rankIndexFor(110000), 10);
  });

  test('tam gün 60 XP', () {
    final r = evaluate(
      start: DateTime(2026, 1, 1),
      asOf: DateTime(2026, 1, 1, 20),
      habits: [easy()],
      checks: {
        '2026-01-01': {'a'},
      },
      goals: const [],
    );
    expect(r.xp, 60);
    expect(r.streak, 1);
  });

  test('7. gün çarpanı x1.2', () {
    final checks = <String, Set<String>>{};
    for (var d = 1; d <= 7; d++) {
      checks['2026-01-${d.toString().padLeft(2, '0')}'] = {'a'};
    }
    final r = evaluate(
      start: DateTime(2026, 1, 1),
      asOf: DateTime(2026, 1, 7, 20),
      habits: [easy()],
      checks: checks,
      goals: const [],
    );
    expect(r.xp, 432);
    expect(r.streak, 7);
  });

  test('bugün boş seri kırmaz', () {
    final r = evaluate(
      start: DateTime(2026, 1, 1),
      asOf: DateTime(2026, 1, 2, 12),
      habits: [easy()],
      checks: {
        '2026-01-01': {'a'},
      },
      goals: const [],
    );
    expect(r.streak, 1);
    expect(r.xp, 60);
  });

  test('üç boş gün -100', () {
    final checks = <String, Set<String>>{};
    for (var d = 1; d <= 20; d++) {
      checks['2026-01-${d.toString().padLeft(2, '0')}'] = {'a'};
    }
    final full = evaluate(
      start: DateTime(2026, 1, 1),
      asOf: DateTime(2026, 1, 20, 20),
      habits: [easy()],
      checks: checks,
      goals: const [],
    );
    final hit = evaluate(
      start: DateTime(2026, 1, 1),
      asOf: DateTime(2026, 1, 24, 12),
      habits: [easy()],
      checks: checks,
      goals: const [],
    );
    expect(hit.xp, full.xp - 100);
    expect(hit.streak, 0);
  });

  test('aylık hedef +500', () {
    const goal = LifeGoal(
      id: 'g',
      kind: 'birikim',
      horizon: 'aylik',
      title: 'Birikim',
      target: 1000,
      current: 1000,
      unit: 'TL',
    );
    final r = evaluate(
      start: DateTime(2026, 1, 1),
      asOf: DateTime(2026, 1, 1),
      habits: const [],
      checks: const {},
      goals: const [goal],
    );
    expect(r.xp, 500);
  });
}
