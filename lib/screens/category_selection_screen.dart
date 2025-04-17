import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/question_service.dart';
import '../utils/extensions.dart';
import '../widgets/category_selection_card.dart';
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
          SnackBar(content: Text(context.l10n.loadingCategoriesError(e.toString()))),
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
        SnackBar(content: Text(context.l10n.selectCategoryPlease)),
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
    final String title = widget.isForQuiz ? context.l10n.quizCategories : context.l10n.flashcardCategories;
    final String buttonText = widget.isForQuiz ? context.l10n.startQuiz : context.l10n.openFlashcards;
    
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
          : LayoutBuilder(
              builder: (context, constraints) {
                // Genişliğe ve yüksekliğe bağlı daha esnek responsive mantığı
                final isLargeScreen = constraints.maxWidth > 900;
                final isMediumScreen = constraints.maxWidth > 600 && constraints.maxWidth <= 900;
                final isPortrait = constraints.maxHeight > constraints.maxWidth;
                
                // Hem orientasyon hem de ekran boyutu dikkate alınıyor
                final useGridLayout = !isPortrait || constraints.maxWidth > 600;
                
                return _buildCategoryList(isLargeScreen, isMediumScreen, useGridLayout);
              },
            ),
      floatingActionButton: _selectedCategories.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _startWithSelectedCategories,
              label: Text(
                _selectedCategories.length == 1
                    ? context.l10n.startWithCategory(1)
                    : context.l10n.startWithCategories(_selectedCategories.length),
              ),
              icon: const Icon(Icons.play_arrow),
            ),
    );
  }

  Widget _buildCategoryList(bool isLargeScreen, bool isMediumScreen, bool useGridLayout) {
    // Tüm kategorilerdeki toplam istatistikleri hesapla
    int totalQuestions = 0;
    int totalCompleted = 0;
    
    for (final category in _categories) {
      totalQuestions += _questionCounts[category] ?? 0;
      totalCompleted += _completedCounts[category] ?? 0;
    }
    
    // For grid layout in medium and large screens
    Widget buildCategoryGrid() {
      // Ekran ölçüsüne göre grid sütun sayısını belirle
      final int crossAxisCount = isLargeScreen ? 3 : (isMediumScreen ? 2 : 1);
      
      return GridView.builder(
        padding: EdgeInsets.all(isLargeScreen ? 24.0 : 16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: isLargeScreen ? 2.5 : 2.2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategories.contains(category);
          final questionCount = _questionCounts[category] ?? 0;
          final completedCount = _completedCounts[category] ?? 0;
          final successRate = _successRates[category] ?? 0.0;
          
          final categoryColor = _categoryColorMap[category] ?? Colors.blue;
          
          return CategorySelectionCard(
            category: category,
            isSelected: isSelected,
            questionCount: questionCount,
            completedCount: completedCount,
            successRate: successRate,
            categoryColor: categoryColor,
            showProgressIndicator: !widget.isForQuiz,
            onTap: () => _toggleCategory(category),
          );
        },
      );
    }
    
    // For list layout in small screens
    Widget buildCategoryList() {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategories.contains(category);
          final questionCount = _questionCounts[category] ?? 0;
          final completedCount = _completedCounts[category] ?? 0;
          final successRate = _successRates[category] ?? 0.0;
          
          final categoryColor = _categoryColorMap[category] ?? Colors.blue;
          
          return CategorySelectionCard(
            category: category,
            isSelected: isSelected,
            questionCount: questionCount,
            completedCount: completedCount,
            successRate: successRate,
            categoryColor: categoryColor,
            showProgressIndicator: !widget.isForQuiz,
            onTap: () => _toggleCategory(category),
          );
        },
      );
    }
    
    return Column(
      children: [
        // Genel ilerleme
        if (!widget.isForQuiz) // Flashcard kategorileri için
          Padding(
            padding: EdgeInsets.all(isLargeScreen ? 24.0 : 16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(isLargeScreen ? 24.0 : 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.generalProgress,
                      style: TextStyle(
                        fontSize: isLargeScreen ? 22 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: isLargeScreen ? 16 : 12),
                    LinearProgressIndicator(
                      value: totalQuestions > 0 ? totalCompleted / totalQuestions : 0.0,
                      minHeight: isLargeScreen ? 10 : 8,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                    ),
                    SizedBox(height: isLargeScreen ? 12 : 8),
                    Text(
                      context.l10n.completed(totalCompleted, totalQuestions, totalQuestions > 0 ? (totalCompleted * 100 / totalQuestions).toStringAsFixed(1) : '0'),
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: isLargeScreen ? 16 : 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
        // Seçim kontrolü butonları
        Padding(
          padding: EdgeInsets.all(isLargeScreen ? 24.0 : 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  context.l10n.categoriesCount(_selectedCategories.length, _categories.length),
                  style: TextStyle(
                    fontSize: isLargeScreen ? 18 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  TextButton.icon(
                    onPressed: _selectAllCategories,
                    icon: Icon(Icons.select_all, size: isLargeScreen ? 20 : 18),
                    label: Text(context.l10n.selectAll),
                  ),
                  TextButton.icon(
                    onPressed: _deselectAllCategories,
                    icon: Icon(Icons.clear_all, size: isLargeScreen ? 20 : 18),
                    label: Text(context.l10n.clear),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Kategori listesi veya ızgarası
        Expanded(
          child: useGridLayout ? buildCategoryGrid() : buildCategoryList(),
        ),
        
        // Başlatma butonu
        SafeArea(
          child: Padding(
            padding: EdgeInsets.all(isLargeScreen ? 24.0 : 16.0),
            child: ElevatedButton(
              onPressed: _selectedCategories.isEmpty
                  ? null
                  : _startWithSelectedCategories,
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(isLargeScreen ? 60 : 50),
                padding: EdgeInsets.symmetric(vertical: isLargeScreen ? 16 : 12),
              ),
              child: Text(
                _selectedCategories.isEmpty
                    ? context.l10n.pleaseSelectCategory
                    : widget.isForQuiz
                        ? context.l10n.startQuizWithCategories(_selectedCategories.length)
                        : context.l10n.openWithCategories(_selectedCategories.length),
                style: TextStyle(fontSize: isLargeScreen ? 18 : 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // Method moved to CategorySelectionCard widget
}