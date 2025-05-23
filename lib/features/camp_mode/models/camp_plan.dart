import 'package:flutter/material.dart';
import 'dart:ui';
import 'camp_day.dart';
import '../../../utils/extensions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../utils/app_localizations_provider.dart';

class CampPlan {
  final int id;                      // Kamp planı ID
  final String title;                // Kamp başlığı
  final String description;          // Kamp açıklaması
  final int durationDays;            // Süre (gün olarak)
  final List<CampDay> days;          // Kamp günleri
  final int minCompletionDays;       // Minimum tamamlanması gereken gün sayısı
  final Map<String, String> badges;  // Rozet tanımları (id -> açıklama)
  final Locale? locale;              // Planın oluşturulduğu dil
  
  CampPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.durationDays,
    required this.days,
    required this.minCompletionDays,
    required this.badges,
    this.locale,
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
      locale: json['locale'] != null ? Locale(json['locale']) : null,
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
      'locale': locale?.languageCode,
    };
  }
  
  // Varsayılan kamp planını oluştur
  factory CampPlan.createDefault(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    print('Creating default CampPlan with context locale: ${locale.languageCode}');
    
    // Tüm metinler l10n üzerinden alınıyor
    return CampPlan(
      id: 1,
      title: l10n.campTitle,
      description: l10n.campDescription,
      durationDays: 10,
      minCompletionDays: 8,
      badges: {
        'day_complete': l10n.badgeDayComplete,
        'perfect_day': l10n.badgePerfectDay,
        'halfway': l10n.badgeHalfway,
        'camp_complete': l10n.badgeCampComplete,
        'perfect_camp': l10n.badgePerfectCamp,
      },
      days: _createLocalizedDaysWithL10n(l10n),
      locale: locale, // Locale bilgisini ekle
    );
  }
  
  // Lokalize edilmiş günleri oluştur - AppLocalizations ile
  static List<CampDay> _createLocalizedDaysWithL10n(AppLocalizations l10n) {
    
    return [
      CampDay(
        dayNumber: 1,
        title: l10n.day1Title,
        description: l10n.day1Description,
        totalQuestions: 25,
        targetCorrect: 20,
        difficulty: l10n.difficultyBeginner,
        materialUrl: "materials/americas_birth_guide.pdf",
        isLocked: false, // İlk gün açık
        activities: [
          CampActivity(
            period: l10n.periodMorning,
            title: l10n.day1Activity1Title,
            description: l10n.day1Activity1Description,
            questionCount: 10,
            categories: ["history_foundation", "independence"],
          ),
          CampActivity(
            period: l10n.periodNoon,
            title: l10n.day1Activity2Title,
            description: l10n.day1Activity2Description,
            questionCount: 10,
            categories: ["american_revolution", "early_government"],
          ),
          CampActivity(
            period: l10n.periodEvening,
            title: l10n.day1Activity3Title,
            description: l10n.day1Activity3Description,
            questionCount: 5,
            categories: ["key_historical_events"],
          ),
        ],
      ),
      CampDay(
        dayNumber: 2,
        title: l10n.day2Title,
        description: l10n.day2Description,
        totalQuestions: 30,
        targetCorrect: 23,
        difficulty: l10n.difficultyIntermediate,
        materialUrl: "materials/constitution_guide.pdf",
        isLocked: true, // İkinci gün kilitli başlar
        activities: [
          CampActivity(
            period: l10n.periodMorning,
            title: l10n.day2Activity1Title,
            description: l10n.day2Activity1Description,
            questionCount: 15,
            categories: ["constitution", "amendments"],
          ),
          CampActivity(
            period: l10n.periodNoon, 
            title: l10n.day2Activity2Title,
            description: l10n.day2Activity2Description,
            questionCount: 10,
            categories: ["branches_of_government"],
          ),
          CampActivity(
            period: l10n.periodEvening,
            title: l10n.day2Activity3Title,
            description: l10n.day2Activity3Description,
            questionCount: 5,
            categories: ["checks_balances"],
          ),
        ],
      ),
      CampDay(
        dayNumber: 3,
        title: l10n.day3Title,
        description: l10n.day3Description,
        totalQuestions: 20,
        targetCorrect: 16,
        difficulty: l10n.difficultyIntermediate,
        materialUrl: "materials/rights_responsibilities_guide.pdf",
        isLocked: true,
        activities: [
          CampActivity(
            period: l10n.periodMorning,
            title: l10n.day3Activity1Title,
            description: l10n.day3Activity1Description,
            questionCount: 10,
            categories: ["rights", "constitution"],
          ),
          CampActivity(
            period: l10n.periodNoon,
            title: l10n.day3Activity2Title,
            description: l10n.day3Activity2Description,
            questionCount: 5,
            categories: ["responsibilities", "citizenship"],
          ),
          CampActivity(
            period: l10n.periodEvening,
            title: l10n.day3Activity3Title,
            description: l10n.day3Activity3Description,
            questionCount: 5,
            categories: ["scenarios", "applications"],
          ),
        ],
      ),
      CampDay(
        dayNumber: 4,
        title: l10n.day4Title,
        description: l10n.day4Description,
        totalQuestions: 25,
        targetCorrect: 19,
        difficulty: l10n.difficultyIntermediate,
        materialUrl: "materials/political_system_guide.pdf",
        isLocked: true,
        activities: [
          CampActivity(
            period: l10n.periodMorning,
            title: l10n.day4Activity1Title,
            description: l10n.day4Activity1Description,
            questionCount: 10,
            categories: ["political_system", "government"],
          ),
          CampActivity(
            period: l10n.periodNoon,
            title: l10n.day4Activity2Title,
            description: l10n.day4Activity2Description,
            questionCount: 10,
            categories: ["elections", "voting"],
          ),
          CampActivity(
            period: l10n.periodEvening,
            title: l10n.day4Activity3Title,
            description: l10n.day4Activity3Description,
            questionCount: 5,
            categories: ["political_parties", "current_leaders"],
          ),
        ],
      ),
      CampDay(
        dayNumber: 5,
        title: l10n.day5Title,
        description: l10n.day5Description,
        totalQuestions: 40,
        targetCorrect: 30,
        difficulty: l10n.difficultyIntermediateAdvanced,
        materialUrl: "materials/week1_review.pdf",
        isLocked: true,
        activities: [
          CampActivity(
            period: l10n.periodMorning,
            title: l10n.day5Activity1Title,
            description: l10n.day5Activity1Description,
            questionCount: 15,
            categories: ["history", "constitution"],
          ),
          CampActivity(
            period: l10n.periodNoon,
            title: l10n.day5Activity2Title,
            description: l10n.day5Activity2Description,
            questionCount: 15,
            categories: ["rights", "political_system"],
          ),
          CampActivity(
            period: l10n.periodEvening,
            title: l10n.day5Activity3Title,
            description: l10n.day5Activity3Description,
            questionCount: 10,
            categories: ["weak_areas", "consolidation"],
          ),
        ],
      ),
      CampDay(
        dayNumber: 6,
        title: l10n.day6Title,
        description: l10n.day6Description,
        totalQuestions: 25,
        targetCorrect: 19,
        difficulty: l10n.difficultyIntermediate,
        materialUrl: "materials/state_local_government_guide.pdf",
        isLocked: true,
        activities: [
          CampActivity(
            period: l10n.periodMorning,
            title: l10n.day6Activity1Title,
            description: l10n.day6Activity1Description,
            questionCount: 10,
            categories: ["state_government", "federalism"],
          ),
          CampActivity(
            period: l10n.periodNoon,
            title: l10n.day6Activity2Title,
            description: l10n.day6Activity2Description,
            questionCount: 10,
            categories: ["local_government", "civic_structure"],
          ),
          CampActivity(
            period: l10n.periodEvening,
            title: l10n.day6Activity3Title,
            description: l10n.day6Activity3Description,
            questionCount: 5,
            categories: ["government_interaction", "civic_engagement"],
          ),
        ],
      ),
      CampDay(
        dayNumber: 7,
        title: l10n.day7Title,
        description: l10n.day7Description,
        totalQuestions: 15,
        targetCorrect: 13,
        difficulty: l10n.difficultyBeginnerIntermediate,
        materialUrl: "materials/symbols_holidays_guide.pdf",
        isLocked: true,
        activities: [
          CampActivity(
            period: l10n.periodMorning,
            title: l10n.day7Activity1Title,
            description: l10n.day7Activity1Description,
            questionCount: 5,
            categories: ["national_symbols", "flag"],
          ),
          CampActivity(
            period: l10n.periodNoon,
            title: l10n.day7Activity2Title,
            description: l10n.day7Activity2Description,
            questionCount: 5,
            categories: ["holidays", "commemorations"],
          ),
          CampActivity(
            period: l10n.periodEvening,
            title: l10n.day7Activity3Title,
            description: l10n.day7Activity3Description,
            questionCount: 5,
            categories: ["monuments", "landmarks"],
          ),
        ],
      ),
      CampDay(
        dayNumber: 8,
        title: l10n.day8Title,
        description: l10n.day8Description,
        totalQuestions: 20,
        targetCorrect: 17,
        difficulty: l10n.difficultyIntermediate,
        materialUrl: "materials/current_leaders_guide.pdf",
        isLocked: true,
        activities: [
          CampActivity(
            period: l10n.periodMorning,
            title: l10n.day8Activity1Title,
            description: l10n.day8Activity1Description,
            questionCount: 10,
            categories: ["executive_branch", "president"],
          ),
          CampActivity(
            period: l10n.periodNoon,
            title: l10n.day8Activity2Title,
            description: l10n.day8Activity2Description,
            questionCount: 5,
            categories: ["legislative_branch", "congress"],
          ),
          CampActivity(
            period: l10n.periodEvening,
            title: l10n.day8Activity3Title,
            description: l10n.day8Activity3Description,
            questionCount: 5,
            categories: ["judicial_branch", "supreme_court"],
          ),
        ],
      ),
      CampDay(
        dayNumber: 9,
        title: l10n.day9Title,
        description: l10n.day9Description,
        totalQuestions: 15,
        targetCorrect: 12,
        difficulty: l10n.difficultyIntermediate,
        materialUrl: "materials/geography_states_guide.pdf",
        isLocked: true,
        activities: [
          CampActivity(
            period: l10n.periodMorning,
            title: l10n.day9Activity1Title,
            description: l10n.day9Activity1Description,
            questionCount: 5,
            categories: ["geography", "regions"],
          ),
          CampActivity(
            period: l10n.periodNoon,
            title: l10n.day9Activity2Title,
            description: l10n.day9Activity2Description,
            questionCount: 5,
            categories: ["states", "capitals"],
          ),
          CampActivity(
            period: l10n.periodEvening,
            title: l10n.day9Activity3Title,
            description: l10n.day9Activity3Description,
            questionCount: 5,
            categories: ["landmarks", "natural_features"],
          ),
        ],
      ),
      CampDay(
        dayNumber: 10,
        title: l10n.day10Title,
        description: l10n.day10Description,
        totalQuestions: 100,
        targetCorrect: 85,
        difficulty: l10n.difficultyAdvanced,
        materialUrl: "materials/final_exam_guide.pdf",
        isLocked: true,
        activities: [
          CampActivity(
            period: l10n.periodMorning,
            title: l10n.day10Activity1Title,
            description: l10n.day10Activity1Description,
            questionCount: 50,
            categories: ["comprehensive", "exam_simulation"],
          ),
          CampActivity(
            period: l10n.periodNoon,
            title: l10n.day10Activity2Title,
            description: l10n.day10Activity2Description,
            questionCount: 0,
            categories: ["review", "weak_areas"],
          ),
          CampActivity(
            period: l10n.periodEvening,
            title: l10n.day10Activity3Title,
            description: l10n.day10Activity3Description,
            questionCount: 50,
            categories: ["comprehensive", "exam_simulation"],
          ),
        ],
      ),
    ];
  }
  
  // BuildContext olmadığında kullanılabilecek alternatif
  static Future<CampPlan> createDefaultWithLocale(Locale locale, [BuildContext? context]) async {
    // Context verilmişse, context üzerinden oluştur
    if (context != null) {
      final plan = CampPlan.createDefault(context);
      // Locale bilgisini ekleyerek geriye döndür
      return CampPlan(
        id: plan.id,
        title: plan.title,
        description: plan.description,
        durationDays: plan.durationDays,
        minCompletionDays: plan.minCompletionDays,
        badges: plan.badges,
        days: plan.days,
        locale: locale,  // Locale bilgisini ekle
      );
    }
    
    print('Creating CampPlan with locale: ${locale.languageCode}');
    
    // Öncelikle locale'den AppLocalizations yükleyelim
    AppLocalizations? l10n;
    
    try {
      // Önce global provider'dan almayı dene
      l10n = appLocalizationsProvider.localizations;
      
      // Eğer globalden alamazsak locale'den yükleyelim
      if (l10n == null) {
        l10n = await AppLocalizations.delegate.load(locale);
      }
    } catch (e) {
      // Hata durumunda İngilizce'ye düşelim
      locale = const Locale('en');
      l10n = await AppLocalizations.delegate.load(locale);
      print('Localization loading error: $e');
    }
    
    // 10-gün kamp planı oluştur - tüm metinleri l10n'den alarak
    return CampPlan(
      id: 1,
      title: l10n.campTitle, // ARB'den lokalize metni kullan
      description: l10n.campDescription, // ARB'den lokalize metni kullan
      durationDays: 10,
      minCompletionDays: 8,
      badges: {
        'day_complete': l10n.badgeDayComplete,
        'perfect_day': l10n.badgePerfectDay,
        'halfway': l10n.badgeHalfway,
        'camp_complete': l10n.badgeCampComplete,
        'perfect_camp': l10n.badgePerfectCamp,
      },
      days: _createLocalizedDaysWithL10n(l10n),
      locale: locale,  // Locale bilgisini ekle
    );
  }
  
  // Static utils method to get a CampPlan with current locale
  static Future<CampPlan> getCurrentLocaleInstance() async {
    final locale = appLocalizationsProvider.currentLocale;
    final l10n = appLocalizationsProvider.localizations;
    
    print('Getting CampPlan with current locale: ${locale.languageCode}');
    
    if (l10n == null) {
      // Provider henüz yüklenmemişse, locale ile yükle
      return await CampPlan.createDefaultWithLocale(locale);
    }
    
    return CampPlan(
      id: 1,
      title: l10n.campTitle, // ARB'den lokalize metni kullan
      description: l10n.campDescription, // ARB'den lokalize metni kullan
      durationDays: 10,
      minCompletionDays: 8,
      badges: {
        'day_complete': l10n.badgeDayComplete,
        'perfect_day': l10n.badgePerfectDay,
        'halfway': l10n.badgeHalfway,
        'camp_complete': l10n.badgeCampComplete,
        'perfect_camp': l10n.badgePerfectCamp,
      },
      days: _createLocalizedDaysWithL10n(l10n),
      locale: locale, // Locale bilgisini ekle
    );
  }
}