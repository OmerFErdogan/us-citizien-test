import 'package:flutter/material.dart';
import 'package:us_civics_test_app/screens/language_selection_screen.dart';
import 'package:us_civics_test_app/screens/static_screen.dart';
import 'package:us_civics_test_app/screens/test_intro_screen.dart';
import '../services/question_service.dart';
import '../services/settings/language_service.dart';
import '../utils/extensions.dart';
import 'quiz_screen.dart';
import 'category_selection_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../features/camp_mode/screens/camp_intro_screen.dart';
import '../features/camp_mode/services/camp_service.dart';



class HomeScreen extends StatefulWidget {
  final QuestionService questionService;
  final LanguageService languageService;

  const HomeScreen({
    Key? key, 
    required this.questionService,
    required this.languageService,
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
  int _todayQuestions = 0;
  int _dailyGoal = 10;

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

      // Soru verilerini yükle
      await widget.questionService.loadQuestions();
      
      // İstatistikleri hesapla
      final allQuestions = widget.questionService.getAllQuestions();
      final attempted = allQuestions.where((q) => q.isAttempted).toList();
      final correct = attempted.where((q) => q.isMarkedCorrect).toList();
      
      // Günlük istatistikler
      final todayQuestions = widget.questionService.getTodayQuestionCount();
      final dailyGoal = widget.questionService.getDailyGoal();
      
      setState(() {
        _totalQuestions = allQuestions.length;
        _answeredQuestions = attempted.length;
        _correctRate = attempted.isEmpty ? 0.0 : correct.length / attempted.length;
        _todayQuestions = todayQuestions;
        _dailyGoal = dailyGoal;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = context.l10n.errorLoading('$e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue.shade800,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/american_flag_icon.png',
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.americanDream,
              style: TextStyle(
                fontWeight: FontWeight.w600, 
                fontSize: 18,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.settings_outlined, color: Colors.blue.shade800),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LanguageSelectionScreen(),
              ),
            );
          },
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_horiz, color: Colors.blue.shade800),
            offset: const Offset(0, 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (value) async {
              if (value == 'reset') {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Text(context.l10n.attention),
                    content: Text(context.l10n.resetProgressWarning),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(context.l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(context.l10n.reset),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                      ),
                    ],
                  ),
                ) ?? false;
                
                if (confirmed) {
                  await widget.questionService.resetAllAnswers();
                  _loadQuestions();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.progressReset),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: EdgeInsets.all(16),
                    ),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'reset',
                child: Row(
                  children: [
                    const Icon(Icons.restore, color: Colors.red),
                    const SizedBox(width: 12),
                    Text(
                      context.l10n.resetProgress,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.blue.shade700,
                strokeWidth: 3,
              ),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage, 
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
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
            // Motivasyon banner'ı
            _buildAmericanDreamBanner(),
            const SizedBox(height: 16),
            // Günlük hedef özeti
            _buildDailyGoalCard(),
            const SizedBox(height: 24),
            
            // İlerleme özeti kartı
            _buildProgressCard(),
            const SizedBox(height: 24),
            
            // Ana seçenekler için kartlar
            _buildActionCard(
              title: context.l10n.citizenshipExam,
              description: context.l10n.oneStepCloser,
              icon: Icons.star,
              color: Colors.blue,
              onTap: () => _navigateToQuizSelection(context),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              title: context.l10n.libertyCards,
              description: context.l10n.learnWithCards,
              icon: Icons.flip,
              color: Colors.red,
              onTap: () => _navigateToFlashcardSelection(context),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              title: context.l10n.secondChance,
              description: context.l10n.neverGiveUp,
              icon: Icons.assignment_late,
              color: Colors.indigo,
              onTap: () => _navigateToWrongQuestions(context),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              title: context.l10n.citizenshipExam,
              description: context.l10n.realExamSimulation,
              icon: Icons.workspace_premium,
              color: Colors.green,
              onTap: () => _navigateToTestMode(context),
              isHighlighted: true,
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              title: context.l10n.tenDayCamp,
              description: context.l10n.tenDayCampDescription,
              icon: Icons.calendar_month,
              color: Colors.purple,
              onTap: () => _navigateToCampMode(context),
              isHighlighted: true,
            ),
            const SizedBox(height: 32),

            // İstatistikler butonu
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StatisticsScreen(
                      questionService: widget.questionService,
                    ),
                  ),
                ).then((_) => _loadQuestions());
              },
              icon: const Icon(Icons.bar_chart),
              label: Text(context.l10n.detailedStatisticsButton),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyGoalCard() {
    final goalCompletion = _todayQuestions / _dailyGoal;
    final isCompleted = _todayQuestions >= _dailyGoal;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          // Arkaplan deseni - Amerika Bayrağı Motifleri
          Positioned(
            right: -10,
            top: -10,
            child: Icon(
              Icons.star_outline,
              size: 60,
              color: Colors.blue.withOpacity(0.05),
            ),
          ),
          Positioned(
            left: -15,
            bottom: -15,
            child: Icon(
              Icons.star_outline,
              size: 80,
              color: Colors.red.withOpacity(0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.stars,
                          color: Colors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.dailyCitizenshipGoal,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.blue[700], size: 16),
                            const SizedBox(width: 4),
                            Text(
                            context.l10n.missionComplete,
                            style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // İlerleme göstergesi
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_todayQuestions} / ${_dailyGoal} soru',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isCompleted ? Colors.blue[700] : Colors.red[700],
                          ),
                        ),
                        Text(
                          '${(goalCompletion * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isCompleted ? Colors.blue[700] : Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // İlerleme çubuğu
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: goalCompletion.clamp(0.0, 1.0),
                          minHeight: 12,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isCompleted ? Colors.blue[600]! : Colors.red[500]!,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
            Text(
              context.l10n.learningProgressTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  label: context.l10n.totalQuestions,
                  value: '$_totalQuestions',
                  icon: Icons.help_outline,
                ),
                _buildStatItem(
                  label: context.l10n.answered,
                  value: '$_answeredQuestions',
                  icon: Icons.check_circle_outline,
                ),
                _buildStatItem(
                  label: context.l10n.successRate,
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

  Widget _buildAmericanDreamBanner() {
    return Card(
      elevation: 4,
      color: Colors.blue.shade800,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade700,
              Colors.indigo.shade900,
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/statue_of_liberty_icon.png',
                  width: 28,
                  height: 28,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Text(
                  context.l10n.americanDream,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(width: 8),
                Image.asset(
                  'assets/images/american_flag_icon.png',
                  width: 24,
                  height: 24,
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              context.l10n.dreamMotivation,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                _buildProgressStep(1, context.l10n.knowledge, Colors.green[300]!),
                _buildStepConnector(),
                _buildProgressStep(2, context.l10n.exam, Colors.amber[300]!),
                _buildStepConnector(),
                _buildProgressStep(3, context.l10n.citizenship, Colors.red[300]!),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStep(int number, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector() {
    return Container(
      width: 20,
      height: 2,
      color: Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildStatItem({
    required dynamic label,
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
          label.toString(),
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
    bool isHighlighted = false,
  }) {
    return Card(
      elevation: isHighlighted ? 5 : 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Amerikan Bayrağı Renkleri Arkaplanı
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.red.shade100, Colors.red.shade300, Colors.blue.shade300],
                  ),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
              ),
            ),
            
            // Öne çıkan özellik için özel banner (test modu gibi)
            if (isHighlighted)
              Positioned(
                right: 0,
                top: 12,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.new_releases, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text(
                        context.l10n.newFeature,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withOpacity(0.2), width: 2),
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
                            color: Colors.grey[700],
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
          ],
        ),
      ),
    );
  }

  void _navigateToTestMode(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestIntroScreen(
          questionService: widget.questionService,
        ),
      ),
    ).then((_) => _loadQuestions());
  }

  void _navigateToQuizSelection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategorySelectionScreen(
          questionService: widget.questionService,
          isForQuiz: true,
        ),
      ),
    ).then((_) => _loadQuestions());
  }

  void _navigateToFlashcardSelection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategorySelectionScreen(
          questionService: widget.questionService,
          isForQuiz: false,
        ),
      ),
    ).then((_) => _loadQuestions());
  }

  void _navigateToWrongQuestions(BuildContext context) {
    // Yanlış cevaplanmış soruları kontrol et
    final wrongQuestions = widget.questionService.getIncorrectAnsweredQuestions();
    
    if (wrongQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.noWrongQuestionsYet),
        ),
      );
      return;
    }
    
    // Yanlış cevaplanmış soruları quiz formatında al
    final quizQuestions = widget.questionService.getIncorrectAnsweredQuestionsForQuiz();
    final questionCount = quizQuestions.length > 10 ? 10 : quizQuestions.length;
    
    // Yanlış cevaplanmış sorularla bir quiz başlat
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          questionService: widget.questionService,
          questionCount: questionCount,
          questions: quizQuestions.take(questionCount).toList(),
        ),
      ),
    ).then((_) => _loadQuestions());
  }
  
  void _navigateToCampMode(BuildContext context) async {
    try {
      // Kamp moduna geçmeden önce servisi başlat ve senkronize et
      final campService = CampService();
      await campService.initialize();
      await campService.syncProgressWithActivities();
      
      // Kamp ekranına yönlendir
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CampIntroScreen(),
        ),
      ).then((_) => _loadQuestions());
    } catch (e) {
      print('Kamp moduna geçiş hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.campModeError),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}