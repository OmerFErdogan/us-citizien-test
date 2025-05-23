import 'package:flutter/material.dart';
import '../../utils/extensions.dart';
import '../../utils/responsive/responsive.dart';
import '../../widgets/animations/animated_widgets.dart';
import '../../themes/app_themes.dart';

class StudyTab extends StatelessWidget {
  final int answeredQuestions;
  final int totalQuestions;
  final double correctRate;
  final int todayQuestions;
  final Function(BuildContext) onQuizSelected;
  final Function(BuildContext) onFlashcardSelected;
  final Function(BuildContext) onWrongQuestionsSelected;
  final Function(BuildContext) onTestModeSelected;
  final Function(BuildContext) onCampModeSelected;

  const StudyTab({
    Key? key,
    required this.answeredQuestions,
    required this.totalQuestions,
    required this.correctRate,
    required this.todayQuestions,
    required this.onQuizSelected,
    required this.onFlashcardSelected,
    required this.onWrongQuestionsSelected,
    required this.onTestModeSelected,
    required this.onCampModeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).brightness == Brightness.dark 
                ? const Color(0xFF2D1B69)
                : const Color(0xFF6C63FF),
            Theme.of(context).brightness == Brightness.dark 
                ? const Color(0xFF1A1A2E)
                : const Color(0xFFF8F9FF),
          ],
          stops: const [0.0, 0.4],
        ),
      ),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Premium Camp Mode Hero
          SliverToBoxAdapter(
            child: _buildCampModeHero(context),
          ),
          
          // Quick Stats Bar
          SliverToBoxAdapter(
            child: _buildQuickStats(context),
          ),
          
          // Study Options Grid
          SliverToBoxAdapter(
            child: _buildStudyOptionsGrid(context),
          ),
          
          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  // Premium Camp Mode Hero - Kamp modunu ön plana çıkaran hero section
  Widget _buildCampModeHero(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          // Premium Camp Mode Card - Enhanced and larger
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF667eea),
                  Color(0xFF764ba2),
                  Color(0xFF9b59b6),
                ],
                stops: [0.0, 0.6, 1.0],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667eea).withOpacity(0.6),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                // Enhanced Premium badge with animation effect
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.diamond, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'PREMIUM EXCLUSIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Enhanced Camp mode icon with glow effect
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.military_tech,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Mobile-optimized Title
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '14-Day Citizenship\nBootcamp',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 6),
                
                // Mobile-optimized Subtitle with better line breaks
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Expert-designed program\nGuaranteed success\n🎯 Pass on first try',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 16,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Enhanced CTA Button with gradient
                GestureDetector(
                  onTap: () => onCampModeSelected(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.white, Color(0xFFF8F9FA)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.rocket_launch,
                          color: const Color(0xFF667eea),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Start Bootcamp Now',
                          style: TextStyle(
                            color: const Color(0xFF667eea),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          color: const Color(0xFF667eea),
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Success rate indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.verified,
                      color: Colors.white.withOpacity(0.9),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '94% success rate',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Quick Stats - Basitleştirilmiş istatistik çubuğu
  Widget _buildQuickStats(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              context,
              icon: Icons.quiz,
              value: '${answeredQuestions}/${totalQuestions}',
              label: 'Progress',
              color: Colors.blue,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade300,
          ),
          Expanded(
            child: _buildStatItem(
              context,
              icon: Icons.check_circle,
              value: '${(correctRate * 100).toInt()}%',
              label: 'Accuracy',
              color: Colors.green,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade300,
          ),
          Expanded(
            child: _buildStatItem(
              context,
              icon: Icons.today,
              value: '$todayQuestions',
              label: 'Today',
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // Study Options Grid - Kamp odaklı grid
  Widget _buildStudyOptionsGrid(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.menu_book_outlined,
                color: Colors.grey[600],
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Alternative Study Methods',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Grid of study options
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.6,
            children: [
              _buildStudyOptionCard(
                context,
                title: 'Practice Quiz',
                subtitle: 'Test knowledge',
                icon: Icons.quiz,
                color: const Color(0xFF667eea),
                onTap: () => onQuizSelected(context),
              ),
              _buildStudyOptionCard(
                context,
                title: 'Test Mode',
                subtitle: 'Real exam simulation',
                icon: Icons.workspace_premium,
                color: const Color(0xFF11998e),
                onTap: () => onTestModeSelected(context),
                isHighlighted: true,
              ),
              _buildStudyOptionCard(
                context,
                title: 'Flashcards',
                subtitle: 'Interactive cards',
                icon: Icons.style,
                color: const Color(0xFFfc466b),
                onTap: () => onFlashcardSelected(context),
              ),
              _buildStudyOptionCard(
                context,
                title: 'Wrong Answers',
                subtitle: 'Review mistakes',
                icon: Icons.assignment_late,
                color: const Color(0xFFff9a9e),
                onTap: () => onWrongQuestionsSelected(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudyOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Highlighted badge removed to save space
            // if (isHighlighted)
            //   Container(...),
            // if (isHighlighted) const SizedBox(height: 6),
            
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            
            const SizedBox(height: 6),
            
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            
            const SizedBox(height: 2),
            
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
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
