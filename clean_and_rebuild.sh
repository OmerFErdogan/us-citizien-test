#!/bin/bash

echo "🧹 Flutter projesini temizleme ve yeniden build etme"

echo "1. Flutter clean..."
flutter clean

echo "2. Pub get..."
flutter pub get

echo "3. Android clean..."
cd android
./gradlew clean
cd ..

echo "4. Build klasörlerini temizle..."
rm -rf build/
rm -rf android/.gradle/
rm -rf android/app/build/

echo "✅ Temizlik tamamlandı!"
echo "🚀 Şimdi 'flutter run' ile test edebilirsiniz"
