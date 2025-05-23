import 'package:flutter/material.dart';
import 'dart:math';
import '../../utils/extensions.dart';
import '../../utils/responsive/responsive.dart';
import '../../widgets/banner_ad_widget.dart';
import '../../widgets/animations/animated_widgets.dart';
import '../../themes/app_themes.dart';

class HomeTab extends StatelessWidget {
  final int todayQuestions;
  final int dailyGoal;
  final int answeredQuestions;
  final int totalQuestions;
  final double correctRate;
  final Function() onRefresh;
  final Function(BuildContext) onQuizSelected;
  final Function(BuildContext) onTestModeSelected;
  final Function(BuildContext) onCampModeSelected;

  const HomeTab({
    Key? key,
    required this.todayQuestions,
    required this.dailyGoal,
    required this.answeredQuestions,
    required this.totalQuestions,
    required this.correctRate,
    required this.onRefresh,
    required this.onQuizSelected,
    required this.onTestModeSelected,
    required this.onCampModeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(onRefresh),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Hero section with glassmorphism
          SliverToBoxAdapter(
            child: _buildModernHeroSection(context),
          ),
          
          // Quick stats cards
          SliverToBoxAdapter(
            child: _buildQuickStatsSection(context),
          ),
          
          // Action buttons with modern design
          SliverToBoxAdapter(
            child: _buildModernActionButtons(context),
          ),
          
          // Achievement section
          SliverToBoxAdapter(
            child: _buildAchievementSection(context),
          ),
          
          // Add some bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  // Rastgele motivasyon alıntısı seç
  String _getRandomMotivationalQuote() {
    final quotes = [
      "Citizenship is the chance to make a difference to the place where you belong.",
      "Democracy cannot succeed unless those who express their choice are prepared to choose wisely.",
      "In America, the people own the government and not the other way around.",
      "America's strength lies in its unity and diversity.",
      "Freedom is never more than one generation away from extinction.",
      "Liberty is the breath of life to nations.",
      "We can only be the land of the free if we are also the home of the brave.",
    ];
    
    // Her zaman rastgele bir alıntı seç
    return quotes[DateTime.now().millisecond % quotes.length];
  }

  // Modern hero section with glassmorphism
  Widget _buildModernHeroSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: AppThemes.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: PatternPainter(),
            ),
          ),
          
          // Glassmorphism overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.white.withOpacity(0.1),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.flag,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Journey to Citizenship',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Making the American Dream Real',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // Progress indicator
                _buildProgressIndicator(context),
                
                const SizedBox(height: 16),
                
                // Call to action
                GestureDetector(
                  onTap: () => onQuizSelected(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Continue Learning',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Progress indicator with animation
  Widget _buildProgressIndicator(BuildContext context) {
    final progress = answeredQuestions / (totalQuestions > 0 ? totalQuestions : 1);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Overall Progress',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.white, Colors.white70],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Quick stats with modern cards
  Widget _buildQuickStatsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              context,
              icon: Icons.quiz,
              title: 'Completed',
              value: '$answeredQuestions',
              subtitle: 'of $totalQuestions',
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              context,
              icon: Icons.analytics,
              title: 'Accuracy',
              value: '${(correctRate * 100).toInt()}%',
              subtitle: 'correct rate',
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              context,
              icon: Icons.today,
              title: 'Today',
              value: '$todayQuestions',
              subtitle: 'questions',
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  // Modern stat card
  Widget _buildStatCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          AnimatedCounter(
            value: int.tryParse(value.replaceAll('%', '').replaceAll('of $totalQuestions', '')) ?? 0,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // Günlük ilerleme kartı - animasyonlu ve görsel
  Widget _buildDailyProgressCard(BuildContext context) {
    final goalCompletion = todayQuestions / dailyGoal;
    final isCompleted = todayQuestions >= dailyGoal;
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isCompleted
                ? [Colors.green.shade50, Colors.green.shade100]
                : [Colors.orange.shade50, Colors.orange.shade100],
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isCompleted ? Colors.green : Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCompleted ? Icons.check : Icons.star,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.dailyCitizenshipGoal != null ? context.l10n.dailyCitizenshipGoal! : "Daily Goal",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          isCompleted
                              ? "Congratulations!"
                              : "Keep going!",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Tamamlanma yüzdesi
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted ? Colors.green : Colors.orange,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "${(goalCompletion * 100).toStringAsFixed(0)}%",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Günlük ilerleme çubuğu
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    // İlerleme çubuğu
                    FractionallySizedBox(
                      widthFactor: goalCompletion.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: isCompleted
                                ? [Colors.green.shade300, Colors.green.shade500]
                                : [Colors.orange.shade300, Colors.orange.shade500],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    // İlerleme metni
                    Positioned.fill(
                      child: Center(
                        child: Text(
                          "${todayQuestions} / ${dailyGoal} questions",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Modern action buttons with animations
  Widget _buildModernActionButtons(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          AnimatedActionButton(
            title: 'Practice Quiz',
            subtitle: 'Test your knowledge with practice questions',
            icon: Icons.quiz,
            gradientColors: const [Color(0xFF667eea), Color(0xFF764ba2)],
            onTap: () => onQuizSelected(context),
          ),
          const SizedBox(height: 12),
          AnimatedActionButton(
            title: 'Test Mode',
            subtitle: 'Simulate the real citizenship exam',
            icon: Icons.workspace_premium,
            gradientColors: const [Color(0xFF11998e), Color(0xFF38ef7d)],
            onTap: () => onTestModeSelected(context),
            isHighlighted: true,
          ),
          const SizedBox(height: 12),
          AnimatedActionButton(
            title: '10-Day Camp',
            subtitle: 'Structured learning program',
            icon: Icons.calendar_month,
            gradientColors: const [Color(0xFFfc466b), Color(0xFF3f5efb)],
            onTap: () => onCampModeSelected(context),
          ),
        ],
      ),
    );
  }

  // Achievement section
  Widget _buildAchievementSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
              const SizedBox(width: 12),
              Text(
                'Your Achievements',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Achievement badges
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _buildAchievementBadges(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAchievementBadges() {
    final badges = <Widget>[];
    
    if (answeredQuestions >= 10) {
      badges.add(_buildAchievementBadge('First Steps', Icons.baby_changing_station, Colors.blue));
    }
    
    if (answeredQuestions >= 50) {
      badges.add(_buildAchievementBadge('Halfway There', Icons.trending_up, Colors.orange));
    }
    
    if (correctRate >= 0.8) {
      badges.add(_buildAchievementBadge('Expert', Icons.school, Colors.green));
    }
    
    if (todayQuestions >= dailyGoal) {
      badges.add(_buildAchievementBadge('Daily Hero', Icons.today, Colors.purple));
    }
    
    if (badges.isEmpty) {
      badges.add(_buildAchievementBadge('Getting Started', Icons.star, Colors.grey));
    }
    
    return badges;
  }

  Widget _buildAchievementBadge(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

}

// Custom painter for background pattern
class PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;

    for (int i = 0; i < 20; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.1 * i, size.height * 0.1 * i),
        2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
