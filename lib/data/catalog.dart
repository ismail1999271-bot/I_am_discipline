import 'package:i_am_disiplin/models/app_models.dart';

class PackDef {
  final String id;
  final String name;
  final String detail;
  final List<Habit> habits;
  const PackDef(this.id, this.name, this.detail, this.habits);
}

Habit _h(String name, String icon, {bool hard = false, String? reminder}) {
  return Habit(
    id: 'taslak',
    name: name,
    icon: icon,
    hard: hard,
    days: const [1, 2, 3, 4, 5, 6, 7],
    reminder: reminder,
    created: '1970-01-01',
  );
}

List<PackDef> packList() => [
      PackDef('sabah', 'Sabah Rutini', 'Kalk, duş, su. Günün geri kalanı bahaneye kapalı.', [
        _h('Kalkış 06:00', 'alarm', reminder: '06:00'),
        _h('Soğuk duş', 'water', hard: true, reminder: '06:10'),
        _h('Su iç', 'water', reminder: '06:20'),
      ]),
      PackDef('sporcu', 'Sporcu', 'Antrenman, hareket, esneklik.', [
        _h('Antrenman', 'fitness', hard: true, reminder: '18:00'),
        _h('Hareket', 'run', reminder: '12:00'),
        _h('Esneklik', 'self', reminder: '21:00'),
      ]),
      PackDef('dil', 'Dil Öğrenen', 'Kelime, dinleme, cümle.', [
        _h('Kelime', 'language', hard: true, reminder: '20:00'),
        _h('Dinleme', 'language', reminder: '08:00'),
        _h('Cümle kur', 'edit', reminder: '21:30'),
      ]),
      PackDef('okur', 'Okuyucu', 'Sayfa, not, tekrar.', [
        _h('Sayfa oku', 'book', hard: true, reminder: '22:00'),
        _h('Not çıkar', 'edit'),
        _h('Tekrar et', 'psych'),
      ]),
      PackDef('zihin', 'Zihin', 'Yoga, meditasyon, nefes.', [
        _h('Yoga', 'self', hard: true, reminder: '07:00'),
        _h('Meditasyon', 'self', reminder: '07:20'),
        _h('Nefes', 'air', reminder: '07:30'),
      ]),
    ];
