class Option {
  final String text;
  final bool isCorrect;
  
  Option({
    required this.text,
    required this.isCorrect,
  });
  
  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      text: json['text'] as String,
      isCorrect: json['isCorrect'] as bool,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isCorrect': isCorrect,
    };
  }
}

class Question {
  final int id;
  final String category;
  final String question;
  final List<Option> options;
  bool isMarkedCorrect;
  bool isAttempted;
  String? selectedAnswer;
  DateTime? lastAttemptDate; // Sorunun en son cevaplanma tarihi
  int attemptCount; // Sorunun kaç kez denendiği

  Question({
    required this.id,
    required this.category,
    required this.question,
    required this.options,
    this.isMarkedCorrect = false,
    this.isAttempted = false,
    this.selectedAnswer,
    this.lastAttemptDate,
    this.attemptCount = 0,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int,
      category: json['category'] as String,
      question: json['question'] as String,
      options: (json['options'] as List)
          .map((option) => Option.fromJson(option as Map<String, dynamic>))
          .toList(),
      isMarkedCorrect: json['isMarkedCorrect'] as bool? ?? false,
      isAttempted: json['isAttempted'] as bool? ?? false,
      selectedAnswer: json['selectedAnswer'] as String?,
      lastAttemptDate: json['lastAttemptDate'] != null 
          ? DateTime.parse(json['lastAttemptDate'] as String) 
          : null,
      attemptCount: json['attemptCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'question': question,
      'options': options.map((option) => option.toJson()).toList(),
      'isMarkedCorrect': isMarkedCorrect,
      'isAttempted': isAttempted,
      'selectedAnswer': selectedAnswer,
      'lastAttemptDate': lastAttemptDate?.toIso8601String(),
      'attemptCount': attemptCount,
    };
  }

  Question copyWith({
    int? id,
    String? category,
    String? question,
    List<Option>? options,
    bool? isMarkedCorrect,
    bool? isAttempted,
    String? selectedAnswer,
    DateTime? lastAttemptDate,
    int? attemptCount,
  }) {
    return Question(
      id: id ?? this.id,
      category: category ?? this.category,
      question: question ?? this.question,
      options: options ?? this.options,
      isMarkedCorrect: isMarkedCorrect ?? this.isMarkedCorrect,
      isAttempted: isAttempted ?? this.isAttempted,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      lastAttemptDate: lastAttemptDate ?? this.lastAttemptDate,
      attemptCount: attemptCount ?? this.attemptCount,
    );
  }
  
  // Tüm doğru cevapların listesini döndürür
  List<String> get allCorrectAnswers {
    return options
        .where((option) => option.isCorrect)
        .map((option) => option.text)
        .toList();
  }
  
  // Sadece ilk doğru cevabı döndürür
  String get correctAnswer {
    final correctOptions = options.where((option) => option.isCorrect);
    return correctOptions.isNotEmpty ? correctOptions.first.text : '';
  }
  
  // Tüm seçeneklerin metinlerini döndürür
  List<String> get allOptionTexts {
    return options.map((option) => option.text).toList();
  }
  
  // Verilen metin doğru cevap mı kontrol eder
  bool isCorrectAnswer(String text) {
    return options.any((option) => option.text == text && option.isCorrect);
  }
}