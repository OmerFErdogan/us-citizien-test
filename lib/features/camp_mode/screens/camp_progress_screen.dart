import 'package:flutter/material.dart';
import '../models/camp_progress.dart';
import '../models/camp_plan.dart';
import '../services/camp_service.dart';
import '../widgets/camp_calendar_widget.dart';
import '../widgets/camp_progress_chart.dart';
import '../widgets/badge_widget.dart';
import '../../../utils/extensions.dart'; // Extensions eklendi (context.l10n için)

class CampProgressScreen extends StatefulWidget {
  const CampProgressScreen({
    Key? key,
  }) : super(key: key);

  @override
  _CampProgressScreenState createState() => _CampProgressScreenState();
}

class _CampProgressScreenState extends State<CampProgressScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late TabController _tabController;
  final CampService _campService = CampService();
  CampProgress? _progress;
  late CampPlan _campPlan;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProgressData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProgressData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _campService.initialize();
      
      // İlerleme ve aktivite durumlarını senkronize et
      await _campService.syncProgressWithActivities();
      
      // Kamp planı ve ilerleme verilerini yükle
      _campPlan = _campService.getCampPlan();
      _progress = _campService.getUserProgress();
      
      if (_progress == null) {
        _errorMessage = context.l10n.errorNoActiveProgress;
      }
    } catch (e) {
      print('Hata: $e'); // Hata log'u
      setState(() {
        _errorMessage = context.l10n.errorLoadingData + e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.campProgressTitle),
        elevation: 0,
        actions: [
          // Yenileme butonu ekle
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: context.l10n.refreshTooltip,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.l10n.refreshingMessage)),
              );
              _loadProgressData();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.bar_chart), text: context.l10n.overviewTabTitle),
            Tab(icon: const Icon(Icons.calendar_today), text: context.l10n.daysTabTitle),
            Tab(icon: const Icon(Icons.emoji_events), text: context.l10n.badgesTabTitle),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red)))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildCalendarTab(),
                    _buildBadgesTab(),
                  ],
                ),
    );
  }

  Widget _buildOverviewTab() {
    if (_progress == null) {
      return _buildNoProgressView();
    }
    
    final completedDays = _progress!.completedDaysCount;
    final totalDays = _campPlan.durationDays;
    final progress = completedDays / totalDays;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewCard(),
          const SizedBox(height: 24),
          Text(
            context.l10n.performanceByDay,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: CampProgressChart(progress: _progress!, campPlan: _campPlan),
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.strengthsWeaknesses,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          _buildStrengthsWeaknessesCard(),
          const SizedBox(height: 24),
          if (_progress!.isCampCompleted) _buildCompletionCard(),
        ],
      ),
    );
  }

  Widget _buildOverviewCard() {
    if (_progress == null) return Container();
    
    final completedDays = _progress!.completedDaysCount;
    final totalDays = _campPlan.durationDays;
    final progress = completedDays / totalDays;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.campProgress,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn(
                  context.l10n.startDate,
                  _progress!.startDate.toString().substring(0, 10),
                  Icons.calendar_today,
                ),
                _buildStatColumn(
                  context.l10n.completedDay,
                  completedDays.toString() + ' / ' + totalDays.toString(),
                  Icons.check_circle,
                ),
                _buildStatColumn(
                  context.l10n.totalSuccess,
                  context.l10n.percentPrefix + (_progress!.overallSuccessRate * 100).toStringAsFixed(0),
                  Icons.trending_up,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.generalProgress,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.grey[200],
              color: _getProgressColor(progress),
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.dayZero,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Container(
                  height: 16,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 1,
                        height: 8,
                        color: Colors.orange,
                      ),
                      Positioned(
                        bottom: 0,
                        child: Text(
                          _campPlan.minCompletionDays.toString() + context.l10n.day,
                          style: const TextStyle(color: Colors.orange, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                totalDays.toString() + context.l10n.day,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  _progress!.isCampCompleted ? Icons.check_circle : Icons.info,
                  color: _progress!.isCampCompleted ? Colors.green : Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _progress!.isCampCompleted
                        ? context.l10n.congratsComplete
                        : context.l10n.minCompletionDaysText + _campPlan.minCompletionDays.toString() + context.l10n.minCompletionDaysText2,
                    style: TextStyle(
                      color: _progress!.isCampCompleted ? Colors.green : Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue.shade600, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStrengthsWeaknessesCard() {
    if (_progress == null) return Container();
    
    // Zorlanılan konuları topla
    final List<String> allStrugglingTopics = [];
    _progress!.dayProgress.values.forEach((day) {
      if (day.isCompleted) {
        allStrugglingTopics.addAll(day.strugglingTopics);
      }
    });
    
    // En çok zorlanılan 3 konu
    final topStrugglingTopics = _getTopNOccurrences(allStrugglingTopics, 3);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.strengthsWeaknessesTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            if (topStrugglingTopics.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    context.l10n.notEnoughData,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else
              Column(
                children: [
                  ...topStrugglingTopics.map((topic) => _buildTopicItem(
                    topic.key,
                    topic.value / allStrugglingTopics.length,
                    Colors.red.shade600,
                  )),
                ],
              ),
            if (topStrugglingTopics.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.lightbulb),
                  label: Text(context.l10n.extraStudySuggestions),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.l10n.studySuggestionsMessage)),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicItem(String topic, double ratio, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            topic,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 2),
          Text(
            (ratio * 100).toStringAsFixed(0) + context.l10n.struggleRateText,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionCard() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade300,
              Colors.blue.shade500,
            ],
          ),
        ),
        child: Column(
          children: [
            const Icon(Icons.workspace_premium, color: Colors.yellow, size: 48),
            const SizedBox(height: 16),
            Text(
              context.l10n.congratsTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.campCompletionText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            if (_progress!.isCertificateEarned)
              OutlinedButton.icon(
                icon: const Icon(Icons.download, color: Colors.white),
                label: Text(
                  context.l10n.downloadCertificate,
                  style: const TextStyle(color: Colors.white),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.downloadingCertificateMessage)),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarTab() {
    if (_progress == null) {
      return _buildNoProgressView();
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.tenDayCampCalendar,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          CampCalendarWidget(
            campPlan: _campPlan,
            progress: _progress!,
            onDayTap: (day) {
              Navigator.pop(context);
              Navigator.pushNamed(
                context, 
                '/camp_day',
                arguments: day.dayNumber,
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.dailySummary,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          _buildDaySummariesList(),
        ],
      ),
    );
  }

  Widget _buildDaySummariesList() {
    if (_progress == null) return Container();
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _campPlan.days.length,
      itemBuilder: (context, index) {
        final day = _campPlan.days[index];
        final dayProgress = _progress!.dayProgress[day.dayNumber];
        
        final isCompleted = dayProgress?.isCompleted ?? false;
        final dayColor = _getDayColor(day.dayNumber);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isCompleted 
                  ? Colors.green
                  : day.isLocked 
                      ? Colors.grey.shade300
                      : dayColor.withOpacity(0.5),
              width: isCompleted ? 2 : 1,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted 
                    ? Colors.green
                    : day.isLocked 
                        ? Colors.grey.shade400
                        : dayColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  day.dayNumber.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            title: Text(
              day.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: day.isLocked ? Colors.grey : Colors.black,
              ),
            ),
            subtitle: dayProgress != null
                ? Text(
                dayProgress.correctAnswers.toString() + '/' + day.totalQuestions.toString() + ' | ' +
                context.l10n.successLabel,
                style: TextStyle(
                color: day.isLocked ? Colors.grey : Colors.grey.shade700,
                ),
                )
                : Text(
                    day.difficulty,
                    style: TextStyle(
                      color: day.isLocked ? Colors.grey : Colors.grey.shade700,
                    ),
                  ),
            trailing: isCompleted
                ? const Icon(Icons.check_circle, color: Colors.green)
                : Icon(
                    day.isLocked ? Icons.lock : Icons.arrow_forward_ios,
                    color: day.isLocked ? Colors.grey : Colors.grey.shade400,
                    size: 16,
                  ),
            onTap: day.isLocked
                ? null
                : () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context, 
                      '/camp_day',
                      arguments: day.dayNumber,
                    );
                  },
          ),
        );
      },
    );
  }

  Widget _buildBadgesTab() {
    if (_progress == null) {
      return _buildNoProgressView();
    }
    
    final earnedBadges = _progress!.earnedBadges;
    final totalPossibleBadges = _campPlan.badges.length + _campPlan.durationDays;
    
    // Kazanılan rozet grupları
    final dayBadges = earnedBadges.where((b) => b.id.startsWith('day_complete')).toList();
    final perfectDayBadges = earnedBadges.where((b) => b.id.startsWith('perfect_day')).toList();
    final specialBadges = earnedBadges.where((b) => 
        !b.id.startsWith('day_complete') && !b.id.startsWith('perfect_day')).toList();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    context.l10n.badgeGallery,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildProgressInfoBox(
                      context.l10n.earnedBadges,
                      earnedBadges.length.toString(),
                      Colors.green,
                      ),
                      _buildProgressInfoBox(
                        context.l10n.remainingBadges,
                        (totalPossibleBadges - earnedBadges.length).toString(),
                        Colors.orange,
                      ),
                      _buildProgressInfoBox(
                        context.l10n.completionRate,
                        context.l10n.percentPrefix + (earnedBadges.length / totalPossibleBadges * 100).toStringAsFixed(0),
                        Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          if (specialBadges.isNotEmpty) ...[
            Text(
              context.l10n.specialBadges,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: specialBadges.map((badge) => 
                BadgeWidget(badge: badge)
              ).toList(),
            ),
            const SizedBox(height: 24),
          ],
          
          Text(
            context.l10n.dayCompletionBadges,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _campPlan.durationDays,
              itemBuilder: (context, index) {
                final dayNumber = index + 1;
                final badgeId = 'day_complete_$dayNumber';
                final earnedBadge = earnedBadges.firstWhere(
                  (b) => b.id == badgeId,
                  orElse: () => CampBadge(
                    id: 'locked_$dayNumber',
                    title: context.l10n.dayBadgeTemplate(dayNumber),
                    description: context.l10n.badgeNotEarned,
                    iconPath: 'assets/badges/locked.png',
                    earnedDate: DateTime.now(),
                  ),
                );
                
                final isEarned = earnedBadge.id.startsWith('day_complete');
                
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 8),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isEarned ? Colors.blue.shade100 : Colors.grey.shade200,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isEarned ? Colors.blue : Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: isEarned
                              ? Icon(Icons.check_circle, color: Colors.blue, size: 32)
                              : Text(
                                  dayNumber.toString(),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.dayTextPrefix + dayNumber.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: isEarned ? Colors.blue : Colors.grey.shade600,
                          fontWeight: isEarned ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          
          if (perfectDayBadges.isNotEmpty) ...[
            Text(
              context.l10n.perfectDayBadges,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: perfectDayBadges.map((badge) => 
                BadgeWidget(badge: badge)
              ).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressInfoBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoProgressView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hiking,
            size: 72,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.noCampStarted,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.trackProgressText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: Text(context.l10n.startCamp),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.3) {
      return Colors.red;
    } else if (progress < 0.8) {
      return Colors.orange;
    } else {
      return Colors.green;
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

  List<MapEntry<String, int>> _getTopNOccurrences(List<String> items, int n) {
    // Eleman ve tekrar sayılarını hesapla
    final Map<String, int> occurrences = {};
    for (final item in items) {
      occurrences[item] = (occurrences[item] ?? 0) + 1;
    }
    
    // Azalan sırayla sırala
    final sortedEntries = occurrences.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // İlk n elemanı döndür
    return sortedEntries.take(n).toList();
  }
}