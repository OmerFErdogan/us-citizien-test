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
      
      // Her kategorideki soru sayısını hesapla
      final questionCounts = <String, int>{};
      for (final category in categories) {
        final count = allQuestions.where((q) => q.category == category).length;
        questionCounts[category] = count;
      }
      
      // Alfabetik sırala
      categories.sort();
      
      setState(() {
        _categories = categories;
        _questionCounts = questionCounts;
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isForQuiz ? 'Quiz Kategorileri' : 'Flashcard Kategorileri'),
        actions: [
          TextButton(
            onPressed: _selectedCategories.isEmpty
                ? null
                : _startWithSelectedCategories,
            child: Text(
              widget.isForQuiz ? 'Quiz Başlat' : 'Flashcardları Aç',
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
    );
  }

  Widget _buildCategoryList() {
    return Column(
      children: [
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
                  TextButton(
                    onPressed: _selectAllCategories,
                    child: const Text('Tümünü Seç'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _deselectAllCategories,
                    child: const Text('Temizle'),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const Divider(height: 1),
        
        // Kategori listesi
        Expanded(
          child: ListView.builder(
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategories.contains(category);
              final questionCount = _questionCounts[category] ?? 0;
              
              return ListTile(
                title: Text(category),
                subtitle: Text('$questionCount soru'),
                leading: Checkbox(
                  value: isSelected,
                  onChanged: (value) => _toggleCategory(category),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: () => _toggleCategory(category),
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
}