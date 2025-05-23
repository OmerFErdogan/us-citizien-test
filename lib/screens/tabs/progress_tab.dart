import 'package:flutter/material.dart';
import '../../utils/extensions.dart';
import '../../utils/responsive/responsive.dart';
import '../../screens/static_screen.dart';
import '../../services/question_service.dart';

/// Optimized Progress Tab with improved UI/UX
/// 
/// Key improvements:
/// - Simplified information hierarchy
/// - Better visual balance
/// - Improved mobile experience
/// - Reduced cognitive load
/// - Enhanced interactivity
class ProgressTab extends StatefulWidget {
  final int answeredQuestions;
  final int totalQuestions;
  final double correctRate;
  final QuestionService questionService;
  final Function() onReloadData;

  const ProgressTab({
    Key? key,
    required this.answeredQuestions,
    required this.totalQuestions,
    required this.correctRate,
    required this.questionService,
    required this.onReloadData,
  }) : super(key: key);

  @override
  State<ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<ProgressTab>
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return RefreshIndicator(
      onRefresh: () async {
        widget.onReloadData();
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Simplified Header
            SliverToBoxAdapter(
              child: _buildSimplifiedHeader(context),
            ),
            
            // Main Stats - Focused on key metrics
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverToBoxAdapter(
                child: _buildKeyMetrics(context),
              ),
            ),
            
            // Quick Actions
            SliverToBoxAdapter(
              child: _buildQuickActions(context),
            ),
            
            // Simplified Motivation Section
            SliverToBoxAdapter(
              child: _buildMotivationCard(context),
            ),
            
            // Bottom spacing
            const SliverPadding(
              padding: EdgeInsets.only(bottom: 20),
            ),
          ],
        ),
      ),
    );
  }

  /// Simplified header focusing on essential information
  Widget _buildSimplifiedHeader(BuildContext context) {
    final progressPercentage = widget.totalQuestions > 0 
        ? widget.answeredQuestions / widget.totalQuestions 
        : 0.0;
    
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade600,
            Colors.blue.shade800,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and progress percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.learningProgressTitle ?? "Your Progress",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${(progressPercentage * 100).toStringAsFixed(0)}%",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressPercentage,
              minHeight: 12,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Progress text
          Text(
            "${widget.answeredQuestions} of ${widget.totalQuestions} questions completed",
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Key metrics with improved visual hierarchy
  Widget _buildKeyMetrics(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Performance Overview",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        
        // Two main metrics side by side
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: "Accuracy Rate",
                value: "${(widget.correctRate * 100).toStringAsFixed(1)}%",
                icon: Icons.track_changes,
                color: _getAccuracyColor(widget.correctRate),
                subtitle: _getAccuracyMessage(widget.correctRate),
                onTap: () => _showAccuracyDetails(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                title: "Daily Goal",
                value: "${widget.questionService.getTodayQuestionCount()}",
                icon: Icons.today,
                color: Colors.orange,
                subtitle: "of ${widget.questionService.getDailyGoal()} today",
                onTap: () => _showDailyGoalDetails(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  /// Get color based on accuracy rate
  Color _getAccuracyColor(double rate) {
    final percentage = rate * 100;
    if (percentage >= 90) return Colors.green;
    if (percentage >= 80) return Colors.lightGreen;
    if (percentage >= 70) return Colors.blue;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }
  
  /// Get motivational message based on accuracy
  String _getAccuracyMessage(double rate) {
    final percentage = rate * 100;
    if (percentage >= 90) return "Excellent!"; 
    if (percentage >= 80) return "Very good!"; 
    if (percentage >= 70) return "Good work!"; 
    if (percentage >= 60) return "Keep improving"; 
    return "Keep practicing";
  }
  
  /// Simplified metric card with tap interaction
  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Simplified motivation card
  Widget _buildMotivationCard(BuildContext context) {
    final progressPercentage = widget.totalQuestions > 0 
        ? widget.answeredQuestions / widget.totalQuestions 
        : 0.0;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade600,
            Colors.purple.shade800,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_events,
                color: Colors.amber,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.l10n.americanDream ?? "Your Citizenship Journey",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _getMotivationalMessage(progressPercentage),
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Quick action buttons
  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StatisticsScreen(
                      questionService: widget.questionService,
                    ),
                  ),
                ).then((_) => widget.onReloadData());
              },
              icon: const Icon(Icons.bar_chart, size: 20),
              label: const Text("View Details"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _resetProgress(context),
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text("Reset"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue.shade600,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.blue.shade600),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Get motivational message based on progress
  String _getMotivationalMessage(double progress) {
    if (progress >= 0.9) {
      return "🎉 Almost there! You're doing amazing - just a few more questions to complete your journey!";
    } else if (progress >= 0.7) {
      return "🚀 Great progress! You're well on your way to citizenship success. Keep up the excellent work!";
    } else if (progress >= 0.5) {
      return "💪 You're halfway there! Every question brings you closer to achieving your American Dream.";
    } else if (progress >= 0.3) {
      return "🌟 Nice start! Building knowledge takes time, and you're making steady progress toward your goal.";
    } else {
      return "🇺🇸 Welcome to your citizenship journey! Every expert was once a beginner. You've got this!";
    }
  }
  
  /// Show accuracy details dialog
  void _showAccuracyDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Accuracy Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Current accuracy: ${(widget.correctRate * 100).toStringAsFixed(1)}%"),
            const SizedBox(height: 8),
            Text("Correct answers: ${(widget.answeredQuestions * widget.correctRate).round()}"),
            Text("Total attempted: ${widget.answeredQuestions}"),
            const SizedBox(height: 16),
            Text(
              _getAccuracyMessage(widget.correctRate),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getAccuracyColor(widget.correctRate),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  /// Show daily goal details dialog
  void _showDailyGoalDetails(BuildContext context) {
    final todayCount = widget.questionService.getTodayQuestionCount();
    final dailyGoal = widget.questionService.getDailyGoal();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Daily Goal Progress"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Today's progress: $todayCount / $dailyGoal questions"),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: todayCount / dailyGoal,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                todayCount >= dailyGoal ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              todayCount >= dailyGoal 
                  ? "🎉 Goal completed! Great job!"
                  : "💪 ${dailyGoal - todayCount} more questions to reach your goal!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: todayCount >= dailyGoal ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
  
  /// Reset progress confirmation dialog
  void _resetProgress(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Progress"),
        content: const Text(
          "Are you sure you want to reset your progress? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await widget.questionService.resetAllAnswers();
              widget.onReloadData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Progress has been reset"),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text(
              "Reset",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
