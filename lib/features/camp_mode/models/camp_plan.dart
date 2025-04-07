import 'camp_day.dart';

class CampPlan {
  final int id;                      // Kamp planı ID
  final String title;                // Kamp başlığı
  final String description;          // Kamp açıklaması
  final int durationDays;            // Süre (gün olarak)
  final List<CampDay> days;          // Kamp günleri
  final int minCompletionDays;       // Minimum tamamlanması gereken gün sayısı
  final Map<String, String> badges;  // Rozet tanımları (id -> açıklama)
  
  CampPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.durationDays,
    required this.days,
    required this.minCompletionDays,
    required this.badges,
  });
  
  // Belirli bir günü getir
  CampDay? getDayByNumber(int dayNumber) {
    try {
      return days.firstWhere((day) => day.dayNumber == dayNumber);
    } catch (e) {
      return null;
    }
  }
  
  // JSON'dan nesne oluşturma
  factory CampPlan.fromJson(Map<String, dynamic> json) {
    return CampPlan(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      durationDays: json['durationDays'],
      days: (json['days'] as List)
          .map((day) => CampDay.fromJson(day))
          .toList(),
      minCompletionDays: json['minCompletionDays'],
      badges: Map<String, String>.from(json['badges']),
    );
  }
  
  // Nesneyi JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'durationDays': durationDays,
      'days': days.map((day) => day.toJson()).toList(),
      'minCompletionDays': minCompletionDays,
      'badges': badges,
    };
  }
  
  // Varsayılan 10 günlük kamp planını oluştur
  factory CampPlan.createDefault() {
    return CampPlan(
      id: 1,
      title: "10 Günde Vatandaşlık",
      description: "Amerikan Vatandaşlık Sınavına 10 günde hazırlanmak için yoğun çalışma programı",
      durationDays: 10,
      minCompletionDays: 8,
      badges: {
        'day_complete': 'Günü tamamladınız',
        'perfect_day': 'Mükemmel gün: %100 başarı',
        'halfway': 'Yolun yarısını tamamladınız',
        'camp_complete': 'Kampı tamamladınız',
        'perfect_camp': 'Mükemmel kamp: 10/10 gün'
      },
      days: _createDefaultDays(), // Varsayılan günleri oluştur
    );
  }
  
  // Varsayılan günleri oluştur
  static List<CampDay> _createDefaultDays() {
    return [
      CampDay(
        dayNumber: 1,
        title: "Amerikan Tarihi Temelleri",
        description: "Kolonilerden bağımsızlığa, İç Savaş ve önemli tarihi olaylar",
        totalQuestions: 25,
        targetCorrect: 20,
        difficulty: "Başlangıç",
        materialUrl: "materials/americas_birth_guide.pdf",
        isLocked: false, // İlk gün açık
        activities: [
          CampActivity(
            period: "Sabah",
            title: "Tarih Temelleri",
            description: "Amerika'nın kuruluşu ve ilk yılları",
            questionCount: 10,
            categories: ["history_foundation", "independence"],
          ),
          CampActivity(
            period: "Öğle",
            title: "Çoktan Seçmeli Pratik",
            description: "Amerikan Devrimi ve Anayasal gelişimi",
            questionCount: 10,
            categories: ["american_revolution", "early_government"],
          ),
          CampActivity(
            period: "Akşam",
            title: "Kapsamlı Tekrar",
            description: "Önemli tarihi olayların özeti",
            questionCount: 5,
            categories: ["key_historical_events"],
          ),
        ],
      ),
      CampDay(
        dayNumber: 2,
        title: "Amerikan Hükümeti ve Anayasa",
        description: "Anayasa, değişiklikler, federal sistem yapısı",
        totalQuestions: 30,
        targetCorrect: 23,
        difficulty: "Orta",
        materialUrl: "materials/constitution_guide.pdf",
        isLocked: true, // İkinci gün kilitli başlar
        activities: [
          CampActivity(
            period: "Sabah",
            title: "Anayasa Maddeleri",
            description: "Anayasa'nın temel maddeleri ve yapısı",
            questionCount: 15,
            categories: ["constitution", "amendments"],
          ),
          CampActivity(
            period: "Öğle", 
            title: "Hükümet Organları",
            description: "Yasama, yürütme ve yargı",
            questionCount: 10,
            categories: ["branches_of_government"],
          ),
          CampActivity(
            period: "Akşam",
            title: "Denge ve Denetleme",
            description: "Hükümet organları arasındaki kontrol sistemi",
            questionCount: 5,
            categories: ["checks_balances"],
          ),
        ],
      ),
      CampDay(
        dayNumber: 3,
        title: "Haklar ve Sorumluluklar",
        description: "Vatandaşlık hakları, sorumluluklar ve görevler",
        totalQuestions: 20,
        targetCorrect: 16,
        difficulty: "Orta",
        materialUrl: "materials/rights_responsibilities_guide.pdf",
        isLocked: true,
        activities: [
          CampActivity(
            period: "Sabah",
            title: "Temel Haklar",
            description: "Anayasal haklar ve korumaları",
            questionCount: 10,
            categories: ["rights", "constitution"],
          ),
          CampActivity(
            period: "Öğle",
            title: "Vatandaşlık Sorumlulukları",
            description: "Amerikan vatandaşlarının görevleri",
            questionCount: 5,
            categories: ["responsibilities", "citizenship"],
          ),
          CampActivity(
            period: "Akşam",
            title: "Senaryolu Uygulamalar",
            description: "Gerçek hayat durumlarında haklar ve sorumluluklar",
            questionCount: 5,
            categories: ["scenarios", "applications"],
          ),
        ],
      ),
      CampDay(
        dayNumber: 4,
        title: "Politik Sistem ve Partiler",
        description: "Politik partiler, seçim sistemi, politik katılım",
        totalQuestions: 25,
        targetCorrect: 19,
        difficulty: "Orta",
        materialUrl: "materials/political_system_guide.pdf",
        isLocked: true,
        activities: [
          CampActivity(
            period: "Sabah",
            title: "Politik Sistem",
            description: "Amerikan politik sisteminin temelleri",
            questionCount: 10,
            categories: ["political_system", "government"],
          ),
          CampActivity(
            period: "Öğle",
            title: "Seçim Süreci",
            description: "Amerika'daki seçimler ve oylama",
            questionCount: 10,
            categories: ["elections", "voting"],
          ),
          CampActivity(
            period: "Akşam",
            title: "Güncel Politik Yapı",
            description: "Mevcut siyasi partiler ve liderler",
            questionCount: 5,
            categories: ["political_parties", "current_leaders"],
          ),
        ],
      ),
      CampDay(
        dayNumber: 5,
        title: "Tekrar ve Ara Değerlendirme",
        description: "İlk 4 günün kapsamlı tekrarı ve değerlendirmesi",
        totalQuestions: 40,
        targetCorrect: 30,
        difficulty: "Orta-İleri",
        materialUrl: "materials/week1_review.pdf",
        isLocked: true,
        activities: [
          CampActivity(
            period: "Sabah",
            title: "Tarih ve Anayasa Tekrarı",
            description: "1-2. gün konuları tekrarı ve uygulaması",
            questionCount: 15,
            categories: ["history", "constitution"],
          ),
          CampActivity(
            period: "Öğle",
            title: "Haklar ve Politik Sistem Tekrarı",
            description: "3-4. gün konuları tekrarı ve uygulaması",
            questionCount: 15,
            categories: ["rights", "political_system"],
          ),
          CampActivity(
            period: "Akşam",
            title: "Zayıf Konular Tekrarı",
            description: "Eksik kalan alanların belirlenmesi ve çalışılması",
            questionCount: 10,
            categories: ["weak_areas", "consolidation"],
          ),
        ],
      ),
      CampDay(
        dayNumber: 6,
        title: "Eyalet ve Yerel Yönetimler",
        description: "Eyalet yönetimleri, yerel idare yapısı, eyalet-federal ilişkiler",
        totalQuestions: 25,
        targetCorrect: 19,
        difficulty: "Orta",
        materialUrl: "materials/state_local_government_guide.pdf",
        isLocked: true,
        activities: [
          CampActivity(
            period: "Sabah",
            title: "Eyalet Yönetimleri",
            description: "Eyalet yapısı ve federal sistemdeki rolleri",
            questionCount: 10,
            categories: ["state_government", "federalism"],
          ),
          CampActivity(
            period: "Öğle",
            title: "Yerel Yönetimler",
            description: "Yerel yönetim kademeleri ve işlevleri",
            questionCount: 10,
            categories: ["local_government", "civic_structure"],
          ),
          CampActivity(
            period: "Akşam",
            title: "Entegre Uygulama",
            description: "Yönetim kademeleri arası ilişkiler ve roller",
            questionCount: 5,
            categories: ["government_interaction", "civic_engagement"],
          ),
        ],
      ),
      CampDay(
        dayNumber: 7,
        title: "Amerikan Sembolleri ve Tatiller",
        description: "Ulusal semboller, tatiller, önemli anıtlar",
        totalQuestions: 15,
        targetCorrect: 13,
        difficulty: "Kolay-Orta",
        materialUrl: "materials/symbols_holidays_guide.pdf",
        isLocked: true,
        activities: [
          CampActivity(
            period: "Sabah",
            title: "Ulusal Semboller",
            description: "Amerikan bayrağı, milli marş ve diğer semboller",
            questionCount: 5,
            categories: ["national_symbols", "flag"],
          ),
          CampActivity(
            period: "Öğle",
            title: "Resmi Tatiller",
            description: "Federal tatiller ve anlamları",
            questionCount: 5,
            categories: ["holidays", "commemorations"],
          ),
          CampActivity(
            period: "Akşam",
            title: "Önemli Anıtlar",
            description: "Tarihi anıtlar ve ulusal önemi",
            questionCount: 5,
            categories: ["monuments", "landmarks"],
          ),
        ],
      ),
      CampDay(
        dayNumber: 8,
        title: "Güncel Amerikan Liderleri",
        description: "Mevcut başkan, kabine, Kongre liderleri, Yüksek Mahkeme",
        totalQuestions: 20,
        targetCorrect: 17,
        difficulty: "Orta",
        materialUrl: "materials/current_leaders_guide.pdf",
        isLocked: true,
        activities: [
          CampActivity(
            period: "Sabah",
            title: "Yürütme Organı",
            description: "Başkan, Başkan Yardımcısı ve Kabine",
            questionCount: 10,
            categories: ["executive_branch", "president"],
          ),
          CampActivity(
            period: "Öğle",
            title: "Yasama Organı",
            description: "Kongre yapısı ve önemli pozisyonlar",
            questionCount: 5,
            categories: ["legislative_branch", "congress"],
          ),
          CampActivity(
            period: "Akşam",
            title: "Yargı Organı",
            description: "Yüksek Mahkeme ve federal yargı sistemi",
            questionCount: 5,
            categories: ["judicial_branch", "supreme_court"],
          ),
        ],
      ),
      CampDay(
        dayNumber: 9,
        title: "Coğrafya ve Eyaletler",
        description: "Amerika'nın coğrafyası, eyaletler, başkentler, bölgeler",
        totalQuestions: 15,
        targetCorrect: 12,
        difficulty: "Orta",
        materialUrl: "materials/geography_states_guide.pdf",
        isLocked: true,
        activities: [
          CampActivity(
            period: "Sabah",
            title: "Coğrafi Bölgeler",
            description: "ABD'nin coğrafi bölgeleri ve özellikleri",
            questionCount: 5,
            categories: ["geography", "regions"],
          ),
          CampActivity(
            period: "Öğle",
            title: "Eyaletler ve Başkentler",
            description: "Eyaletler, başkentler ve temel özellikleri",
            questionCount: 5,
            categories: ["states", "capitals"],
          ),
          CampActivity(
            period: "Akşam",
            title: "Önemli Coğrafi Oluşumlar",
            description: "Büyük nehirler, göller, dağlar ve diğer oluşumlar",
            questionCount: 5,
            categories: ["landmarks", "natural_features"],
          ),
        ],
      ),
      CampDay(
        dayNumber: 10,
        title: "Final Pratik Sınavı",
        description: "Tüm konuların kapsamlı uygulaması ve simüle sınav",
        totalQuestions: 100,
        targetCorrect: 85,
        difficulty: "İleri",
        materialUrl: "materials/final_exam_guide.pdf",
        isLocked: true,
        activities: [
          CampActivity(
            period: "Sabah",
            title: "Simüle Sınav 1",
            description: "Gerçek sınav formatında ilk deneme",
            questionCount: 50,
            categories: ["comprehensive", "exam_simulation"],
          ),
          CampActivity(
            period: "Öğle",
            title: "Değerlendirme ve Tekrar",
            description: "Zayıf alanların tespiti ve çalışılması",
            questionCount: 0,
            categories: ["review", "weak_areas"],
          ),
          CampActivity(
            period: "Akşam",
            title: "Simüle Sınav 2",
            description: "Gerçek sınav formatında ikinci deneme",
            questionCount: 50,
            categories: ["comprehensive", "exam_simulation"],
          ),
        ],
      ),
    ];
  }
}