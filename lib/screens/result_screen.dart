import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/question_service.dart';
import '../utils/extensions.dart';
import 'home_screen.dart';

class ResultScreen extends StatelessWidget {
  final List<Question> questions;
  final QuestionService questionService;
  final List<bool>? results; // Quiz sonuçları (test modunda kullanılır)
  final int? timeSpent; // Sınav süresi (saniye cinsinden, test modunda kullanılır)
  final bool isTestMode; // Test modu mu?
  final VoidCallback? onGoBack; // Geri dönüş callback'i

  const ResultScreen({
    Key? key,
    required this.questions,
    required this.questionService,
    this.results,
    this.timeSpent,
    this.isTestMode = false,
    this.onGoBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late List<Question> answeredQuestions;
    late List<Question> correctAnswers;
    late int correctCount;
    
    if (isTestMode && results != null) {
      // Test modunda, sonuçlar doğrudan parametreden alınır
      correctCount = results!.where((result) => result).length;
    } else {
      // Normal quiz modunda
      answeredQuestions = questions.where((q) => q.isAttempted).toList();
      correctAnswers = answeredQuestions.where((q) => q.isMarkedCorrect).toList();
      correctCount = correctAnswers.length;
    }
    
    final totalQuestions = questions.length;
    final score = totalQuestions > 0 ? (correctCount / totalQuestions) * 100 : 0.0;
    
    final scoreColor = _getScoreColor(score);
    
    // Test modu için geçti/kaldı durumu
    final bool passedTest = isTestMode && correctCount >= 6; // Vatandaşlık sınavında geçme sınırı 6/10
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isTestMode ? context.l10n.examResults : context.l10n.quizResults),
        automaticallyImplyLeading: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive design için gerekli ölçüleri belirleyelim
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;
          final isLargeScreen = screenWidth > 900;
          final isMediumScreen = screenWidth > 600 && screenWidth <= 900;
          final isPortrait = screenHeight > screenWidth;
          
          // Örneğin tablet ve laptop gibi cihazlarda yan yana görünüm kullanılabilir
          final useWideLayout = !isPortrait && screenWidth >= 700 || screenWidth >= 900;
          
          // Dinamik boyutlandırma değerleri
          final double contentPadding = isLargeScreen ? 32.0 : (isMediumScreen ? 24.0 : 16.0);
          final double itemSpacing = isLargeScreen ? 32.0 : (isMediumScreen ? 24.0 : 16.0);
          final double cardPadding = isLargeScreen ? 32.0 : (isMediumScreen ? 24.0 : 20.0);
          final double titleFontSize = isLargeScreen ? 30.0 : (isMediumScreen ? 26.0 : 24.0);
          final double scoreFontSize = isLargeScreen ? 36.0 : (isMediumScreen ? 32.0 : 28.0);
          final double scoreCircleSize = isLargeScreen ? 150.0 : (isMediumScreen ? 130.0 : 120.0);
          final double scoreCircleBorderWidth = isLargeScreen ? 8.0 : 6.0;
          
          if (useWideLayout) {
            // Geniş ekranlarda 2 sütunlu yerleşim
            return SingleChildScrollView(
              padding: EdgeInsets.all(contentPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Test modu için geçti/kaldı bilgisi
                  if (isTestMode)
                    _buildTestResultBanner(context, passedTest, isLargeScreen: isLargeScreen),
                  
                  // Ana içerik: Yanyana sonuç kartı ve sorular
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sol taraf: Sonuç özeti kartı
                      Expanded(
                        flex: 2,
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(isLargeScreen ? 20 : 16),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(cardPadding),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Quiz/Exam tamamlandı başlığı
                                Text(
                                  isTestMode ? context.l10n.examCompleted : context.l10n.quizCompleted,
                                  style: TextStyle(
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: itemSpacing),
                                
                                // Skor yüzdesi
                                Container(
                                  width: scoreCircleSize,
                                  height: scoreCircleSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: scoreColor.withOpacity(0.1),
                                    border: Border.all(
                                      color: scoreColor,
                                      width: scoreCircleBorderWidth,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${score.toInt()}%',
                                      style: TextStyle(
                                        fontSize: scoreFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: scoreColor,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: itemSpacing * 0.75),
                                
                                // Derece
                                Text(
                                  isTestMode 
                                    ? (passedTest ? context.l10n.pass : context.l10n.fail)
                                    : _getScoreGrade(context, score),
                                  style: TextStyle(
                                    fontSize: isLargeScreen ? 26 : 24,
                                    fontWeight: FontWeight.bold,
                                    color: isTestMode 
                                      ? (passedTest ? Colors.green[700] : Colors.red[700])
                                      : scoreColor,
                                  ),
                                ),
                                SizedBox(height: isLargeScreen ? 12 : 8),
                                
                                // Skor detayı
                                Text(
                                  context.l10n.correctIncorrect(correctCount, totalQuestions - correctCount),
                                  style: TextStyle(
                                    fontSize: isLargeScreen ? 18 : 16,
                                    color: Colors.grey[700],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                
                                // Test modunda geçme kriteri bilgisi
                                if (isTestMode) ...[  
                                  SizedBox(height: isLargeScreen ? 12 : 8),
                                  Text(
                                    context.l10n.passCriteria,
                                    style: TextStyle(
                                      fontSize: isLargeScreen ? 16 : 14,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey[700],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                                
                                // Test modunda süre bilgisi
                                if (isTestMode && timeSpent != null) ...[  
                                  SizedBox(height: isLargeScreen ? 20 : 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.timer, color: Colors.grey[600], size: isLargeScreen ? 20 : 16),
                                      SizedBox(width: isLargeScreen ? 6 : 4),
                                      Text(
                                        context.l10n.totalTime(_formatDuration(timeSpent!)),
                                        style: TextStyle(
                                          fontSize: isLargeScreen ? 16 : 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                
                                SizedBox(height: itemSpacing),
                                
                                // Başarı rozeti
                                if ((isTestMode && passedTest) || (!isTestMode && score >= 80))
                                  _buildAchievementBadge(context, isTestMode, isLargeScreen: isLargeScreen),
                                
                                SizedBox(height: itemSpacing),
                                
                                // Eylem butonları
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          Navigator.of(context).popUntil((route) => route.isFirst);
                                        },
                                        style: OutlinedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(vertical: isLargeScreen ? 16 : 12),
                                        ),
                                        child: Text(
                                          context.l10n.homePage,
                                          style: TextStyle(fontSize: isLargeScreen ? 16 : 14),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: isLargeScreen ? 20 : 16),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(vertical: isLargeScreen ? 16 : 12),
                                        ),
                                        child: Text(
                                          isTestMode ? context.l10n.newExam : context.l10n.newQuiz,
                                          style: TextStyle(fontSize: isLargeScreen ? 16 : 14),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(width: itemSpacing),
                      
                      // Sağ taraf: Soru listesi
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Soru detayları başlığı
                            Padding(
                              padding: EdgeInsets.only(left: 8.0, bottom: isLargeScreen ? 16.0 : 8.0),
                              child: Text(
                                context.l10n.yourAnswers,
                                style: TextStyle(
                                  fontSize: isLargeScreen ? 22 : 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            
                            // Soru listesi
                            _buildQuestionsList(context, isLargeScreen: isLargeScreen),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else {
            // Normal tek sütunlu mobil yerleşimi
            return SingleChildScrollView(
              padding: EdgeInsets.all(contentPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Test modu için geçti/kaldı bilgisi
                  if (isTestMode)
                    _buildTestResultBanner(context, passedTest, isLargeScreen: isLargeScreen),
                  
                  // Sonuç özeti kartı
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isLargeScreen ? 20 : 16),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(cardPadding),
                      child: Column(
                        children: [
                          Text(
                            isTestMode ? context.l10n.examCompleted : context.l10n.quizCompleted,
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: itemSpacing),
                          
                          // Skor yüzdesi
                          Container(
                            width: scoreCircleSize,
                            height: scoreCircleSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: scoreColor.withOpacity(0.1),
                              border: Border.all(
                                color: scoreColor,
                                width: scoreCircleBorderWidth,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${score.toInt()}%',
                                style: TextStyle(
                                  fontSize: scoreFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: scoreColor,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: itemSpacing * 0.75),
                          
                          // Derece
                          Text(
                            isTestMode 
                              ? (passedTest ? context.l10n.pass : context.l10n.fail)
                              : _getScoreGrade(context, score),
                            style: TextStyle(
                              fontSize: isLargeScreen ? 26 : 24,
                              fontWeight: FontWeight.bold,
                              color: isTestMode 
                                ? (passedTest ? Colors.green[700] : Colors.red[700])
                                : scoreColor,
                            ),
                          ),
                          SizedBox(height: isLargeScreen ? 12 : 8),
                          
                          // Skor detayı
                          Text(
                            context.l10n.correctIncorrect(correctCount, totalQuestions - correctCount),
                            style: TextStyle(
                              fontSize: isLargeScreen ? 18 : 16,
                              color: Colors.grey[700],
                            ),
                          ),
                          
                          // Test modunda geçme kriteri bilgisi
                          if (isTestMode) ...[  
                            SizedBox(height: isLargeScreen ? 12 : 8),
                            Text(
                              context.l10n.passCriteria,
                              style: TextStyle(
                                fontSize: isLargeScreen ? 16 : 14,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                          
                          // Test modunda süre bilgisi
                          if (isTestMode && timeSpent != null) ...[  
                            SizedBox(height: isLargeScreen ? 20 : 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.timer, color: Colors.grey[600], size: isLargeScreen ? 20 : 16),
                                SizedBox(width: isLargeScreen ? 6 : 4),
                                Text(
                                  context.l10n.totalTime(_formatDuration(timeSpent!)),
                                  style: TextStyle(
                                    fontSize: isLargeScreen ? 16 : 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                          
                          SizedBox(height: itemSpacing),
                          
                          // Başarı rozeti
                          if ((isTestMode && passedTest) || (!isTestMode && score >= 80))
                            _buildAchievementBadge(context, isTestMode, isLargeScreen: isLargeScreen),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: itemSpacing),
                  
                  // Soru detayları başlığı
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      context.l10n.yourAnswers,
                      style: TextStyle(
                        fontSize: isLargeScreen ? 22 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 16 : 8),
                  
                  // Soru listesi
                  _buildQuestionsList(context, isLargeScreen: isLargeScreen),
                  
                  SizedBox(height: itemSpacing),
                  
                  // Eylem butonları
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: isLargeScreen ? 16 : 12),
                          ),
                          child: Text(
                            context.l10n.homePage,
                            style: TextStyle(fontSize: isLargeScreen ? 16 : 14),
                          ),
                        ),
                      ),
                      SizedBox(width: isLargeScreen ? 20 : 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: isLargeScreen ? 16 : 12),
                          ),
                          child: Text(
                            isTestMode ? context.l10n.newExam : context.l10n.newQuiz,
                            style: TextStyle(fontSize: isLargeScreen ? 16 : 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildAchievementBadge(BuildContext context, bool isTestMode, {bool isLargeScreen = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 20 : 16, 
        vertical: isLargeScreen ? 10 : 8
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isLargeScreen ? 24 : 20),
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: isLargeScreen ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isTestMode ? Icons.military_tech : Icons.emoji_events,
            color: Colors.amber[700],
            size: isLargeScreen ? 28 : 24,
          ),
          SizedBox(width: isLargeScreen ? 10 : 8),
          Text(
            isTestMode ? context.l10n.passedUSCISExam : context.l10n.greatAchievement,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: isLargeScreen ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsList(BuildContext parentContext, {bool isLargeScreen = false}) {
    final double spacing = isLargeScreen ? 12.0 : 8.0;
    final double borderRadius = isLargeScreen ? 16.0 : 12.0;
    final double titleFontSize = isLargeScreen ? 18.0 : 16.0;
    final double contentFontSize = isLargeScreen ? 16.0 : 14.0;
    final double subtitleFontSize = isLargeScreen ? 14.0 : 12.0;
    final double iconSize = isLargeScreen ? 28.0 : 24.0;
    final double padding = isLargeScreen ? 20.0 : 16.0;
    
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: questions.length,
      separatorBuilder: (_, index) => SizedBox(height: spacing),
      itemBuilder: (_, index) {
        final question = questions[index];
        late bool isCorrect;
        
        // Test modunda sonuçları parametreden, normal quiz modunda sorudan al
        if (isTestMode && results != null) {
          isCorrect = results![index];
        } else {
          isCorrect = question.isMarkedCorrect;
        }
        
        return Container(
          decoration: BoxDecoration(
            color: isCorrect ? Colors.green[50] : Colors.red[50],
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isCorrect ? Colors.green[300]! : Colors.red[300]!,
              width: isLargeScreen ? 1.5 : 1.0,
            ),
          ),
          child: Theme(
            data: Theme.of(parentContext).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              leading: Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
                size: iconSize,
              ),
              title: Text(
                question.question,
                style: TextStyle(
                  color: isCorrect ? Colors.green[800] : Colors.red[800],
                  fontWeight: FontWeight.bold,
                  fontSize: titleFontSize,
                ),
              ),
              subtitle: Text(
                parentContext.l10n.category(question.category),
                style: TextStyle(
                  color: isCorrect ? Colors.green[600] : Colors.red[600],
                  fontSize: subtitleFontSize,
                ),
              ),
              childrenPadding: EdgeInsets.all(padding),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parentContext.l10n.correctAnswer,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: contentFontSize,
                  ),
                ),
                SizedBox(height: spacing / 2),
                
                // Birden fazla doğru cevap olabilir
                ...question.allCorrectAnswers.map((correctAnswer) => 
                  Padding(
                    padding: EdgeInsets.only(bottom: spacing / 2),
                    child: Text(
                      '• $correctAnswer',
                      style: TextStyle(fontSize: contentFontSize),
                    ),
                  )
                ),
                
                if (question.selectedAnswer != null) ...[  
                  SizedBox(height: spacing * 1.5),
                  Text(
                    parentContext.l10n.yourAnswer,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: contentFontSize,
                    ),
                  ),
                  SizedBox(height: spacing / 2),
                  Text(
                    question.selectedAnswer!,
                    style: TextStyle(
                      color: isCorrect ? Colors.green[700] : Colors.red[700],
                      fontWeight: FontWeight.bold,
                      fontSize: contentFontSize,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTestResultBanner(BuildContext context, bool passed, {bool isLargeScreen = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: isLargeScreen ? 24.0 : 16.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: passed ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(isLargeScreen ? 16.0 : 12.0),
        border: Border.all(
          color: passed ? Colors.green[300]! : Colors.red[300]!,
          width: isLargeScreen ? 2.5 : 2.0,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isLargeScreen ? 24.0 : 16.0),
        child: Column(
          children: [
            Icon(
              passed ? Icons.verified : Icons.error_outline,
              color: passed ? Colors.green[700] : Colors.red[700],
              size: isLargeScreen ? 64.0 : 48.0,
            ),
            SizedBox(height: isLargeScreen ? 16.0 : 12.0),
            Text(
              passed ? context.l10n.passedUSCISExamBanner : context.l10n.failedUSCISExamBanner,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isLargeScreen ? 22.0 : 18.0,
                fontWeight: FontWeight.bold,
                color: passed ? Colors.green[700] : Colors.red[700],
              ),
            ),
            SizedBox(height: isLargeScreen ? 12.0 : 8.0),
            Text(
              passed 
                ? context.l10n.congratsPassedCivics
                : context.l10n.needMorePractice,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: passed ? Colors.green[700] : Colors.red[700],
                fontSize: isLargeScreen ? 16.0 : 14.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _getScoreGrade(BuildContext context, double score) {
    if (score >= 90) return context.l10n.excellent;
    if (score >= 80) return context.l10n.veryGood;
    if (score >= 70) return context.l10n.good;
    if (score >= 60) return context.l10n.average;
    return context.l10n.needsImprovement;
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return Colors.green[700]!;
    if (score >= 80) return Colors.green;
    if (score >= 70) return Colors.blue;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}