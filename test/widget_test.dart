import 'package:flutter_test/flutter_test.dart';
import 'package:i_am_disiplin/models.dart';
import 'package:i_am_disiplin/calorie.dart';

void main() {
  test('Esnek gün kontrolü', () {
    final h = Habit(key: 'k', name: 'Koşu', type: HabitType.qty, goal: 5, mini: 1, unit: 'km',
        identity: 'Fit', days: [1, 3, 5]);
    expect(h.on(DateTime(2026, 10, 12)), true); // Pazartesi
    expect(h.on(DateTime(2026, 10, 13)), false); // Salı
  });

  test('Kalori hedefi güvenli alt sınırın altına inmez', () {
    final t = calorieTarget({'kilo': 45, 'boy': 150, 'yas': 60, 'cinsiyet': 'Kadın',
      'aktivite': 'Hareketsiz', 'hedef': 'Kilo vermek'});
    expect(t >= 1200, true);
  });
}
