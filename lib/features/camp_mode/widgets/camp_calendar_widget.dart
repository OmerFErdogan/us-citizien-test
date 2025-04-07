import 'package:flutter/material.dart';
import '../models/camp_day.dart';
import '../models/camp_plan.dart';
import '../models/camp_progress.dart';

class CampCalendarWidget extends StatelessWidget {
  final CampPlan campPlan;
  final CampProgress progress;
  final Function(CampDay) onDayTap;

  const CampCalendarWidget({
    Key? key,
    required this.campPlan,
    required this.progress,
    required this.onDayTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: campPlan.days.length,
      itemBuilder: (context, index) {
        final day = campPlan.days[index];
        final dayProgress = progress.dayProgress[day.dayNumber];
        final isCompleted = dayProgress?.isCompleted ?? false;
        final isActive = !day.isLocked && !isCompleted;
        
        return GestureDetector(
          onTap: day.isLocked ? null : () => onDayTap(day),
          child: Container(
            decoration: BoxDecoration(
              color: _getBackgroundColor(day, isCompleted, isActive),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getBorderColor(day, isCompleted, isActive),
                width: isActive ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day.dayNumber.toString(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _getTextColor(day, isCompleted, isActive),
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  _getStatusIcon(day, isCompleted, isActive),
                  size: 16,
                  color: _getIconColor(day, isCompleted, isActive),
                ),
                const SizedBox(height: 4),
                Text(
                  _getDayStatus(day, isCompleted, isActive),
                  style: TextStyle(
                    fontSize: 10,
                    color: _getTextColor(day, isCompleted, isActive),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getBackgroundColor(CampDay day, bool isCompleted, bool isActive) {
    if (isCompleted) {
      return Colors.green.shade50;
    } else if (isActive) {
      return _getDayColor(day.dayNumber).withOpacity(0.1);
    } else if (day.isLocked) {
      return Colors.grey.shade100;
    } else {
      return Colors.white;
    }
  }

  Color _getBorderColor(CampDay day, bool isCompleted, bool isActive) {
    if (isCompleted) {
      return Colors.green;
    } else if (isActive) {
      return _getDayColor(day.dayNumber);
    } else if (day.isLocked) {
      return Colors.grey.shade300;
    } else {
      return Colors.grey.shade400;
    }
  }

  Color _getTextColor(CampDay day, bool isCompleted, bool isActive) {
    if (isCompleted) {
      return Colors.green.shade700;
    } else if (isActive) {
      return _getDayColor(day.dayNumber);
    } else if (day.isLocked) {
      return Colors.grey.shade500;
    } else {
      return Colors.grey.shade800;
    }
  }

  Color _getIconColor(CampDay day, bool isCompleted, bool isActive) {
    if (isCompleted) {
      return Colors.green;
    } else if (isActive) {
      return _getDayColor(day.dayNumber);
    } else if (day.isLocked) {
      return Colors.grey.shade400;
    } else {
      return Colors.grey.shade500;
    }
  }

  IconData _getStatusIcon(CampDay day, bool isCompleted, bool isActive) {
    if (isCompleted) {
      return Icons.check_circle;
    } else if (isActive) {
      return Icons.play_circle_fill;
    } else if (day.isLocked) {
      return Icons.lock;
    } else {
      return Icons.circle_outlined;
    }
  }

  String _getDayStatus(CampDay day, bool isCompleted, bool isActive) {
    if (isCompleted) {
      return 'Tamamlandı';
    } else if (isActive) {
      return 'Aktif';
    } else if (day.isLocked) {
      return 'Kilitli';
    } else {
      return 'Bekliyor';
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