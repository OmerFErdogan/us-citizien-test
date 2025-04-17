import 'package:flutter/foundation.dart';

/// Uscis Memuru temsili
class UscisOfficer {
  final String name;
  final String avatarImagePath;
  final String position;

  const UscisOfficer({
    required this.name,
    required this.avatarImagePath,
    required this.position,
  });
  
  // Bu metodu override ediyoruz ki debug bilgileri görünmesin
  @override
  String toString() => name;
}

/// Mülakat ortamı ayarları
class InterviewSettings {
  final bool useStrictMode; // Daha zorlu değerlendirme
  final bool useTimedResponses; // Cevaplar için zaman sınırı
  final bool includePersonalQuestions; // Kişisel bilgi soruları dahil
  final bool includeN400Questions; // N-400 formundan sorular dahil
  final int questionCount; // Toplam soru sayısı
  final bool useAudio; // Sesli sorular
  final bool useVoiceInput; // Sesli yanıt girişi

  const InterviewSettings({
    this.useStrictMode = false,
    this.useTimedResponses = false,
    this.includePersonalQuestions = true,
    this.includeN400Questions = true, 
    this.questionCount = 10,
    this.useAudio = true,
    this.useVoiceInput = false,
  });

  InterviewSettings copyWith({
    bool? useStrictMode,
    bool? useTimedResponses,
    bool? includePersonalQuestions,
    bool? includeN400Questions,
    int? questionCount,
    bool? useAudio,
    bool? useVoiceInput,
  }) {
    return InterviewSettings(
      useStrictMode: useStrictMode ?? this.useStrictMode,
      useTimedResponses: useTimedResponses ?? this.useTimedResponses,
      includePersonalQuestions: includePersonalQuestions ?? this.includePersonalQuestions,
      includeN400Questions: includeN400Questions ?? this.includeN400Questions,
      questionCount: questionCount ?? this.questionCount,
      useAudio: useAudio ?? this.useAudio,
      useVoiceInput: useVoiceInput ?? this.useVoiceInput,
    );
  }
}

/// Mülakat soru tipleri
enum InterviewQuestionType {
  civics, // Vatandaşlık testi sorusu
  personal, // Kişisel bilgi sorusu
  n400, // N-400 formundan soru
  englishReading, // İngilizce okuma testi
  englishWriting, // İngilizce yazma testi
}

/// Mülakat sorusu modeli
class InterviewQuestion {
  final String id;
  final String question;
  final List<String> acceptableAnswers;
  final String audioPath; // Ses dosyası yolu (opsiyonel)
  final InterviewQuestionType type;
  final String? hint; // İpucu (opsiyonel)
  final String? context; // Ek bağlam bilgisi (opsiyonel)

  const InterviewQuestion({
    required this.id,
    required this.question,
    required this.acceptableAnswers,
    this.audioPath = '',
    required this.type,
    this.hint,
    this.context,
  });
}

/// Mülakat yanıtı modeli
class InterviewResponse {
  final String questionId;
  final String userResponse;
  final bool isCorrect;
  final DateTime timestamp;
  final int? responseTimeInSeconds;
  final String? officerFeedback;

  const InterviewResponse({
    required this.questionId,
    required this.userResponse,
    required this.isCorrect,
    required this.timestamp,
    this.responseTimeInSeconds,
    this.officerFeedback,
  });
}

/// Mülakat oturumu modeli
class InterviewSession {
  final String id;
  final DateTime date;
  final int totalQuestions;
  final int correctAnswers;
  final InterviewSettings settings;
  final List<InterviewResponse> responses;
  final bool isCompleted;
  final int durationInMinutes;
  final String? officerName;

  const InterviewSession({
    required this.id,
    required this.date,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.settings,
    required this.responses,
    required this.isCompleted,
    required this.durationInMinutes,
    this.officerName,
  });

  /// Başarı yüzdesi hesaplama
  double get successRate => 
    totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;
    
  /// Başarılı mı kontrol etme
  bool get isPassed => successRate >= 60; // %60 ve üzeri başarı
}
