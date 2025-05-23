import 'package:flutter/material.dart';
import 'package:us_citizenship_test/screens/answer_option.dart';
import '../models/question.dart';
import '../services/question_service.dart';
import '../utils/extensions.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final QuestionService questionService;
  final int questionCount;
  final List<String>? categories; // Kategori parametresi
  final List<Question>? questions; // Doğrudan gönderilen sorular (özel quizler için)
  final bool Function(List<Question>)? onResultScreen; // Quiz tamamlandığında çağrılacak callback

  const QuizScreen({
    Key? key, 
    required this.questionService,
    this.questionCount = 10,
    this.categories, // Seçili kategoriler
    this.questions, // Özel sorular
    this.onResultScreen, // Callback fonksiyonu
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
      
      // Özel sorular gönderildiyse onları kullan
      if (widget.questions != null && widget.questions!.isNotEmpty) {
        setState(() {
          _questions = widget.questions!;
          _currentQuestionIndex = 0;
          _selectedAnswer = null;
          _answerChecked = false;
          _isLoading = false;
        });
        return;
      }
      
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
        SnackBar(content: Text(context.l10n.errorLoading('$e'))),
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
    // Eğer onResultScreen callback'i varsa çağır
    if (widget.onResultScreen != null) {
      // Eğer callback false döndürürse, sonuç ekranını gösterme
      bool showResultScreen = widget.onResultScreen!(_questions);
      if (!showResultScreen) {
        // Navigasyon yığınından geri dön
        Navigator.pop(context);
        return;
      }
    }
    
    // Sonuç ekranına git - pushreplacement ile önceki route'u yenisi ile değiştir
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
        title: Text(context.l10n.startQuiz),
        actions: [
          TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(context.l10n.finish),
                  content: Text(context.l10n.resetProgressWarning),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(context.l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Dialog'u kapat
                        Navigator.pop(context); // Quiz ekranından çık
                      },
                      child: Text(context.l10n.finish),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.close, color: Colors.white),
            label: Text(context.l10n.finish, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _questions.isEmpty
                ? _buildEmptyState()
                : LayoutBuilder(
                    builder: (context, constraints) {
                      // Daha esnek responsive tasarım mantığı
                      final isPortrait = constraints.maxHeight > constraints.maxWidth;
                      final availableWidth = constraints.maxWidth;
                      final availableHeight = constraints.maxHeight;
                      
                      // Hem ekran boyutu hem de orientasyon dikkate alınıyor
                      final useTabletLayout = !isPortrait && availableWidth >= 700 || availableWidth >= 900;
                      
                      return _buildQuizContent(isTabletMode: useTabletLayout,
                                               screenWidth: availableWidth, 
                                               screenHeight: availableHeight);
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning, size: 48, color: Colors.orange),
          const SizedBox(height: 16),
           Text(
            context.l10n.noCardsFound,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
           Text(
            context.l10n.errorLoadingQuestions,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadQuizQuestions,
            child: Text(context.l10n.startQuiz),
          ),
        ],
      ),
    );
  }

  // Standard mobile/portrait layout ve tablet/landscape layout yerine tek bir metoda geçiş yapalım
  Widget _buildQuizContent({required bool isTabletMode, required double screenWidth, required double screenHeight}) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final isCorrect = _answerChecked && 
                     currentQuestion.isCorrectAnswer(_selectedAnswer ?? '');
    
    // Ekran boyutlarına bağlı dinamik ölçülendirme
    final bool isLargeScreen = screenWidth >= 900;
    final bool isMediumScreen = screenWidth >= 600 && screenWidth < 900;
    final double fontSize = isLargeScreen ? 22 : (isMediumScreen ? 20 : 18);
    final double padding = isLargeScreen ? 24.0 : (isMediumScreen ? 20.0 : 16.0);
    final double spacing = isLargeScreen ? 32.0 : (isMediumScreen ? 24.0 : 16.0);
    
    // Layout modification based on screen size/orientation
    if (isTabletMode) {
      // Side-by-side layout for tablets/landscape mode
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
                  context.l10n.questionProgress((_currentQuestionIndex + 1), _questions.length),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  context.l10n.categoryName(currentQuestion.category),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          
          // Split view for tablet mode
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question section
                Expanded(
                  flex: 4,
                  child: Card(
                    margin: const EdgeInsets.all(16.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentQuestion.question,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Answer feedbacks for tablet mode
                          if (_answerChecked)
                            _buildAnswerFeedback(isCorrect, currentQuestion),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Answer options section
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ..._buildAnswerOptions(currentQuestion),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Button section
          _buildBottomActionButton(),
        ],
      );
    } else {
      // Standard mobile/portrait layout
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
                  context.l10n.questionProgress((_currentQuestionIndex + 1), _questions.length),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  context.l10n.categoryName(currentQuestion.category),
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
                  ..._buildAnswerOptions(currentQuestion),
                  
                  // Cevap kontrolü sonrası açıklama
                  if (_answerChecked)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: _buildAnswerFeedback(isCorrect, currentQuestion),
                    ),
                ],
              ),
            ),
          ),
          
          // Alt butonlar
          _buildBottomActionButton(),
        ],
      );
    }
  }
  
  // Extract answer options to a reusable method
  List<Widget> _buildAnswerOptions(Question currentQuestion) {
    return currentQuestion.options.map((option) {
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
    }).toList();
  }
  
  // Extract answer feedback to a reusable method
 Widget _buildAnswerFeedback(bool isCorrect, Question currentQuestion) {
  return Card(
    color: isCorrect ? Colors.green[50] : Colors.red[50],
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
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
                isCorrect ? context.l10n.correctLabel : context.l10n.incorrectLabel,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          if (!isCorrect) ...[                      // 👈 yaymadan sonra köşeli parantez aç
            const SizedBox(height: 8),
            Text(
              context.l10n.correctAnswer,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            // Birden fazla doğru cevap olabilir
            ...currentQuestion.allCorrectAnswers.map(
              (correct) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $correct', style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],                                        // 👈 listeyi kapat
        ],
      ),
    ),
  );
}

  
  // Extract bottom action button to a reusable method
  Widget _buildBottomActionButton() {
    return Container(
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
                          ? context.l10n.next
                          : context.l10n.reviewAnswers,
                    ),
                  )
                : ElevatedButton(
                    onPressed: _selectedAnswer != null
                        ? _checkAnswer
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(context.l10n.checkAnswer),
                  ),
          ),
        ],
      ),
    );
  }
}