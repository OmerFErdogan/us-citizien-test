# Teknik Bağlam

## Kullanılan Teknolojiler

### Programlama Dili ve Framework

- **Dart**: Uygulama, Google tarafından geliştirilen Dart programlama dili kullanılarak yazılmıştır.
- **Flutter**: Cross-platform mobil uygulama geliştirme framework'ü olarak Flutter kullanılmıştır. Flutter, tek bir kod tabanıyla hem Android hem de iOS platformları için native-like uygulamalar geliştirmeyi sağlar.

### Veri Depolama

- **JSON**: Soru verileri, uygulama içinde gömülü bir JSON dosyasında (assets/questions.json) saklanmaktadır.
- **In-Memory Storage**: Kullanıcı ilerlemesi şu anda sadece uygulama çalıştığı sürece bellekte tutulmaktadır. Uygulama kapatıldığında bu veriler kaybolur.

### UI Bileşenleri

- **Material Design**: Uygulama, Google'ın Material Design prensiplerini takip eden bir arayüze sahiptir.
- **Custom Widgets**: Özel ihtiyaçlar için AnswerOption ve QuestionCard gibi özel widget'lar geliştirilmiştir.

## Geliştirme Ortamı

### Gerekli Araçlar

- **Flutter SDK**: En az 3.7.2 sürümü
- **Dart SDK**: Flutter SDK ile birlikte gelir
- **IDE**: Visual Studio Code veya Android Studio (Flutter ve Dart eklentileri ile)
- **Git**: Versiyon kontrolü için

### Kurulum Adımları

1. Flutter SDK'yı [flutter.dev](https://flutter.dev/docs/get-started/install) adresinden indirin ve kurun
2. Geliştirme ortamınızı `flutter doctor` komutu ile kontrol edin
3. Projeyi klonlayın: `git clone <repo-url>`
4. Bağımlılıkları yükleyin: `flutter pub get`
5. Uygulamayı çalıştırın: `flutter run`

### Proje Yapısı

```
us_civics_test_app/
├── android/            # Android platformu için dosyalar
├── ios/                # iOS platformu için dosyalar
├── lib/                # Dart kaynak kodları
│   ├── data/           # Veri dosyaları
│   ├── models/         # Veri modelleri
│   ├── screens/        # Uygulama ekranları
│   ├── services/       # Servisler
│   ├── widgets/        # Yeniden kullanılabilir widget'lar
│   └── main.dart       # Uygulama giriş noktası
├── assets/             # Resimler, fontlar ve diğer varlıklar
│   └── questions.json  # Soru veritabanı
├── test/               # Test dosyaları
└── pubspec.yaml        # Proje konfigürasyonu ve bağımlılıklar
```

## Teknik Kısıtlamalar

### Performans Kısıtlamaları

- **Soru Sayısı**: Uygulama şu anda 100 civarında soru içermektedir. Soru sayısı çok artarsa performans sorunları yaşanabilir.
- **Bellek Kullanımı**: Tüm sorular uygulama başlatıldığında belleğe yüklenir. Çok büyük veri setleri için bu yaklaşım optimize edilmelidir.

### Ölçeklenebilirlik Kısıtlamaları

- **Veri Depolama**: Şu anda kullanıcı ilerlemesi kalıcı olarak saklanmamaktadır. İlerleme verilerinin kalıcı olarak saklanması için bir veritabanı çözümü eklenmelidir.
- **Çevrimdışı Kullanım**: Uygulama tamamen çevrimdışı çalışacak şekilde tasarlanmıştır, bu nedenle çevrimiçi özellikler eklemek için ek geliştirmeler gerekecektir.

### Güvenlik Kısıtlamaları

- **Veri Güvenliği**: Sorular ve cevaplar şifrelenmeden saklanmaktadır. Hassas veriler için şifreleme eklenmelidir.
- **Kullanıcı Kimlik Doğrulama**: Şu anda kullanıcı kimlik doğrulama mekanizması bulunmamaktadır.

## Bağımlılıklar

Projenin ana bağımlılıkları şunlardır:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

## Dağıtım ve Yayınlama

### Android

- APK veya App Bundle oluşturma: `flutter build apk` veya `flutter build appbundle`
- Google Play Store üzerinden yayınlama

### iOS

- IPA oluşturma: `flutter build ios`
- App Store üzerinden yayınlama (Apple Developer hesabı gereklidir)

## Gelecekteki Teknik Geliştirmeler

1. **Kalıcı Veri Depolama**: Kullanıcı ilerlemesini kalıcı olarak saklamak için SQLite veya Hive gibi bir yerel veritabanı çözümü eklenebilir.
2. **Kullanıcı Hesapları**: Kullanıcıların ilerlemelerini farklı cihazlar arasında senkronize edebilmeleri için bulut tabanlı kullanıcı hesapları eklenebilir.
3. **Çevrimiçi Özellikler**: Güncel soru veritabanı için API entegrasyonu, topluluk özellikleri veya çoklu oyuncu modları eklenebilir.
4. **Performans Optimizasyonları**: Büyük veri setleri için lazy loading ve pagination gibi optimizasyonlar yapılabilir.
5. **Erişilebilirlik İyileştirmeleri**: Ekran okuyucu desteği, yüksek kontrast modu gibi erişilebilirlik özellikleri eklenebilir.
