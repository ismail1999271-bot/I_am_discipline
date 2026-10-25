final packs = <String, List<Habit>>{
  'Sınav Dönemi': [
    Habit(key: 'h0', name: 'Konu çalış', type: HabitType.dur, goal: 50, mini: 15, unit: 'dk', identity: 'Okuyan', days: [1,2,3,4,5,6,7], routine: 'Akşam'),
    Habit(key: 'h1', name: 'Soru çöz', type: HabitType.qty, goal: 20, mini: 5, unit: 'soru', identity: 'Okuyan', days: [1,2,3,4,5,6,7], routine: 'Akşam'),
    Habit(key: 'h2', name: 'Uyku saati', type: HabitType.bool_, goal: 1, mini: 1, unit: '', identity: 'Sakin zihin', days: [1,2,3,4,5,6,7], routine: 'Akşam'),
  ],
  'Yeni Anne Baba': [
    Habit(key: 'h0', name: 'Kısa nefes', type: HabitType.dur, goal: 5, mini: 1, unit: 'dk', identity: 'Sakin zihin', days: [1,2,3,4,5,6,7], routine: 'Sabah'),
    Habit(key: 'h1', name: 'Kısa yürüyüş', type: HabitType.dur, goal: 15, mini: 5, unit: 'dk', identity: 'Fit', days: [1,2,3,4,5,6,7], routine: ''),
    Habit(key: 'h2', name: 'Su', type: HabitType.qty, goal: 6, mini: 2, unit: 'bardak', identity: 'Fit', days: [1,2,3,4,5,6,7], routine: ''),
  ],
  'Ramazan': [
    Habit(key: 'h0', name: 'Kısa okuma', type: HabitType.dur, goal: 15, mini: 5, unit: 'dk', identity: 'Sakin zihin', days: [1,2,3,4,5,6,7], routine: 'Akşam'),
    Habit(key: 'h1', name: 'İftar yürüyüşü', type: HabitType.dur, goal: 15, mini: 5, unit: 'dk', identity: 'Fit', days: [1,2,3,4,5,6,7], routine: 'Akşam'),
    Habit(key: 'h2', name: 'Su takibi', type: HabitType.qty, goal: 8, mini: 3, unit: 'bardak', identity: 'Fit', days: [1,2,3,4,5,6,7], routine: ''),
  ],
  'Erken Kalkan': [
    Habit(key: 'h0', name: 'Alarmda kalk', type: HabitType.bool_, goal: 1, mini: 1, unit: '', identity: 'Disiplinli', days: [1,2,3,4,5,6,7], routine: 'Sabah'),
    Habit(key: 'h1', name: 'Günün ilk işi', type: HabitType.dur, goal: 20, mini: 5, unit: 'dk', identity: 'Disiplinli', days: [1,2,3,4,5,6,7], routine: 'Sabah'),
    Habit(key: 'h2', name: 'Sabah ışığı', type: HabitType.dur, goal: 10, mini: 3, unit: 'dk', identity: 'Sakin zihin', days: [1,2,3,4,5,6,7], routine: 'Sabah'),
  ],
  'Dijital Detoks': [
    Habit(key: 'h0', name: 'Sabah telefonsuz', type: HabitType.dur, goal: 30, mini: 10, unit: 'dk', identity: 'Sakin zihin', days: [1,2,3,4,5,6,7], routine: 'Sabah'),
    Habit(key: 'h1', name: 'Kitap', type: HabitType.dur, goal: 20, mini: 5, unit: 'dk', identity: 'Okuyan', days: [1,2,3,4,5,6,7], routine: 'Akşam'),
    Habit(key: 'h2', name: 'Bildirim kapalı blok', type: HabitType.dur, goal: 45, mini: 15, unit: 'dk', identity: 'Disiplinli', days: [1,2,3,4,5,6,7], routine: ''),
  ],
  'Girişimci Sabahı': [
    Habit(key: 'h0', name: 'Önce iş', type: HabitType.dur, goal: 40, mini: 10, unit: 'dk', identity: 'Girişimci', days: [1,2,3,4,5], routine: 'Sabah'),
    Habit(key: 'h1', name: 'Müşteri mesajı', type: HabitType.qty, goal: 3, mini: 1, unit: 'mesaj', identity: 'Girişimci', days: [1,2,3,4,5], routine: 'Sabah'),
    Habit(key: 'h2', name: 'Gelir gider notu', type: HabitType.bool_, goal: 1, mini: 1, unit: '', identity: 'Girişimci', days: [1,2,3,4,5,6,7], routine: 'Akşam'),
  ],
  'Kilo Verme Başlangıcı': [
    Habit(key: 'h0', name: 'Yürüyüş', type: HabitType.dur, goal: 25, mini: 8, unit: 'dk', identity: 'Fit', days: [1,2,3,4,5,6,7], routine: ''),
    Habit(key: 'h1', name: 'Porsiyon tabağı', type: HabitType.bool_, goal: 1, mini: 1, unit: '', identity: 'Fit', days: [1,2,3,4,5,6,7], routine: ''),
    Habit(key: 'h2', name: 'Su', type: HabitType.qty, goal: 8, mini: 3, unit: 'bardak', identity: 'Fit', days: [1,2,3,4,5,6,7], routine: ''),
  ],
  'Yabancı Dil 90 Gün': [
    Habit(key: 'h0', name: 'Kelime', type: HabitType.qty, goal: 10, mini: 3, unit: 'kelime', identity: 'Dil bilen', days: [1,2,3,4,5,6,7], routine: 'Sabah'),
    Habit(key: 'h1', name: 'Dinleme', type: HabitType.dur, goal: 15, mini: 5, unit: 'dk', identity: 'Dil bilen', days: [1,2,3,4,5,6,7], routine: ''),
    Habit(key: 'h2', name: 'Cümle kur', type: HabitType.qty, goal: 3, mini: 1, unit: 'cümle', identity: 'Dil bilen', days: [1,2,3,4,5,6,7], routine: 'Akşam'),
  ],
  'Yazar Olmak': [
    Habit(key: 'h0', name: 'Yaz', type: HabitType.dur, goal: 25, mini: 10, unit: 'dk', identity: 'Üreten', days: [1,2,3,4,5,6,7], routine: 'Sabah'),
    Habit(key: 'h1', name: 'Kelime sayısı', type: HabitType.qty, goal: 300, mini: 50, unit: 'kelime', identity: 'Üreten', days: [1,2,3,4,5,6,7], routine: 'Sabah'),
    Habit(key: 'h2', name: 'Oku', type: HabitType.qty, goal: 10, mini: 2, unit: 'sayfa', identity: 'Okuyan', days: [1,2,3,4,5,6,7], routine: 'Akşam'),
  ],
  'Stres Azaltma': [
    Habit(key: 'h0', name: 'Nefes', type: HabitType.dur, goal: 8, mini: 2, unit: 'dk', identity: 'Sakin zihin', days: [1,2,3,4,5,6,7], routine: 'Sabah'),
    Habit(key: 'h1', name: 'Ekransız mola', type: HabitType.dur, goal: 20, mini: 5, unit: 'dk', identity: 'Sakin zihin', days: [1,2,3,4,5,6,7], routine: ''),
    Habit(key: 'h2', name: 'Yürüyüş', type: HabitType.dur, goal: 15, mini: 5, unit: 'dk', identity: 'Fit', days: [1,2,3,4,5,6,7], routine: 'Akşam'),
  ],
  'Para Biriktirme': [
    Habit(key: 'h0', name: 'Harcama yaz', type: HabitType.bool_, goal: 1, mini: 1, unit: '', identity: 'Girişimci', days: [1,2,3,4,5,6,7], routine: 'Akşam'),
    Habit(key: 'h1', name: 'Birikim ayır', type: HabitType.bool_, goal: 1, mini: 1, unit: '', identity: 'Disiplinli', days: [1,2,3,4,5,6,7], routine: ''),
    Habit(key: 'h2', name: 'Gereksiz alışveriş yok', type: HabitType.bool_, goal: 1, mini: 1, unit: '', identity: 'Disiplinli', days: [1,2,3,4,5,6,7], routine: ''),
  ],
  'Uyku Düzeni': [
    Habit(key: 'h0', name: 'Aynı saatte yat', type: HabitType.bool_, goal: 1, mini: 1, unit: '', identity: 'Sakin zihin', days: [1,2,3,4,5,6,7], routine: 'Akşam'),
    Habit(key: 'h1', name: 'Ekransız son yarım saat', type: HabitType.dur, goal: 30, mini: 10, unit: 'dk', identity: 'Sakin zihin', days: [1,2,3,4,5,6,7], routine: 'Akşam'),
    Habit(key: 'h2', name: 'Sabah kalk', type: HabitType.bool_, goal: 1, mini: 1, unit: '', identity: 'Disiplinli', days: [1,2,3,4,5,6,7], routine: 'Sabah'),
  ],
  'Fit Başlangıç': [
    Habit(key: 'h0', name: 'Yürüyüş', type: HabitType.dur, goal: 20, mini: 8, unit: 'dk', identity: 'Fit', days: [1,2,3,4,5,6,7], routine: ''),
    Habit(key: 'h1', name: 'Esneklik', type: HabitType.dur, goal: 10, mini: 3, unit: 'dk', identity: 'Fit', days: [1,2,3,4,5,6,7], routine: 'Akşam'),
    Habit(key: 'h2', name: 'Su', type: HabitType.qty, goal: 8, mini: 3, unit: 'bardak', identity: 'Fit', days: [1,2,3,4,5,6,7], routine: ''),
  ],
  'Okuma Alışkanlığı': [
    Habit(key: 'h0', name: 'Sayfa', type: HabitType.qty, goal: 15, mini: 2, unit: 'sayfa', identity: 'Okuyan', days: [1,2,3,4,5,6,7], routine: 'Akşam'),
    Habit(key: 'h1', name: 'Not', type: HabitType.qty, goal: 3, mini: 1, unit: 'not', identity: 'Okuyan', days: [1,2,3,4,5,6,7], routine: 'Akşam'),
    Habit(key: 'h2', name: 'Telefonsuz okuma', type: HabitType.dur, goal: 20, mini: 5, unit: 'dk', identity: 'Disiplinli', days: [1,2,3,4,5,6,7], routine: 'Akşam'),
  ],
  'Odak ve Derin İş': [
    Habit(key: 'h0', name: 'Derin iş bloğu', type: HabitType.dur, goal: 50, mini: 15, unit: 'dk', identity: 'Üreten', days: [1,2,3,4,5], routine: 'Sabah'),
    Habit(key: 'h1', name: 'Bildirim kapalı', type: HabitType.bool_, goal: 1, mini: 1, unit: '', identity: 'Disiplinli', days: [1,2,3,4,5], routine: 'Sabah'),
    Habit(key: 'h2', name: 'Gün sonu tek cümle', type: HabitType.bool_, goal: 1, mini: 1, unit: '', identity: 'Üreten', days: [1,2,3,4,5], routine: 'Akşam'),
  ],
};
