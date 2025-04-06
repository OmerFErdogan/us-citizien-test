import 'package:flutter/material.dart';
import '../services/question_service.dart';

class WeeklyProgressChart extends StatefulWidget {
  final QuestionService questionService;
  
  const WeeklyProgressChart({
    Key? key,
    required this.questionService,
  }) : super(key: key);

  @override
  _WeeklyProgressChartState createState() => _WeeklyProgressChartState();
}

class _WeeklyProgressChartState extends State<WeeklyProgressChart> {
  Map<String, int> _weeklyStats = {};
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadWeeklyStats();
  }
  
  Future<void> _loadWeeklyStats() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final stats = await widget.questionService.getLast7DaysStats();
      setState(() {
        _weeklyStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_weeklyStats.isEmpty) {
      return const Center(child: Text('Henüz istatistik veri bulunmamaktadır.'));
    }
    
    // Tarihleri son 7 günü içerecek şekilde sırala
    final sortedDates = _weeklyStats.keys.toList()
      ..sort((a, b) => a.compareTo(b));
    
    // En yüksek değeri bul (grafik ölçeklendirmesi için)
    final maxValue = _weeklyStats.values.fold<int>(0, 
        (max, value) => value > max ? value : max);
    
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Son 7 Günlük İlerleme',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          SizedBox(
            height: 200,
            child: Row(
              children: sortedDates.map((dateStr) {
                final date = DateTime.parse(dateStr);
                final dayName = _getDayName(date.weekday);
                final value = _weeklyStats[dateStr] ?? 0;
                final barHeight = maxValue > 0 
                    ? (value / maxValue * 150) 
                    : 0.0;
                
                final isToday = _isDateToday(date);
                
                return Expanded(
                  child: Column(
                    children: [
                      Text(
                        value.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isToday ? Colors.blue : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 150,
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: 20,
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: isToday 
                                ? Colors.blue 
                                : Colors.blue.withOpacity(0.6),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dayName,
                        style: TextStyle(
                          fontSize: 12,
                          color: isToday ? Colors.blue : Colors.grey[700],
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Açıklama metni
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              'Her çubuk, o gün cevaplanmış soru sayısını gösterir.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Pzt';
      case 2: return 'Sal';
      case 3: return 'Çar';
      case 4: return 'Per';
      case 5: return 'Cum';
      case 6: return 'Cmt';
      case 7: return 'Paz';
      default: return '';
    }
  }
  
  bool _isDateToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
}