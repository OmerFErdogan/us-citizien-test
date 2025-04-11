import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/question_service.dart';
import '../utils/extensions.dart';

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
  bool _isLoading = true;
  Map<String, int> _weeklyData = {};
  final Map<String, List<String>> _weekDaysMap = {
    'en': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    'tr': ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'],
    'es': ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom']
  };
  List<String> get _weekDays => _weekDaysMap[Localizations.localeOf(context).languageCode] ?? _weekDaysMap['en']!;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Son 7 günlük istatistikleri al
      final stats = await widget.questionService.getLast7DaysStats();
      
      setState(() {
        _weeklyData = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.weeklyDataLoadingError(e.toString()))),
        );
      }
    }
  }

  List<BarChartGroupData> _getBarGroups() {
    final now = DateTime.now();
    final groups = <BarChartGroupData>[];
    
    // Son 7 günün tarihlerini oluştur (bugün dahil)
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateString = _formatDateString(date);
      
      // Bu gün için çözülen soru sayısı
      final count = _weeklyData[dateString] ?? 0;
      
      // Haftanın günü (0-6)
      final weekdayIndex = date.weekday - 1; // 0: Pazartesi, 6: Pazar
      
      groups.add(
        BarChartGroupData(
          x: 6 - i, // x: 0 bugündür, x: 6 6 gün öncesidir
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: _getBarColor(count),
              width: 16,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
          showingTooltipIndicators: [0],
        ),
      );
    }
    
    return groups;
  }

  String _formatDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Color _getBarColor(int count) {
    final dailyGoal = widget.questionService.getDailyGoal();
    
    if (count >= dailyGoal) {
      return Colors.green;
    } else if (count >= dailyGoal / 2) {
      return Colors.orange;
    } else if (count > 0) {
      return Colors.blue;
    } else {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.weeklyProgress,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
              tooltip: context.l10n.refresh,
              color: Colors.grey[600],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _isLoading
            ? Center(child: CircularProgressIndicator())
            : SizedBox(
                height: 250,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _calculateMaxY(),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Colors.blueGrey,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final date = DateTime.now().subtract(Duration(days: 6 - group.x.toInt()));
                          final dateString = '${date.day}/${date.month}';
                          
                          return BarTooltipItem(
                            '$dateString\n${rod.toY.toInt()} ${context.l10n.questions}',
                            const TextStyle(color: Colors.white),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= 7) return Container();
                            
                            // Bugünden geriye doğru 7 günün başlıklarını hesapla
                            final date = DateTime.now().subtract(Duration(days: 6 - index));
                            final weekday = _weekDays[date.weekday - 1]; // 0: Pazartesi, 6: Pazar
                            
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                weekday,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            if (value == 0) {
                              return const Text('0');
                            }
                            
                            if (value == _calculateMaxY()) {
                              return Text(value.toInt().toString());
                            }
                            
                            if (value == _calculateMaxY() / 2) {
                              return Text(value.toInt().toString());
                            }
                            
                            return const Text('');
                          },
                        ),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      checkToShowHorizontalLine: (value) => value % 5 == 0,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey[300]!,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    barGroups: _getBarGroups(),
                  ),
                ),
              ),
        const SizedBox(height: 16),
        _buildWeeklySummary(),
      ],
    );
  }

  double _calculateMaxY() {
    final values = _weeklyData.values.toList();
    if (values.isEmpty) return 10;
    
    final max = values.reduce((a, b) => a > b ? a : b).toDouble();
    return max < 10 ? 10 : (max * 1.2).ceilToDouble();
  }

  Widget _buildWeeklySummary() {
    final totalThisWeek = _weeklyData.values.fold(0, (sum, count) => sum + count);
    final dailyGoal = widget.questionService.getDailyGoal();
    final weeklyGoal = dailyGoal * 7;
    final completion = totalThisWeek / weeklyGoal;
    
    return Card(
      color: Colors.blue[50],
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              completion >= 1 ? Icons.emoji_events : Icons.info_outline,
              color: completion >= 1 ? Colors.amber : Colors.blue,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.thisWeekSolvedQuestions(totalThisWeek),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    completion >= 1
                        ? context.l10n.weeklyGoalCompleted
                        : context.l10n.weeklyGoalTarget(weeklyGoal),
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}