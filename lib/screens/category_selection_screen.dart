import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/question_service.dart';
import 'quiz_screen.dart';
import 'flashcard_screen.dart';

class CategorySelectionScreen extends StatefulWidget {
  final QuestionService questionService;
  final bool isForQuiz; // Quiz için mi Flashcard için mi?

  const CategorySelectionScreen({
    Key? key,
    required this.questionService,
    required this.isForQuiz,
  }) : super(key: key);

  @override
  _CategorySelectionScreenState createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  bool _isLoading = true;
  List<String> _categories = [];
  List<String> _selectedCategories = [];
  Map<String, int> _questionCounts = {};
  Map<String, int> _completedCounts = {};
  Map<String, double> _successRates = {};
  
  // Kategori renkleri
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
  Map<String, Color> _categoryColorMap = {};

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await widget.questionService.loadQuestions();
      
      // Tüm soruları al
      final allQuestions = widget.questionService.getAllQuestions();
      
      // Benzersiz kategorileri bul
      final categories = allQuestions
          .map((q) => q.category)
          .toSet()
          .toList();
      
      // Her kategorideki soru sayısını ve tamamlanma durumunu hesapla
      final questionCounts = <String, int>{};
      final completedCounts = <String, int>{};
      final successRates = <String, double>{};
      
      for (final category in categories) {
        final questionsInCategory = allQuestions.where((q) => q.category == category).toList();
        final attemptedQuestions = questionsInCategory.where((q) => q.isAttempted).toList();
        final correctAnswers = attemptedQuestions.where((q) => q.isMarkedCorrect).toList();
        
        questionCounts[category] = questionsInCategory.length;
        completedCounts[category] = attemptedQuestions.length;
        successRates[category] = attemptedQuestions.isEmpty 
            ? 0.0 
            : correctAnswers.length / attemptedQuestions.length;
      }
      
      // Kategorileri alfabetik sırala
      categories.sort();
      
      // Kategori renkleri ata
      _categoryColorMap = {};
      for (int i = 0; i < categories.length; i++) {
        _categoryColorMap[categories[i]] = _categoryColors[i % _categoryColors.length];
      }
      
      setState(() {
        _categories = categories;
        _questionCounts = questionCounts;
        _completedCounts = completedCounts;
        _successRates = successRates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kategoriler yüklenirken hata oluştu: $e')),
        );
      }
    }
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  void _selectAllCategories() {
    setState(() {
      _selectedCategories = List.from(_categories);
    });
  }

  void _deselectAllCategories() {
    setState(() {
      _selectedCategories.clear();
    });
  }

  void _startWithSelectedCategories() {
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen en az bir kategori seçin')),
      );
      return;
    }

    if (widget.isForQuiz) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizScreen(
            questionService: widget.questionService,
            categories: _selectedCategories,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FlashcardScreen(
            questionService: widget.questionService,
            categories: _selectedCategories,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.isForQuiz ? 'Quiz Kategorileri' : 'Flashcard Kategorileri';
    final String buttonText = widget.isForQuiz ? 'Quiz Başlat' : 'Flashcardları Aç';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          TextButton(
            onPressed: _selectedCategories.isEmpty
                ? null
                : _startWithSelectedCategories,
            child: Text(
              buttonText,
              style: TextStyle(
                color: _selectedCategories.isEmpty ? Colors.grey : Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildCategoryList(),
      floatingActionButton: _selectedCategories.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _startWithSelectedCategories,
              label: Text(
                _selectedCategories.length == 1
                    ? '1 kategori ile başlat'
                    : '${_selectedCategories.length} kategori ile başlat',
              ),
              icon: const Icon(Icons.play_arrow),
            ),
    );
  }

  Widget _buildCategoryList() {
    // Tüm kategorilerdeki toplam istatistikleri hesapla
    int totalQuestions = 0;
    int totalCompleted = 0;
    
    for (final category in _categories) {
      totalQuestions += _questionCounts[category] ?? 0;
      totalCompleted += _completedCounts[category] ?? 0;
    }
    
    return Column(
      children: [
        // Genel ilerleme
        if (!widget.isForQuiz) // Flashcard kategorileri için
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Genel İlerleme',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: totalQuestions > 0 ? totalCompleted / totalQuestions : 0.0,
                      minHeight: 8,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tamamlanan: $totalCompleted / $totalQuestions soru',
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
        // Seçim kontrolü butonları
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kategoriler (${_selectedCategories.length}/${_categories.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _selectAllCategories,
                    icon: const Icon(Icons.select_all, size: 18),
                    label: const Text('Tümünü Seç'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _deselectAllCategories,
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('Temizle'),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Kategori listesi
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategories.contains(category);
              final questionCount = _questionCounts[category] ?? 0;
              final completedCount = _completedCounts[category] ?? 0;
              final successRate = _successRates[category] ?? 0.0;
              
              final categoryColor = _categoryColorMap[category] ?? Colors.blue;
              
              return Card(
                elevation: isSelected ? 4 : 1,
                margin: const EdgeInsets.only(bottom: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isSelected 
                      ? BorderSide(color: categoryColor, width: 2) 
                      : BorderSide.none,
                ),
                child: InkWell(
                  onTap: () => _toggleCategory(category),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Seçim göstergesi
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected 
                                      ? categoryColor 
                                      : Colors.grey[400]!,
                                  width: 2,
                                ),
                                color: isSelected 
                                    ? categoryColor.withOpacity(0.2) 
                                    : Colors.transparent,
                              ),
                              child: isSelected 
                                  ? Icon(
                                      Icons.check, 
                                      color: categoryColor,
                                      size: 16,
                                    ) 
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            
                            // Kategori adı
                            Expanded(
                              child: Text(
                                category,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? categoryColor : Colors.black,
                                ),
                              ),
                            ),
                            
                            // Soru sayısı
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$questionCount soru',
                                style: TextStyle(
                                  color: categoryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        if (!widget.isForQuiz) // Flashcard kategorileri için ilerleme bilgisi
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0, left: 36.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Tamamlanan: $completedCount / $questionCount',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    if (completedCount > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _getSuccessRateColor(successRate).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '%${(successRate * 100).toStringAsFixed(0)} başarı',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: _getSuccessRateColor(successRate),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: questionCount > 0 ? completedCount / questionCount : 0.0,
                                  minHeight: 4,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        // Başlatma butonu
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _selectedCategories.isEmpty
                  ? null
                  : _startWithSelectedCategories,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: Text(
                _selectedCategories.isEmpty
                    ? 'Lütfen kategori seçin'
                    : widget.isForQuiz
                        ? '${_selectedCategories.length} kategori ile Quiz başlat'
                        : '${_selectedCategories.length} kategori ile Flashcardları aç',
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Color _getSuccessRateColor(double rate) {
    if (rate >= 0.9) return Colors.green[700]!;
    if (rate >= 0.7) return Colors.green;
    if (rate >= 0.5) return Colors.orange;
    if (rate >= 0.3) return Colors.orange[700]!;
    return Colors.red;
  }
}