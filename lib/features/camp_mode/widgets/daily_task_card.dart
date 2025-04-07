import 'package:flutter/material.dart';
import '../models/camp_day.dart';

class DailyTaskCard extends StatelessWidget {
  final CampActivity activity;
  final int dayNumber;
  final bool isCompleted;
  final VoidCallback onStartActivity;

  const DailyTaskCard({
    Key? key,
    required this.activity,
    required this.dayNumber,
    required this.isCompleted,
    required this.onStartActivity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Periyoda göre renk ve ikon belirle
    final (color, icon) = _getPeriodInfo(activity.period);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCompleted
            ? BorderSide(color: Colors.green, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onStartActivity,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.period,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          activity.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.shade700,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Tamamlandı',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                activity.description,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.question_answer,
                    '${activity.questionCount} soru',
                    Colors.blue.shade700,
                  ),
                  const SizedBox(width: 8),
                  ...activity.categories.take(2).map((category) => 
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: _buildInfoChip(
                        Icons.category,
                        category,
                        Colors.purple.shade700,
                      ),
                    ),
                  ),
                  if (activity.categories.length > 2)
                    _buildInfoChip(
                      Icons.more_horiz,
                      '+${activity.categories.length - 2}',
                      Colors.grey.shade700,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: Icon(
                  isCompleted ? Icons.replay : Icons.play_arrow,
                  color: isCompleted ? Colors.green : _getDayColor(dayNumber),
                ),
                label: Text(
                  isCompleted ? 'Tekrar Çalış' : 'Başlat',
                  style: TextStyle(
                    color: isCompleted ? Colors.green : _getDayColor(dayNumber),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  side: BorderSide(
                    color: isCompleted ? Colors.green : _getDayColor(dayNumber),
                  ),
                ),
                onPressed: onStartActivity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }

  (Color, IconData) _getPeriodInfo(String period) {
    switch (period.toLowerCase()) {
      case 'sabah':
        return (Colors.orange, Icons.wb_sunny);
      case 'öğle':
        return (Colors.blue, Icons.wb_cloudy);
      case 'akşam':
        return (Colors.indigo, Icons.nightlight_round);
      default:
        return (Colors.grey, Icons.access_time);
    }
  }

  Color _getDayColor(int dayNumber) {
    final colors = [
      Colors.blue,
      Colors.indigo,
      Colors.teal,
      Colors.purple,
      Colors.orange,
      Colors.green,
      Colors.amber,
      Colors.pink,
      Colors.cyan,
      Colors.red,
    ];
    
    return colors[(dayNumber - 1) % colors.length];
  }
}