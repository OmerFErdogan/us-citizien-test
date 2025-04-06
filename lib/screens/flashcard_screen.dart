import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/question.dart';
import '../services/question_service.dart';

class FlashcardScreen extends StatefulWidget {
  final QuestionService questionService;
  final int maxCardCount;

  const FlashcardScreen({
    Key? key,
    required this.questionService,
    this.maxCardCount = 20,
  }) : super(key: key);

  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  List<Question> _questions = [];
  int _currentCardIndex = 0;
  bool _isCardFlipped = false;
  bool _isLoading = true;
  
  // Kartın çevrilmesini kontrol eden controller
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadFlashcards();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadFlashcards() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.questionService.loadQuestions();
      
      // Öncelikle bilinmeyen veya yanlış cevaplanan soruları seç
      List<Question> priorityQuestions = widget.questionService
          .getIncorrectAnsweredQuestions();
      
      // Eğer yeteri kadar yoksa, cevaplanmamış soruları ekle
      if (priorityQuestions.length < widget.maxCardCount) {
        final unansweredQuestions = widget.questionService
            .getUnansweredQuestions()
            .take(widget.maxCardCount - priorityQuestions.length)
            .toList();
        
        priorityQuestions.addAll(unansweredQuestions);
      }
      
      // Hala yeteri kadar yoksa, rastgele sorular ekle
      if (priorityQuestions.length < widget.maxCardCount) {
        final remainingCount = widget.maxCardCount - priorityQuestions.length;
        final allQuestions = widget.questionService.getAllQuestions();
        
        // Zaten seçilenleri hariç tut
        final selectedIds = priorityQuestions.map((q) => q.id).toSet();
        final remainingQuestions = allQuestions
            .where((q) => !selectedIds.contains(q.id))
            .toList();
        
        // Rastgele sırala ve gerekli sayıyı al
        remainingQuestions.shuffle();
        priorityQuestions.addAll(
          remainingQuestions.take(remainingCount)
        );
      }
      
      // Tüm kartları karıştır
      priorityQuestions.shuffle();
      
      setState(() {
        _questions = priorityQuestions;
        _currentCardIndex = 0;
        _isCardFlipped = false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Flashcardlar yüklenirken hata oluştu: $e')),
        );
      }
    }
  }

  void _nextCard() {
    if (_currentCardIndex < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousCard() {
    if (_currentCardIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _flipCard() {
    setState(() {
      _isCardFlipped = !_isCardFlipped;
    });
  }

  void _markCardKnown() {
    if (_questions.isEmpty) return;
    
    final currentQuestion = _questions[_currentCardIndex];
    // Doğru bir cevabı seç (ilk doğru cevabı)
    final correctAnswer = currentQuestion.correctAnswer;
    
    widget.questionService.answerQuestion(
      currentQuestion.id,
      correctAnswer
    );
    
    _nextCard();
  }

  void _markCardUnknown() {
    if (_questions.isEmpty) return;
    
    final currentQuestion = _questions[_currentCardIndex];
    
    // Soruyu yanlış olarak işaretle (boş cevap ile)
    widget.questionService.answerQuestion(
      currentQuestion.id,
      ""
    );
    
    _nextCard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcardlar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            tooltip: 'Kartları Karıştır',
            onPressed: () {
              setState(() {
                _questions.shuffle();
                _currentCardIndex = 0;
                _isCardFlipped = false;
                _pageController.jumpToPage(0);
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _questions.isEmpty
              ? _buildEmptyState()
              : _buildFlashcardContent(),
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
            'Hiç flashcard bulunamadı!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Lütfen daha sonra tekrar deneyin veya soruları yeniden yükleyin.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadFlashcards,
            child: const Text('Yeniden Dene'),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcardContent() {
    return Column(
      children: [
        // İlerleme göstergesi
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Kart ${_currentCardIndex + 1}/${_questions.length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        
        // Flashcard
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _questions.length,
            onPageChanged: (index) {
              setState(() {
                _currentCardIndex = index;
                _isCardFlipped = false;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildFlashcard(_questions[index]),
              );
            },
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Önceki buton
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _currentCardIndex > 0 ? _previousCard : null,
                color: Colors.blue,
              ),
              
              // Bilmiyorum
              ElevatedButton.icon(
                onPressed: _isCardFlipped ? _markCardUnknown : null,
                icon: const Icon(Icons.close),
                label: const Text('Bilmiyorum'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                ),
              ),
              
              // Biliyorum
              ElevatedButton.icon(
                onPressed: _isCardFlipped ? _markCardKnown : null,
                icon: const Icon(Icons.check),
                label: const Text('Biliyorum'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[400],
                ),
              ),
              
              // Sonraki buton
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: _currentCardIndex < _questions.length - 1 ? _nextCard : null,
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFlashcard(Question question) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final rotate = Tween(begin: math.pi, end: 0.0).animate(animation);
          return AnimatedBuilder(
            animation: rotate,
            child: child,
            builder: (BuildContext context, Widget? child) {
              final isUnder = (ValueKey(_isCardFlipped) != child?.key);
              final value = isUnder ? math.min(rotate.value, math.pi / 2) : rotate.value;
              return Transform(
                transform: Matrix4.rotationY(value),
                alignment: Alignment.center,
                child: child,
              );
            },
          );
        },
        child: _isCardFlipped
            ? _buildCardSide(
                key: const ValueKey(true),
                color: Colors.green[50]!,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 48,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'CEVAP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Birden fazla doğru cevap olabilir
                    ...question.allCorrectAnswers.map((answer) => 
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          answer,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Kategori: ${question.category}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : _buildCardSide(
                key: const ValueKey(false),
                color: Colors.blue[50]!,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.help_outline,
                      size: 48,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'SORU',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      question.question,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Kategori: ${question.category}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Cevabı görmek için kartı çevir',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildCardSide({
    required Key key,
    required Color color,
    required Widget child,
  }) {
    return Card(
      key: key,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          width: double.infinity,
          height: 300,
          child: child,
        ),
      ),
    );
  }
}