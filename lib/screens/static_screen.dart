import 'package:flutter/material.dart';
import 'package:us_civics_test_app/widgets/weekly_goal_chart.dart';
import '../models/question.dart';
import '../services/question_service.dart';
import '../widgets/category_progress_chart.dart';
import '../widgets/stats_info_card.dart';
import '../widgets/difficult_questions_list.dart';
import '../widgets/daily_goal_chart.dart';

class StatisticsScreen extends StatefulWidget {
  final QuestionService questionService;

  const StatisticsScreen({
    Key? key,
    required this.questionService,
  }) : super(key: key);

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Question> _allQuestions = [];
  Map<String, Map<String, dynamic>> _categoryStats = {};
  List<Question> _difficultQuestions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadStatistics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Tüm soruları yükle
      await widget.questionService.loadQuestions();
      _allQuestions = widget.questionService.getAllQuestions();
      
      // Kategori istatistiklerini hesapla
      _calculateCategoryStatistics();

      // En zorlanılan soruları al (en çok yanlış cevaplanmış olanlar)
      _difficultQuestions = _getDifficultQuestions();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('İstatistikler yüklenirken hata oluştu: $e')),
        );
      }
    }
  }

  void _calculateCategoryStatistics() {
    final Map<String, Map<String, dynamic>> stats = {};
    
    // Tüm benzersiz kategorileri bul
    final categories = _allQuestions.map((q) => q.category).toSet().toList();
    
    for (final category in categories) {
      // Bu kategorideki tüm soruları bul
      final questionsInCategory = _allQuestions.where((q) => q.category == category).toList();
      
      // Bu kategorideki denenen soruları bul
      final attempted = questionsInCategory.where((q) => q.isAttempted).toList();
      
      // Bu kategorideki doğru cevaplanmış soruları bul
      final correct = attempted.where((q) => q.isMarkedCorrect).toList();
      
      // İstatistikleri hesapla
      final totalCount = questionsInCategory.length;
      final attemptedCount = attempted.length;
      final correctCount = correct.length;
      final successRate = attempted.isEmpty ? 0.0 : correctCount / attempted.length;
      final progressRate = totalCount == 0 ? 0.0 : attemptedCount / totalCount;
      
      // İstatistikleri map'e ekle
      stats[category] = {
        'totalCount': totalCount,
        'attemptedCount': attemptedCount,
        'correctCount': correctCount,
        'successRate': successRate,
        'progressRate': progressRate,
      };
    }
    
    // Kategorileri başarı oranına göre sırala (en yüksek başarıdan en düşüğe)
    final sortedCategories = categories.toList()
      ..sort((a, b) => (stats[b]!['successRate'] as double)
          .compareTo(stats[a]!['successRate'] as double));
    
    // Sıralanmış istatistikler map'i oluştur
    final sortedStats = <String, Map<String, dynamic>>{};
    for (final category in sortedCategories) {
      sortedStats[category] = stats[category]!;
    }
    
    _categoryStats = sortedStats;
  }

  List<Question> _getDifficultQuestions() {
    // Denenmiş tüm soruları al
    final attempted = _allQuestions.where((q) => q.isAttempted).toList();
    
    // Yanlış cevaplanmış soruları bul
    final incorrect = attempted.where((q) => !q.isMarkedCorrect).toList();
    
    // Yanlış cevaplanma sıklığına göre sırala (şimdilik sadece yanlış cevapları döndürüyoruz)
    // Burada daha gelişmiş bir sıralama algoritması kullanılabilir
    return incorrect.take(10).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Genel istatistikler
    final totalQuestions = _allQuestions.length;
    final attemptedQuestions = _allQuestions.where((q) => q.isAttempted).length;
    final correctAnswers = _allQuestions.where((q) => q.isMarkedCorrect).length;
    final correctRate = attemptedQuestions > 0 
        ? (correctAnswers / attemptedQuestions) * 100 
        : 0.0;
    final progressRate = totalQuestions > 0 
        ? (attemptedQuestions / totalQuestions) * 100 
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('İstatistikler'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Genel'),
            Tab(text: 'Kategoriler'),
            Tab(text: 'Zorluklar'),
            Tab(text: 'İlerleme'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Genel istatistikler sekmesi
                _buildOverallStatisticsTab(
                  totalQuestions, 
                  attemptedQuestions, 
                  correctAnswers, 
                  correctRate, 
                  progressRate
                ),
                
                // Kategori istatistikleri sekmesi
                _buildCategoryStatisticsTab(),
                
                // Zorluklar sekmesi
                _buildDifficultQuestionsTab(),
                
                // İlerleme sekmesi
                _buildProgressTab(),
              ],
            ),
    );
  }

  Widget _buildOverallStatisticsTab(
    int totalQuestions, 
    int attemptedQuestions, 
    int correctAnswers, 
    double correctRate, 
    double progressRate
  ) {
    return RefreshIndicator(
      onRefresh: _loadStatistics,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Genel ilerleme kartı
            Card(
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
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: progressRate / 100,
                      minHeight: 12,
                      backgroundColor: Colors.grey[300],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tamamlanan: $attemptedQuestions / $totalQuestions (%${progressRate.toStringAsFixed(1)})',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Doğruluk oranı
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Doğruluk Oranı',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: CircularProgressIndicator(
                              value: correctRate / 100,
                              strokeWidth: 12,
                              backgroundColor: Colors.grey[300],
                              color: _getColorForScore(correctRate),
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                '%${correctRate.toStringAsFixed(1)}',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: _getColorForScore(correctRate),
                                ),
                              ),
                              Text(
                                '$correctAnswers / $attemptedQuestions',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getScoreComment(correctRate),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // İstatistik kartları
            Row(
              children: [
                Expanded(
                  child: StatsInfoCard(
                    title: 'Cevaplanan',
                    value: attemptedQuestions.toString(),
                    icon: Icons.check_circle_outline,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsInfoCard(
                    title: 'Doğru',
                    value: correctAnswers.toString(),
                    icon: Icons.thumb_up_alt_outlined,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsInfoCard(
                    title: 'Yanlış',
                    value: (attemptedQuestions - correctAnswers).toString(),
                    icon: Icons.thumb_down_alt_outlined,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryStatisticsTab() {
    return RefreshIndicator(
      onRefresh: _loadStatistics,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Kategori bazlı ilerleme grafiği
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kategori Bazlı Başarı',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: CategoryProgressChart(categoryStats: _categoryStats),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Kategori listesi
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kategori Detayları',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._categoryStats.entries.map((entry) {
                      final category = entry.key;
                      final stats = entry.value;
                      
                      final totalCount = stats['totalCount'] as int;
                      final attemptedCount = stats['attemptedCount'] as int;
                      final correctCount = stats['correctCount'] as int;
                      final successRate = stats['successRate'] as double;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Tamamlanan: $attemptedCount / $totalCount'),
                                      Text('Doğruluk: $correctCount / $attemptedCount'),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: Text(
                                      '%${(successRate * 100).toStringAsFixed(1)}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: _getColorForScore(successRate * 100),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: successRate,
                              minHeight: 8,
                              backgroundColor: Colors.grey[300],
                              color: _getColorForScore(successRate * 100),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            const SizedBox(height: 8),
                            const Divider(),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultQuestionsTab() {
    return RefreshIndicator(
      onRefresh: _loadStatistics,
      child: _difficultQuestions.isEmpty
          ? const Center(
              child: Text(
                'Henüz yanlış cevaplanmış soru bulunmamaktadır.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : DifficultQuestionsList(questions: _difficultQuestions),
    );
  }
  
  Widget _buildProgressTab() {
    return RefreshIndicator(
      onRefresh: _loadStatistics,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Günlük hedef kartı
            DailyGoalChart(questionService: widget.questionService),
            const SizedBox(height: 24),
            
            // Haftalık ilerleme grafiği
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: WeeklyProgressChart(questionService: widget.questionService),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Çalışma önerileri
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Çalışma Önerileri',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildStudyTip(
                      icon: Icons.calendar_today,
                      title: 'Düzenli Çalışın',
                      description: 'Her gün 10-15 dakika düzenli çalışmak, bir günde uzun süre çalışmaktan daha etkilidir.',
                    ),
                    
                    _buildStudyTip(
                      icon: Icons.trending_up,
                      title: 'Zorlanılan Konulara Odaklanın',
                      description: 'Yanlış cevapladığınız soruları düzenli olarak tekrar edin.',
                    ),
                    
                    _buildStudyTip(
                      icon: Icons.repeat,
                      title: 'Tekrar Önemlidir',
                      description: 'Aynı soruları farklı günlerde tekrar çözün. Hatırlama yeteneğinizi geliştirir.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStudyTip({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
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

  Color _getColorForScore(double score) {
    if (score >= 90) return Colors.green[700]!;
    if (score >= 80) return Colors.green;
    if (score >= 70) return Colors.blue;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getScoreComment(double score) {
    if (score >= 90) return 'Mükemmel! Konulara hakim görünüyorsunuz.';
    if (score >= 80) return 'Çok iyi! Birkaç konu üzerinde daha çalışabilirsiniz.';
    if (score >= 70) return 'İyi! Biraz daha pratik yapmalısınız.';
    if (score >= 60) return 'Fena değil. Daha fazla çalışmalısınız.';
    if (score >= 40) return 'Geliştirilebilir. Daha çok pratik yapın.';
    return 'Daha fazla çalışma gerekiyor. Flashcardlar yardımcı olabilir.';
  }
}