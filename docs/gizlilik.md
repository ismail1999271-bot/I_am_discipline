# Gizlilik Politikası — Ben Disiplinim

Son güncelleme: 25 Ekim 2026

Bu metin hukuki danışmanlık değildir. Mağaza formlarıyla birlikte okunmalıdır.

## Veri sorumlusu

Ben Disiplinim mobil uygulamasını (Android, iPhone) ve varsa web sürümünü geliştiren kişi, 6698 sayılı Kişisel Verilerin Korunması Kanunu kapsamında veri sorumlusu adayıdır. Ticari unvan ve e-posta yayından önce aşağıdaki İletişim bölümüne yazılacaktır. Şu anki geliştirici hesabı: GitHub `ismail1999271-bot`.

## Kapsam

Bu politika uygulamayı kullanan kişilerin cihazında tutulan kayıtları anlatır. Uygulama hesap açtırmaz. Türkiye’deki 18 yaş ve üzeri kullanıcılar için tasarlanmıştır.

## Topladığımız veriler

Geliştirici bir sunucuda veri toplamaz. Aşağıdakiler yalnızca kullanıcının kendi cihazında, `SharedPreferences` anahtarı `bd_state_v1` altında durur:

- Cinsiyet seçimi (kadın veya erkek), açılış görseli için
- Alışkanlık adı, günleri, zorluk işareti ve isteğe bağlı hatırlatma saati
- Günlük işaretler, ajanda, not defteri, hedefler, para notları, film listesi
- Yemek kayıtları (ad, kalori, protein, karbonhidrat, yağ) ve kalori hedefleri
- Rütbe, XP, seri ve premium kilidinin yerel işareti

Ad, soyad, telefon, e-posta, konum, rehber, fotoğraf, reklam kimliği veya ödeme kartı istenmez. Ödeme yoktur.

Kullanıcı not alanına istediği metni yazabilir. Sağlık veya başkasına ait bilgi yazarsa o metin de yalnızca cihazda kalır.

## Veriler nasıl kullanılır

Kayıtlar alışkanlığı, takvimi, rütbeyi, kalori özetini ve hatırlatmayı göstermek için cihazda işlenir. Profil çıkarmak, reklam göstermek, satmak veya puanlamak için kullanılmaz. Geliştirici bu kayıtlara erişemez, çünkü kayıt geliştiricinin sunucusuna gitmez.

## Sunucu, aktarım ve üçüncü taraf

Uygulamanın kendi sunucusu yoktur. Analitik, reklam, çökme raporlama veya uzak bildirim hizmeti bağlı değildir. Kişisel kayıt üçüncü kişiye satılmaz, kiralanmaz ve aktarılmaz.

Web sürümü açılırsa sayfa bir barındırıcıdan (örneğin GitHub Pages) iner. Alışkanlık ve beslenme kaydı tarayıcının yerel deposunda kalır; barındırıcıya yazılmaz. Barındırıcı, sayfayı açan ziyaretçinin bağlantı kaydını (IP adresi gibi) kendi politikasına göre tutabilir. Bu kayıt uygulama içeriğini içermez. GitHub için: [GitHub Privacy Statement](https://docs.github.com/en/site-policy/privacy-policies/github-privacy-statement).

Yurt dışına uygulama verisi aktarılmaz, çünkü uygulama verisi cihazdan çıkmaz.

## Sağlık ve beslenme verisi (KVKK)

Beslenme kaydı, kalori hedefi ve kullanıcının sağlık diye yazdığı notlar, KVKK m.6 kapsamındaki özel nitelikli kişisel veri (sağlık verisi) sayılabilir. Bu veriler:

- yalnızca kullanıcının kendi girişi ile oluşur
- geliştiriciye veya bir sağlık kuruluşuna gönderilmez
- teşhis, tedavi veya diyetisyen hizmeti değildir

Uygulama kendini diyetisyen, doktor veya tedavi aracı olarak tanıtmaz. Beslenme koçu veya antrenman asistanı dili kullanılırsa bu bir sağlık hizmeti vaadi değildir.

KVKK m.6 için açık rıza ve saklama şartları cihazda kalan veriye nasıl uygulanacağı yayından önce bir hukukçu ile netleştirilmelidir. Kullanıcı kaydı silerek bu veriyi yok edebilir.

## Bildirim izni

Hatırlatma isteğe bağlıdır. Android’de bildirim izni, iPhone’da bildirim izni sorulabilir. İzin verilmezse uygulama çalışır, yalnızca yerel hatırlatma kurulmaz.

İzin verilirse alarm cihazın kendi saatine göre planlanır. Bildirim metni alışkanlık adını içerebilir. Anlık bildirim (push) sunucusu yoktur; jeton (token) bir sunucuya gönderilmez. İzin, sistem ayarından geri alınabilir.

## Diğer izinler

Uygulama konum, kamera, mikrofon, rehber veya dosya izni istemez. İnternet izni, mağaza ve web sürümünün kendisini indirmek için işletim sisteminde bulunabilir; alışkanlık kaydını göndermek için kullanılmaz.

## Çocuklar

Uygulama 18 yaş altına yönelik değildir. Yaş sorulmaz ve doğum tarihi alınmaz. Bilerek çocuklardan veri istenmez. Bir çocuk uygulamayı açarsa girdiği kayıt yine cihazda kalır ve aşağıdaki silme yollarıyla yok edilir. Ebeveyn, cihazın uygulama verisini temizleyebilir.

App Store ve Google Play yaş derecesi yayında ayrıca seçilecektir. Bu politika, çocuklara yönelik hizmet beyanı değildir.

## Saklama ve silme

Kayıt, kullanıcı silene veya uygulamayı kaldırana kadar cihazda durur. Süre sınırı geliştirici tarafından uygulanamaz, çünkü kopya geliştiricide yoktur.

Silme yolları:

- Ayarlar içindeki sıfırlama: tüm yerel veri silinir, geri alınmaz
- İşletim sisteminden uygulama verisini temizlemek
- Uygulamayı kaldırmak

Yedek (Android yedek, iCloud) cihazın kendi yedeğidir. Uygulama yedeği bir sunucuya ayrıca kopyalamaz. Yedekten dönen kopya için cihaz ayarlarına bakın.

## Güvenlik

Kayıt cihazın uygulama korumasındadır. Cihazın kilidi, şifresi ve işletim sistemi güncelliği kullanıcının sorumluluğundadır. Cihaz kaybolursa geliştirici uzaktan silme yapamaz, çünkü sunucu kopyası yoktur.

## Haklar

KVKK m.11 hakları (öğrenme, düzeltme, silme, itiraz) cihazdaki kayıt için uygulama içinden kullanılır: kullanıcı kendi kaydını görür, değiştirir ve sıfırlar. Geliştiricinin elinde kopya olmadığı için ayrıca bir dosya üzerinden talep yerine getirilemez. Mağaza hesabı veya barındırıcı kaydı için ilgili platformun kendi politikası geçerlidir.

## App Store ve Google Play

Bu sürümde geliştirici veri toplamaz, veri satmaz, reklam amacıyla izlemez ve veriyi üçüncü tarafla paylaşmaz. Mağaza formları buna göre doldurulmalıdır:

- Apple gizlilik etiketi: veri cihazdan çıkmıyorsa “Data Not Collected” ile uyumludur. İleride bir çözümleme kiti eklenirse hem kod hem bu politika hem etiket güncellenir.
- Google Play Veri güvenliği: geliştirici tarafından toplanan veri yok, paylaşılan veri yok. Bildirim izni, kullanıcı isterse yerel hatırlatma içindir.

Mağaza, ödeme veya işletim sistemi kendi verisini ayrı işler. O işlem bu uygulamanın politikasının dışındadır.

## Değişiklikler

Politika değişirse bu dosyanın tarihi ve mağaza açıklamasındaki sürüm notu güncellenir. Sunucu hesabı olmadığı için e-posta ile duyuru yapılmaz. Değişiklik yayına girmeden önce mağaza metni de aynı hale getirilir. Yeni bir veri türü cihaza eklenirse bu listeye yazılır. Veri cihazdan çıkmaya başlarsa politika, veri çıkmadan önce baştan yazılır.

## İletişim

Yayından önce gerçek adres yazın: `[E-POSTA]`.

O zamana kadar kamuya açık kanal: [github.com/ismail1999271-bot/I_am_discipline](https://github.com/ismail1999271-bot/I_am_discipline).

Yayından önce bir hukukçuya kontrol ettirin.
