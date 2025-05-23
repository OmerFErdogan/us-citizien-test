import 'package:flutter/material.dart';
import '../models/camp_progress.dart';

class BadgeWidget extends StatelessWidget {
  final CampBadge badge;
  final bool isLarge;

  const BadgeWidget({
    Key? key,
    required this.badge,
    this.isLarge = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showBadgeDetails(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: isLarge ? 120 : 80,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.blue.shade200,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isLarge ? 80 : 48,
              height: isLarge ? 80 : 48,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.blue.shade400,
                  width: 2,
                ),
              ),
              child: Icon(
                _getBadgeIcon(),
                color: Colors.blue.shade700,
                size: isLarge ? 40 : 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badge.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isLarge ? 14 : 10,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              _getFormattedDate(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isLarge ? 12 : 8,
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getBadgeIcon() {
    if (badge.id.startsWith('day_complete')) {
      return Icons.check_circle;
    } else if (badge.id.startsWith('perfect_day')) {
      return Icons.star;
    } else if (badge.id == 'halfway') {
      return Icons.flag;
    } else if (badge.id == 'camp_complete') {
      return Icons.emoji_events;
    } else if (badge.id == 'perfect_camp') {
      return Icons.workspace_premium;
    } else {
      return Icons.shield;
    }
  }

  String _getFormattedDate() {
    final day = badge.earnedDate.day.toString().padLeft(2, '0');
    final month = badge.earnedDate.month.toString().padLeft(2, '0');
    final year = badge.earnedDate.year;
    
    return '$day.$month.$year';
  }

  void _showBadgeDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(_getBadgeIcon(), color: Colors.blue.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                badge.title,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blue.shade900,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              badge.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'WIN: ${_getFormattedDate()}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OKEY'),
          ),
        ],
      ),
    );
  }
}