class CampProgress {
  final int userId;                 // Kullanıcı ID (gelecekte çoklu kullanıcı için)
  final DateTime startDate;         // Kamp başlangıç tarihi
  DateTime? completionDate;         // Kamp bitiş tarihi
  final Map<int, CampDayProgress> dayProgress; // Günlük ilerleme durumları
  List<CampBadge> earnedBadges = [];     // Kazanılan rozetler
  bool isCertificateEarned;         // Sertifika hak kazanıldı mı?
  
  CampProgress({
    required this.userId,
    required this.startDate,
    this.completionDate,
    required this.dayProgress,
    List<CampBadge>? earnedBadges,
    this.isCertificateEarned = false,
  }) {
    if (earnedBadges != null) {
      this.earnedBadges = earnedBadges;
    }
  }
  
  // Tamamlanan gün sayısı
  int get completedDaysCount => dayProgress.values.where((day) => day.isCompleted).length;
  
  // Kamp tamamlandı mı? (en az 8 gün)
  bool get isCampCompleted => completedDaysCount >= 8;
  
  // Mükemmel tamamlama (10 günün 10'u)
  bool get isPerfectCompletion => completedDaysCount == 10;
  
  // Toplam doğru cevap oranı
  double get overallSuccessRate {
    int totalCorrect = 0;
    int totalQuestions = 0;
    
    dayProgress.values.forEach((day) {
      totalCorrect += day.correctAnswers;
      totalQuestions += day.totalQuestions;
    });
    
    return totalQuestions > 0 ? totalCorrect / totalQuestions : 0.0;
  }
  
  // JSON'dan nesne oluşturma
  factory CampProgress.fromJson(Map<String, dynamic> json) {
    return CampProgress(
      userId: json['userId'],
      startDate: DateTime.parse(json['startDate']),
      completionDate: json['completionDate'] != null
          ? DateTime.parse(json['completionDate'])
          : null,
      dayProgress: (json['dayProgress'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          int.parse(key),
          CampDayProgress.fromJson(value),
        ),
      ),
      earnedBadges: json['earnedBadges'] != null ? (json['earnedBadges'] as List)
          .map((badge) => CampBadge.fromJson(badge as Map<String, dynamic>))
          .toList() : [],
      isCertificateEarned: json['isCertificateEarned'] ?? false,
    );
  }
  
  // Nesneyi JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'startDate': startDate.toIso8601String(),
      'completionDate': completionDate?.toIso8601String(),
      'dayProgress': dayProgress.map(
        (key, value) => MapEntry(key.toString(), value.toJson()),
      ),
      'earnedBadges': earnedBadges.map((badge) => badge.toJson()).toList(),
      'isCertificateEarned': isCertificateEarned,
    };
  }
}

// Günlük ilerleme durumu
class CampDayProgress {
  final int dayNumber;            // Gün numarası
  final int totalQuestions;       // Toplam soru sayısı
  final int targetCorrect;        // Hedef doğru sayısı
  int correctAnswers;             // Doğru cevap sayısı
  int attemptCount;               // Toplam deneme sayısı
  DateTime? completedDate;        // Tamamlanma tarihi
  List<String> strugglingTopics;  // Zorlanılan konular
  
  CampDayProgress({
    required this.dayNumber,
    required this.totalQuestions,
    required this.targetCorrect,
    this.correctAnswers = 0,
    this.attemptCount = 0,
    this.completedDate,
    this.strugglingTopics = const [],
  });
  
  // Tamamlandı mı?
  bool get isCompleted => completedDate != null;
  
  // Hedef karşılandı mı?
  bool get isTargetMet => correctAnswers >= targetCorrect;
  
  // Başarı oranı
  double get successRate => totalQuestions > 0 ? correctAnswers / totalQuestions : 0.0;
  
  // JSON'dan nesne oluşturma
  factory CampDayProgress.fromJson(Map<String, dynamic> json) {
    return CampDayProgress(
      dayNumber: json['dayNumber'],
      totalQuestions: json['totalQuestions'],
      targetCorrect: json['targetCorrect'],
      correctAnswers: json['correctAnswers'] ?? 0,
      attemptCount: json['attemptCount'] ?? 0,
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'])
          : null,
      strugglingTopics: List<String>.from(json['strugglingTopics'] ?? []),
    );
  }
  
  // Nesneyi JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'dayNumber': dayNumber,
      'totalQuestions': totalQuestions,
      'targetCorrect': targetCorrect,
      'correctAnswers': correctAnswers,
      'attemptCount': attemptCount,
      'completedDate': completedDate?.toIso8601String(),
      'strugglingTopics': strugglingTopics,
    };
  }
}

// Rozet modeli
class CampBadge {
  final String id;            // Rozet ID
  final String title;         // Rozet başlığı
  final String description;   // Rozet açıklaması
  final String iconPath;      // Rozet ikon yolu
  final DateTime earnedDate;  // Kazanılma tarihi
  
  CampBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.earnedDate,
  });
  
  // JSON'dan nesne oluşturma
  factory CampBadge.fromJson(Map<String, dynamic> json) {
    return CampBadge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      iconPath: json['iconPath'],
      earnedDate: DateTime.parse(json['earnedDate']),
    );
  }
  
  // Nesneyi JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconPath': iconPath,
      'earnedDate': earnedDate.toIso8601String(),
    };
  }
}