# Grok Görevleri — I Am Disiplin

Her görevi Grok'a AYRI bir sohbette ver. Önce "BAĞLAM" bölümünü, sonra görevin metnini yapıştır.
Çıktıyı Claude'a getir; Claude doğrulayıp uygulamaya ekleyecek.

---

## BAĞLAM (her görevin başına yapıştır)

```
"I Am Disiplin" adında Türkçe bir Android uygulaması geliştiriyorum (Flutter).
Fikir: Kullanıcı "nasıl bir insan olmak istiyorum" sorusuna cevap verir (Okuyan, Fit, Dil bilen,
Üreten, Sakin zihin, Girişimci, Disiplinli). Her günlük alışkanlık bu kimliklerden birine "oy" verir.
Tam hedef = 2 oy, kötü gün minimumu = 1 oy. Seri kırılınca her şey sıfırlanmaz, "alışkanlık gücü" yavaş düşer.
Premium'da: kalori takibi, su takibi, antrenman programları, kilo/ölçü takibi, AI beslenme koçu ve
antrenman asistanı var. Uygulama kendini "diyetisyen" veya "antrenör" olarak TANITMAZ;
"beslenme koçu" ve "antrenman asistanı" der. Hedef kitle: 18-40 yaş, Türkiye.
Çıktıyı tam istediğim formatta ver, açıklama ekleme.
```

---

## GÖREV 1 — Yemek veritabanını 300 yemeğe çıkar (uzun görev)

```
Türk mutfağı ve Türkiye'de yaygın tüketilen 300 yiyecek/içecek için besin değeri listesi hazırla.
Kategoriler: kahvaltılık, çorbalar, etli yemekler, sebze yemekleri, zeytinyağlılar, baklagiller,
pilav-makarna, hamur işleri, fast food, tatlılar, meyveler, kuruyemiş, içecekler, süt ürünleri,
zincir restoran ürünleri (genel, marka adı yok).

Format: her satır tam olarak şu Dart satırı olsun, başka hiçbir şey yazma:
  Food('Ad', 'porsiyon', kcal, protein_g, karbonhidrat_g, yag_g),
Örnek:
  Food('Mercimek çorbası', '1 kase', 180, 9, 26, 4.5),

Kurallar:
- Porsiyonu Türk kullanıcının anlayacağı şekilde yaz (1 kase, 1 dilim, 1 porsiyon, 100 g).
- Değerler TÜRKOMP veya USDA ortalamalarına dayansın; makrolar kaloriyle tutarlı olsun
  (protein*4 + karb*4 + yağ*9 ≈ kcal, ±%15).
- Aynı yemeği iki kez yazma. 50'şer satırlık 6 parça halinde ver; ben "devam" dedikçe sonrakini yaz.
```

## GÖREV 2 — Hareket kütüphanesi (uzun görev)

```
Antrenman uygulaması için 80 egzersizlik Türkçe hareket kütüphanesi hazırla.
Gruplar: göğüs, sırt, omuz, kol, bacak, kalça, karın/core, kardiyo, mobilite/esneme, yoga.
Her hareket için JSON nesnesi ver:
{"ad": "", "grup": "", "ekipman": "yok|dambıl|halter|makine|bant|barfiks barı",
 "seviye": "başlangıç|orta|ileri", "nasil": ["adım 1", "adım 2", "adım 3"],
 "hatalar": ["sık hata 1", "sık hata 2"], "kolay_versiyon": "", "zor_versiyon": ""}
Tüm çıktı tek bir JSON dizisi olsun. 20'şer hareketlik 4 parça halinde ver.
Güvenlik: bel/diz riski olan hareketlerde "hatalar" kısmında mutlaka belirt.
```

## GÖREV 3 — 10 yeni hazır program

```
Şu hedefler için 10 antrenman programı tasarla:
1) Evde 20 dk sabah  2) Ofis çalışanı için duruş düzeltme  3) Salonda 3 gün tüm vücut (orta)
4) 5 gün itme/çekme/bacak  5) Sadece dambılla evde  6) 40 yaş üstü başlangıç  7) Kadınlar için kalça-bacak
8) 10 km koşu hazırlık (8 hafta)  9) Yürüyüşle başlangıç (kilolu bireyler)  10) Esneklik ve mobilite

Format (her program için JSON):
{"ad": "", "aciklama": "", "seviye": "", "haftada_gun": 3,
 "gunler": [{"ad": "Gün A", "hareketler": [{"ad": "", "set": 3, "tekrar": 10, "birim": "tekrar|sn|dk|tur", "agirlikli": false}]}]}
Hareket adları GÖREV 2'deki listeyle aynı olsun.
```

## GÖREV 4 — Kimlik mesajları ve bildirim metinleri

```
Uygulamanın konuşan sesini yaz. Ton: samimi, kısa, suçlamayan, "sen" diye hitap eden.
1) Her kimlik için (Okuyan, Fit, Dil bilen, Üreten, Sakin zihin, Girişimci, Disiplinli) 15'er kimlik cümlesi.
   Örnek: "Bugünkü 10 sayfa, okuyan biri olduğunun kanıtı."
2) 60 günlük hatırlatıcı bildirimi (başlık max 35 karakter, metin max 90 karakter).
3) Seri kırıldığında gösterilecek 20 teselli + geri dönüş mesajı (asla suçlama yok).
4) Rozet kazanınca gösterilecek 30 tebrik mesajı (7, 21, 66, 100 gün için ayrı ayrı).
5) Kaçırma sebebine göre öneri: Yorgun, Vakit yok, Unuttum, İsteksiz için 10'ar öneri.
Format: JSON {"kimlik_cumleleri": {"Okuyan": [...]}, "bildirimler": [{"baslik":"","metin":""}],
"seri_kirildi": [...], "rozet": {"7":[...],"21":[...],"66":[...],"100":[...]}, "kacirma": {"Yorgun":[...]}}
```

## GÖREV 5 — 15 yeni "başarı paketi"

```
Onboarding'de seçilecek 15 hazır alışkanlık paketi tasarla. Her pakette 3 alışkanlık.
Örnek temalar: Sınav dönemi, Yeni anne/baba, Ramazan, Erken kalkan, Dijital detoks, Girişimci sabahı,
Kilo verme başlangıcı, Yabancı dil 90 gün, Yazar olmak, Stres azaltma, Para biriktirme, Uyku düzeni...
Format (Dart):
'Paket adı': [
  Habit(key: 'h0', name: '', type: HabitType.dur|qty|bool_, goal: 30, mini: 10, unit: 'dk',
        identity: 'Okuyan|Fit|Dil bilen|Üreten|Sakin zihin|Girişimci|Disiplinli',
        days: [1,2,3,4,5,6,7], routine: 'Sabah|Akşam|'),
  ...
],
Her alışkanlığın "mini" değeri gerçekten kötü bir günde yapılabilecek kadar küçük olsun.
```

## GÖREV 6 — Rakip analizi ve fiyatlandırma (araştırma)

```
Türkiye'de ve dünyada şu uygulamaları karşılaştır: Habitica, Streaks, Fabulous, Atoms (James Clear),
Loop Habit Tracker, MyFitnessPal, Yazio, FatSecret, Fitbod, Hevy.
Tablo: uygulama | ücretsiz özellikler | premium özellikler | Türkiye fiyatı (aylık/yıllık) | kullanıcı şikayetleri
(Play Store yorumlarından) | bizim fırsatımız.
Sonra: I Am Disiplin için önerilen fiyat (aylık, yıllık, ömür boyu), deneme süresi ve
ücretsiz/premium sınırı öner; gerekçeni yaz. Kaynak linklerini ekle.
```

## GÖREV 7 — Play Store ASO ve pazarlama (uzun görev)

```
1) Türkçe Play Store için 30 anahtar kelime (aranma potansiyeli ve rekabet tahminiyle).
2) Uygulama adı için 10 alternatif (max 30 karakter) ve kısa açıklama için 10 alternatif (max 80 karakter).
3) 8 ekran görüntüsünün üzerine yazılacak başlıklar (max 6 kelime).
4) Lansman için 30 günlük Instagram/TikTok içerik takvimi: gün | format (reels/carousel/story) |
   konu | ilk 3 saniyedeki kanca cümlesi | açıklama metni | hashtagler.
5) İlk 1000 kullanıcıya ulaşmak için bütçesiz 10 taktik (Türkiye'ye özel).
```

## GÖREV 8 — Uzman pazar yeri iş planı

```
Uygulamaya gerçek diyetisyen ve spor eğitmenlerinin ücretli program sattığı bir bölüm eklemek istiyorum.
1) Türkiye'de diyetisyen ve antrenörlerin online hizmet vermesine dair yasal çerçeve
   (diyetisyen unvanı, reklam yasakları, KVKK, sağlık verisi). Kaynak ver.
2) Komisyon modeli önerisi (yüzde, ödeme akışı, iade).
3) Uzmanları nasıl bulup ikna ederim: e-posta / DM şablonu (3 versiyon).
4) Uzman doğrulama süreci (diploma, sertifika kontrolü).
5) İlk 6 ay için adım adım yol haritası.
Not: Hukuki konularda "bir avukata danışın" uyarısını ekle.
```

---

## Claude'a geri getirirken

Çıktıyı dosya olarak kaydet (ör. `grok_gorev1.txt`) ve **Belgeler\i_am_disiplin\grok\** klasörüne koy.
Claude'a "grok görev 1 hazır" yaz; Claude kontrol edip (kalori tutarlılığı, yinelenen kayıt, format)
uygulamaya ekleyecek.

Öncelik sırası: **1 → 4 → 5 → 2 → 3** (uygulamaya doğrudan girenler), sonra **6 → 7 → 8** (iş tarafı).
