import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../models/question.dart';
import '../../utils/extensions.dart';
import '../../utils/responsive/responsive.dart';

class VisualFlashcard extends StatelessWidget {
  final Question question;
  final bool isFlipped;
  final Color categoryColor;
  final VoidCallback onTap;
  final bool isLargeScreen;

  const VisualFlashcard({
    Key? key,
    required this.question,
    required this.isFlipped,
    required this.categoryColor,
    required this.onTap,
    this.isLargeScreen = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: categoryColor.withOpacity(0.1),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: isFlipped 
              ? _buildBackCard(context, responsive)
              : _buildFrontCard(context, responsive),
        ),
      ),
    );
  }

  Widget _buildFrontCard(BuildContext context, ResponsiveHelper responsive) {
    return Container(
      decoration: BoxDecoration(
        gradient: _getBackgroundGradient(),
      ),
      child: Stack(
        children: [
          // Background Pattern/Image
          _buildBackgroundPattern(),
          
          // Overlay gradient for text readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.0),
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.0),
                ],
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: EdgeInsets.all(responsive.widthPercent(6)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category badge
                _buildCategoryBadge(context, responsive),
                
                SizedBox(height: responsive.heightPercent(2)),
                
                // Main content area
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Category icon
                      _buildCategoryIcon(responsive),
                      
                      SizedBox(height: responsive.heightPercent(3)),
                      
                      // Question text
                      _buildQuestionText(context, responsive),
                    ],
                  ),
                ),
                
                // Bottom hint
                _buildBottomHint(context, responsive),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard(BuildContext context, ResponsiveHelper responsive) {
    return Container(
      decoration: BoxDecoration(
        gradient: _getAnswerBackgroundGradient(),
      ),
      child: Stack(
        children: [
          // Background pattern for answer
          _buildAnswerBackgroundPattern(),
          
          // Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.90),
                ],
              ),
            ),
          ),
          
          // Answer content
          Padding(
            padding: EdgeInsets.all(responsive.widthPercent(6)),
            child: Column(
              children: [
                // Answer header
                _buildAnswerHeader(context, responsive),
                
                SizedBox(height: responsive.heightPercent(3)),
                
                // Answers list
                Expanded(
                  child: _buildAnswersList(context, responsive),
                ),
                
                // Action hints
                _buildActionHints(context, responsive),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    String imagePath = _getCategoryBackgroundImage();
    
    return Positioned.fill(
      child: Opacity(
        opacity: 0.15,
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback pattern if image not found
            return Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.5,
                  colors: [
                    categoryColor.withOpacity(0.3),
                    categoryColor.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnswerBackgroundPattern() {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.08,
        child: Image.asset(
          'assets/images/eagle_icon.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.bottomLeft,
                  radius: 2.0,
                  colors: [
                    Colors.green.withOpacity(0.2),
                    Colors.green.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(BuildContext context, ResponsiveHelper responsive) {
    return Container(
      padding: responsive.adaptivePadding(
        horizontal: 16.0,
        vertical: 8.0,
        densityFactor: 0.8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(responsive.widthPercent(6)),
        border: Border.all(
          color: categoryColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: responsive.widthPercent(2),
            height: responsive.widthPercent(2),
            decoration: BoxDecoration(
              color: categoryColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: responsive.widthPercent(2)),
          AutoSizeText(
            question.category,
            style: TextStyle(
              fontSize: responsive.scaledFontSize(small: 12.0, medium: 13.0, large: 14.0),
              fontWeight: FontWeight.bold,
              color: categoryColor.withOpacity(0.8),
            ),
            minFontSize: 10.0,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(ResponsiveHelper responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.widthPercent(4)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Icon(
        _getCategoryIcon(),
        size: responsive.adaptiveIconSize(size: 48.0, densityFactor: 0.8),
        color: Colors.white,
      ),
    );
  }

  Widget _buildQuestionText(BuildContext context, ResponsiveHelper responsive) {
    return Container(
      padding: responsive.adaptivePadding(
        horizontal: 20.0,
        vertical: 24.0,
        densityFactor: 0.8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(responsive.widthPercent(4)),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AutoSizeText(
        question.question,
        style: TextStyle(
          fontSize: responsive.scaledFontSize(small: 18.0, medium: 20.0, large: 22.0),
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
          height: 1.4,
        ),
        textAlign: TextAlign.center,
        minFontSize: 14.0,
        maxLines: 6,
      ),
    );
  }

  Widget _buildBottomHint(BuildContext context, ResponsiveHelper responsive) {
    return Container(
      padding: responsive.adaptivePadding(
        horizontal: 16.0,
        vertical: 12.0,
        densityFactor: 0.6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(responsive.widthPercent(4)),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app_rounded,
            size: responsive.adaptiveIconSize(size: 20.0),
            color: Colors.grey[600],
          ),
          SizedBox(width: responsive.widthPercent(2)),
          AutoSizeText(
            context.l10n.tapToFlip,
            style: TextStyle(
              fontSize: responsive.scaledFontSize(small: 14.0, medium: 15.0, large: 16.0),
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            minFontSize: 12.0,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerHeader(BuildContext context, ResponsiveHelper responsive) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(responsive.widthPercent(3)),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.green.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.lightbulb_outline_rounded,
            size: responsive.adaptiveIconSize(size: 32.0),
            color: Colors.green[700],
          ),
        ),
        SizedBox(width: responsive.widthPercent(4)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                context.l10n.answer,
                style: TextStyle(
                  fontSize: responsive.scaledFontSize(small: 20.0, medium: 22.0, large: 24.0),
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
                minFontSize: 16.0,
                maxLines: 1,
              ),
              AutoSizeText(
                'Correct Answer(s)',
                style: TextStyle(
                  fontSize: responsive.scaledFontSize(small: 12.0, medium: 13.0, large: 14.0),
                  color: Colors.grey[600],
                ),
                minFontSize: 10.0,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnswersList(BuildContext context, ResponsiveHelper responsive) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: question.allCorrectAnswers.length,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: responsive.heightPercent(1.5)),
          padding: responsive.adaptivePadding(
            horizontal: 16.0,
            vertical: 16.0,
            densityFactor: 0.8,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(responsive.widthPercent(3)),
            border: Border.all(
              color: Colors.green.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(responsive.widthPercent(1.5)),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  size: responsive.adaptiveIconSize(size: 24.0),
                  color: Colors.green[600],
                ),
              ),
              SizedBox(width: responsive.widthPercent(3)),
              Expanded(
                child: AutoSizeText(
                  question.allCorrectAnswers[index],
                  style: TextStyle(
                    fontSize: responsive.scaledFontSize(small: 16.0, medium: 17.0, large: 18.0),
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                    height: 1.3,
                  ),
                  minFontSize: 14.0,
                  maxLines: 3,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionHints(BuildContext context, ResponsiveHelper responsive) {
    return Container(
      padding: responsive.adaptivePadding(
        horizontal: 16.0,
        vertical: 12.0,
        densityFactor: 0.6,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(responsive.widthPercent(3)),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionHint(
            context,
            responsive,
            Icons.swipe_left_rounded,
            'Swipe ←',
            'Still Learning',
            Colors.orange[400]!, // Kırmızı → Turuncu
          ),
          Container(
            width: 1,
            height: responsive.heightPercent(4),
            color: Colors.grey[300],
          ),
          _buildActionHint(
            context,
            responsive,
            Icons.swipe_right_rounded,
            'Swipe →',
            'Got It!',
            Colors.green[400]!,
          ),
        ],
      ),
    );
  }

  Widget _buildActionHint(
    BuildContext context,
    ResponsiveHelper responsive,
    IconData icon,
    String gesture,
    String action,
    Color color,
  ) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: responsive.adaptiveIconSize(size: 24.0),
            color: color,
          ),
          SizedBox(height: responsive.heightPercent(0.5)),
          AutoSizeText(
            gesture,
            style: TextStyle(
              fontSize: responsive.scaledFontSize(small: 11.0, medium: 12.0, large: 13.0),
              fontWeight: FontWeight.bold,
              color: color,
            ),
            minFontSize: 9.0,
            maxLines: 1,
          ),
          AutoSizeText(
            action,
            style: TextStyle(
              fontSize: responsive.scaledFontSize(small: 10.0, medium: 11.0, large: 12.0),
              color: Colors.grey[600],
            ),
            minFontSize: 8.0,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  // Helper methods for category-based styling
  String _getCategoryBackgroundImage() {
    switch (question.category.toLowerCase()) {
      case 'principles of american democracy':
        return 'assets/images/statue_of_liberty_icon.png';
      case 'system of government':
        return 'assets/images/capitol_building_icon.png';
      case 'american history':
        return 'assets/images/declaration.png';
      case 'geography':
        return 'assets/images/usa_map_background.png';
      case 'symbols':
        return 'assets/images/american_flag_icon.png';
      case 'rights and responsibilities':
        return 'assets/images/liberty.png';
      case 'holidays':
        return 'assets/images/flag.png';
      default:
        return 'assets/images/eagle_icon.png';
    }
  }

  IconData _getCategoryIcon() {
    switch (question.category.toLowerCase()) {
      case 'principles of american democracy':
        return Icons.account_balance_rounded;
      case 'system of government':
        return Icons.gavel_rounded;
      case 'rights and responsibilities':
        return Icons.how_to_vote_rounded;
      case 'american history':
        return Icons.history_edu_rounded;
      case 'geography':
        return Icons.public_rounded;
      case 'symbols':
        return Icons.emoji_symbols_rounded;
      case 'holidays':
        return Icons.celebration_rounded;
      default:
        return Icons.quiz_rounded;
    }
  }

  LinearGradient _getBackgroundGradient() {
    switch (question.category.toLowerCase()) {
      case 'principles of american democracy':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[600]!,
            Colors.blue[800]!,
            Colors.indigo[900]!,
          ],
        );
      case 'system of government':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.indigo[600]!, // Kırmızı → İndigo
            Colors.indigo[800]!,
            Colors.indigo[900]!,
          ],
        );
      case 'rights and responsibilities':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green[600]!,
            Colors.green[800]!,
            Colors.teal[900]!,
          ],
        );
      case 'american history':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber[700]!,
            Colors.orange[800]!,
            Colors.deepOrange[900]!,
          ],
        );
      case 'geography':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.teal[600]!,
            Colors.cyan[800]!,
            Colors.blue[900]!,
          ],
        );
      case 'symbols':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple[600]!,
            Colors.purple[800]!,
            Colors.indigo[900]!,
          ],
        );
      case 'holidays':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple[600]!, // Kırmızı → Mor
            Colors.deepPurple[800]!,
            Colors.deepPurple[900]!,
          ],
        );
      default:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            categoryColor,
            categoryColor.withOpacity(0.8),
            categoryColor.withOpacity(0.6),
          ],
        );
    }
  }

  LinearGradient _getAnswerBackgroundGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.green[50]!,
        Colors.green[100]!,
        Colors.green[50]!,
      ],
    );
  }
}
