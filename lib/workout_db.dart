/// Hazır antrenman programları. reps: hedef tekrar (saniye bazlıysa "sn" birimi)
class Ex {
  final String name;
  final int sets, reps;
  final String unit; // 'tekrar' veya 'sn' veya 'dk'
  final bool weighted;
  const Ex(this.name, this.sets, this.reps, {this.unit = 'tekrar', this.weighted = false});
}

class ProgramDay {
  final String name;
  final List<Ex> exercises;
  const ProgramDay(this.name, this.exercises);
}

class Program {
  final String name, desc, level;
  final List<ProgramDay> days;
  const Program(this.name, this.desc, this.level, this.days);
}

const programs = <Program>[
  Program('Evde Başlangıç', 'Ekipmansız, haftada 3 gün tüm vücut', 'Başlangıç', [
    ProgramDay('Tüm vücut A', [
      Ex('Squat', 3, 12), Ex('Şınav (dizde olabilir)', 3, 8), Ex('Glute bridge', 3, 15),
      Ex('Plank', 3, 30, unit: 'sn'), Ex('Superman', 3, 12),
    ]),
    ProgramDay('Tüm vücut B', [
      Ex('Lunge', 3, 10), Ex('Sandalyede dips', 3, 8), Ex('Mountain climber', 3, 20),
      Ex('Yan plank', 3, 20, unit: 'sn'), Ex('Jumping jack', 3, 30),
    ]),
  ]),
  Program('Salon Başlangıç', 'Haftada 3 gün A/B dönüşümlü, ağırlıkla', 'Başlangıç', [
    ProgramDay('Gün A', [
      Ex('Squat', 3, 8, weighted: true), Ex('Bench press', 3, 8, weighted: true),
      Ex('Barbell row', 3, 8, weighted: true), Ex('Plank', 3, 40, unit: 'sn'),
    ]),
    ProgramDay('Gün B', [
      Ex('Deadlift', 3, 5, weighted: true), Ex('Overhead press', 3, 8, weighted: true),
      Ex('Lat pulldown', 3, 10, weighted: true), Ex('Leg press', 3, 10, weighted: true),
    ]),
  ]),
  Program('Üst / Alt Vücut', 'Haftada 4 gün, orta seviye', 'Orta', [
    ProgramDay('Üst vücut', [
      Ex('Bench press', 4, 8, weighted: true), Ex('Barbell row', 4, 8, weighted: true),
      Ex('Dumbbell shoulder press', 3, 10, weighted: true), Ex('Barfiks', 3, 6),
      Ex('Biceps curl', 3, 12, weighted: true), Ex('Triceps pushdown', 3, 12, weighted: true),
    ]),
    ProgramDay('Alt vücut', [
      Ex('Squat', 4, 6, weighted: true), Ex('Romanian deadlift', 3, 8, weighted: true),
      Ex('Leg press', 3, 12, weighted: true), Ex('Leg curl', 3, 12, weighted: true),
      Ex('Calf raise', 4, 15, weighted: true),
    ]),
  ]),
  Program('0 → 5 km Koşu', '8 hafta, haftada 3 gün yürü-koş', 'Başlangıç', [
    ProgramDay('Hafta 1-2', [Ex('Isınma yürüyüşü', 1, 5, unit: 'dk'), Ex('1 dk koş + 2 dk yürü', 8, 1, unit: 'tur')]),
    ProgramDay('Hafta 3-4', [Ex('Isınma yürüyüşü', 1, 5, unit: 'dk'), Ex('3 dk koş + 2 dk yürü', 5, 1, unit: 'tur')]),
    ProgramDay('Hafta 5-6', [Ex('Isınma yürüyüşü', 1, 5, unit: 'dk'), Ex('8 dk koş + 2 dk yürü', 3, 1, unit: 'tur')]),
    ProgramDay('Hafta 7-8', [Ex('Isınma yürüyüşü', 1, 5, unit: 'dk'), Ex('Kesintisiz koşu', 1, 30, unit: 'dk')]),
  ]),
  Program('Sabah Yogası', '20 dakikalık esneme ve nefes akışı', 'Herkes', [
    ProgramDay('Akış', [
      Ex('Nefes çalışması', 1, 2, unit: 'dk'), Ex('Kedi-inek', 1, 10), Ex('Aşağı bakan köpek', 3, 30, unit: 'sn'),
      Ex('Savaşçı 2 (her yön)', 2, 30, unit: 'sn'), Ex('Çocuk pozu', 1, 60, unit: 'sn'), Ex('Shavasana', 1, 3, unit: 'dk'),
    ]),
  ]),
];
