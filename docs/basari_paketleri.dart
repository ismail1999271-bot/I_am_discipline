final packs = <String, List<Habit>>{
  'Sınav Dönemi': [
    Habit(key: 'h0', name: 'Konu çalış', type: HabitType.dur, goal: 60, mini: 20, unit: 'dk', identity: 'Okuyan', days: [1,2,3,4,5,6,7], routine: 'Akşam'),
    Habit(key: 'h1', name: 'Soru çöz', type: HabitType.qty, goal: 30, mini: 10, unit: 'soru', identity: 'Okuyan'),
    Habit(key: 'h2', name: 'Uyku', type: HabitType.dur, goal: 480, mini: 360, unit: 'dk', identity: 'Sakin zihin', routine: 'Akşam'),
  ],
  'Yeni Anne/Baba': [
    Habit(key: 'h0', name: 'Kısa nefes', type: HabitType.dur, goal: 5, mini: 2, unit: 'dk', identity: 'Sakin zihin', routine: 'Sabah'),
    Habit(key: 'h1', name: 'Yürüyüş', type: HabitType.dur, goal: 20, mini: 10, unit: 'dk', identity: 'Fit'),
    Habit(key: 'h2', name: 'Su iç', type: HabitType.qty, goal: 8, mini: 4, unit: 'bardak', identity: 'Fit'),
  ],
  'Ramazan': [
    Habit(key: 'h0', name: 'Kur\'an oku', type: HabitType.dur, goal: 20, mini: 5, unit: 'dk', identity: 'Sakin zihin', routine: 'Akşam'),
    Habit(key: 'h1', name: 'Yürüyüş (iftar öncesi)', type: HabitType.dur, goal: 15, mini: 5, unit: 'dk', identity: 'Fit'),
    Habit(key: 'h2', name: 'Su takibi', type: HabitType.qty, goal: 10, mini: 5, unit: 'bardak', identity: 'Fit'),
  ],
  'Erken Kalkan': [
    Habit(key: 'h0', name: 'Sabah kalk', type: HabitType.bool_, goal: 1, mini: 1, unit: '', identity: 'Disiplinli', routine: 'Sabah'),
    Habit(key: 'h1', name: 'Soğuk duş', type: HabitType.bool_, goal: 1, mini: 1, unit: '', identity: 'Disiplinli', routine: 'Sabah'),
    Habit(key: 'h2', name: 'Meditasyon', type: HabitType.dur, goal: 10, mini: 3, unit: 'dk', identity: 'Sakin zihin', routine: 'Sabah'),
  ],
  'Dijital Detoks': [
    Habit(key: 'h0', name: 'Telefon yok sabah', type: HabitType.dur, goal: 60, mini: 30, unit: 'dk', identity: 'Sakin zihin', routine: 'Sabah'),
    Habit(key: 'h1', name: 'Kitap oku', type: HabitType.dur, goal: 30, mini: 10, unit: 'dk', identity: 'Okuyan'),
    Habit(key: 'h2', name: 'Yürüyüş', type: HabitType.dur, goal: 20, mini: 10, unit: 'dk', identity: 'Fit'),
  ],
};
