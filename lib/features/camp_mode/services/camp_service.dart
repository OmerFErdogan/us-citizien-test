import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:us_civics_test_app/models/question.dart';
import '../models/camp_day.dart';
import '../models/camp_progress.dart';
import '../models/camp_plan.dart';
import '../../../services/question_service.dart';

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
  
  // Sabitleri
  static const String _campPlanKey = 'camp_plan';
  static const String _userProgressKey = 'user_camp_progress';
  
  // Servisi başlat
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _questionService.loadQuestions();
      await _loadCampPlan();
      await _loadUserProgress();
      _isInitialized = true;
    } catch (e) {
      print('Kamp servisi başlatılırken hata: $e');
      _isInitialized = false;
      rethrow;
    }
  }
  
  // Kamp planını yükle
  Future<void> _loadCampPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final campPlanJson = prefs.getString(_campPlanKey);
    
    if (campPlanJson != null) {
      _campPlan = CampPlan.fromJson(jsonDecode(campPlanJson));
    } else {
      // Varsayılan kamp planını oluştur
      _campPlan = CampPlan.createDefault();
      await _saveCampPlan();
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
  
  // Kamp planını kaydet
  Future<void> _saveCampPlan() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_campPlanKey, jsonEncode(_campPlan.toJson()));
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
      throw Exception('Kamp servisi başlatılmadı. Önce initialize() metodunu çağırın.');
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
      throw Exception('Kamp servisi başlatılmadı. Önce initialize() metodunu çağırın.');
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
      throw Exception('Kamp başlatılmadı veya servis başlatılmadı.');
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
          print('Gün $nextDayNumber kilidini açtı');
          
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
      throw Exception('Kamp servisi başlatılmadı. Önce initialize() metodunu çağırın.');
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
      title: '$completedDayNumber. Gün Tamamlandı',
      description: '$completedDayNumber. günün çalışmasını başarıyla tamamladınız!',
      iconPath: 'assets/images/badges/day_complete_$completedDayNumber.png',
      earnedDate: DateTime.now(),
    );
    
    _userProgress!.earnedBadges = [..._userProgress!.earnedBadges, dayBadge];
    
    // Mükemmel gün rozeti (tüm soruları doğru cevapladıysa)
    final dayProgress = _userProgress!.dayProgress[completedDayNumber]!;
    if (dayProgress.correctAnswers == dayProgress.totalQuestions) {
      final perfectDayBadge = CampBadge(
        id: 'perfect_day_$completedDayNumber',
        title: 'Mükemmel $completedDayNumber. Gün',
        description: '$completedDayNumber. günün tüm sorularını doğru cevapladınız!',
        iconPath: 'assets/images/badges/perfect_day.png',
        earnedDate: DateTime.now(),
      );
      
      _userProgress!.earnedBadges = [..._userProgress!.earnedBadges, perfectDayBadge];
    }
    
    // Yarıyol rozeti (5. gün tamamlandığında)
    if (completedDayNumber == 5) {
      final halfwayBadge = CampBadge(
        id: 'halfway',
        title: 'Yarı Yolu Tamamladınız',
        description: 'Kampın yarısını başarıyla tamamladınız!',
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
      title: 'Kamp Tamamlandı',
      description: 'Tebrikler! 10 Günlük Vatandaşlık Kampını başarıyla tamamladınız.',
      iconPath: 'assets/images/badges/camp_complete.png',
      earnedDate: DateTime.now(),
    );
    
    _userProgress!.earnedBadges = [..._userProgress!.earnedBadges, completionBadge];
    
    // Mükemmel tamamlama (10/10 gün)
    if (_userProgress!.isPerfectCompletion) {
      final perfectBadge = CampBadge(
        id: 'perfect_camp',
        title: 'Mükemmel Kamp',
        description: 'İnanılmaz! Kampın tüm 10 gününü başarıyla tamamladınız.',
        iconPath: 'assets/images/badges/perfect_camp.png',
        earnedDate: DateTime.now(),
      );
      
      _userProgress!.earnedBadges = [..._userProgress!.earnedBadges, perfectBadge];
    }
  }
  
  // Kampı sıfırla
  Future<void> resetCamp() async {
    if (!_isInitialized) {
      throw Exception('Kamp servisi başlatılmadı. Önce initialize() metodunu çağırın.');
    }
    
    // Kamp planını varsayılana döndür
    _campPlan = CampPlan.createDefault();
    
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
      throw Exception('Kamp servisi başlatılmadı. Önce initialize() metodunu çağırın.');
    }
    
    return _campPlan.getDayByNumber(dayNumber);
  }
  
  // Aktif günü getir (tamamlanmamış ve kilit açık en düşük gün numarası)
  CampDay? getActiveDay() {
    if (!_isInitialized || _userProgress == null) {
      throw Exception('Kamp başlatılmadı veya servis başlatılmadı.');
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
      throw Exception('Kamp servisi başlatılmadı. Önce initialize() metodunu çağırın.');
    }
    
    final day = _campPlan.getDayByNumber(dayNumber);
    if (day == null) {
      print('Gün $dayNumber bulunamadı');
      return false;
    }
    
    // Günün aktivitelerinde istenen başlığa sahip aktiviteyi bul
    final activityIndex = day.activities.indexWhere((a) => a.title == activityTitle);
    if (activityIndex == -1) {
      print('"$activityTitle" başlıklı aktivite bulunamadı.');
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
      print('Gün $dayNumber için tüm aktiviteler tamamlandı!');
      
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
      print('Aktivite tamamlama durumu güncellenirken hata: $e');
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
                print('Tüm aktiviteler tamamlandı, günü tamamlama işlemi başlatılıyor: Gün=${day.dayNumber}, Hesaplanan Puan=$totalCorrect');
                await completeDay(day.dayNumber, totalCorrect, []);
              }
            }
          }
        }
      }
    } catch (e) {
      print('İlerleme ve aktivite durumu senkronize edilirken hata: $e');
    }
  }
}