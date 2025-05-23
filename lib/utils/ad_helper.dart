class AdHelper {
  // Gerçek reklam kimliği
  static const String bannerAdUnitId = 'ca-app-pub-7274759420959002/3396408811';
  
  // Test reklam kimliği (geliştirme aşamasında)
  static const String testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  
  // Canlı ortama geçince bannerAdUnitId'yi kullanın
  static String getBannerAdUnitId() {
    // Geliştirme aşamasında test ID'sini kullanın
    return testBannerAdUnitId;
    
    // Canlı ortamda gerçek ID'yi kullanın
    // return bannerAdUnitId;
  }
}