# Aktif Bağlam

## Mevcut Çalışma Odağı

ABD Vatandaşlık Testi Uygulaması, ABD vatandaşlık sınavına hazırlanan kişilere yardımcı olmak için tasarlanmış bir mobil uygulamadır. Uygulama şu anda temel işlevselliğe sahiptir ve aşağıdaki özellikleri içermektedir:

- Quiz modu (rastgele sorularla test)
- Flashcard modu (soru-cevap kartları)
- Kategori filtreleme
- İlerleme takibi

Mevcut çalışma odağı, uygulamanın temel işlevselliğini geliştirmek ve kullanıcı deneyimini iyileştirmektir.

## Son Değişiklikler

Uygulama şu anda ilk geliştirme aşamasındadır. Temel ekranlar ve işlevsellik uygulanmıştır:

1. Ana ekran (HomeScreen) - İlerleme özeti ve ana modlara erişim
2. Quiz ekranı (QuizScreen) - Çoktan seçmeli sorular ve sonuçlar
3. Flashcard ekranı (FlashcardScreen) - Çevrilebilir soru-cevap kartları
4. Kategori seçim ekranı (CategorySelectionScreen) - Belirli kategorilere odaklanma
5. Sonuç ekranı (ResultScreen) - Quiz sonuçlarını görüntüleme

Son değişiklikler şunları içermektedir:

- Temel UI bileşenlerinin uygulanması
- QuestionService'in geliştirilmesi
- Veri modellerinin oluşturulması
- JSON veri kaynağının entegrasyonu
- Ekranlar arası navigasyon

## Sonraki Adımlar

Uygulamanın geliştirilmesi için planlanan sonraki adımlar şunlardır:

### Kısa Vadeli (1-2 Sprint)

1. **Kalıcı Veri Depolama**: Kullanıcı ilerlemesini kalıcı olarak saklamak için SharedPreferences veya SQLite entegrasyonu
2. **UI İyileştirmeleri**: 
   - Daha iyi animasyonlar
   - Daha tutarlı tema
   - Responsive tasarım iyileştirmeleri
3. **Hata İşleme**: Daha sağlam hata işleme ve kullanıcı geri bildirimi
4. **Performans Optimizasyonları**: Büyük veri setleri için lazy loading

### Orta Vadeli (3-4 Sprint)

1. **Kullanıcı Profilleri**: Birden fazla kullanıcı profili desteği
2. **İstatistikler Ekranı**: Detaylı ilerleme istatistikleri ve grafikler
3. **Arama Özelliği**: Sorular içinde arama yapabilme
4. **Favoriler**: Soruları favorilere ekleme ve favori sorularla çalışma
5. **Çalışma Planı**: Kişiselleştirilmiş çalışma planı oluşturma

### Uzun Vadeli (Gelecek Sürümler)

1. **Çevrimiçi Senkronizasyon**: Kullanıcı verilerini bulut ile senkronize etme
2. **Topluluk Özellikleri**: Kullanıcıların kendi sorularını paylaşabilmesi
3. **Çoklu Dil Desteği**: İngilizce dışında dillerde arayüz ve içerik
4. **Sesli Okuma**: Soruların sesli okunması
5. **Gamification**: Rozet, seviye ve ödül sistemi

## Aktif Kararlar ve Değerlendirmeler

### Teknik Kararlar

1. **Veri Depolama Stratejisi**: Kullanıcı ilerlemesini kalıcı olarak saklamak için en uygun yöntem değerlendirilmektedir. Seçenekler:
   - SharedPreferences (basit veriler için)
   - SQLite (daha karmaşık sorgular için)
   - Hive (NoSQL, performans odaklı)

2. **State Management**: Uygulama büyüdükçe daha kapsamlı bir state management çözümü gerekebilir. Seçenekler:
   - Provider
   - Bloc/Cubit
   - Riverpod
   - GetX

### Ürün Kararları

1. **Öğrenme Deneyimi**: Kullanıcıların daha etkili öğrenmesini sağlamak için ek özellikler değerlendirilmektedir:
   - Spaced repetition (aralıklı tekrar) algoritması
   - Yanlış cevaplanan soruların daha sık gösterilmesi
   - Öğrenme ilerlemesine göre zorluk seviyesi ayarlama

2. **Kullanıcı Geri Bildirimi**: Kullanıcı deneyimini iyileştirmek için geri bildirim mekanizmaları eklenmesi düşünülmektedir:
   - In-app geri bildirim formu
   - Kullanıcı memnuniyet anketleri
   - Kullanım analitikleri

## Güncel Zorluklar

1. **Veri Kalıcılığı**: Şu anda kullanıcı ilerlemesi uygulama kapatıldığında kaybolmaktadır. Bu, öncelikli olarak çözülmesi gereken bir sorundur.

2. **Test Kapsamı**: Uygulama için otomatik testler henüz uygulanmamıştır. Unit ve widget testleri eklenmesi gerekmektedir.

3. **Performans**: Soru sayısı arttıkça performans sorunları yaşanabilir. Özellikle büyük veri setleri için optimizasyon gereklidir.

4. **Erişilebilirlik**: Uygulama henüz tam erişilebilirlik standartlarını karşılamamaktadır. Ekran okuyucu desteği ve diğer erişilebilirlik özellikleri eklenmelidir.
