# AdMob Crash Fix Guide

## 🚨 Problem
```
FATAL EXCEPTION: Invalid application ID
java.lang.IllegalStateException: Invalid application ID
```

## ✅ Çözümler

### 1. Hızlı Çözüm (Test ID)
AndroidManifest.xml'de test ID kullan:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-3940256099942544~3347511713" />
```

### 2. Production Çözümü
Gerçek AdMob hesabı oluştur:
1. https://admob.google.com/ adresine git
2. Yeni uygulama oluştur
3. Application ID'yi al
4. AndroidManifest.xml'i güncelle

### 3. Error Handling ile Safe Init
main.dart'da try-catch kullan:
```dart
try {
  await MobileAds.instance.initialize();
  print('✅ AdMob başlatıldı');
} catch (e) {
  print('⚠️ AdMob başlatılamadı: $e');
  // Uygulama reklam olmadan çalışır
}
```

### 4. Conditional AdMob (Recommended)
```dart
// Debug mode'da AdMob'u atla
if (kReleaseMode) {
  try {
    await MobileAds.instance.initialize();
  } catch (e) {
    print('AdMob init failed: $e');
  }
}
```

## 🔄 Test Etme
1. `flutter clean`
2. `flutter pub get`
3. `flutter run`

## 📋 Checklist
- [ ] AndroidManifest.xml güncellendi
- [ ] main.dart'da error handling eklendi  
- [ ] Test edildi
- [ ] Production'da gerçek ID kullanılacak

## 🚀 Next Steps
1. Test ID ile çalıştır
2. AdMob hesabı oluştur
3. Gerçek ID'yi ekle
4. Production'a deploy et
