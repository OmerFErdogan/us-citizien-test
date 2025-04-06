import 'package:flutter/material.dart';
import '../services/question_service.dart';
import 'quiz_screen.dart';
import 'flashcard_screen.dart';

class HomeScreen extends StatefulWidget {
  final QuestionService questionService; // Bu parametre eklendi

  const HomeScreen({
    Key? key, 
    required this.questionService, // Constructor'a eklendi
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  int _totalQuestions = 0;
  int _answeredQuestions = 0;
  double _correctRate = 0.0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // widget.questionService kullanılarak veri çekilecek
      await widget.questionService.loadQuestions();
      
      // Calculate statistics
      final allQuestions = widget.questionService.getAllQuestions();
      final attempted = allQuestions.where((q) => q.isAttempted).toList();
      final correct = attempted.where((q) => q.isMarkedCorrect).toList();
      
      setState(() {
        _totalQuestions = allQuestions.length;
        _answeredQuestions = attempted.length;
        _correctRate = attempted.isEmpty ? 0.0 : correct.length / attempted.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Sorular yüklenirken bir hata oluştu: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğrenme Uygulaması'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
              : _buildHomeContent(),
    );
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: _loadQuestions,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // İlerleme özeti kartı
            _buildProgressCard(),
            const SizedBox(height: 24),
            
            // Ana seçenekler için kartlar
            _buildActionCard(
              title: 'Quiz Başlat',
              description: 'Bilgilerini test etmek için 10 soruluk quiz',
              icon: Icons.quiz,
              color: Colors.indigo,
              onTap: () => _navigateToQuiz(context),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              title: 'Flashcardlar',
              description: 'Soruları ve cevapları kartlarla öğren',
              icon: Icons.flip,
              color: Colors.teal,
              onTap: () => _navigateToFlashcards(context),
            ),
            const SizedBox(height: 32),

            // Gelişmiş Ayarlar ve İstatistikler butonu
            OutlinedButton.icon(
              onPressed: () {
                // İstatistikler sayfasına git (Henüz impl. edilmedi)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('İstatistik sayfası yakında eklenecek')),
                );
              },
              icon: const Icon(Icons.bar_chart),
              label: const Text('Detaylı İstatistikler'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Öğrenme İlerlemen',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  label: 'Toplam Soru',
                  value: '$_totalQuestions',
                  icon: Icons.help_outline,
                ),
                _buildStatItem(
                  label: 'Cevaplanan',
                  value: '$_answeredQuestions',
                  icon: Icons.check_circle_outline,
                ),
                _buildStatItem(
                  label: 'Başarı Oranı',
                  value: '${(_correctRate * 100).toStringAsFixed(1)}%',
                  icon: Icons.trending_up,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _answeredQuestions / (_totalQuestions > 0 ? _totalQuestions : 1),
              minHeight: 8,
              backgroundColor: Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToQuiz(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(questionService: widget.questionService),
      ),
    ).then((_) => _loadQuestions());
  }

  void _navigateToFlashcards(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlashcardScreen(questionService: widget.questionService),
      ),
    ).then((_) => _loadQuestions());
  }
}