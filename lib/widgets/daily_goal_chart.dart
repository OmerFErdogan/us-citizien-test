import 'package:flutter/material.dart';
import '../services/question_service.dart';

class DailyGoalChart extends StatelessWidget {
  final QuestionService questionService;
  
  const DailyGoalChart({
    Key? key,
    required this.questionService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dailyGoal = questionService.getDailyGoal();
    final todayCount = questionService.getTodayQuestionCount();
    final completionRate = questionService.getDailyGoalCompletionRate();
    
    final isCompleted = todayCount >= dailyGoal;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Günlük Hedefiniz',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[700], size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Tamamlandı!',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            
            // İlerleme grafiği
            Column(
              children: [
                // Hedef sayısı
                Text(
                  '$todayCount / $dailyGoal soru',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.green[700] : Colors.blue[700],
                  ),
                ),
                const SizedBox(height: 8),
                
                // İlerleme çubuğu
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: completionRate.clamp(0.0, 1.0),
                    minHeight: 16,
                    backgroundColor: Colors.grey[200],
                    color: isCompleted ? Colors.green : Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Bilgi metni
                Text(
                  isCompleted
                      ? 'Tebrikler! Bugünkü hedefinizi tamamladınız.'
                      : 'Hedefinizi tamamlamak için ${dailyGoal - todayCount} soru daha cevaplayın.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Hedefi düzenle butonu
            OutlinedButton.icon(
              onPressed: () => _showGoalEditDialog(context),
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Günlük Hedefi Düzenle'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showGoalEditDialog(BuildContext context) {
    final currentGoal = questionService.getDailyGoal();
    int newGoal = currentGoal;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Günlük Hedefi Düzenle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Her gün tamamlamak istediğiniz soru sayısını belirleyin:'),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    Text(
                      newGoal.toString(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Slider(
                      value: newGoal.toDouble(),
                      min: 5,
                      max: 50,
                      divisions: 9,
                      label: newGoal.toString(),
                      onChanged: (value) {
                        setState(() {
                          newGoal = value.round();
                        });
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              questionService.setDailyGoal(newGoal);
              Navigator.pop(context);
              // Ekranı yenile - Bu genellikle StatefulWidget içinde setState ile yapılır
              // Bu widget genellikle bir parent widget tarafından yeniden oluşturulur
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}