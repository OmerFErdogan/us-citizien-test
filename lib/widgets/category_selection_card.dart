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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Daha esnek responsive tasarım mantığı
        final double cardWidth = constraints.maxWidth;
        final bool isLargeScreen = cardWidth > 400; // Kart genişliğine göre karar ver
        final bool isMediumScreen = cardWidth > 300 && cardWidth <= 400;
        
        // Dinamik boyutlandırma
        final double iconSize = isLargeScreen ? 28 : (isMediumScreen ? 26 : 24);
        final double fontSize = isLargeScreen ? 18 : (isMediumScreen ? 17 : 16); 
        final double padding = isLargeScreen ? 20.0 : (isMediumScreen ? 18.0 : 16.0);
        final double borderRadius = isLargeScreen ? 16 : (isMediumScreen ? 14 : 12);
        final double spacing = isLargeScreen ? 16 : (isMediumScreen ? 14 : 12);
        
        return Card(
          elevation: isSelected ? 4 : 1,
          margin: EdgeInsets.only(bottom: isLargeScreen ? 16.0 : 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: isSelected 
                ? BorderSide(color: categoryColor, width: isLargeScreen ? 3 : 2) 
                : BorderSide.none,
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Selection indicator
                      Container(
                        width: iconSize,
                        height: iconSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected 
                                ? categoryColor 
                                : Colors.grey[400]!,
                            width: isLargeScreen ? 2.5 : 2,
                          ),
                          color: isSelected 
                              ? categoryColor.withOpacity(0.2) 
                              : Colors.transparent,
                        ),
                        child: isSelected 
                            ? Icon(
                                Icons.check, 
                                color: categoryColor,
                                size: iconSize * 0.6,
                              ) 
                            : null,
                      ),
                      SizedBox(width: spacing),
                      
                      // Category name
                      Expanded(
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? categoryColor : Colors.black,
                          ),
                        ),
                      ),
                      
                      // Question count
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isLargeScreen ? 10 : 8, 
                          vertical: isLargeScreen ? 6 : 4
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(isLargeScreen ? 10 : 8),
                        ),
                        child: Text(
                          context.l10n.questionsCount(questionCount),
                          style: TextStyle(
                            color: categoryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: isLargeScreen ? 14 : 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  if (showProgressIndicator) // Progress info for flashcard categories
                    Padding(
                      padding: EdgeInsets.only(
                        top: isLargeScreen ? 16.0 : 12.0, 
                        left: isLargeScreen ? 44.0 : 36.0
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.l10n.completed(completedCount, questionCount, questionCount > 0 ? (completedCount * 100 / questionCount).toStringAsFixed(1) : '0'),
                                style: TextStyle(
                                  fontSize: isLargeScreen ? 14 : 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                              if (completedCount > 0)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isLargeScreen ? 8 : 6, 
                                    vertical: isLargeScreen ? 3 : 2
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getSuccessRateColor(successRate).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(isLargeScreen ? 6 : 4),
                                  ),
                                  child: Text(
                                    context.l10n.successRate((successRate * 100).toStringAsFixed(0)),
                                    style: TextStyle(
                                      fontSize: isLargeScreen ? 12 : 10,
                                      fontWeight: FontWeight.bold,
                                      color: _getSuccessRateColor(successRate),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: isLargeScreen ? 6 : 4),
                          LinearProgressIndicator(
                            value: questionCount > 0 ? completedCount / questionCount : 0.0,
                            minHeight: isLargeScreen ? 6 : 4,
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
      },
    );
  }
}