import 'package:flutter/material.dart';
import '../services/question_service.dart';
import '../utils/extensions.dart';
import '../widgets/category_selection_card.dart';
import 'quiz_screen.dart';
import 'flashcard_screen.dart';

class CategorySelectionScreen extends StatefulWidget {
  final QuestionService questionService;
  final bool isForQuiz;

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

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // Category icons mapping
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'principles of american democracy':
        return Icons.account_balance;
      case 'system of government':
        return Icons.gavel;
      case 'rights and responsibilities':
        return Icons.how_to_vote;
      case 'american history':
        return Icons.flag;
      case 'geography':
        return Icons.public;
      case 'symbols':
        return Icons.emoji_symbols;
      case 'holidays':
        return Icons.celebration;
      default:
        return Icons.quiz;
    }
  }

  // Category background colors
  Color _getCategoryBackgroundColor(String category) {
    switch (category.toLowerCase()) {
      case 'principles of american democracy':
        return const Color(0xFFE8F4FD);
      case 'system of government':
        return const Color(0xFFF3E8FF);
      case 'rights and responsibilities':
        return const Color(0xFFE8F8F5);
      case 'american history':
        return const Color(0xFFFFF2E8);
      case 'geography':
        return const Color(0xFFE8F9F5);
      case 'symbols':
        return const Color(0xFFF8E8FF);
      case 'holidays':
        return const Color(0xFFFFF0E8);
      default:
        return const Color(0xFFF5F7FA);
    }
  }

  // Category icon colors
  Color _getCategoryIconColor(String category) {
    switch (category.toLowerCase()) {
      case 'principles of american democracy':
        return const Color(0xFF3B82F6);
      case 'system of government':
        return const Color(0xFF8B5CF6);
      case 'rights and responsibilities':
        return const Color(0xFF10B981);
      case 'american history':
        return const Color(0xFFF59E0B);
      case 'geography':
        return const Color(0xFF06B6D4);
      case 'symbols':
        return const Color(0xFFEC4899);
      case 'holidays':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Future<void> _loadCategories() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await widget.questionService.loadQuestions();
      
      final allQuestions = widget.questionService.getAllQuestions();
      final categories = allQuestions.map((q) => q.category).toSet().toList();
      
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
      
      categories.sort();
      
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
          SnackBar(content: Text('Error loading categories: $e')),
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

  void _startWithSelectedCategories() {
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one category')),
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
    final String title = widget.isForQuiz ? 'Select Quiz Categories' : 'Select Study Categories';
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildModernCategoryList(),
    );
  }

  Widget _buildModernCategoryList() {
    // Calculate overall progress
    int totalQuestions = 0;
    int totalCompleted = 0;
    
    for (final category in _categories) {
      totalQuestions += _questionCounts[category] ?? 0;
      totalCompleted += _completedCounts[category] ?? 0;
    }
    
    final overallProgress = totalQuestions > 0 ? totalCompleted / totalQuestions : 0.0;

    return Column(
      children: [
        // Overall Progress Card (only for flashcards)
        if (!widget.isForQuiz)
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE0E7FF), Color(0xFFC7D2FE)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Overall Progress',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: overallProgress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${(overallProgress * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

        // Category List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategories.contains(category);
              final questionCount = _questionCounts[category] ?? 0;
              final completedCount = _completedCounts[category] ?? 0;
              final progressPercentage = questionCount > 0 
                  ? (completedCount / questionCount * 100).round() 
                  : 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _toggleCategory(category),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? _getCategoryBackgroundColor(category).withOpacity(0.8)
                            : _getCategoryBackgroundColor(category),
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected 
                            ? Border.all(color: _getCategoryIconColor(category), width: 2)
                            : null,
                      ),
                      child: Row(
                        children: [
                          // Category Icon
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getCategoryIcon(category),
                              color: _getCategoryIconColor(category),
                              size: 28,
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Category Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$completedCount of $questionCount cards',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: completedCount > 0 
                                  ? const Color(0xFF10B981).withOpacity(0.1)
                                  : const Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              completedCount > 0 
                                  ? '$progressPercentage%'
                                  : 'Activity available',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: completedCount > 0 
                                    ? const Color(0xFF065F46)
                                    : const Color(0xFF10B981),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Bottom Action Button
        SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedCategories.isEmpty
                    ? null
                    : _startWithSelectedCategories,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _selectedCategories.isEmpty
                      ? 'Select categories to start'
                      : 'Start with ${_selectedCategories.length} ${_selectedCategories.length == 1 ? 'category' : 'categories'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}