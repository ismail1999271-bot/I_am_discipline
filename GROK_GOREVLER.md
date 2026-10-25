# Grok Görevleri — Ben Disiplinim

Son kontrol: 25 Ekim 2026 (Claude). Her görevi Grok'a AYRI sohbette ver: önce **BAĞLAM**, sonra görev metni.

## DURUM TABLOSU

| # | Görev | Durum | Not |
|---|---|---|---|
| 1 | 300 yemek | ✅ | 300 kayıt, makro-kalori tutarlı, tekrar yok |
| 2 | 80 egzersiz | ✅ | Uygulamada (lib/data/workouts.dart) |
| 3 | 10 program | ✅ | Tüm hareket adları kütüphaneyle eşleşiyor |
| 4 | Uygulama sesi | ✅ | docs/uygulama_sesi.json — Claude uygulamaya bağlayacak |
| 5 | 15 başarı paketi | ✅ | docs/basari_paketleri.dart — Claude uygulamaya bağlayacak |
| 6–8 | Rakip / mağaza / uzman pazarı | ✅ | docs/ altında |
| 9 | Motivasyon sözleri 200 | ✅ | 200 söz, özgün, max 90 karakter |
| 10 | Terfi + ceza mesajları | ✅ | terfi 11×3, ceza 10, max 90 |
| 11 | Kampanya metinleri | ❌ | yeni |
| 12 | Heykeller + ikon | ✅ | splash_male.jpg, splash_female.jpg 1290×2796, icon.png 1024 |
| 13 | Gizlilik / KVKK | ❌ | taslak kısa |
| 14 | App Store metinleri | ❌ | yeni (iPhone) |

---

## BAĞLAM (her görevin başına yapıştır)

```
"Ben Disiplinim" adında Türkçe bir Flutter uygulaması (Android + iPhone).
Repo: github.com/ismail1999271-bot/I_am_discipline
Kullanıcı alışkanlıklarını işaretler, XP kazanır, rütbe atlar:
Acemi, Er, Onbaşı, Çavuş, Astsubay, Teğmen, Yüzbaşı, Binbaşı, Albay, Komutan, Efsane.
Ton: sert, kısa, güçlü, premium; siyah-altın tasarım. Asla aşağılayıcı veya suçlayıcı değil.
Uygulama kendini "diyetisyen" veya "doktor" olarak TANITMAZ ("beslenme koçu", "antrenman asistanı").
Hedef kitle: 18-40 yaş, Türkiye.
Repo kuralları:
- Sadece görevde belirtilen dosyalara yaz. lib/services/ altına DOKUNMA.
- pubspec.yaml'a sadece gerçekten var olan dosyaları ekle.
- Push etmeden önce "flutter analyze" ve "flutter test" temiz geçmeli. Her görev tek commit, Türkçe mesaj.
```

---

## GÖREV 9 — Motivasyon sözleri 200'e

```
assets/sozler.json dizisine 91 yeni söz ekle. Özgün (ünlü söz/alıntı yok), max 90 karakter, sert ve kısa.
Mevcutları tekrar etme. Geçerli JSON dizisi kalsın.
```

## GÖREV 10 — Terfi ve ceza mesajları

```
docs/uygulama_sesi.json'a iki anahtar ekle (diğerlerine dokunma):
"terfi": 11 rütbenin her biri için 3'er mesaj, ör. {"Er": ["", "", ""], ...} — max 90 karakter
"ceza": 3 gün boş kalınca -100 XP düştüğünde gösterilecek 10 mesaj — sert ama geri çağıran
```

## GÖREV 11 — Özel gün kampanya metinleri

```
lib/data/campaigns.dart'taki kampanyaları incele. docs/kampanya_metinleri.md oluştur. Her kampanya için:
- 3 banner başlığı (max 25 karakter) + satış cümlesi (max 70 karakter)
- 2 push bildirimi (başlık max 35, metin max 90): kampanya başlangıcı ve son gün
- 1 Instagram/TikTok gönderi fikri
Ayrıca 2026-2030 Ramazan ve Kurban Bayramı tarihlerini Diyanet takviminden doğrula, kaynağıyla yaz.
```

## GÖREV 12 — Açılış heykelleri ve uygulama ikonu (Grok Imagine)

```
1) assets/splash_male.jpg: siyah zemin, dramatik altın ışıkla güçlü erkek mermer heykeli
   (antik Yunan tarzı), dikey 1290x2796, yazı YOK.
2) assets/splash_female.jpg: aynı tarzda güçlü, atletik kadın mermer heykeli, yazı YOK.
3) assets/icon.png 1024x1024: siyah zemin, altın rütbe/kalkan sembolü, yazı yok.
Dosyaları ekle, pubspec.yaml assets listesine iki splash dosyasını yaz.
```

## GÖREV 13 — Gizlilik politikası ve KVKK

```
docs/gizlilik.md'yi yayına hazır tam metne çevir: veriler sadece cihazda, sunucu yok, bildirim izni,
sağlık/beslenme verisi (KVKK özel nitelikli veri), çocuklar, iletişim, değişiklikler.
App Store ve Google Play'in istediği başlıklar olsun. Sonuna "Yayından önce bir hukukçuya kontrol ettirin." ekle.
```

## GÖREV 14 — App Store metinleri

```
docs/magaza.md'ye "App Store" bölümü ekle: ad (max 30), alt başlık (max 30), promosyon metni (max 170),
açıklama (max 4000), anahtar kelime alanı (max 100 karakter, virgülle), 6.7" ekran görüntüsü için
8 başlık (max 6 kelime), "Neler yeni" v1.0.
```

---

## Öncelik
**12 → 10 → 9 → 11 → 13 → 14**

## Claude'un yapacakları (Grok'a verme)
- Uygulama sesini (bildirim, seri, rozet, kaçırma, terfi) ve 15 paketi koda bağlamak
- Kampanya bildirimleri
- Sahip modu, ödeme, ücretsiz deneme (en sona)
- iPhone mağaza sürümü ve 3D kas animasyonları (en sona)
