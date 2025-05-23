#!/bin/bash

# 🚀 Flutter Performance Testing Script
# Bu script'i çalıştırarak uygulamanızın performansını test edebilirsiniz

echo "📊 Flutter Performance Testing Suite"
echo "===================================="

# 1. App build performance
echo "🔨 Testing build performance..."
flutter clean
time flutter build apk --release --analyze-size

# 2. Test performance
echo "🧪 Running performance tests..."
flutter test test/performance_test.dart

# 3. Profile mode'da çalıştır
echo "🏃 Running in profile mode..."
flutter run --profile &
FLUTTER_PID=$!

# 5 saniye bekle, sonra performance trace al
sleep 5
echo "📊 Collecting performance trace..."
flutter attach --debug-port=12345 --profile

# DevTools URL'ini yazdır
echo "🔗 Open DevTools at: http://localhost:9100"

# Cleanup
trap "kill $FLUTTER_PID" EXIT

echo "✅ Performance testing completed!"
echo "📈 Check the results above and in DevTools"
