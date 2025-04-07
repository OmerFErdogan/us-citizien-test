class CampDay {
  final int dayNumber;        // Gün numarası (1-10)
  final String title;         // Günün başlığı
  final String description;   // Günün açıklaması
  final List<CampActivity> activities; // Günlük aktiviteler
  final int totalQuestions;   // Toplam soru sayısı
  final int targetCorrect;    // Hedeflenen doğru sayısı
  final String difficulty;    // Zorluk seviyesi
  final String materialUrl;   // Çalışma materyali referansı
  DateTime? completedDate;    // Tamamlanma tarihi (tamamlanmadıysa null)
  int correctAnswers;         // Doğru cevap sayısı
  bool isLocked;              // Gün kilitli mi?
  
  // Yapıcı metod
  CampDay({
    required this.dayNumber,
    required this.title,
    required this.description,
    required this.activities,
    required this.totalQuestions,
    required this.targetCorrect,
    required this.difficulty,
    required this.materialUrl,
    this.completedDate,
    this.correctAnswers = 0,
    this.isLocked = true,
  });
  
  // Tamamlanma durumunu kontrol et
  bool get isCompleted => completedDate != null;
  
  // Başarı oranını hesapla
  double get successRate => totalQuestions > 0 ? correctAnswers / totalQuestions : 0.0;
  
  // Hedef başarı oranını hesapla
  double get targetSuccessRate => totalQuestions > 0 ? targetCorrect / totalQuestions : 0.0;
  
  // Hedefi karşıladı mı?
  bool get isTargetMet => correctAnswers >= targetCorrect;
  
  // JSON'dan nesne oluşturma
  factory CampDay.fromJson(Map<String, dynamic> json) {
    return CampDay(
      dayNumber: json['dayNumber'],
      title: json['title'],
      description: json['description'],
      activities: (json['activities'] as List)
          .map((activity) => CampActivity.fromJson(activity))
          .toList(),
      totalQuestions: json['totalQuestions'],
      targetCorrect: json['targetCorrect'],
      difficulty: json['difficulty'],
      materialUrl: json['materialUrl'],
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'])
          : null,
      correctAnswers: json['correctAnswers'] ?? 0,
      isLocked: json['isLocked'] ?? true,
    );
  }
  
  // Nesneyi JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'dayNumber': dayNumber,
      'title': title,
      'description': description,
      'activities': activities.map((activity) => activity.toJson()).toList(),
      'totalQuestions': totalQuestions,
      'targetCorrect': targetCorrect,
      'difficulty': difficulty,
      'materialUrl': materialUrl,
      'completedDate': completedDate?.toIso8601String(),
      'correctAnswers': correctAnswers,
      'isLocked': isLocked,
    };
  }
  
  // Günü kopyalama ve değişiklik yapma
  CampDay copyWith({
    int? dayNumber,
    String? title,
    String? description,
    List<CampActivity>? activities,
    int? totalQuestions,
    int? targetCorrect,
    String? difficulty,
    String? materialUrl,
    DateTime? completedDate,
    int? correctAnswers,
    bool? isLocked,
  }) {
    return CampDay(
      dayNumber: dayNumber ?? this.dayNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      activities: activities ?? this.activities,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      targetCorrect: targetCorrect ?? this.targetCorrect,
      difficulty: difficulty ?? this.difficulty,
      materialUrl: materialUrl ?? this.materialUrl,
      completedDate: completedDate ?? this.completedDate,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}

// Günlük aktivite modeli
class CampActivity {
  final String period;        // Sabah, öğle, akşam
  final String title;         // Aktivite başlığı
  final String description;   // Aktivite açıklaması
  final int questionCount;    // Aktivite soru sayısı
  final List<String> categories; // Soru kategorileri
  bool isCompleted;           // Tamamlandı mı?
  
  CampActivity({
    required this.period,
    required this.title,
    required this.description,
    required this.questionCount,
    required this.categories,
    this.isCompleted = false,
  });
  
  // JSON'dan nesne oluşturma
  factory CampActivity.fromJson(Map<String, dynamic> json) {
    return CampActivity(
      period: json['period'],
      title: json['title'],
      description: json['description'],
      questionCount: json['questionCount'],
      categories: List<String>.from(json['categories']),
      isCompleted: json['isCompleted'] ?? false,
    );
  }
  
  // Nesneyi JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'title': title,
      'description': description,
      'questionCount': questionCount,
      'categories': categories,
      'isCompleted': isCompleted,
    };
  }
}