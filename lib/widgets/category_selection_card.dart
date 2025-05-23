import 'package:flutter/material.dart';

class CategorySelectionCard extends StatelessWidget {
  final String category;
  final bool isSelected;
  final int questionCount;
  final int completedCount;
  final double successRate;
  final Color categoryColor;
  final bool showProgressIndicator;
  final VoidCallback onTap;

  const CategorySelectionCard({
    Key? key,
    required this.category,
    required this.isSelected,
    required this.questionCount,
    required this.completedCount,
    required this.successRate,
    required this.categoryColor,
    required this.showProgressIndicator,
    required this.onTap,
  }) : super(key: key);

  // Category icons mapping
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'principles of american democracy':
        return Icons.account_balance;
      case 'system of government':
        return Icons.gavel;
      case 'rights and responsibilities':
        return Icons.how_to_vote;
      case 'american history':
        return Icons.flag;
      case 'geography':
        return Icons.public;
      case 'symbols':
        return Icons.emoji_symbols;
      case 'holidays':
        return Icons.celebration;
      default:
        return Icons.quiz;
    }
  }

  // Category background colors
  Color _getCategoryBackgroundColor(String category) {
    switch (category.toLowerCase()) {
      case 'principles of american democracy':
        return const Color(0xFFE8F4FD);
      case 'system of government':
        return const Color(0xFFF3E8FF);
      case 'rights and responsibilities':
        return const Color(0xFFE8F8F5);
      case 'american history':
        return const Color(0xFFFFF2E8);
      case 'geography':
        return const Color(0xFFE8F9F5);
      case 'symbols':
        return const Color(0xFFF8E8FF);
      case 'holidays':
        return const Color(0xFFFFF0E8);
      default:
        return const Color(0xFFF5F7FA);
    }
  }

  // Category icon colors
  Color _getCategoryIconColor(String category) {
    switch (category.toLowerCase()) {
      case 'principles of american democracy':
        return const Color(0xFF3B82F6);
      case 'system of government':
        return const Color(0xFF8B5CF6);
      case 'rights and responsibilities':
        return const Color(0xFF10B981);
      case 'american history':
        return const Color(0xFFF59E0B);
      case 'geography':
        return const Color(0xFF06B6D4);
      case 'symbols':
        return const Color(0xFFEC4899);
      case 'holidays':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progressPercentage = questionCount > 0 
        ? (completedCount / questionCount * 100).round() 
        : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected 
                  ? _getCategoryBackgroundColor(category).withOpacity(0.8)
                  : _getCategoryBackgroundColor(category),
              borderRadius: BorderRadius.circular(16),
              border: isSelected 
                  ? Border.all(color: _getCategoryIconColor(category), width: 2)
                  : null,
            ),
            child: Row(
              children: [
                // Category Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(category),
                    color: _getCategoryIconColor(category),
                    size: 28,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Category Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$completedCount of $questionCount cards',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: completedCount > 0 
                        ? const Color(0xFF10B981).withOpacity(0.1)
                        : const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    completedCount > 0 
                        ? '$progressPercentage%'
                        : 'Activity available',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: completedCount > 0 
                          ? const Color(0xFF065F46)
                          : const Color(0xFF10B981),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}