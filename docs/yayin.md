# Google Play'e yayın adımları

## 1. İmza anahtarı (bir kez, KAYBETME)
PowerShell'de proje klasöründe:
```
keytool -genkey -v -keystore $HOME\iamdisiplin.jks -keyalg RSA -keysize 2048 -validity 10000 -alias iamdisiplin
```
(keytool Android Studio ile gelir: "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe")
Sorulan şifreyi bir yere not et. **Bu dosyayı ve şifreyi kaybedersen uygulamayı bir daha güncelleyemezsin.**
Dosyayı Google Drive gibi güvenli bir yere de yedekle. GitHub'a ASLA yükleme.

## 2. android/key.properties dosyası oluştur
```
storePassword=SIFREN
keyPassword=SIFREN
keyAlias=iamdisiplin
storeFile=C:\\Users\\msi\\iamdisiplin.jks
```
Bu dosya .gitignore'da, GitHub'a gitmez.

## 3. Yayın paketi
```
flutter build appbundle
```
Çıktı: build\app\outputs\bundle\release\app-release.aab

## 4. Google Play Console
1. https://play.google.com/console — tek seferlik 25 USD geliştirici kaydı
2. Uygulama oluştur → ad: I Am Disiplin, dil: Türkçe, ücretsiz (içinde abonelik var)
3. Mağaza girişi: docs/magaza.md metinleri, 512x512 ikon, 1024x500 öne çıkan görsel, en az 2 ekran görüntüsü
4. Gizlilik politikası: docs/gizlilik.md'yi bir web sayfasına koy, linkini gir
5. İçerik derecelendirmesi anketi, hedef kitle (18+), veri güvenliği formu
6. Önce "Dahili test" kanalına .aab yükle, kendi telefonunda dene
7. Kişisel geliştirici hesaplarında üretime çıkmadan önce 12 test kullanıcısıyla 14 günlük kapalı test istenebilir

## Paket kimliği
com.iamdisiplin.app — yayından sonra değiştirilemez.
