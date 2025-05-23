import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:us_citizenship_test/models/question.dart';
import '../models/camp_day.dart';
import '../models/camp_progress.dart';
import '../models/camp_plan.dart';
import '../../../services/question_service.dart';
import '../../../services/revenue_cat_service.dart';
import '../../../utils/app_localizations_provider.dart';

// Localization yardımcı fonksiyonlar
class CampServiceTexts {
  // L10n'e erişim
  static get l10n => appLocalizationsProvider.localizations;
  
  // Sabit metinler
  static String get kServiceNotInitialized => l10n?.kServiceNotInitialized ?? "Camp service not initialized. Call the initialize() method first.";
  static String get kServiceInitError => l10n?.kServiceInitError ?? "Error while initializing camp service:";
  static String get kCampNotStarted => l10n?.kCampNotStarted ?? "Camp not started or service not initialized.";
  static String get kHalfwayTitle => l10n?.kHalfwayTitle ?? "Halfway There";
  static String get kHalfwayDesc => l10n?.kHalfwayDesc ?? "You have successfully completed half of the camp!";
  static String get kCampCompletedTitle => l10n?.kCampCompletedTitle ?? "Camp Completed";
  static String get kCampCompletedDesc => l10n?.kCampCompletedDesc ?? "Congratulations! You have successfully completed the 10-Day Citizenship Camp.";
  static String get kPerfectCampTitle => l10n?.kPerfectCampTitle ?? "Perfect Camp";
  static String get kPerfectCampDesc => l10n?.kPerfectCampDesc ?? "Amazing! You have successfully completed all 10 days of the camp.";
  static String get kSyncProgressError => l10n?.kSyncProgressError ?? "Error synchronizing progress and activity status:";
  static String get kUpdateActivityError => l10n?.kUpdateActivityError ?? "Error updating activity completion status:";

  // Parametre alan metinler
  static String kDayUnlocked(int dayNumber) => l10n?.kDayUnlocked(dayNumber) ?? "Day $dayNumber unlocked";
  static String kDayCompletedTitle(int dayNumber) => l10n?.kDayCompletedTitle(dayNumber) ?? "Day $dayNumber Completed";
  static String kDayCompletedDesc(int dayNumber) => l10n?.kDayCompletedDesc(dayNumber) ?? "You have successfully completed the study for day $dayNumber!";
  static String kPerfectDayTitle(int dayNumber) => l10n?.kPerfectDayTitle(dayNumber) ?? "Perfect Day $dayNumber";
  static String kPerfectDayDesc(int dayNumber) => l10n?.kPerfectDayDesc(dayNumber) ?? "You answered all questions correctly for day $dayNumber!";
  static String kDayNotFound(int dayNumber) => l10n?.kDayNotFound(dayNumber) ?? "Day $dayNumber not found";
  static String kActivityNotFound(String activityTitle) => l10n?.kActivityNotFound(activityTitle) ?? "Activity with title \"$activityTitle\" not found.";
  static String kAllActivitiesCompleted(int dayNumber) => l10n?.kAllActivitiesCompleted(dayNumber) ?? "All activities for Day $dayNumber completed!";
  static String kCompletingDayFromActivities(int dayNumber, int totalCorrect) => l10n?.kCompletingDayFromActivities(dayNumber, totalCorrect) ?? "All activities completed, starting day completion: Day=$dayNumber, Calculated Score=$totalCorrect";
}


class CampService {
  // Singleton pattern
  static final CampService _instance = CampService._internal();
  
  factory CampService() {
    return _instance;
  }
  
  CampService._internal();
  
  // Sınıf özellikleri
  late CampPlan _campPlan;
  CampProgress? _userProgress;
  bool _isInitialized = false;
  final QuestionService _questionService = QuestionService();
  Locale _currentLocale = const Locale('en'); // Varsayılan olarak İngilizce
  
  // Sabitleri
  static const String _campPlanKey = 'camp_plan';
  static const String _userProgressKey = 'user_camp_progress';
  
  // Servisi başlat
  Future<void> initialize({Locale? locale}) async {
    if (_isInitialized) return;
    
    // Dil bilgisini güncelle
    if (locale != null) {
      _currentLocale = locale;
      // Global localizations provider'ı güncelliyoruz
      await appLocalizationsProvider.updateLocale(locale);
    } else {
      // Eğer locale belirtilmemişse, global provider'dan al
      _currentLocale = appLocalizationsProvider.currentLocale;
    }
    
    print('Initializing CampService with locale: ${_currentLocale.languageCode}');
    
    try {
      await _questionService.loadQuestions();
      // Önce SharedPreferences'tan kamp planını yüklemeyi dene
      final savedCampPlan = await _loadCampPlan();
      
      // Kamp planı yoksa veya dil farklı ise yeni bir tane oluştur
      if (savedCampPlan == null) {
        // Yeni bir kamp planı oluştur
        _campPlan = await CampPlan.createDefaultWithLocale(_currentLocale);
        await _saveCampPlan(); // Hemen kaydet
        print('Created new camp plan with locale: ${_currentLocale.languageCode}');
      }
      
      await _loadUserProgress();
      
      // Premium duruma göre gün kilit durumlarını güncelle
      await updateDayLocksBasedOnPremium();
      
      _isInitialized = true;
    } catch (e) {
      print('${CampServiceTexts.kServiceInitError} $e');
      _isInitialized = false;
      rethrow;
    }
  }
  
  // Kamp planını yükle ve döndür
  Future<CampPlan?> _loadCampPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final campPlanJson = prefs.getString(_campPlanKey);
    
    if (campPlanJson != null) {
      try {
        final loadedPlan = CampPlan.fromJson(jsonDecode(campPlanJson));
        
        // Önceden kaydedilmiş planın dili ile mevcut dil aynı mı kontrol et
        // Eğer farklıysa yeni bir plan oluştur ve null döndür
        final planLocale = loadedPlan.locale?.languageCode;
        final currentLocale = _currentLocale.languageCode;
        
        if (planLocale != null && planLocale != currentLocale) {
          print('Stored plan has different locale: $planLocale, current: $currentLocale, creating new plan');
          // Farklı dilde olduğu için null döndür (yeni plan oluşturulacak)
          return null;
        }
        
        // Plan yüklendi ve dil uyumlu
        _campPlan = loadedPlan;
        return loadedPlan;
      } catch (e) {
        print('Error loading camp plan: $e');
        return null; // Parse hatası durumunda null döndür
      }
    } else {
      // Kaydedilmiş plan yok
      return null;
    }
  }
  
  // Kullanıcı ilerlemesini yükle
  Future<void> _loadUserProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final userProgressJson = prefs.getString(_userProgressKey);
    
    if (userProgressJson != null) {
      _userProgress = CampProgress.fromJson(jsonDecode(userProgressJson));
      
      // Kullanıcı ilerlemesine göre günlerin kilit durumlarını güncelle
      if (_userProgress != null) {
        _syncCampDayWithProgress();
        
        // İlk günün kilidini her zaman aç
        final firstDay = _campPlan.getDayByNumber(1);
        if (firstDay != null) {
          final index = _campPlan.days.indexOf(firstDay);
          _campPlan.days[index] = firstDay.copyWith(isLocked: false);
        }
      }
    }
  }
  
  // Kamp planını kaydet (private)
  Future<void> _saveCampPlan() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_campPlanKey, jsonEncode(_campPlan.toJson()));
  }
  
  // Kamp planını kaydet (public)
  Future<void> saveCampPlan() async {
    await _saveCampPlan();
  }
  
  // Kullanıcı ilerlemesini kaydet
  Future<void> _saveUserProgress() async {
    if (_userProgress == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProgressKey, jsonEncode(_userProgress!.toJson()));
  }
  
  // Kamp planını getir
  CampPlan getCampPlan() {
    if (!_isInitialized) {
      throw Exception(CampServiceTexts.kServiceNotInitialized);
    }
    return _campPlan;
  }
  
  // Kullanıcı ilerlemesini getir
  CampProgress? getUserProgress() {
    return _userProgress;
  }
  
  // Yeni kamp başlat
  Future<CampProgress> startNewCamp({int userId = 1}) async {
    if (!_isInitialized) {
      throw Exception(CampServiceTexts.kServiceNotInitialized);
    }
    
    // Yeni ilerleme oluştur
    final Map<int, CampDayProgress> dayProgress = {};
    
    // Her gün için ilerleme durumu oluştur
    for (var day in _campPlan.days) {
      dayProgress[day.dayNumber] = CampDayProgress(
        dayNumber: day.dayNumber,
        totalQuestions: day.totalQuestions,
        targetCorrect: day.targetCorrect,
      );
    }
    
    // Kullanıcı ilerlemesini oluştur
    _userProgress = CampProgress(
      userId: userId,
      startDate: DateTime.now(),
      dayProgress: dayProgress,
    );
    
    // İlerlemeyi kaydet
    await _saveUserProgress();
    
    return _userProgress!;
  }
  
  // Günlerin kilit durumunu kullanıcı ilerlemesine göre güncelleme
  void _syncCampDayWithProgress() {
    if (_userProgress == null) return;
    
    for (var day in _campPlan.days) {
      if (_userProgress!.dayProgress.containsKey(day.dayNumber)) {
        final progress = _userProgress!.dayProgress[day.dayNumber]!;
        
        // Özelleştirilmiş günü getir ve güncellemeler yap
        final index = _campPlan.days.indexOf(day);
        _campPlan.days[index] = day.copyWith(
          completedDate: progress.completedDate,
          correctAnswers: progress.correctAnswers,
          isLocked: day.dayNumber == 1 ? false : !_isUnlocked(day.dayNumber) 
        );
      }
    }
  }
  
  // Bir günün kilidinin açık olup olmadığını kontrol et
  bool _isUnlocked(int dayNumber) {
    if (dayNumber == 1) return true; // İlk gün her zaman açık
    
    // Önceki günün tamamlanıp tamamlanmadığını kontrol et
    final previousDayNumber = dayNumber - 1;
    return _userProgress != null && 
           _userProgress!.dayProgress.containsKey(previousDayNumber) &&
           _userProgress!.dayProgress[previousDayNumber]!.isCompleted;
  }
  
  // Günü tamamla
  Future<bool> completeDay(int dayNumber, int correctAnswers, List<String> strugglingTopics) async {
    if (!_isInitialized || _userProgress == null) {
      throw Exception(CampServiceTexts.kCampNotStarted);
    }
    
    if (!_userProgress!.dayProgress.containsKey(dayNumber)) {
      return false;
    }
    
    // Günlük ilerlemeyi al
    final dayProgress = _userProgress!.dayProgress[dayNumber]!;
    
    // İlerlemeyi güncelle
    dayProgress.correctAnswers = correctAnswers;
    dayProgress.attemptCount += 1;
    dayProgress.strugglingTopics = strugglingTopics;
    
    // Başarı oranını hesapla
    final successRate = dayProgress.totalQuestions > 0 ? 
                       correctAnswers / dayProgress.totalQuestions : 0.0;
    
    // Hedef karşılandıysa güncelle ve bir sonraki günü aç
    if (dayProgress.isTargetMet) {
      // Tamamlanma tarihini ayarla
      dayProgress.completedDate = DateTime.now();
      
      // CampDay nesnesini de güncelle
      final day = _campPlan.getDayByNumber(dayNumber);
      if (day != null) {
        final index = _campPlan.days.indexOf(day);
        _campPlan.days[index] = day.copyWith(
          completedDate: DateTime.now(),
          correctAnswers: correctAnswers
        );
      }
      
      // Bir sonraki günün kilidini aç
      final nextDayNumber = dayNumber + 1;
      if (nextDayNumber <= _campPlan.durationDays) {
        final nextDay = _campPlan.getDayByNumber(nextDayNumber);
        if (nextDay != null) {
          final index = _campPlan.days.indexOf(nextDay);
          _campPlan.days[index] = nextDay.copyWith(isLocked: false);
          print(CampServiceTexts.kDayUnlocked(nextDayNumber));
          
          // Kullanıcı ilerlemesindeki günün durumunu da güncelle
          // Bu, uygulama yeniden başlatıldığında kilit durumunu korumak için önemli
          if (_userProgress != null && _userProgress!.dayProgress.containsKey(nextDayNumber)) {
            // İlerleme verileri zaten var, sadece güncelleme gerekli
            // Kilidi açık olarak işaretlemek için doğrudan bir alan olmadığından,
            // kullanıcı ilerlemesi ile CampDay nesneleri arasındaki senkronizasyonu
            // _syncCampDayWithProgress metodu sağlıyor
          }
        }
      }
      
      // Rozet ekle
      _addBadgeIfEarned(dayNumber);
      
      // Kamp tamamlandı mı kontrol et
      if (_userProgress!.isCampCompleted && _userProgress!.completionDate == null) {
        _userProgress!.completionDate = DateTime.now();
        _userProgress!.isCertificateEarned = true;
        _addCompletionBadge();
      }
      
      await _saveCampPlan();
    }
    
    // İlerlemeyi kaydet
    await _saveUserProgress();
    
    return dayProgress.isTargetMet;
  }
  
  // Belirli bir gün için soruları getir
  List<Question> getQuestionsForDay(int dayNumber, {List<String>? categories, int? limit}) {
    if (!_isInitialized) {
      throw Exception(CampServiceTexts.kServiceNotInitialized);
    }
    
    final day = _campPlan.getDayByNumber(dayNumber);
    if (day == null) {
      return [];
    }
    
    // Günün aktivitelerine ait kategorileri topla
    Set<String> dayCategories = {};
    for (var activity in day.activities) {
      dayCategories.addAll(activity.categories);
    }
    
    // Günün kategorilerini veya belirtilen kategorileri kullan
    final categoriesToUse = categories ?? dayCategories.toList();
    
    // Eğer kategori listesi boşsa, tüm sorulardan rastgele seç
    if (categoriesToUse.isEmpty) {
      return _questionService.getRandomQuestions(limit ?? day.totalQuestions);
    }
    
    // Kategorilere göre soruları getir
    final questions = _questionService.getRandomQuestionsByCategories(
      limit ?? day.totalQuestions, 
      categoriesToUse
    );
    
    // Yeterli soru yoksa, tüm sorulardan tamamla
    if (questions.length < (limit ?? day.totalQuestions)) {
      final remainingCount = (limit ?? day.totalQuestions) - questions.length;
      final additionalQuestions = _questionService.getRandomQuestions(remainingCount);
      questions.addAll(additionalQuestions);
    }
    
    return questions;
  }
  
  // Rozet ekleme
  void _addBadgeIfEarned(int completedDayNumber) {
    if (_userProgress == null) return;
    
    // Gün tamamlama rozeti
    final dayBadge = CampBadge(
      id: 'day_complete_$completedDayNumber',
      title: CampServiceTexts.kDayCompletedTitle(completedDayNumber),
      description: CampServiceTexts.kDayCompletedDesc(completedDayNumber),
      iconPath: 'assets/images/badges/day_complete_$completedDayNumber.png',
      earnedDate: DateTime.now(),
    );
    
    _userProgress!.earnedBadges = [..._userProgress!.earnedBadges, dayBadge];
    
    // Mükemmel gün rozeti (tüm soruları doğru cevapladıysa)
    final dayProgress = _userProgress!.dayProgress[completedDayNumber]!;
    if (dayProgress.correctAnswers == dayProgress.totalQuestions) {
      final perfectDayBadge = CampBadge(
        id: 'perfect_day_$completedDayNumber',
        title: CampServiceTexts.kPerfectDayTitle(completedDayNumber),
        description: CampServiceTexts.kPerfectDayDesc(completedDayNumber),
        iconPath: 'assets/images/badges/perfect_day.png',
        earnedDate: DateTime.now(),
      );
      
      _userProgress!.earnedBadges = [..._userProgress!.earnedBadges, perfectDayBadge];
    }
    
    // Yarıyol rozeti (5. gün tamamlandığında)
    if (completedDayNumber == 5) {
      final halfwayBadge = CampBadge(
        id: 'halfway',
        title: CampServiceTexts.kHalfwayTitle,
        description: CampServiceTexts.kHalfwayDesc,
        iconPath: 'assets/images/badges/halfway.png',
        earnedDate: DateTime.now(),
      );
      
      _userProgress!.earnedBadges = [..._userProgress!.earnedBadges, halfwayBadge];
    }
  }
  
  // Kamp tamamlama rozeti ekle
  void _addCompletionBadge() {
    if (_userProgress == null) return;
    
    // Kamp tamamlama rozeti
    final completionBadge = CampBadge(
      id: 'camp_complete',
      title: CampServiceTexts.kCampCompletedTitle,
      description: CampServiceTexts.kCampCompletedDesc,
      iconPath: 'assets/images/badges/camp_complete.png',
      earnedDate: DateTime.now(),
    );
    
    _userProgress!.earnedBadges = [..._userProgress!.earnedBadges, completionBadge];
    
    // Mükemmel tamamlama (10/10 gün)
    if (_userProgress!.isPerfectCompletion) {
      final perfectBadge = CampBadge(
        id: 'perfect_camp',
        title: CampServiceTexts.kPerfectCampTitle,
        description: CampServiceTexts.kPerfectCampDesc,
        iconPath: 'assets/images/badges/perfect_camp.png',
        earnedDate: DateTime.now(),
      );
      
      _userProgress!.earnedBadges = [..._userProgress!.earnedBadges, perfectBadge];
    }
  }
  
  // Kampı sıfırla
  Future<void> resetCamp() async {
    if (!_isInitialized) {
      throw Exception(CampServiceTexts.kServiceNotInitialized);
    }
    
    // Kamp planını varsayılana döndür
    _campPlan = await CampPlan.createDefaultWithLocale(_currentLocale);
    
    // Kullanıcı ilerlemesini temizle
    _userProgress = null;
    
    // Değişiklikleri kaydet
    await _saveCampPlan();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userProgressKey);
  }
  
  // Belirli bir günü getir
  CampDay? getDayByNumber(int dayNumber) {
    if (!_isInitialized) {
      throw Exception(CampServiceTexts.kServiceNotInitialized);
    }
    
    return _campPlan.getDayByNumber(dayNumber);
  }
  
  // Aktif günü getir (tamamlanmamış ve kilit açık en düşük gün numarası)
  CampDay? getActiveDay() {
    if (!_isInitialized || _userProgress == null) {
      throw Exception(CampServiceTexts.kCampNotStarted);
    }
    
    // Önce kilidi açık ve tamamlanmamış ilk günü bul
    for (int i = 1; i <= _campPlan.durationDays; i++) {
      final day = _campPlan.getDayByNumber(i);
      
      // Günün kilidinin açık olduğunu ve tamamlanmadığını kontrol et
      if (day != null && !day.isLocked && 
          (_userProgress!.dayProgress.containsKey(i) && 
           !_userProgress!.dayProgress[i]!.isCompleted)) {
        return day;
      }
    }
    
    // Kilidi açık herhangi bir günü bul (tamamlanmış olsa bile)
    for (int i = 1; i <= _campPlan.durationDays; i++) {
      final day = _campPlan.getDayByNumber(i);
      if (day != null && !day.isLocked) {
        return day;
      }
    }
    
    // Tüm günler tamamlandıysa veya kilitlendiyse ilk günü döndür
    return _campPlan.getDayByNumber(1);
  }
  
  // Belirli bir günün aktivite tamamlanma durumunu güncelle
  Future<bool> updateActivityCompletion(int dayNumber, String activityTitle, bool isCompleted) async {
    try {
    if (!_isInitialized) {
      throw Exception(CampServiceTexts.kServiceNotInitialized);
    }
    
    final day = _campPlan.getDayByNumber(dayNumber);
    if (day == null) {
      print(CampServiceTexts.kDayNotFound(dayNumber));
      return false;
    }
    
    // Günün aktivitelerinde istenen başlığa sahip aktiviteyi bul
    final activityIndex = day.activities.indexWhere((a) => a.title == activityTitle);
    if (activityIndex == -1) {
      print(CampServiceTexts.kActivityNotFound(activityTitle));
      return false;
    }
    
    // Aktivite tamamlanma durumunu güncelle
    final updatedActivity = day.activities[activityIndex];
    updatedActivity.isCompleted = isCompleted;
    
    // CampDay nesnesinde aktiviteyi güncelle
    final dayIndex = _campPlan.days.indexOf(day);
    final updatedActivities = List<CampActivity>.from(day.activities);
    updatedActivities[activityIndex] = updatedActivity;
    
    // Güncellenmiş aktiviteler listesiyle günü yeniden oluştur
    _campPlan.days[dayIndex] = day.copyWith(
      activities: updatedActivities
    );
    
    // Değişiklikleri kaydet
    await _saveCampPlan();
    
    // Günde tüm aktiviteler tamamlandıysa günün ilerlemesini güncelle
    final allActivitiesCompleted = _campPlan.days[dayIndex].activities.every((a) => a.isCompleted);
    if (allActivitiesCompleted && _userProgress != null && _userProgress!.dayProgress.containsKey(dayNumber)) {
      // Tüm aktivitelerin tamamlandığını göster
      print(CampServiceTexts.kAllActivitiesCompleted(dayNumber));
      
      // Günlük ilerlemeyi al ve güncelle
      if (_userProgress!.dayProgress[dayNumber]!.completedDate == null) {
        // Sadece eğer daha önce tamamlanmadıysa güncelle
        final totalCorrect = _calculateTotalCorrectForCompletedActivities(day);
        if (totalCorrect > 0) {
          await completeDay(dayNumber, totalCorrect, []);
        }
      }
    }
    
    return true;
    } catch (e) {
      print('${CampServiceTexts.kUpdateActivityError} $e');
      return false;
    }
  }
  
  // Tamamlanan aktivitelere göre toplam doğru sayısını hesapla
  int _calculateTotalCorrectForCompletedActivities(CampDay day) {
    int totalQuestions = 0;
    int estimatedCorrect = 0;
    
    for (var activity in day.activities) {
      if (activity.isCompleted) {
        totalQuestions += activity.questionCount;
        // Tahmin edilen doğru sayısı (tamamlanmış aktiviteler için en az %80 başarı gerekiyor)
        // %70 yerine %80 kullanarak daha gerçekçi bir puan hesaplaması yapıyoruz
        estimatedCorrect += (activity.questionCount * 0.8).ceil();
      }
    }
    
    // Günün toplam soru sayısına ölçeklendirme
    if (totalQuestions > 0 && totalQuestions != day.totalQuestions) {
      return (estimatedCorrect * day.totalQuestions / totalQuestions).ceil();
    }
    
    return estimatedCorrect;
  }
  
  // Günlük ilerleme ve aktivite tamamlama durumunu güncelleme
  Future<void> syncProgressWithActivities() async {
    if (_userProgress == null || !_isInitialized) return;
    
    try {
      // Her gün için aktivite durumlarını kontrol et
      for (var day in _campPlan.days) {
        if (_userProgress!.dayProgress.containsKey(day.dayNumber)) {
          final dayProgress = _userProgress!.dayProgress[day.dayNumber]!;
          
          // Gün tamamlandıysa, tüm aktiviteleri tamamla
          if (dayProgress.isCompleted) {
            bool anyUpdated = false;
            for (var activity in day.activities) {
              if (!activity.isCompleted) {
                // Aktiviteyi tamamla
                activity.isCompleted = true;
                anyUpdated = true;
              }
            }
            
            // Değişiklik varsa kaydet
            if (anyUpdated) {
              await _saveCampPlan();
            }
          } else {
            // Gün tamamlanmadıysa, tüm aktiviteler tamamlandı mı kontrol et
            bool allActivitiesCompleted = day.activities.every((a) => a.isCompleted);
            
            if (allActivitiesCompleted && !dayProgress.isCompleted && day.activities.isNotEmpty) {
              // Tüm aktiviteler tamamlandı ancak gün henüz tamamlanmadı
              // Günü tamamla
              final totalCorrect = _calculateTotalCorrectForCompletedActivities(day);
              if (totalCorrect > 0) {
                print(CampServiceTexts.kCompletingDayFromActivities(day.dayNumber, totalCorrect));
                await completeDay(day.dayNumber, totalCorrect, []);
              }
            }
          }
        }
      }
    } catch (e) {
      print('${CampServiceTexts.kSyncProgressError} $e');
    }
  }
  
  /// Premium kamp moduna erişim kontrolü
  Future<bool> canAccessCampMode() async {
    return await RevenueCatService.isPremiumUser();
  }
  
  /// Belirli bir güne erişim kontrolü
  Future<bool> canAccessDay(int dayNumber) async {
    // İlk 2 gün ücretsiz (free trial)
    if (dayNumber <= 2) return true;
    
    // Geri kalan günler premium gerektirir
    return await RevenueCatService.isPremiumUser();
  }
  
  /// Premium durumunu kontrol et ve bildirim gönder
  Future<void> checkPremiumStatus() async {
    // Bu metod UI'dan çağrılabilir, premium durum değişikliklerini dinlemek için
    final isPremium = await RevenueCatService.isPremiumUser();
    print('Current premium status: $isPremium');
  }
  
  /// Günlerin kilit durumunu premium duruma göre güncelle
  Future<void> updateDayLocksBasedOnPremium() async {
    final isPremium = await RevenueCatService.isPremiumUser();
    
    // Premium değilse 3. günden sonraki günleri kilitle
    for (var day in _campPlan.days) {
      if (day.dayNumber > 2 && !isPremium) {
        // Premium olmayan kullanıcılar için kilitle
        final index = _campPlan.days.indexOf(day);
        _campPlan.days[index] = day.copyWith(isLocked: true);
      } else if (day.dayNumber <= 2) {
        // İlk 2 gün her zaman açık
        final index = _campPlan.days.indexOf(day);
        _campPlan.days[index] = day.copyWith(isLocked: false);
      } else if (isPremium) {
        // Premium kullanıcılar için normal kilit mantığını kullan
        final index = _campPlan.days.indexOf(day);
        _campPlan.days[index] = day.copyWith(isLocked: !_isUnlocked(day.dayNumber));
      }
    }
    
    await _saveCampPlan();
  }
  
  // Dili güncelle
  Future<void> updateLocale(Locale locale) async {
    _currentLocale = locale;
    
    // Global localizations provider'ı güncelle
    await appLocalizationsProvider.updateLocale(locale);
    
    // Kullanıcı ilerleme verilerini sakla
    Map<int, CampDayProgress>? existingProgress;
    if (_userProgress != null) {
      existingProgress = Map.from(_userProgress!.dayProgress);
    }
    
    // Kamp planını yeniden oluşturma (verileri kaybetmeden)
    if (_isInitialized) {
      print('Updating camp plan for locale: ${locale.languageCode}');
      
      // Verileri korumak için günlerin ve aktivitelerin durumlarını kaydediyoruz
      final dayLockStatuses = <int, bool>{};
      final dayCompletedDates = <int, DateTime?>{};
      final dayCorrectAnswers = <int, int>{};
      final activityCompletionStatus = <int, Map<String, bool>>{};
      
      // Önemli verileri yedekle
      for (var day in _campPlan.days) {
        dayLockStatuses[day.dayNumber] = day.isLocked;
        dayCompletedDates[day.dayNumber] = day.completedDate;
        dayCorrectAnswers[day.dayNumber] = day.correctAnswers;
        
        // Aktivite tamamlanma durumlarını da kayıt altına al
        // Gün numarasına göre aktivite durumlarını saklayan bir harita oluştur
        final activityStatus = <String, bool>{};
        for (var activity in day.activities) {
          // Aktivitenin index'ini veya benzersiz bir tanımlayıcısını kullanarak eşleştireceğiz
          // Böylece aynı konumdaki aktiviteleri eşleştireceğiz
          activityStatus['${activity.period}_${day.activities.indexOf(activity)}'] = activity.isCompleted;
        }
        activityCompletionStatus[day.dayNumber] = activityStatus;
      }
      
      // Tamamen yeni bir kamp planı oluştur (tüm metinler lokalize olacak)
      final newCampPlan = await CampPlan.createDefaultWithLocale(locale);
      
      // Önceki verileri yeni plan ile birleştir
      final updatedDays = <CampDay>[];
      for (var newDay in newCampPlan.days) {
        if (dayLockStatuses.containsKey(newDay.dayNumber)) {
          // Aktivitelerin tamamlanma durumlarını eşleştirerek koru
          final newActivities = <CampActivity>[];
          for (var i = 0; i < newDay.activities.length; i++) {
            var newActivity = newDay.activities[i];
            final periodKey = '${newActivity.period}_$i';
            final wasCompleted = activityCompletionStatus[newDay.dayNumber]?[periodKey] ?? false;
            
            // Yeni aktiviteyi kopyala ve tamamlanma durumunu güncelle
            newActivities.add(CampActivity(
              period: newActivity.period,
              title: newActivity.title,
              description: newActivity.description,
              questionCount: newActivity.questionCount,
              categories: newActivity.categories,
              isCompleted: wasCompleted
            ));
          }
          
          // Günü, aktiviteler dahil tamamen yeniden oluştur
          updatedDays.add(CampDay(
            dayNumber: newDay.dayNumber,
            title: newDay.title,  // Yeni lokalize başlık
            description: newDay.description,  // Yeni lokalize açıklama
            activities: newActivities,  // Tamamlanma durumları korunmuş aktiviteler 
            totalQuestions: newDay.totalQuestions,
            targetCorrect: newDay.targetCorrect,
            difficulty: newDay.difficulty,  // Yeni lokalize zorluk seviyesi
            materialUrl: newDay.materialUrl,
            completedDate: dayCompletedDates[newDay.dayNumber],
            correctAnswers: dayCorrectAnswers[newDay.dayNumber] ?? 0,
            isLocked: dayLockStatuses[newDay.dayNumber]!
          ));
        } else {
          updatedDays.add(newDay);
        }
      }
      
      // Yeni kamp planını kaydedip servisi yeniden başlat
      _campPlan = CampPlan(
        id: newCampPlan.id,
        title: newCampPlan.title,
        description: newCampPlan.description,
        durationDays: newCampPlan.durationDays,
        minCompletionDays: newCampPlan.minCompletionDays,
        badges: newCampPlan.badges,
        days: updatedDays
      );
      
      // Kullanıcı ilerleme verilerini geri yükle
      if (existingProgress != null && _userProgress != null) {
        // dayProgress final olduğu için doğrudan atama yapamayız
        // Bunun yerine önce mevcut içeriği temizliyoruz
        _userProgress!.dayProgress.clear();
        // Sonra tüm günleri tek tek ekliyoruz
        existingProgress.forEach((key, value) {
          _userProgress!.dayProgress[key] = value;
        });
      }
      
      // Değişiklikleri kaydet
      await _saveCampPlan();
      if (_userProgress != null) {
        await _saveUserProgress();
      }
      
      // Aktivite ve ilerleme durumlarını senkronize et
      await syncProgressWithActivities();
      
      print('Camp plan updated successfully for locale: ${locale.languageCode}');
    }
  }
}