import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/question.dart';
import '../services/question_service.dart';
import '../utils/extensions.dart';

class FlashcardScreen extends StatefulWidget {
  final QuestionService questionService;
  final List<String>? categories;
  final int maxCardCount;

  const FlashcardScreen({
    Key? key,
    required this.questionService,
    this.categories,
    this.maxCardCount = 20,
  }) : super(key: key);

  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _flipController;

  List<Question> _questions = [];
  Map<String, Color> _categoryColorMap = {};
  int _currentCardIndex = 0;
  int _knownCount = 0;
  int _unknownCount = 0;
  bool _isCardFlipped = false;
  bool _isLoading = true;

  final List<Color> _categoryColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _loadFlashcards();
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  Future<void> _loadFlashcards() async {
    setState(() => _isLoading = true);

    try {
      await widget.questionService.loadQuestions();

      // 1) Kategori filtresi uygula
      List<Question> availableQuestions = _getFilteredQuestions();

      // 2) Öncelikle yanlış cevaplanan soruları seç
      List<Question> priorityQuestions = availableQuestions
          .where((q) => q.isAttempted && !q.isMarkedCorrect)
          .toList();

      // 3) Eğer yeterli değilse, cevaplanmamışları ekle
      priorityQuestions = _addUnansweredQuestions(priorityQuestions, availableQuestions);

      // 4) Hâlâ eksik varsa, rastgele sorular ekle
      priorityQuestions = _addRandomQuestions(priorityQuestions, availableQuestions);

      // 5) Tüm seçilen kartları karıştır
      priorityQuestions.shuffle();

      // 6) Kategori-renk eşlemesini oluştur
      _createCategoryColorMap(priorityQuestions);

      setState(() {
        _questions = priorityQuestions;
        _currentCardIndex = 0;
        _knownCount = 0;
        _unknownCount = 0;
        _isCardFlipped = false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Flashcardlar yüklenirken hata oluştu: $e')),
        );
      }
    }
  }

  List<Question> _getFilteredQuestions() {
    if (widget.categories != null && widget.categories!.isNotEmpty) {
      return widget.questionService.getQuestionsByCategories(widget.categories!);
    } else {
      return widget.questionService.getAllQuestions();
    }
  }

  List<Question> _addUnansweredQuestions(List<Question> priorityQuestions, List<Question> all) {
    if (priorityQuestions.length < widget.maxCardCount) {
      final countNeeded = widget.maxCardCount - priorityQuestions.length;
      final unanswered = all.where((q) => !q.isAttempted).take(countNeeded).toList();
      priorityQuestions.addAll(unanswered);
    }
    return priorityQuestions;
  }

  List<Question> _addRandomQuestions(List<Question> priorityQuestions, List<Question> all) {
    if (priorityQuestions.length < widget.maxCardCount) {
      final remainingCount = widget.maxCardCount - priorityQuestions.length;
      final selectedIds = priorityQuestions.map((q) => q.id).toSet();
      final remainingQuestions = all.where((q) => !selectedIds.contains(q.id)).toList();
      remainingQuestions.shuffle();
      priorityQuestions.addAll(remainingQuestions.take(remainingCount));
    }
    return priorityQuestions;
  }

  void _createCategoryColorMap(List<Question> questions) {
    final categories = questions.map((q) => q.category).toSet().toList();
    _categoryColorMap = {};
    for (int i = 0; i < categories.length; i++) {
      _categoryColorMap[categories[i]] = _categoryColors[i % _categoryColors.length];
    }
  }

  void _flipCard() {
    setState(() => _isCardFlipped = !_isCardFlipped);
    if (_isCardFlipped) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
  }

  /// Bilmiyorum (yanlış) veya Biliyorum (doğru) buton tıklama işlemleri tek metod
  void _markCard({required bool known}) {
    if (_questions.isEmpty || _currentCardIndex >= _questions.length) return;
    final question = _questions[_currentCardIndex];

    // known = true ise, ilk doğru cevabı işaretle
    final answerText = known ? question.correctAnswer : "";

    // Serviste güncelle
    widget.questionService.answerQuestion(question.id, answerText);

    setState(() {
      known ? _knownCount++ : _unknownCount++;
    });

    _nextCard();
  }

  void _nextCard() {
    if (_currentCardIndex < _questions.length - 1) {
      setState(() {
        _currentCardIndex++;
        _isCardFlipped = false;
      });
      _flipController.reset();
    } else {
      _showSummaryDialog();
    }
  }

  void _previousCard() {
    if (_currentCardIndex > 0) {
      setState(() {
        _currentCardIndex--;
        _isCardFlipped = false;
      });
      _flipController.reset();
    }
  }

  void _showSummaryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.realizingDream),
        titleTextStyle: TextStyle(
          fontSize: 18, 
          fontWeight: FontWeight.bold, 
          color: Colors.blue[700],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/eagle_icon.png',
                      width: 32,
                      height: 32,
                      color: Colors.blue[800],
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        context.l10n.citizenshipJourney,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.libertyAwaits,
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryItem(
                  icon: Icons.check_circle,
                  value: _knownCount.toString(),
                  label: 'Biliyorum',
                  color: Colors.green,
                ),
                _buildSummaryItem(
                  icon: Icons.cancel,
                  value: _unknownCount.toString(),
                  label: 'Bilmiyorum',
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _knownCount / (_knownCount + _unknownCount),
              backgroundColor: Colors.red[100],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              minHeight: 10,
            ),
            const SizedBox(height: 8),
            Text(
              'Başarı Oranı: %${((_knownCount / (_knownCount + _unknownCount)) * 100).toStringAsFixed(1)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Ana ekrana dön
            },
            child: const Text('Çıkış'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Kartları yeniden başlat
              setState(() {
                _currentCardIndex = 0;
                _isCardFlipped = false;
                _knownCount = 0;
                _unknownCount = 0;
              });
              _flipController.reset();
            },
            child: const Text('Tekrar Başlat'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.libertyCards),
        backgroundColor: Colors.red.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            tooltip: 'Kartları Karıştır',
            onPressed: () {
              if (_questions.isNotEmpty) {
                setState(() {
                  _questions.shuffle();
                  _currentCardIndex = 0;
                  _isCardFlipped = false;
                  _knownCount = 0;
                  _unknownCount = 0;
                });
                _flipController.reset();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Yeniden Yükle',
            onPressed: _loadFlashcards,
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
          Image.asset(
            'assets/images/statue_of_liberty_icon.png',
            width: 80,
            height: 80,
            color: Colors.blue[700],
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.noCardsFound,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Lütfen farklı kategoriler seçin veya soruları yeniden yükleyin.',
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
    final progressPercent =
        _questions.isEmpty ? 0.0 : (_currentCardIndex + 1) / _questions.length;

    return Column(
      children: [
        // Üst kısım: progress bar, sayaç, vs.
        _buildProgressIndicatorAndStats(progressPercent),

        // Ortadaki kart
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: _flipCard,
              child: _questions.isNotEmpty
                      ? _buildFlipCard(_questions[_currentCardIndex])
                      : const SizedBox(),
            ),
          ),
        ),

        // Alt butonlar
        _buildBottomButtons(),
      ],
    );
  }

  Widget _buildProgressIndicatorAndStats(double progressPercent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kart ${_currentCardIndex + 1}/${_questions.length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (_questions.isNotEmpty && _currentCardIndex < _questions.length)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(_questions[_currentCardIndex].category)
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _questions[_currentCardIndex].category,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getCategoryColor(_questions[_currentCardIndex].category),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // İlerleme çubuğu
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressPercent,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
          // Oturum istatistikleri
          if (_knownCount > 0 || _unknownCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSessionStats(
                    text: 'Biliyorum: $_knownCount',
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _buildSessionStats(
                    text: 'Bilmiyorum: $_unknownCount',
                    color: Colors.red,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSessionStats({required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _currentCardIndex > 0 ? _previousCard : null,
            color: Colors.blue,
          ),
          ElevatedButton.icon(
            onPressed: _isCardFlipped ? () => _markCard(known: false) : null,
            icon: const Icon(Icons.close),
            label: const Text('Bilmiyorum'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              disabledBackgroundColor: Colors.red[100],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _isCardFlipped ? () => _markCard(known: true) : null,
            icon: const Icon(Icons.check),
            label: const Text('Biliyorum'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[400],
              disabledBackgroundColor: Colors.green[100],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _currentCardIndex < _questions.length - 1 ? _nextCard : null,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildFlipCard(Question question) {
    return AnimatedBuilder(
      animation: _flipController,
      builder: (context, child) {
        // İsterseniz buradaki açı değeriyle (angle) dönüşüm ekleyebilirsiniz.
        // final angle = _isCardFlipped ? math.pi : 0.0;

        return Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isCardFlipped
                ? _buildCardBack(question)
                : _buildCardFront(question),
          ),
        );
      },
    );
  }

  Widget _buildCardFront(Question question) {
    final categoryColor = _getCategoryColor(question.category);

    return Container(
      key: const ValueKey('front'),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            categoryColor.withOpacity(0.1),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Kategori etiketi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              question.category,
              style: TextStyle(
                fontSize: 12,
                color: categoryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Icon(Icons.help_outline, size: 48, color: categoryColor),
          const SizedBox(height: 24),
          Text(
            question.question,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.touch_app, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Cevabı görmek için kartı çevirin',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(Question question) {
    return Container(
      key: const ValueKey('back'),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.green[50]!,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 48, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            'CEVAP',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: question.allCorrectAnswers.map((answer) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            answer,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBackCardHint(Icons.close, 'Bilmiyorum', Colors.red[400]),
              _buildBackCardHint(Icons.check, 'Biliyorum', Colors.green[400]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackCardHint(IconData icon, String label, Color? color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    return _categoryColorMap[category] ?? Colors.blue;
  }
}
