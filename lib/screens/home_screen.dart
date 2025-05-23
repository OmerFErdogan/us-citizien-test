import 'package:flutter/material.dart';
import '../services/question_service.dart';
import '../services/settings/language_service.dart';
import '../utils/extensions.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/error_content_widget.dart';
import '../widgets/camp_paywall.dart';
import '../services/revenue_cat_service.dart';
import 'tabs/home_tab.dart';
import 'tabs/study_tab.dart';
import 'tabs/progress_tab.dart';
import 'quiz_screen.dart';
import 'category_selection_screen.dart';
import 'test_intro_screen.dart';
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
  int _selectedIndex = 0;
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

  Future<void> _resetProgress() async {
    await widget.questionService.resetAllAnswers();
    _loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBody: true,
      appBar: AppBarWidget(onReset: _resetProgress),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: const Color(0xFF667eea),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading your citizenship journey...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage.isNotEmpty
              ? ErrorContentWidget(errorMessage: _errorMessage)
              : _buildBody(),
      bottomNavigationBar: _isLoading || _errorMessage.isNotEmpty
          ? null
          : BottomNavBar(
              selectedIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
    );
  }

  Widget _buildBody() {
    // Seçilen sekmeye göre farklı içerik göster
    switch (_selectedIndex) {
      case 0:
        return HomeTab(
          todayQuestions: _todayQuestions,
          dailyGoal: _dailyGoal,
          answeredQuestions: _answeredQuestions,
          totalQuestions: _totalQuestions,
          correctRate: _correctRate,
          onRefresh: _loadQuestions,
          onQuizSelected: _navigateToQuizSelection,
          onTestModeSelected: _navigateToTestMode,
          onCampModeSelected: _navigateToCampMode,
        );
      case 1:
        return StudyTab(
          answeredQuestions: _answeredQuestions,
          totalQuestions: _totalQuestions,
          correctRate: _correctRate,
          todayQuestions: _todayQuestions,
          onQuizSelected: _navigateToQuizSelection,
          onFlashcardSelected: _navigateToFlashcardSelection,
          onWrongQuestionsSelected: _navigateToWrongQuestions,
          onTestModeSelected: _navigateToTestMode,
          onCampModeSelected: _navigateToCampMode,
        );
      case 2:
        return ProgressTab(
          answeredQuestions: _answeredQuestions,
          totalQuestions: _totalQuestions,
          correctRate: _correctRate,
          questionService: widget.questionService,
          onReloadData: _loadQuestions,
        );
      default:
        return HomeTab(
          todayQuestions: _todayQuestions,
          dailyGoal: _dailyGoal,
          answeredQuestions: _answeredQuestions,
          totalQuestions: _totalQuestions,
          correctRate: _correctRate,
          onRefresh: _loadQuestions,
          onQuizSelected: _navigateToQuizSelection,
          onTestModeSelected: _navigateToTestMode,
          onCampModeSelected: _navigateToCampMode,
        );
    }
  }

  // Navigation methods
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
      
      // Premium durumunu kontrol et
      final canAccess = await campService.canAccessCampMode();
      
      if (!canAccess) {
        // Premium değilse paywall göster
        final purchased = await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const CampPaywall(),
        );
        
        if (purchased != true) {
          // Satın alma gerçekleşmedi, kamp moduna gitmeden çık
          return;
        }
      }
      
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
