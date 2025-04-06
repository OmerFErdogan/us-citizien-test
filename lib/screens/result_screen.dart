import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/question_service.dart';
import 'home_screen.dart';

class ResultScreen extends StatelessWidget {
  final List<Question> questions;
  final QuestionService questionService;

  const ResultScreen({
    Key? key,
    required this.questions,
    required this.questionService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final answeredQuestions = questions.where((q) => q.isAttempted).toList();
    final correctAnswers = answeredQuestions.where((q) => q.isMarkedCorrect).toList();
    
    final totalQuestions = questions.length;
    final correctCount = correctAnswers.length;
    final score = totalQuestions > 0 ? (correctCount / totalQuestions) * 100 : 0.0;
    
    final scoreGrade = _getScoreGrade(score);
    final scoreColor = _getScoreColor(score);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Sonuçları'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                    const Text(
                      'Quiz Tamamlandı!',
                      style: TextStyle(
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
                      scoreGrade,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
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
                    const SizedBox(height: 24),
                    
                    // Başarı rozeti
                    if (score >= 80)
                      _buildAchievementBadge(context),
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
                      // Yeni bir quiz başlat
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Yeni Quiz'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementBadge(BuildContext context) {
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
            Icons.emoji_events,
            color: Colors.amber[700],
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            'Harika Başarı!',
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
        final isCorrect = question.isMarkedCorrect;
        
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