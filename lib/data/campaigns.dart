// Özel gün indirimleri. Ödeme altyapısı gelince fiyat buradan hesaplanır.
// Yeni kampanya eklemek için sadece [campaignsFor] listesine satır ekle.

class Campaign {
  final String id; // mağaza promosyon kodu / analitik için
  final String title; // banner başlığı
  final String message; // sert, kısa satış cümlesi
  final int discount; // yüzde
  final DateTime start; // dahil
  final DateTime end; // dahil (gün sonu)

  const Campaign(this.id, this.title, this.message, this.discount, this.start, this.end);

  bool isActive(DateTime now) {
    final d = DateTime(now.year, now.month, now.day);
    return !d.isBefore(start) && !d.isAfter(end);
  }

  int daysLeft(DateTime now) => end.difference(DateTime(now.year, now.month, now.day)).inDays;
}

/// Ayın n. pazarı (Anneler Günü: 2. pazar Mayıs, Babalar Günü: 3. pazar Haziran)
DateTime nthSunday(int year, int month, int n) {
  var d = DateTime(year, month, 1);
  while (d.weekday != DateTime.sunday) {
    d = d.add(const Duration(days: 1));
  }
  return d.add(Duration(days: 7 * (n - 1)));
}

/// Kasım'ın 4. perşembesinden sonraki cuma (Efsane Cuma / Black Friday)
DateTime blackFriday(int year) {
  var d = DateTime(year, 11, 1);
  while (d.weekday != DateTime.thursday) {
    d = d.add(const Duration(days: 1));
  }
  return d.add(const Duration(days: 22));
}

DateTime _d(int y, int m, int d) => DateTime(y, m, d);
DateTime _plus(DateTime d, int n) => d.add(Duration(days: n));

/// Dini bayramlar her yıl kayar. Tarihleri yayından önce Diyanet takviminden doğrula.
/// (ilk gün, son gün)
const _ramazan = {2026: [3, 20, 3, 22], 2027: [3, 9, 3, 11], 2028: [2, 26, 2, 28]};
const _kurban = {2026: [5, 27, 5, 30], 2027: [5, 16, 5, 19], 2028: [5, 5, 5, 8]};

List<Campaign> campaignsFor(int y) {
  final anne = nthSunday(y, 5, 2);
  final baba = nthSunday(y, 6, 3);
  final bf = blackFriday(y);
  return [
    Campaign('yeni_yil', 'YENİ YIL, YENİ SEN', 'Kararların 2 hafta sürmesin. Bu yıl rütbe al.', 50,
        _d(y, 1, 1), _d(y, 1, 15)),
    Campaign('sevgililer', 'SEVGİLİLER GÜNÜ', 'En büyük yatırım kendine. Birlikte disiplin.', 30,
        _d(y, 2, 10), _d(y, 2, 14)),
    Campaign('kadinlar', '8 MART', 'Güçlü kadınlar bahane değil sonuç üretir.', 30, _d(y, 3, 6), _d(y, 3, 8)),
    Campaign('23_nisan', '23 NİSAN', 'Geleceği bugünkü alışkanlıklar kurar.', 23, _d(y, 4, 21), _d(y, 4, 23)),
    Campaign('anneler', 'ANNELER GÜNÜ', 'Ona verilecek en iyi hediye: daha güçlü bir sen.', 30,
        _plus(anne, -3), anne),
    Campaign('19_mayis', '19 MAYIS', 'Gençlik disiplinle başlar.', 19, _d(y, 5, 17), _d(y, 5, 19)),
    Campaign('babalar', 'BABALAR GÜNÜ', 'Örnek ol. Lafla değil, seriyle.', 30, _plus(baba, -3), baba),
    Campaign('30_agustos', '30 AĞUSTOS', 'Zafer, vazgeçmeyenlerindir.', 30, _d(y, 8, 28), _d(y, 8, 30)),
    Campaign('eylul', 'YENİ SEZON', 'Yaz bitti. Bahaneler de.', 25, _d(y, 9, 1), _d(y, 9, 7)),
    Campaign('29_ekim', '29 EKİM', 'Kendi cumhuriyetini kur: kurallarını sen koy.', 29, _d(y, 10, 27), _d(y, 10, 29)),
    Campaign('efsane_cuma', 'EFSANE CUMA', 'Yılın en büyük indirimi. Efsane rütbesine giden yol.', 60,
        _plus(bf, -3), _plus(bf, 3)),
    Campaign('yilsonu', 'YIL SONU', 'Yeni yıla hazır gir. Bekleme.', 40, _d(y, 12, 26), _d(y, 12, 31)),
    if (_ramazan[y] case final r?)
      Campaign('ramazan_bayrami', 'RAMAZAN BAYRAMI', 'Bayramın mübarek olsun. Disiplin hediyemiz.', 30,
          _plus(_d(y, r[0], r[1]), -2), _d(y, r[2], r[3])),
    if (_kurban[y] case final k?)
      Campaign('kurban_bayrami', 'KURBAN BAYRAMI', 'Bayramın mübarek olsun. Disiplin hediyemiz.', 30,
          _plus(_d(y, k[0], k[1]), -2), _d(y, k[2], k[3])),
  ];
}

/// Şu an aktif kampanya. Çakışırsa en yüksek indirim kazanır.
Campaign? activeCampaign([DateTime? now]) {
  final n = now ?? DateTime.now();
  final list = [...campaignsFor(n.year), ...campaignsFor(n.year - 1)].where((c) => c.isActive(n)).toList()
    ..sort((a, b) => b.discount.compareTo(a.discount));
  return list.isEmpty ? null : list.first;
}

/// Sıradaki kampanya (bildirim / "yakında" bannerı için)
Campaign? nextCampaign([DateTime? now]) {
  final n = now ?? DateTime.now();
  final today = DateTime(n.year, n.month, n.day);
  final list = [...campaignsFor(n.year), ...campaignsFor(n.year + 1)].where((c) => c.start.isAfter(today)).toList()
    ..sort((a, b) => a.start.compareTo(b.start));
  return list.isEmpty ? null : list.first;
}

/// İndirimli fiyat. Ödeme gelince mağaza fiyatı buraya verilir.
double discounted(double price, [DateTime? now]) {
  final c = activeCampaign(now);
  return c == null ? price : price * (100 - c.discount) / 100;
}
