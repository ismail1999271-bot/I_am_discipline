# Ben Disiplinim

Siyah zemin, keskin köşe, altın vurgu. Alışkanlıklarını işaretle, rütbe kazan, günü kaçırma.

Veri yalnızca cihazda durur (`SharedPreferences`, anahtar `bd_state_v1`). Backend yok. Ödeme yok. Premium bir kilit bayrağıdır.

## Özellikler

- Hazır paketler: Sabah Rutini, Sporcu, Dil Öğrenen, Okuyucu, Zihin.
- Özel alışkanlık: ad, ikon, zorluk (normal +10 / zor +20), günler, hatırlatma saati.
- Günlük işaret ve seri.
- Rütbeler: Acemi, Er, Onbaşı, Çavuş, Astsubay, Teğmen, Yüzbaşı, Binbaşı, Albay, Komutan, Efsane.
- Seri çarpanı: 7 gün x1.2, 30 gün x1.5, 90 gün x2. Gün tamamlanınca +50 XP. Aylık hedef tutunca +500 XP.
- 3 gün üst üste hiç işaret yoksa -100 XP. Rütbe düşmez.
- Terfi ekranı: rozet, yeni tema, sert cümle.
- Ajanda: takvim, spor / yemek / uyku / iş, sınırsız defter.
- Yaşam planı: birikim, bütçe, dil, vücut, yan gelir. Aylık ve yıllık. Çubuk ve grafik.
- Film listesi: izlenecek / izlenen, 1–10 puan, not.
- Her gün ana ekranda sert bir söz (`assets/sozler.json`).
- Premium kilit: kalori ve makro, diyetisyen öğün planı, antrenör programları ve kas grupları. 3D animasyon yer tutucu.
- 300 yiyecek (`lib/data/foods.dart`). Kalori, makro ile uyumludur.
- 80 hareket ve 10 program (`lib/exercises.json`, `lib/programs.json`).

## İçerik dosyaları

- 300 yemek satırı: `docs/gorev1_yemekler.dart`
- 80 hareket ve 10 program: `lib/exercises.json`, `lib/programs.json` (aynı dosyalar `assets/` altında da durur)
- Uygulama sesi: `docs/uygulama_sesi.json`
- 15 başarı paketi: `docs/basari_paketleri.dart` (eski `Habit` şeması; uygulamanın kendi paketleri `lib/data/catalog.dart`)
- Rakip, mağaza, uzman: `docs/rakip_analizi.md`, `docs/magaza_pazarlama.md`, `docs/uzman_pazar.md`


## Kurulum

Flutter 3.27 veya daha yeni gerekir.

```bash
flutter pub get
flutter run
```

Bildirim için Android 13+ izin sorar. Hatırlatma saati `Europe/Istanbul` gününe göre kurulur.

Açılış heykeli:

1. `assets/splash_male.jpg` ve `assets/splash_female.jpg` koy.
2. `pubspec.yaml` içindeki `flutter/assets` listesine bu iki dosyayı ekle.
3. Dosya yoksa uygulama çökmez; siyah zemin üstünde altın çizgi figür gösterilir.
4. Kadın seçilirse kadın görseli, erkek seçilirse erkek görseli açılır. Açılışta yazı yoktur.

## Yapılacaklar

- 3D kas animasyonları
- ücretsiz deneme süresi
- mağaza ekran görüntüleri
- sahip modu
