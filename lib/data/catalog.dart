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

class FoodInfo {
  final String name;
  final String portion;
  final double kcal;
  final double p;
  final double c;
  final double f;
  const FoodInfo(this.name, this.portion, this.kcal, this.p, this.c, this.f);
}

const foods = <FoodInfo>[
  FoodInfo('Yumurta', '1 adet', 78, 6, 0.6, 5),
  FoodInfo('Yulaf', '40 g', 150, 5, 27, 3),
  FoodInfo('Tavuk göğsü', '100 g', 165, 31, 0, 3.6),
  FoodInfo('Pirinç pilavı', '150 g', 195, 4, 42, 0.5),
  FoodInfo('Mercimek çorbası', '1 kase', 180, 10, 28, 3),
  FoodInfo('Yoğurt', '150 g', 90, 8, 7, 3),
  FoodInfo('Beyaz peynir', '50 g', 130, 8, 1, 10),
  FoodInfo('Tam buğday ekmek', '1 dilim', 80, 4, 14, 1),
  FoodInfo('Zeytinyağı', '1 yemek kaşığı', 90, 0, 0, 10),
  FoodInfo('Elma', '1 adet', 80, 0.4, 21, 0.3),
  FoodInfo('Muz', '1 adet', 105, 1.3, 27, 0.4),
  FoodInfo('Ceviz', '30 g', 196, 4.5, 4, 20),
  FoodInfo('Somon', '120 g', 250, 25, 0, 16),
  FoodInfo('Izgara köfte', '100 g', 250, 20, 2, 18),
  FoodInfo('Bulgur', '150 g', 170, 5, 36, 0.5),
  FoodInfo('Salatalık', '100 g', 15, 0.7, 3, 0.1),
  FoodInfo('Domates', '100 g', 18, 0.9, 3.9, 0.2),
  FoodInfo('Süt', '200 ml', 120, 6, 10, 6),
  FoodInfo('Badem', '20 g', 116, 4, 4, 10),
  FoodInfo('Makarna', '150 g', 220, 8, 43, 1.5),
  FoodInfo('Haşlanmış patates', '150 g', 130, 3, 30, 0.2),
  FoodInfo('Ton balığı', '1 konserve', 180, 32, 0, 5),
  FoodInfo('Lor peyniri', '100 g', 160, 18, 4, 8),
  FoodInfo('Avokado', 'yarım', 120, 1.5, 6, 11),
  FoodInfo('Bal', '1 tatlı kaşığı', 45, 0, 12, 0),
];

class MoveInfo {
  final String name;
  final String muscle;
  final String gear;
  final String level;
  const MoveInfo(this.name, this.muscle, this.gear, this.level);
}

const moves = <MoveInfo>[
  MoveInfo('Şınav', 'Göğüs', 'yok', 'başlangıç'),
  MoveInfo('Dambıl bench press', 'Göğüs', 'dambıl', 'orta'),
  MoveInfo('Dar şınav', 'Göğüs / kol', 'yok', 'orta'),
  MoveInfo('Barfiks', 'Sırt', 'barfiks barı', 'ileri'),
  MoveInfo('Superman', 'Sırt', 'yok', 'başlangıç'),
  MoveInfo('Squat', 'Bacak', 'yok', 'başlangıç'),
  MoveInfo('Lunge', 'Bacak', 'yok', 'başlangıç'),
  MoveInfo('Glute bridge', 'Kalça', 'yok', 'başlangıç'),
  MoveInfo('Plank', 'Karın', 'yok', 'başlangıç'),
  MoveInfo('Mekik', 'Karın', 'yok', 'başlangıç'),
  MoveInfo('Omuz press', 'Omuz', 'dambıl', 'orta'),
  MoveInfo('Yan raise', 'Omuz', 'dambıl', 'başlangıç'),
  MoveInfo('Biceps curl', 'Kol', 'dambıl', 'başlangıç'),
  MoveInfo('Triceps dip', 'Kol', 'yok', 'orta'),
  MoveInfo('Koşu', 'Kardiyo', 'yok', 'orta'),
  MoveInfo('İp atlama', 'Kardiyo', 'yok', 'orta'),
  MoveInfo('Çocuk pozu', 'Mobilite', 'yok', 'başlangıç'),
  MoveInfo('Aşağı bakan köpek', 'Mobilite', 'yok', 'başlangıç'),
];

class ProgramInfo {
  final String name;
  final String detail;
  final List<String> moves;
  const ProgramInfo(this.name, this.detail, this.moves);
}

const programs = <ProgramInfo>[
  ProgramInfo('Evde Başlangıç', '3 tur. Tempo sende, mola kısa.', ['Şınav', 'Squat', 'Plank', 'Glute bridge']),
  ProgramInfo('Salon Güç', '4 tur. Ağırlığı kontrol et, sallama.', ['Dambıl bench press', 'Squat', 'Omuz press', 'Biceps curl']),
  ProgramInfo('Sabah Yogası', 'Nefesle git. Acele yok, kaçış yok.', ['Çocuk pozu', 'Aşağı bakan köpek', 'Plank']),
];
