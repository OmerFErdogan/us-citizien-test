import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question.dart';
import '../utils/exceptions/app_exceptions.dart';
import '../utils/exceptions/error_handler_service.dart';

class ImprovedQuestionService {
  List<Question> _questions = [];
  bool _isInitialized = false;
  final Random _random = Random();
  final ErrorHandlerService _errorHandler = ErrorHandlerService();
  
  // Günlük hedefler için değişkenler
  int _dailyGoal = 10;
  bool _isStatisticsInitialized = false;
  
  // Kullanıcının çalışma istatistikleri
  Map<String, int> _dailyStats = {};
  List<Map<String, dynamic>> _studySessions = [];

  /// Soruları JSON dosyasından yükler
  Future<void> loadQuestions() async {
    if (_isInitialized) return;
    
    try {
      // JSON dosyasını oku
      final String jsonString = await _loadJsonAsset();
      
      // JSON parse et
      final List<dynamic> jsonData = _parseJsonData(jsonString);
      
      // Question nesnelerine dönüştür
      _questions = _convertToQuestions(jsonData);
      
      // Validate data
      _validateQuestions();
      
      // Kaydedilmiş ilerlemeyi yükle
      await loadProgress();

      _isInitialized = true;
      
      print('✅ Toplam ${_questions.length} soru başarıyla yüklendi');
    } catch (e, stackTrace) {
      _isInitialized = false;
      
      final exception = _createDataException(e);
      
      await _errorHandler.handleError(
        exception: exception,
        stackTrace: stackTrace,
        severity: ErrorSeverity.high,
        context: {
          'operation': 'loadQuestions',
          'questionCount': _questions.length,
        },
      );
      
      throw exception;
    }
  }

  /// JSON asset dosyasını yükle
  Future<String> _loadJsonAsset() async {
    try {
      return await rootBundle.loadString('assets/questions.json');
    } catch (e) {
      throw DataException(
        message: 'Questions file could not be loaded. Please reinstall the app.',
        code: 'ASSET_LOAD_ERROR',
        originalError: e,
      );
    }
  }

  /// JSON string'i parse et
  List<dynamic> _parseJsonData(String jsonString) {
    try {
      final dynamic decoded = json.decode(jsonString);
      if (decoded is! List) {
        throw DataException(
          message: 'Invalid questions data format.',
          code: 'INVALID_JSON_FORMAT',
        );
      }
      return decoded;
    } catch (e) {
      throw DataException(
        message: 'Questions data is corrupted. Please reinstall the app.',
        code: 'JSON_PARSE_ERROR',
        originalError: e,
      );
    }
  }

  /// JSON verilerini Question nesnelerine dönüştür
  List<Question> _convertToQuestions(List<dynamic> jsonData) {
    try {
      return jsonData
          .map<Question>((json) {
            try {
              return Question.fromJson(json);
            } catch (e) {
              throw DataException(
                message: 'Invalid question data at index ${jsonData.indexOf(json)}',
                code: 'QUESTION_CONVERSION_ERROR',
                originalError: e,
              );
            }
          })
          .toList();
    } catch (e) {
      throw DataException(
        message: 'Failed to process questions data.',
        code: 'QUESTIONS_CONVERSION_ERROR',
        originalError: e,
      );
    }
  }

  /// Soruları validate et
  void _validateQuestions() {
    if (_questions.isEmpty) {
      throw DataException(
        message: 'No questions found in the data file.',
        code: 'EMPTY_QUESTIONS',
      );
    }

    // Check for duplicate IDs
    final ids = _questions.map((q) => q.id).toSet();
    if (ids.length != _questions.length) {
      throw DataException(
        message: 'Duplicate question IDs found in data.',
        code: 'DUPLICATE_QUESTION_IDS',
      );
    }

    // Validate each question has correct options
    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      
      if (question.options.isEmpty) {
        throw DataException(
          message: 'Question ${question.id} has no options.',
          code: 'INVALID_QUESTION_OPTIONS',
        );
      }

      final correctOptions = question.options.where((o) => o.isCorrect).length;
      if (correctOptions == 0) {
        throw DataException(
          message: 'Question ${question.id} has no correct answer.',
          code: 'NO_CORRECT_ANSWER',
        );
      }
    }
  }

  /// Kullanıcı ilerlemesini kaydet
  Future<void> saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final progressData = _questions.map((q) => {
        'id': q.id,
        'isAttempted': q.isAttempted,
        'isMarkedCorrect': q.isMarkedCorrect,
        'selectedAnswer': q.selectedAnswer,
        'lastAttemptDate': q.lastAttemptDate?.toIso8601String(),
        'attemptCount': q.attemptCount,
      }).toList();
      
      final success = await prefs.setString('questions_progress', jsonEncode(progressData));
      
      if (!success) {
        throw StorageException(
          message: 'Failed to save progress. Device storage may be full.',
          code: 'PROGRESS_SAVE_ERROR',
        );
      }
      
      print('✅ İlerleme kaydedildi: ${progressData.length} soru');
    } catch (e, stackTrace) {
      final exception = _createStorageException(e);
      
      await _errorHandler.handleError(
        exception: exception,
        stackTrace: stackTrace,
        severity: ErrorSeverity.medium,
        context: {
          'operation': 'saveProgress',
          'questionCount': _questions.length,
        },
      );
      
      // Don't throw for save errors, just log them
    }
  }

  /// Kaydedilen ilerlemeyi yükle
  Future<void> loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final progressString = prefs.getString('questions_progress');
      if (progressString == null) {
        print('ℹ️ Kaydedilmiş ilerleme bulunamadı');
        return;
      }
      
      final List<dynamic> progressData = json.decode(progressString);
      
      _applyProgressData(progressData);
      
      print('✅ İlerleme yüklendi: ${progressData.length} soru');
    } catch (e, stackTrace) {
      final exception = _createStorageException(e);
      
      await _errorHandler.handleError(
        exception: exception,
        stackTrace: stackTrace,
        severity: ErrorSeverity.low, // Don't block app for progress load errors
        context: {
          'operation': 'loadProgress',
        },
      );
      
      // Continue without progress if loading fails
    }
  }

  /// Progress verilerini uygula
  void _applyProgressData(List<dynamic> progressData) {
    for (var progress in progressData) {
      try {
        final int id = progress['id'];
        final index = _questions.indexWhere((q) => q.id == id);
        
        if (index != -1) {
          _questions[index] = _questions[index].copyWith(
            isAttempted: progress['isAttempted'],
            isMarkedCorrect: progress['isMarkedCorrect'],
            selectedAnswer: progress['selectedAnswer'],
            lastAttemptDate: progress['lastAttemptDate'] != null 
                ? DateTime.parse(progress['lastAttemptDate']) 
                : null,
            attemptCount: progress['attemptCount'] ?? 0,
          );
        }
      } catch (e) {
        print('⚠️ Progress data error for question: $progress');
        // Continue with other questions
      }
    }
  }

  /// Soru cevaplama işlemi
  Future<void> answerQuestion(int questionId, String selectedAnswer) async {
    try {
      final index = _questions.indexWhere((q) => q.id == questionId);
      if (index == -1) {
        throw ValidationException(
          message: 'Question not found.',
          code: 'QUESTION_NOT_FOUND',
        );
      }
      
      final question = _questions[index];
      final isCorrect = question.isCorrectAnswer(selectedAnswer);
      
      // Soruyu güncelle
      _questions[index] = question.copyWith(
        isAttempted: true,
        isMarkedCorrect: isCorrect,
        selectedAnswer: selectedAnswer,
        lastAttemptDate: DateTime.now(),
        attemptCount: question.attemptCount + 1,
      );
      
      // İstatistikleri ve ilerlemeyi kaydet
      await _saveStatistics();
      await saveProgress();
      
    } catch (e, stackTrace) {
      final exception = ErrorHandlerService.convertException(e, stackTrace);
      
      await _errorHandler.handleError(
        exception: exception,
        stackTrace: stackTrace,
        severity: ErrorSeverity.medium,
        context: {
          'operation': 'answerQuestion',
          'questionId': questionId,
          'selectedAnswer': selectedAnswer,
        },
      );
      
      throw exception;
    }
  }

  /// İstatistikleri kaydet
  Future<void> _saveStatistics() async {
    try {
      if (!_isStatisticsInitialized) {
        await _loadStatistics();
      }
      
      final today = _getDateString(DateTime.now());
      _dailyStats[today] = (_dailyStats[today] ?? 0) + 1;
      
      final session = {
        'date': DateTime.now().toIso8601String(),
        'correctCount': _questions.where((q) => q.isMarkedCorrect).length,
        'totalCount': _questions.where((q) => q.isAttempted).length,
      };
      _studySessions.add(session);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('daily_stats', jsonEncode(_dailyStats));
      await prefs.setString('study_sessions', jsonEncode(_studySessions));
      
    } catch (e, stackTrace) {
      final exception = _createStorageException(e);
      
      await _errorHandler.handleError(
        exception: exception,
        stackTrace: stackTrace,
        severity: ErrorSeverity.low,
        context: {
          'operation': '_saveStatistics',
        },
      );
    }
  }

  /// İstatistikleri yükle
  Future<void> _loadStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _dailyGoal = prefs.getInt('daily_goal') ?? 10;
      
      final dailyStatsString = prefs.getString('daily_stats');
      if (dailyStatsString != null) {
        final Map<String, dynamic> decoded = jsonDecode(dailyStatsString);
        _dailyStats = decoded.map((key, value) => MapEntry(key, value as int));
      }
      
      final studySessionsString = prefs.getString('study_sessions');
      if (studySessionsString != null) {
        _studySessions = List<Map<String, dynamic>>.from(jsonDecode(studySessionsString));
      }
      
      _isStatisticsInitialized = true;
    } catch (e, stackTrace) {
      final exception = _createStorageException(e);
      
      await _errorHandler.handleError(
        exception: exception,
        stackTrace: stackTrace,
        severity: ErrorSeverity.low,
        context: {
          'operation': '_loadStatistics',
        },
      );
      
      _isStatisticsInitialized = false;
    }
  }

  /// Exception helper methods
  DataException _createDataException(dynamic error) {
    if (error is DataException) return error;
    
    return DataException(
      message: 'Failed to load questions. Please check your app installation.',
      code: 'DATA_LOAD_ERROR',
      originalError: error,
    );
  }

  StorageException _createStorageException(dynamic error) {
    if (error is StorageException) return error;
    
    return StorageException(
      message: 'Failed to access device storage. Please check storage permissions.',
      code: 'STORAGE_ERROR',
      originalError: error,
    );
  }

  /// Utility methods
  String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Getters - all the existing getter methods
  List<Question> getAllQuestions() => _questions;
  bool get isInitialized => _isInitialized;
  
  /// Dispose resources
  void dispose() {
    _errorHandler.dispose();
  }

  /// Singleton pattern
  static final ImprovedQuestionService _instance = ImprovedQuestionService._internal();
  
  factory ImprovedQuestionService() {
    return _instance;
  }
  
  ImprovedQuestionService._internal();
}
