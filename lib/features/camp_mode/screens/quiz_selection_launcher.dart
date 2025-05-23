import 'package:flutter/material.dart';
import 'package:us_citizenship_test/features/camp_mode/services/camp_service.dart';
import 'package:us_citizenship_test/models/question.dart';
import 'package:us_citizenship_test/screens/quiz_screen.dart';
import 'package:us_citizenship_test/services/question_service.dart';
import 'package:us_citizenship_test/utils/extensions.dart';


class QuizSelectionLauncher extends StatefulWidget {
  final String title;
  final String description;
  final int questionCount;
  final int? dayNumber; // Doğrudan gün numarası parametresi
  final List<String>? categories; // İsteğe bağlı kategori listesi
  final Function(int score) onComplete;

  const QuizSelectionLauncher({
    Key? key,
    required this.title,
    required this.description,
    required this.questionCount,
    required this.onComplete,
    this.dayNumber,
    this.categories,
  }) : super(key: key);

  @override
  _QuizSelectionLauncherState createState() => _QuizSelectionLauncherState();
}

class _QuizSelectionLauncherState extends State<QuizSelectionLauncher> {
  final QuestionService _questionService = QuestionService();
  final CampService _campService = CampService(); // CampService'i doğrudan sınıf üyesi olarak ekle
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  // İlgili tüm servisleri başlatan yeni bir metod
  Future<void> _initServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Her iki servisi de başlat
      await _questionService.loadQuestions();
      await _campService.initialize();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Bilgi dialogu göster
        _showQuizInfoDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = context.l10n.errorInitialization + e.toString();
        });
      }
    }
  }

  void _showQuizInfoDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(widget.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.description),
            const SizedBox(height: 16),
            Text(
              context.l10n.questionsCount + widget.questionCount.toString() + context.l10n.questionsSuffix,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(context.l10n.prototypeNote),
            const SizedBox(height: 16),
            Text(context.l10n.option1),
            const SizedBox(height: 8),
            Text(context.l10n.option2),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startRealQuiz();
            },
            child: Text(context.l10n.startQuiz),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _simulateQuiz();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.green,
            ),
            child: Text(context.l10n.simulate),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // İki kere pop ile ana ekrana dön
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(context.l10n.cancel),
          ),
        ],
      ),
    );
  }

  Future<void> _startRealQuiz() async {
    // Yükleme durumuna geçiş
    setState(() {
      _isLoading = true;
    });
    
    List<Question> quizQuestions = [];
    
    // Önce CampService'a erişmeyi dene
    try {
      final campService = CampService();
      await campService.initialize(); // Service'i başlat
      
      // Seçilen gün için soruları al
      if (widget.dayNumber != null) {
        // Günün sorularını al
        quizQuestions = campService.getQuestionsForDay(
          widget.dayNumber!,
          categories: widget.categories,
          limit: widget.questionCount
        );
      } else {
        // Başlık veya açıklamadan gün numarasını çıkarmaya çalış
        final dayNumberRegex = RegExp(r'\bDay *(\d+)\b|\bGün *(\d+)\b');
        final match = dayNumberRegex.firstMatch(widget.title) ?? 
                     dayNumberRegex.firstMatch(widget.description);
        
        if (match != null) {
          // Gün numarasını çıkar
          final String? group1 = match.group(1);
          final String? group2 = match.group(2);
          final int dayNumber = int.parse(group1 ?? group2 ?? '1');
          
          // Günün sorularını al
          quizQuestions = campService.getQuestionsForDay(
            dayNumber,
            categories: widget.categories,
            limit: widget.questionCount
          );
        }
      }
    } catch (e) {
      print(context.l10n.campQuestionsError + e.toString());
      // Hata alırsa, normal sorularla devam et
    }
    
    // Eğer kamp sorularını alamadıysak, normal quiz sorularını kullan
    if (quizQuestions.isEmpty) {
      try {
        quizQuestions = _questionService.getRandomQuestions(widget.questionCount);
      } catch (e) {
        print(context.l10n.randomQuestionsError + e.toString());
      }
    }
    
    // Yükleme durumunu kapat
    setState(() {
      _isLoading = false;
    });
    
    // Quiz başlat
    if (quizQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.noQuestionsFound),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Quiz'i başlat
    _startQuizWithQuestions(quizQuestions);
  }
  
  void _startQuizWithQuestions(List<Question> questions) {
    // Quiz ekranına git
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          questionService: _questionService,
          questionCount: widget.questionCount,
          questions: questions,
          onResultScreen: (questions) {
            // Quiz tamamlandığında doğru sayısını hesapla
            final correctCount = questions.where((q) => q.isMarkedCorrect).length;
            
            // Dönmüş sinyalini kaydet - tamamlama işlemlerini async olarak sonrasında yapacağız
            bool returnValue = true;
            
            // Async işlemleri sonrasında çalıştıracağız
            Future.microtask(() async {
              // İlerleme güncellemesi sırasında gösterge
              setState(() {
                _isCompleting = true;
              });

              try {
                // Aktiviteyi tamamlandı olarak işaretle
                if (widget.dayNumber != null) {
                  // Aktivite başlığını al
                  final activityTitle = widget.title;
                  
                  // Aktiviteyi tamamlandı olarak işaretle
                  await _campService.updateActivityCompletion(
                    widget.dayNumber!,
                    activityTitle,
                    true
                  );

                  // Tüm günlük aktivitelerin durumunu kontrol et ve güncelle
                  await _campService.syncProgressWithActivities();
                  
                  // İlave log - debug için
                  print(context.l10n.activityCompleted + 
                        widget.dayNumber.toString() + 
                        context.l10n.activityCompletedTitle + 
                        activityTitle + 
                        context.l10n.activityCompletedCorrect + 
                        correctCount.toString());
                }
              } catch (e) {
                print(context.l10n.progressUpdateError + e.toString());
              } finally {
                // İşlem tamamlandı
                if (mounted) {
                  setState(() {
                    _isCompleting = false;
                  });
                }
              }
            });
            
            // Callback'i çağır
            widget.onComplete(correctCount);
            
            return returnValue; // Sonuç ekranını göster
          },
        ),
      ),
    );
  }
  
  void _simulateQuiz() {
    // Quiz tamamlandı simülasyonu
    final randomSuccess = 0.85 + (0.10 * (DateTime.now().millisecond / 1000.0));
    final simulatedScore = (widget.questionCount * randomSuccess).round();
    
    // İlerleme güncellemesi
    setState(() {
      _isCompleting = true;
    });

    // Aktivite tamamlama işlemi
    _completeActivity(simulatedScore).then((_) {
      // İlerlemeyi bitir
      setState(() {
        _isCompleting = false;
      });
      
      // Önce callback'i çağır
      widget.onComplete(simulatedScore);
      
      // Puanlama dialog'ını göster
      _showCompletionDialog(simulatedScore);
    }).catchError((e) {
      print(context.l10n.simulationCompletionError + e.toString());
      setState(() {
        _isCompleting = false;
      });
      
      // Hataya rağmen callback'i çağır
      widget.onComplete(simulatedScore);
      
      // Dialog'u göster
      _showCompletionDialog(simulatedScore);
    });
  }
  
  // Aktivite tamamlama işlemi için yeni metod
  Future<void> _completeActivity(int score) async {
    try {
      if (widget.dayNumber != null) {
        // Aktivite başlığını al
        final activityTitle = widget.title;
        
        // Aktiviteyi tamamlandı olarak işaretle
        await _campService.updateActivityCompletion(
          widget.dayNumber!,
          activityTitle,
          true
        );

        // Tüm günlük aktivitelerin durumunu kontrol et ve güncelle
        await _campService.syncProgressWithActivities();
        
        // İlave log - debug için
        print(context.l10n.simulatedActivityCompleted + 
              widget.dayNumber.toString() + 
              context.l10n.activityCompletedTitle + 
              activityTitle + 
              context.l10n.activityCompletedCorrect + 
              score.toString());
      }
    } catch (e) {
      print(context.l10n.activityCompletionError + e.toString());
      rethrow; // Hatayı yukarı ilet
    }
  }
  
  // Tamamlama dialog'unu gösterme
  void _showCompletionDialog(int score) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.quizCompleted),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.congratulations + score.toString() + '/' + widget.questionCount.toString() + context.l10n.correctQuestions,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.successRate + (score / widget.questionCount * 100).round().toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Dialog'u kapat
              Navigator.pop(context);
              // Ana ekrana dön
              Navigator.pop(context);
            },
            child: Text(context.l10n.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          // Ana içerik
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(context.l10n.goBack),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => _initServices(),
                              child: Text(context.l10n.tryAgain),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
                  
          // İşlem göstergesi
          if (_isCompleting)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.savingProgress,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}