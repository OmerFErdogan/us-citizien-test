import 'package:flutter/material.dart';
import '../utils/extensions.dart';

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

  Color _getSuccessRateColor(double rate) {
    if (rate >= 0.9) return Colors.green[700]!;
    if (rate >= 0.7) return Colors.green;
    if (rate >= 0.5) return Colors.orange;
    if (rate >= 0.3) return Colors.orange[700]!;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected 
            ? BorderSide(color: categoryColor, width: 2) 
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Selection indicator
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected 
                            ? categoryColor 
                            : Colors.grey[400]!,
                        width: 2,
                      ),
                      color: isSelected 
                          ? categoryColor.withOpacity(0.2) 
                          : Colors.transparent,
                    ),
                    child: isSelected 
                        ? Icon(
                            Icons.check, 
                            color: categoryColor,
                            size: 16,
                          ) 
                        : null,
                  ),
                  const SizedBox(width: 12),
                  
                  // Category name
                  Expanded(
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? categoryColor : Colors.black,
                      ),
                    ),
                  ),
                  
                  // Question count
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      context.l10n.questionsCount(questionCount),
                      style: TextStyle(
                        color: categoryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              
              if (showProgressIndicator) // Progress info for flashcard categories
                Padding(
                  padding: const EdgeInsets.only(top: 12.0, left: 36.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.l10n.completed(completedCount, questionCount),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          if (completedCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getSuccessRateColor(successRate).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                context.l10n.successRate((successRate * 100).toStringAsFixed(0)),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _getSuccessRateColor(successRate),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: questionCount > 0 ? completedCount / questionCount : 0.0,
                        minHeight: 4,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}