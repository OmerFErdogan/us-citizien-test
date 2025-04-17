import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/interview_models.dart';
import '../../../services/question_service.dart';

/// Mülakat simülasyonu servis sınıfı
class InterviewService {
  static const String _sessionStorageKey = 'interview_sessions';
  static const String _settingsStorageKey = 'interview_settings';
  
  final Random _random = Random();
  late QuestionService _questionService;
  List<InterviewQuestion> _interviewQuestions = [];
  List<InterviewQuestion> _personalQuestions = [];
  List<InterviewQuestion> _n400Questions = [];
  List<InterviewQuestion> _englishReadingQuestions = [];
  List<InterviewQuestion> _englishWritingQuestions = [];
  
  List<UscisOfficer> _officers = [];
  late UscisOfficer _currentOfficer;
  
  List<InterviewSession> _pastSessions = [];
  InterviewSettings _currentSettings = const InterviewSettings();
  
  /// Servis başlatma
  Future<void> initialize(QuestionService questionService) async {
    _questionService = questionService;
    
    await _loadOfficers();
    await _loadQuestions();
    await _loadSettings();
    await _loadPastSessions();
    
    // Rastgele bir memur seç
    _selectRandomOfficer();
  }
  
  /// Memurları yükle
  Future<void> _loadOfficers() async {
    // Demo memurlar - gerçek uygulamada bir API veya JSON dosyasından yüklenebilir
    _officers = [
      const UscisOfficer(
        name: 'Sarah Johnson',
        avatarImagePath: 'assets/images/officers/officer_female_1.png',
        position: 'Immigration Services Officer',
      ),
      const UscisOfficer(
        name: 'Michael Rodriguez',
        avatarImagePath: 'assets/images/officers/officer_male_1.png',
        position: 'Field Office Director',
      ),
      const UscisOfficer(
        name: 'David Chen',
        avatarImagePath: 'assets/images/officers/officer_male_2.png',
        position: 'Immigration Services Officer',
      ),
      const UscisOfficer(
        name: 'Emily Wilson',
        avatarImagePath: 'assets/images/officers/officer_female_2.png',
        position: 'Supervisory Immigration Officer',
      ),
    ];
  }
  
  /// Rastgele memur seçimi
  void _selectRandomOfficer() {
    if (_officers.isNotEmpty) {
      _currentOfficer = _officers[_random.nextInt(_officers.length)];
    } else {
      // Fallback memur
      _currentOfficer = const UscisOfficer(
        name: 'Officer Smith',
        avatarImagePath: 'assets/images/officers/default_officer.png',
        position: 'Immigration Services Officer',
      );
    }
  }
  
  /// Soruları yükle
  Future<void> _loadQuestions() async {
    // 1. Vatandaşlık sınavı sorularını QuestionService'den al
    final civicsQuestions = _questionService.getAllQuestions();
    
    // Her bir soruyu InterviewQuestion formatına dönüştür
    _interviewQuestions = civicsQuestions.map((q) {
      // Doğru cevap seçeneklerini bul
      final correctOptions = q.options
          .where((option) => option.isCorrect)
          .map((option) => option.text)
          .toList();
      
      return InterviewQuestion(
        id: q.id.toString(),
        question: q.question,
        acceptableAnswers: correctOptions,
        type: InterviewQuestionType.civics,
        audioPath: 'assets/audio/questions/${q.id}.mp3', // Varsayılan ses dosyası yolu
      );
    }).toList();
    
    // 2. Kişisel sorular - normalde bir JSON dosyasından yüklenirdi
    _personalQuestions = [
      const InterviewQuestion(
        id: 'p1',
        question: 'What is your full legal name?',
        acceptableAnswers: [], // Kişisel sorularda herhangi bir yanıt kabul edilebilir
        type: InterviewQuestionType.personal,
      ),
      const InterviewQuestion(
        id: 'p2',
        question: 'When and where were you born?',
        acceptableAnswers: [],
        type: InterviewQuestionType.personal,
      ),
      const InterviewQuestion(
        id: 'p3',
        question: 'What is your current address?',
        acceptableAnswers: [],
        type: InterviewQuestionType.personal,
      ),
      const InterviewQuestion(
        id: 'p4',
        question: 'How long have you been living at your current address?',
        acceptableAnswers: [],
        type: InterviewQuestionType.personal,
      ),
      const InterviewQuestion(
        id: 'p5',
        question: 'Do you work? Where do you work?',
        acceptableAnswers: [],
        type: InterviewQuestionType.personal,
      ),
    ];
    
    // 3. N-400 formu soruları - normalde bir JSON dosyasından yüklenirdi
    _n400Questions = [
      const InterviewQuestion(
        id: 'n1',
        question: 'Have you ever claimed to be a U.S. citizen?',
        acceptableAnswers: ['No', 'No, I have not'],
        type: InterviewQuestionType.n400,
      ),
      const InterviewQuestion(
        id: 'n2',
        question: 'Have you ever registered to vote in any Federal, state, or local election in the United States?',
        acceptableAnswers: ['No', 'No, I have not'],
        type: InterviewQuestionType.n400,
      ),
      const InterviewQuestion(
        id: 'n3',
        question: 'Do you owe any overdue Federal, state, or local taxes?',
        acceptableAnswers: ['No', 'No, I do not'],
        type: InterviewQuestionType.n400,
      ),
      const InterviewQuestion(
        id: 'n4',
        question: 'Have you ever been a member of, or associated with, any organization, association, fund, foundation, party, club, society, or similar group in the United States or in any other location in the world?',
        acceptableAnswers: [],
        type: InterviewQuestionType.n400,
      ),
      const InterviewQuestion(
        id: 'n5',
        question: 'Have you ever been a member of the Communist Party?',
        acceptableAnswers: ['No', 'No, I have not'],
        type: InterviewQuestionType.n400,
      ),
    ];
    
    // 4. İngilizce okuma soruları
    _englishReadingQuestions = [
      const InterviewQuestion(
        id: 'r1',
        question: 'Please read this sentence: "Abraham Lincoln was the president during the Civil War."',
        acceptableAnswers: ['Abraham Lincoln was the president during the Civil War.'],
        type: InterviewQuestionType.englishReading,
      ),
      const InterviewQuestion(
        id: 'r2',
        question: 'Please read this sentence: "The United States has fifty states."',
        acceptableAnswers: ['The United States has fifty states.'],
        type: InterviewQuestionType.englishReading,
      ),
      const InterviewQuestion(
        id: 'r3',
        question: 'Please read this sentence: "George Washington was the first president."',
        acceptableAnswers: ['George Washington was the first president.'],
        type: InterviewQuestionType.englishReading,
      ),
    ];
    
    // 5. İngilizce yazma soruları
    _englishWritingQuestions = [
      const InterviewQuestion(
        id: 'w1',
        question: 'Please write this sentence: "The president lives in the White House."',
        acceptableAnswers: ['The president lives in the White House.'],
        type: InterviewQuestionType.englishWriting,
      ),
      const InterviewQuestion(
        id: 'w2',
        question: 'Please write this sentence: "Independence Day is in July."',
        acceptableAnswers: ['Independence Day is in July.'],
        type: InterviewQuestionType.englishWriting,
      ),
      const InterviewQuestion(
        id: 'w3',
        question: 'Please write this sentence: "Citizens have the right to vote."',
        acceptableAnswers: ['Citizens have the right to vote.'],
        type: InterviewQuestionType.englishWriting,
      ),
    ];
  }
  
  /// Mülakat ayarlarını yükle
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsStorageKey);
      
      if (settingsJson != null) {
        final Map<String, dynamic> settingsMap = jsonDecode(settingsJson);
        
        _currentSettings = InterviewSettings(
          useStrictMode: settingsMap['useStrictMode'] ?? false,
          useTimedResponses: settingsMap['useTimedResponses'] ?? false,
          includePersonalQuestions: settingsMap['includePersonalQuestions'] ?? true,
          includeN400Questions: settingsMap['includeN400Questions'] ?? true,
          questionCount: settingsMap['questionCount'] ?? 10,
          useAudio: settingsMap['useAudio'] ?? true,
          useVoiceInput: settingsMap['useVoiceInput'] ?? false,
        );
      }
    } catch (e) {
      print('Mülakat ayarlarını yükleme hatası: $e');
      // Varsayılan ayarları kullan
      _currentSettings = const InterviewSettings();
    }
  }
  
  /// Ayarları kaydet
  Future<void> saveSettings(InterviewSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final settingsMap = {
        'useStrictMode': settings.useStrictMode,
        'useTimedResponses': settings.useTimedResponses,
        'includePersonalQuestions': settings.includePersonalQuestions,
        'includeN400Questions': settings.includeN400Questions,
        'questionCount': settings.questionCount,
        'useAudio': settings.useAudio,
        'useVoiceInput': settings.useVoiceInput,
      };
      
      await prefs.setString(_settingsStorageKey, jsonEncode(settingsMap));
      _currentSettings = settings;
    } catch (e) {
      print('Mülakat ayarlarını kaydetme hatası: $e');
    }
  }
  
  /// Geçmiş oturumları yükle
  Future<void> _loadPastSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getString(_sessionStorageKey);
      
      if (sessionsJson != null) {
        final List<dynamic> sessionsList = jsonDecode(sessionsJson);
        
        _pastSessions = sessionsList.map((session) {
          final responses = (session['responses'] as List)
              .map((r) => InterviewResponse(
                    questionId: r['questionId'],
                    userResponse: r['userResponse'],
                    isCorrect: r['isCorrect'],
                    timestamp: DateTime.parse(r['timestamp']),
                    responseTimeInSeconds: r['responseTimeInSeconds'],
                    officerFeedback: r['officerFeedback'],
                  ))
              .toList();
              
          return InterviewSession(
            id: session['id'],
            date: DateTime.parse(session['date']),
            totalQuestions: session['totalQuestions'],
            correctAnswers: session['correctAnswers'],
            settings: InterviewSettings(
              useStrictMode: session['settings']['useStrictMode'] ?? false,
              useTimedResponses: session['settings']['useTimedResponses'] ?? false,
              includePersonalQuestions: session['settings']['includePersonalQuestions'] ?? true,
              includeN400Questions: session['settings']['includeN400Questions'] ?? true,
              questionCount: session['settings']['questionCount'] ?? 10,
              useAudio: session['settings']['useAudio'] ?? true,
              useVoiceInput: session['settings']['useVoiceInput'] ?? false,
            ),
            responses: responses,
            isCompleted: session['isCompleted'],
            durationInMinutes: session['durationInMinutes'],
            officerName: session['officerName'],
          );
        }).toList();
      }
    } catch (e) {
      print('Geçmiş oturumları yükleme hatası: $e');
      _pastSessions = [];
    }
  }
  
  /// Oturumu kaydet
  Future<void> saveSession(InterviewSession session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Mevcut oturumları güncelle
      _pastSessions.add(session);
      
      // Oturumları JSON formatına dönüştür
      final sessionsList = _pastSessions.map((s) {
        final responsesMap = s.responses.map((r) => {
          'questionId': r.questionId,
          'userResponse': r.userResponse,
          'isCorrect': r.isCorrect,
          'timestamp': r.timestamp.toIso8601String(),
          'responseTimeInSeconds': r.responseTimeInSeconds,
          'officerFeedback': r.officerFeedback,
        }).toList();
        
        return {
          'id': s.id,
          'date': s.date.toIso8601String(),
          'totalQuestions': s.totalQuestions,
          'correctAnswers': s.correctAnswers,
          'settings': {
            'useStrictMode': s.settings.useStrictMode,
            'useTimedResponses': s.settings.useTimedResponses,
            'includePersonalQuestions': s.settings.includePersonalQuestions,
            'includeN400Questions': s.settings.includeN400Questions,
            'questionCount': s.settings.questionCount,
            'useAudio': s.settings.useAudio,
            'useVoiceInput': s.settings.useVoiceInput,
          },
          'responses': responsesMap,
          'isCompleted': s.isCompleted,
          'durationInMinutes': s.durationInMinutes,
          'officerName': s.officerName,
        };
      }).toList();
      
      await prefs.setString(_sessionStorageKey, jsonEncode(sessionsList));
    } catch (e) {
      print('Oturumu kaydetme hatası: $e');
    }
  }
  
  /// Mülakat için soru seti oluştur
  List<InterviewQuestion> generateInterviewQuestionSet() {
    final List<InterviewQuestion> questionSet = [];
    final settings = _currentSettings;
    
    // 1. Vatandaşlık soruları (her zaman dahil edilir)
    // Rastgele seçilen sorular
    final shuffledCivicsQuestions = List<InterviewQuestion>.from(_interviewQuestions)..shuffle(_random);
    
    // Toplam soru sayısının %60'ı vatandaşlık soruları olsun
    int civicsCount = (settings.questionCount * 0.6).ceil();
    civicsCount = min(civicsCount, shuffledCivicsQuestions.length);
    
    questionSet.addAll(shuffledCivicsQuestions.take(civicsCount));
    
    // 2. Kalan soruları diğer kategorilerden ekle
    int remainingCount = settings.questionCount - civicsCount;
    
    if (settings.includePersonalQuestions && remainingCount > 0) {
      final shuffledPersonal = List<InterviewQuestion>.from(_personalQuestions)..shuffle(_random);
      final personalCount = min(remainingCount ~/ 2, shuffledPersonal.length);
      questionSet.addAll(shuffledPersonal.take(personalCount));
      remainingCount -= personalCount;
    }
    
    if (settings.includeN400Questions && remainingCount > 0) {
      final shuffledN400 = List<InterviewQuestion>.from(_n400Questions)..shuffle(_random);
      final n400Count = min(remainingCount, shuffledN400.length);
      questionSet.addAll(shuffledN400.take(n400Count));
      remainingCount -= n400Count;
    }
    
    // 3. İngilizce okuma ve yazma soruları (her zaman 1'er tane)
    if (remainingCount > 0) {
      // Rastgele bir okuma sorusu
      final readingQuestion = _englishReadingQuestions[_random.nextInt(_englishReadingQuestions.length)];
      questionSet.add(readingQuestion);
      remainingCount--;
    }
    
    if (remainingCount > 0) {
      // Rastgele bir yazma sorusu
      final writingQuestion = _englishWritingQuestions[_random.nextInt(_englishWritingQuestions.length)];
      questionSet.add(writingQuestion);
      remainingCount--;
    }
    
    // Son listeyi karıştır (okuma/yazma soruları da dahil)
    questionSet.shuffle(_random);
    
    return questionSet;
  }
  
  /// Yanıtı değerlendir
  bool evaluateAnswer(InterviewQuestion question, String userResponse) {
    if (question.type == InterviewQuestionType.personal) {
      // Kişisel sorular her zaman doğru kabul edilir (çünkü kişisel bilgileri doğrulayamayız)
      return true;
    }
    
    // Boş yanıtı kontrol et
    if (userResponse.trim().isEmpty) {
      return false;
    }
    
    // N400 soruları veya civics soruları için olası yanıtları kontrol et
    if (question.acceptableAnswers.isNotEmpty) {
      // Sıkı mod açıksa, tam eşleşme ara
      if (_currentSettings.useStrictMode) {
        return question.acceptableAnswers.contains(userResponse.trim());
      } else {
        // Sıkı mod kapalıysa, kabul edilebilir cevaplardan biriyle kısmi eşleşme kontrol et
        final lowerUserResponse = userResponse.toLowerCase().trim();
        
        // En az bir kabul edilebilir cevapla kısmi eşleşme var mı?
        return question.acceptableAnswers.any((answer) {
          final lowerAnswer = answer.toLowerCase();
          
          // Kullanıcı cevabı, kabul edilebilir cevabın önemli kısımlarını içeriyor mu?
          // Veya kabul edilebilir cevap, kullanıcı cevabının içinde mi?
          return lowerUserResponse.contains(lowerAnswer) || 
                 lowerAnswer.contains(lowerUserResponse);
        });
      }
    }
    
    // Kabul edilebilir cevaplar boşsa veya diğer durumlar için
    return false;
  }
  
  /// Anlık memuru al
  UscisOfficer getCurrentOfficer() {
    return _currentOfficer;
  }
  
  /// Memuru değiştir
  void changeOfficer() {
    _selectRandomOfficer();
  }
  
  /// Mevcut ayarları al
  InterviewSettings getCurrentSettings() {
    return _currentSettings;
  }
  
  /// Geçmiş oturumları al
  List<InterviewSession> getPastSessions() {
    return _pastSessions;
  }
  
  /// Cevap için memur geri bildirimi oluştur
  String generateOfficerFeedback(bool isCorrect, InterviewQuestionType questionType) {
    if (isCorrect) {
      final correctResponses = [
        "That's correct.",
        "Yes, that's right.",
        "Good answer.",
        "Correct.",
        "That's the answer we're looking for.",
        "Very good.",
      ];
      return correctResponses[_random.nextInt(correctResponses.length)];
    } else {
      if (questionType == InterviewQuestionType.civics) {
        final incorrectResponses = [
          "That's not correct.",
          "I'm sorry, that's not right.",
          "That's not the answer we're looking for.",
          "You might want to review this topic.",
          "Let's move on to the next question.",
        ];
        return incorrectResponses[_random.nextInt(incorrectResponses.length)];
      } else if (questionType == InterviewQuestionType.englishReading || 
                questionType == InterviewQuestionType.englishWriting) {
        final incorrectResponses = [
          "Please try to pronounce/write that more clearly.",
          "Let's move to the next question.",
          "I need you to read/write that more clearly.",
        ];
        return incorrectResponses[_random.nextInt(incorrectResponses.length)];
      } else {
        return "Thank you for your response. Let's continue.";
      }
    }
  }
}
