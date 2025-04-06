import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/question_service.dart';
import 'home_screen.dart';

class ResultScreen extends StatelessWidget {
  final List<Question> questions;
  final QuestionService questionService;
  final List<bool>? results; // Quiz sonuçları (test modunda kullanılır)
  final int? timeSpent; // Sınav süresi (saniye cinsinden, test modunda kullanılır)
  final bool isTestMode; // Test modu mu?

  const ResultScreen({
    Key? key,
    required this.questions,
    required this.questionService,
    this.results,
    this.timeSpent,
    this.isTestMode = false,
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
    
    final scoreGrade = _getScoreGrade(score);
    final scoreColor = _getScoreColor(score);
    
    // Test modu için geçti/kaldı durumu
    final bool passedTest = isTestMode && correctCount >= 6; // Vatandaşlık sınavında geçme sınırı 6/10
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isTestMode ? 'Sınav Sonuçları' : 'Quiz Sonuçları'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Test modu için geçti/kaldı bilgisi
            if (isTestMode)
              _buildTestResultBanner(passedTest),
            
            // Sonuç özeti kartı
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      isTestMode ? 'Sınav Tamamlandı!' : 'Quiz Tamamlandı!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Skor yüzdesi
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: scoreColor.withOpacity(0.1),
                        border: Border.all(
                          color: scoreColor,
                          width: 6,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${score.toInt()}%',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: scoreColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Derece
                    Text(
                      isTestMode 
                        ? (passedTest ? 'GEÇTİNİZ!' : 'KALDINIZ')
                        : scoreGrade,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isTestMode 
                          ? (passedTest ? Colors.green[700] : Colors.red[700])
                          : scoreColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Skor detayı
                    Text(
                      '$correctCount doğru, ${totalQuestions - correctCount} yanlış',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    
                    // Test modunda geçme kriteri bilgisi
                    if (isTestMode) ...[  
                      const SizedBox(height: 8),
                      Text(
                        'Geçme Kriteri: En az 6/10 doğru cevap',
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                    
                    // Test modunda süre bilgisi
                    if (isTestMode && timeSpent != null) ...[  
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.timer, color: Colors.grey[600], size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Toplam Süre: ${_formatDuration(timeSpent!)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    // Başarı rozeti
                    if ((isTestMode && passedTest) || (!isTestMode && score >= 80))
                      _buildAchievementBadge(context, isTestMode),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Soru detayları başlığı
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Cevaplarınız',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            // Soru listesi
            _buildQuestionsList(),
            
            const SizedBox(height: 24),
            
            // Eylem butonları
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(
                            questionService: questionService,
                          ),
                        ),
                        (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Ana Sayfaya Dön'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Yeni bir quiz/test başlat
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(isTestMode ? 'Yeni Sınav' : 'Yeni Quiz'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementBadge(BuildContext context, bool isTestMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isTestMode ? Icons.military_tech : Icons.emoji_events,
            color: Colors.amber[700],
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            isTestMode ? 'ABD Vatandaşlık Sınavını Geçtiniz!' : 'Harika Başarı!',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsList() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: questions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
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
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCorrect ? Colors.green[300]! : Colors.red[300]!,
              width: 1,
            ),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              leading: Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
              ),
              title: Text(
                question.question,
                style: TextStyle(
                  color: isCorrect ? Colors.green[800] : Colors.red[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Kategori: ${question.category}',
                style: TextStyle(
                  color: isCorrect ? Colors.green[600] : Colors.red[600],
                  fontSize: 12,
                ),
              ),
              childrenPadding: const EdgeInsets.all(16),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Doğru Cevap:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                
                // Birden fazla doğru cevap olabilir
                ...question.allCorrectAnswers.map((correctAnswer) => 
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text('• $correctAnswer'),
                  )
                ),
                
                if (question.selectedAnswer != null) ...[  
                  const SizedBox(height: 12),
                  const Text(
                    'Sizin Cevabınız:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    question.selectedAnswer!,
                    style: TextStyle(
                      color: isCorrect ? Colors.green[700] : Colors.red[700],
                      fontWeight: FontWeight.bold,
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

  Widget _buildTestResultBanner(bool passed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: passed ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: passed ? Colors.green[300]! : Colors.red[300]!,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              passed ? Icons.verified : Icons.error_outline,
              color: passed ? Colors.green[700] : Colors.red[700],
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              passed ? 'USCIS Vatandaşlık Sınavını Geçtiniz!' : 'USCIS Vatandaşlık Sınavında Başarısız Oldunuz',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: passed ? Colors.green[700] : Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              passed 
                ? 'Tebrikler! Sivil bilgisi testini başarıyla tamamladınız.'
                : 'Sınavı geçmek için en az 6 soruyu doğru cevaplamanız gerekiyor. Daha fazla pratik yapın ve tekrar deneyin.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: passed ? Colors.green[700] : Colors.red[700],
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

  String _getScoreGrade(double score) {
    if (score >= 90) return 'Mükemmel!';
    if (score >= 80) return 'Çok İyi!';
    if (score >= 70) return 'İyi';
    if (score >= 60) return 'Orta';
    return 'Geliştirilmesi Gerekli';
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return Colors.green[700]!;
    if (score >= 80) return Colors.green;
    if (score >= 70) return Colors.blue;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}