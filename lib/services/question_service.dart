import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/question.dart';

class QuestionService {
  List<Question> _questions = [];
  bool _isInitialized = false;
  final Random _random = Random();

  /// Tüm soruları döndürür
  List<Question> getAllQuestions() {
    return _questions;
  }

  /// Daha önce cevaplanmamış soruları döndürür
  List<Question> getUnansweredQuestions() {
    return _questions.where((q) => !q.isAttempted).toList();
  }

  /// Doğru cevaplanan soruları döndürür
  List<Question> getCorrectAnsweredQuestions() {
    return _questions.where((q) => q.isMarkedCorrect).toList();
  }

  /// Yanlış cevaplanan soruları döndürür
  List<Question> getIncorrectAnsweredQuestions() {
    return _questions.where((q) => q.isAttempted && !q.isMarkedCorrect).toList();
  }

  /// Belirli bir kategorideki soruları döndürür
  List<Question> getQuestionsByCategory(String category) {
    return _questions.where((q) => q.category == category).toList();
  }

  /// Kategori listesine göre filtrelenmiş soruları döndürür
  List<Question> getQuestionsByCategories(List<String> categories) {
    return _questions.where((q) => categories.contains(q.category)).toList();
  }

  /// Kategori listesine göre cevaplanmamış soruları döndürür
  List<Question> getUnansweredQuestionsByCategories(List<String> categories) {
    return _questions.where((q) => 
        !q.isAttempted && categories.contains(q.category)).toList();
  }

  /// Kategori listesine göre yanlış cevaplanan soruları döndürür
  List<Question> getIncorrectAnsweredQuestionsByCategories(List<String> categories) {
    return _questions.where((q) =>
        q.isAttempted && 
        !q.isMarkedCorrect && 
        categories.contains(q.category)).toList();
  }

  /// Rastgele n adet soru döndürür
  List<Question> getRandomQuestions(int count) {
    if (_questions.isEmpty) return [];
    
    List<Question> availableQuestions = List.from(_questions);
    availableQuestions.shuffle();
    
    return availableQuestions
        .take(min(count, availableQuestions.length))
        .map((q) => _prepareQuestionForQuiz(q))
        .toList();
  }

  /// Kategori listesine göre rastgele n adet soru döndürür
  List<Question> getRandomQuestionsByCategories(int count, List<String> categories) {
    // Önce kategori filtresine uyan soruları al
    final filteredQuestions = _questions.where(
      (q) => categories.contains(q.category)
    ).toList();
    
    if (filteredQuestions.isEmpty) return [];
    
    // Soruları karıştır
    filteredQuestions.shuffle();
    
    // En fazla istenen sayıda soruyu al
    return filteredQuestions
        .take(min(count, filteredQuestions.length))
        .map((q) => _prepareQuestionForQuiz(q))
        .toList();
  }

  /// Quizler için soruları hazırla (maksimum 4 seçenek)
  Question _prepareQuestionForQuiz(Question question) {
    // Doğru cevap içeren seçenekleri bul
    List<Option> correctOptions = question.options
        .where((o) => o.isCorrect)
        .toList();
    
    // Eğer doğru cevap yoksa, orijinal soruyu döndür
    if (correctOptions.isEmpty) return question;
    
    // Doğru cevaplardan birini rastgele seç
    Option selectedCorrectOption = correctOptions[
        _random.nextInt(correctOptions.length)
    ];
    
    // Yanlış cevapları bul
    List<Option> incorrectOptions = question.options
        .where((o) => !o.isCorrect)
        .toList();
    incorrectOptions.shuffle();
    
    // Maksimum 3 yanlış seçenek al (toplam 4 şık olacak şekilde)
    incorrectOptions = incorrectOptions.take(3).toList();
    
    // Tüm seçenekleri birleştir ve karıştır
    List<Option> quizOptions = [...incorrectOptions, selectedCorrectOption];
    quizOptions.shuffle();
    
    // Yeni soru oluştur
    return question.copyWith(options: quizOptions);
  }

  /// Soruları JSON dosyasından yükler
  Future<void> loadQuestions() async {
    if (_isInitialized) return;
    
    try {
      // JSON dosyasını oku
      final String jsonString = await rootBundle.loadString('assets/questions.json');
      
      final List<dynamic> jsonData = json.decode(jsonString);
      
      // JSON verilerini Question nesnelerine dönüştür
      _questions = jsonData
          .map<Question>((json) => Question.fromJson(json))
          .toList();
      
      _isInitialized = true;
      
      print('Toplam ${_questions.length} soru yüklendi');
    } catch (e) {
      print('Soru yükleme hatası: $e');
      _isInitialized = false;
      throw Exception('Sorular yüklenirken hata oluştu: $e');
    }
  }

  /// Sorunun cevabını işle ve durumunu güncelle
  void answerQuestion(int questionId, String selectedAnswer) {
    final index = _questions.indexWhere((q) => q.id == questionId);
    if (index == -1) return;
    
    final question = _questions[index];
    final isCorrect = question.isCorrectAnswer(selectedAnswer);
    
    // Soruyu güncelle
    _questions[index] = question.copyWith(
      isAttempted: true,
      isMarkedCorrect: isCorrect,
      selectedAnswer: selectedAnswer,
    );
  }

  /// Soruları sıfırla (tüm cevapları temizle)
  void resetAllAnswers() {
    _questions = _questions.map((q) => q.copyWith(
      isAttempted: false,
      isMarkedCorrect: false,
      selectedAnswer: null,
    )).toList();
  }

  /// Kullanıcının ilerlemesini hesaplar ve yüzde olarak döndürür
  double getProgressPercentage() {
    if (_questions.isEmpty) return 0.0;
    
    int attemptedCount = _questions.where((q) => q.isAttempted).length;
    return attemptedCount / _questions.length;
  }

  /// Doğru cevap oranını hesaplar ve yüzde olarak döndürür
  double getCorrectAnswerRate() {
    final attempted = _questions.where((q) => q.isAttempted).toList();
    if (attempted.isEmpty) return 0.0;
    
    final correctCount = attempted.where((q) => q.isMarkedCorrect).length;
    return correctCount / attempted.length;
  }

  /// Singleton pattern
  static final QuestionService _instance = QuestionService._internal();
  
  factory QuestionService() {
    return _instance;
  }
  
  QuestionService._internal();
}