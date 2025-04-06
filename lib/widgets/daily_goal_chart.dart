import 'package:flutter/material.dart';
import '../services/question_service.dart';

class DailyGoalChart extends StatefulWidget {
  final QuestionService questionService;

  const DailyGoalChart({
    Key? key,
    required this.questionService,
  }) : super(key: key);

  @override
  _DailyGoalChartState createState() => _DailyGoalChartState();
}

class _DailyGoalChartState extends State<DailyGoalChart> {
  late int _dailyGoal;
  late int _todayCount;
  late double _completionRate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _dailyGoal = widget.questionService.getDailyGoal();
    _todayCount = widget.questionService.getTodayQuestionCount();
    _completionRate = _todayCount / _dailyGoal;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Günlük Hedef',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showDailyGoalDialog(context),
                  tooltip: 'Günlük hedefi düzenle',
                  color: Colors.grey[600],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Progres bar ve sayaç
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$_todayCount / $_dailyGoal soru',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _completionRate >= 1.0 ? Colors.green : Colors.orange,
                      ),
                    ),
                    Text(
                      '${(_completionRate * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _completionRate >= 1.0 ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // İlerleme çubuğu
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _completionRate.clamp(0, 1.0),
                    minHeight: 16,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _completionRate >= 1.0 ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Tamamlama durumu mesajı
                _buildCompletionMessage(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionMessage() {
    if (_completionRate >= 1.0) {
      return Card(
        color: Colors.green[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.green.withOpacity(0.5)),
        ),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tebrikler! Bugünkü hedefinizi tamamladınız.',
                  style: TextStyle(color: Colors.green[800]),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      final remainingCount = _dailyGoal - _todayCount;
      return Card(
        color: Colors.blue[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.blue.withOpacity(0.5)),
        ),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Bugünkü hedefinizi tamamlamak için $remainingCount soru kaldı.',
                  style: TextStyle(color: Colors.blue[800]),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showDailyGoalDialog(BuildContext context) {
    int goal = _dailyGoal;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Günlük Hedefi Ayarla'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Günlük çözmek istediğiniz soru sayısını belirleyin:'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle),
                  onPressed: () {
                    if (goal > 5) goal--;
                  },
                  color: Colors.red,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return Text(
                        '$goal',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: () {
                    if (goal < 50) goal++;
                  },
                  color: Colors.green,
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await widget.questionService.setDailyGoal(goal);
              Navigator.pop(context);
              setState(() {
                _loadData();
              });
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}