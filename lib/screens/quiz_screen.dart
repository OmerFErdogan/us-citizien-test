import 'package:flutter/material.dart';
import 'package:us_civics_test_app/screens/answer_option.dart';
import '../models/question.dart';
import '../services/question_service.dart';
import '../widgets/answer_option.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final QuestionService questionService;
  final int questionCount;
  final List<String>? categories; // Yeni kategori parametresi

  const QuizScreen({
    Key? key, 
    required this.questionService,
    this.questionCount = 10,
    this.categories, // Seçili kategoriler
  }) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  bool _answerChecked = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuizQuestions();
  }

  Future<void> _loadQuizQuestions() async {
  setState(() {
    _isLoading = true;
  });

  try {
    await widget.questionService.loadQuestions();
    
    // Kategori filtresi uygulandıysa onu kullan
    List<Question> questions;
    if (widget.categories != null && widget.categories!.isNotEmpty) {
      questions = widget.questionService.getRandomQuestionsByCategories(
        widget.questionCount, 
        widget.categories!
      );
    } else {
      questions = widget.questionService.getRandomQuestions(widget.questionCount);
    }
    
    setState(() {
      _questions = questions;
      _currentQuestionIndex = 0;
      _selectedAnswer = null;
      _answerChecked = false;
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _isLoading = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sorular yüklenirken hata oluştu: $e')),
      );
    }
  }
}

  void _selectAnswer(String answer) {
    if (_answerChecked) return;
    
    setState(() {
      _selectedAnswer = answer;
    });
  }

  void _checkAnswer() {
    if (_selectedAnswer == null) return;
    
    final currentQuestion = _questions[_currentQuestionIndex];
    
    // Doğru cevabı kontrol et
    final isCorrect = currentQuestion.isCorrectAnswer(_selectedAnswer!);
    
    // Bu soruyu güncelle
    _questions[_currentQuestionIndex] = currentQuestion.copyWith(
      isAttempted: true,
      isMarkedCorrect: isCorrect,
      selectedAnswer: _selectedAnswer,
    );
    
    // QuestionService'de de güncelle (global state için)
    widget.questionService.answerQuestion(
      currentQuestion.id, 
      _selectedAnswer!
    );
    
    setState(() {
      _answerChecked = true;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _answerChecked = false;
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          questions: _questions,
          questionService: widget.questionService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
        actions: [
          TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Quiz\'i Sonlandır'),
                  content: const Text('Quiz\'i sonlandırmak istediğinize emin misiniz? İlerlemeniz kaydedilmeyecektir.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('İptal'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Dialog'u kapat
                        Navigator.pop(context); // Quiz ekranından çık
                      },
                      child: const Text('Sonlandır'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.close, color: Colors.white),
            label: const Text('Bitir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _questions.isEmpty
              ? _buildEmptyState()
              : _buildQuizContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning, size: 48, color: Colors.orange),
          const SizedBox(height: 16),
          const Text(
            'Hiç soru bulunamadı!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Lütfen daha sonra tekrar deneyin veya soruları yeniden yükleyin.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadQuizQuestions,
            child: const Text('Yeniden Dene'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizContent() {
    final currentQuestion = _questions[_currentQuestionIndex];
    final isCorrect = _answerChecked && 
                     currentQuestion.isCorrectAnswer(_selectedAnswer ?? '');
    
    return Column(
      children: [
        // İlerleme göstergesi
        LinearProgressIndicator(
          value: (_currentQuestionIndex + 1) / _questions.length,
          minHeight: 8,
          backgroundColor: Colors.grey[300],
        ),
        
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Soru ${_currentQuestionIndex + 1}/${_questions.length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Kategori: ${currentQuestion.category}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        
        // Soru ve cevaplar
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Soru kartı
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentQuestion.question,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Cevap seçenekleri
                ...currentQuestion.options.map((option) {
                  final isSelected = _selectedAnswer == option.text;
                  final isCorrectOption = _answerChecked && option.isCorrect;
                  final isWrongSelection = _answerChecked && isSelected && !option.isCorrect;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: AnswerOption(
                      text: option.text,
                      isSelected: isSelected,
                      isCorrect: isCorrectOption,
                      isIncorrect: isWrongSelection,
                      onTap: () => _selectAnswer(option.text),
                    ),
                  );
                }).toList(),
                
                // Cevap kontrolü sonrası açıklama
                if (_answerChecked)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Card(
                      color: isCorrect ? Colors.green[50] : Colors.red[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isCorrect ? Icons.check_circle : Icons.info,
                                  color: isCorrect ? Colors.green : Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isCorrect ? 'Doğru!' : 'Yanlış!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isCorrect ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            if (!isCorrect) ...[
                              const SizedBox(height: 8),
                              const Text(
                                'Doğru cevap:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              // Birden fazla doğru cevap olabilir
                              ...currentQuestion.allCorrectAnswers.map((correctAnswer) => 
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Text(
                                    '• $correctAnswer',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                )
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        
        // Alt butonlar
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _answerChecked
                    ? ElevatedButton(
                        onPressed: _nextQuestion,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          _currentQuestionIndex < _questions.length - 1
                              ? 'Sonraki Soru'
                              : 'Sonuçları Gör',
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _selectedAnswer != null
                            ? _checkAnswer
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Cevabı Kontrol Et'),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}