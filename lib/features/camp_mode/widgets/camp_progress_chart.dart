import 'package:flutter/material.dart';
import '../models/camp_plan.dart';
import '../models/camp_progress.dart';

// Günlük performans verisi için yardımcı sınıf
class _DayPerformance {
  final int dayNumber;
  final double targetRate; // Hedef başarı oranı
  final double actualRate; // Gerçekleşen başarı oranı
  final bool isCompleted; // Gün tamamlandı mı?
  
  _DayPerformance({
    required this.dayNumber,
    required this.targetRate,
    required this.actualRate,
    required this.isCompleted,
  });
}

class CampProgressChart extends StatelessWidget {
  final CampProgress progress;
  final CampPlan campPlan;

  const CampProgressChart({
    Key? key,
    required this.progress,
    required this.campPlan,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Günlere Göre Başarı Oranı',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _buildBarChart(),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Hedef başarı', Colors.orange),
                const SizedBox(width: 24),
                _buildLegendItem('Başarı oranı', Colors.blue.shade300),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    // Günlere göre başarı oranlarını hesapla
    final List<_DayPerformance> dayPerformances = [];
    
    for (int i = 1; i <= campPlan.durationDays; i++) {
      final day = campPlan.getDayByNumber(i);
      final dayProgress = progress.dayProgress[i];
      
      if (day != null) {
        final double targetRate = day.targetSuccessRate;
        final double actualRate = dayProgress?.successRate ?? 0.0;
        final bool isCompleted = dayProgress?.isCompleted ?? false;
        
        dayPerformances.add(_DayPerformance(
          dayNumber: i,
          targetRate: targetRate,
          actualRate: actualRate,
          isCompleted: isCompleted,
        ));
      }
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxBarWidth = constraints.maxWidth / (dayPerformances.length + 1);
        final double barWidth = maxBarWidth * 0.6; // Her bar, maksimum genişliğin %60'ı kadar
        
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: dayPerformances.map((perf) {
              return _buildDayBar(
                perf, 
                barWidth, 
                constraints.maxHeight * 0.75, // Maksimum yüksekliğin %75'i
              );
            }).toList(),
          ),
        );
      },
    );
  }
  
  Widget _buildDayBar(_DayPerformance perf, double barWidth, double maxHeight) {
    final double targetHeight = maxHeight * perf.targetRate;
    final double actualHeight = maxHeight * perf.actualRate;
    final bool isSuccessful = perf.isCompleted && perf.actualRate >= perf.targetRate;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: barWidth,
          height: actualHeight,
          decoration: BoxDecoration(
            color: _getBarColor(perf.actualRate),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(4),
              topRight: const Radius.circular(4),
            ),
            border: isSuccessful
                ? Border.all(color: Colors.green, width: 2)
                : null,
          ),
        ),
        // Hedef çizgisi
        Container(
          margin: const EdgeInsets.only(top: 2),
          width: barWidth,
          height: 2,
          color: Colors.orange,
        ),
        const SizedBox(height: 4),
        Text(
          '${perf.dayNumber}',
          style: TextStyle(
            fontSize: 10,
            fontWeight: perf.isCompleted ? FontWeight.bold : FontWeight.normal,
            color: perf.isCompleted ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Color _getBarColor(double value) {
    if (value < 0.3) {
      return Colors.red.shade300;
    } else if (value < 0.7) {
      return Colors.orange.shade300;
    } else {
      return Colors.blue.shade300;
    }
  }
}