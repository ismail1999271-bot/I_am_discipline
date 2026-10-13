# I Am Disiplin — Flutter

## Kurulum
1. Flutter SDK kur: https://docs.flutter.dev/get-started/install
2. Bu klasörde:
   flutter create . --project-name i_am_disiplin --platforms android,ios
   flutter pub get
   flutter run

## Ollama koçu
1. Ollama kur: https://ollama.com
2. Model indir:  ollama pull qwen2.5:7b
3. Çalıştır:     ollama serve
4. Adres (lib/main.dart → Coach(host: ...)):
   - Masaüstü / iOS simülatörü: http://localhost:11434
   - Android emülatörü: http://10.0.2.2:11434
   - Gerçek telefon: http://<bilgisayar-IP>:11434  (OLLAMA_HOST=0.0.0.0 ollama serve)
Android'de http için AndroidManifest'e android:usesCleartextTraffic="true" ekle.

## Yapı
lib/models.dart  Habit, Entry
lib/store.dart   kayıt, seri, alışkanlık gücü, koç özeti
lib/coach.dart   Ollama /api/generate çağrısı
lib/main.dart    Onboarding, Bugün, İlerleme, Koç ekranları

## Hızlı başlangıç (Windows)
BASLAT.bat'a çift tıkla. Android klasörünü oluşturur, Android ayarlarını otomatik yapar (android_ayar.ps1),
kodu kontrol eder, Ollama modelini indirir ve uygulamayı çalıştırır.

## Özellikler (v0.5)
- Onboarding: kimlik seçimi → hazır paket veya kendi alışkanlıkların → 90 gün sonraki sana mektup
- Alışkanlık tipleri: evet/hayır, süre, miktar; her birinde "kötü gün minimumu"
- Esnek günler: haftanın istediğin günleri (planlı olmayan gün seriyi bozmaz)
- Rutinler: alışkanlıkları "Sabah", "Akşam" gibi gruplara bağla, adım adım rutin modu
- Bugün: kimlik oyları, Yaptım / Mini / miktar girişi, sayaç, kaçırma sebebi, Pazar değerlendirmesi
- Seviye sistemi: 3 slotla başla, gücü %70'i geçen her alışkanlık 1 yeni slot açar
- İlerleme: 12 haftalık ısı haritası, alışkanlık gücü, son 30 gün tamamlama, en uzun seri, 1 yıllık projeksiyon, rozetler
- Koç: çevrimdışı kural tabanlı tespitler + Ollama ile AI analiz (ayarlardan adres/model)
- Ben: kimlik cümlesi, mektup, alışkanlık düzenle/sırala/arşivle/sil, hatırlatıcı,
  ilerlemeyi paylaş (sorumluluk ortağı), yedek al / geri yükle, sıfırla
- Düzenleme kısayolu: Bugün ekranında bir alışkanlığa uzun bas

## Premium (v0.6)
- Kalori sekmesi premium'a kilitli; kilit ekranında fiyat ve özellikler var
- 55+ Türk yemeği (porsiyon, kcal, protein/karb/yağ) — lib/food_db.dart
- Mifflin-St Jeor ile kişisel hedef; güvenli aralık (en fazla 500 kcal açık, alt sınır 1200/1500)
- "Yazarak ekle": serbest metni Ollama'ya gönderip JSON kalori tahmini alır
- Hedefte kalınan gün "Fit" kimliğine +2 oy
- Ödeme henüz bağlı değil: "Test için premium aç" butonu yayın öncesi kaldırılacak, RevenueCat bağlanacak

## Premium "Sağlık" sekmesi (v0.7)
- Beslenme: su takibi (33 ml/kg), kalori + makro, AI haftalık yemek planı ve alışveriş listesi, "buzdolabında ne var?" tarifleri
- Antrenman: 5 hazır program (Evde başlangıç, Salon başlangıç, Üst/Alt, 0→5 km, Sabah yogası),
  set/tekrar/ağırlık kaydı, otomatik dinlenme sayacı, geçen seansa göre ilerleme önerisi, AI kişisel program
- Vücut: kilo, bel, kalça kaydı ve kilo grafiği
- Antrenman günü ve kalori hedefi günü "Fit" kimliğine +2 oy
- Dil: "beslenme koçu / antrenman asistanı" (diyetisyen/antrenör unvanı kullanılmaz), tıbbi tavsiye uyarıları var

## Yol haritası (sonraki sürümler)
- Health Connect / HealthKit ile adım ve koşu otomatik kaydı
- Bulut yedek ve cihazlar arası senkron (Supabase)
- Uzman pazar yeri: gerçek diyetisyen/antrenör programları, komisyon modeli (sunucu gerekir)
- Öğün fotoğrafından kalori tahmini (görsel model)
- Ödeme: RevenueCat ile gerçek abonelik (Google Play Billing)
- Ana ekran widget'ı
