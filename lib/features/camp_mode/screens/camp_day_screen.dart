import 'dart:math';
import 'package:flutter/material.dart';
import 'package:us_citizenship_test/features/camp_mode/models/camp_progress.dart';
import 'package:us_citizenship_test/utils/extensions.dart';
import '../models/camp_day.dart';
import '../services/camp_service.dart';
import '../widgets/daily_task_card.dart';
import 'quiz_selection_launcher.dart';
import '../../../widgets/camp_paywall.dart';

// Stringler arb dosyalarında tanımlıdır

class CampDayScreen extends StatefulWidget {
  final int dayNumber;

  const CampDayScreen({
    Key? key,
    required this.dayNumber,
  }) : super(key: key);

  @override
  _CampDayScreenState createState() => _CampDayScreenState();
}

class _CampDayScreenState extends State<CampDayScreen> {
  bool _isLoading = true;
  late CampDay _day;
  final CampService _campService = CampService();
  bool _isLocked = true;
  String _errorMessage = '';
  bool _isCompleted = false;
  int _correctAnswers = 0;
  double _successRate = 0.0;

  @override
  void initState() {
    super.initState();
    _loadDayData();
  }

  Future<void> _loadDayData() async {
    print('_loadDayData called - reloading data');
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _campService.initialize();
      
      // Premium durumunu kontrol et
      final canAccess = await _campService.canAccessDay(widget.dayNumber);
      
      if (!canAccess && widget.dayNumber > 2) {
        // Premium olmayan ve 3. günden sonraki günler için locked screen göster
        setState(() {
          _isLoading = false;
          _isLocked = true;
        });
        return;
      }
      
      // İlerleme ve aktivite durumlarını senkronize et
      await _campService.syncProgressWithActivities();
      
      // Günü yükle
      final day = _campService.getDayByNumber(widget.dayNumber);
      
      if (day == null) {
        throw Exception(context.l10n.errorDayNotFound);
      }
      
      // Kullanıcı ilerlemesi
      final progress = _campService.getUserProgress();
      final dayProgress = progress?.dayProgress[widget.dayNumber];

      // Aktivite durumlarını kontrol et ve güncelle (eklendi)
      if (day != null && progress != null) {
        // Eğer gün tamamlandıysa ve aktiviteler güncel değilse
        if (dayProgress?.isCompleted == true) {
          // Tüm aktivitelerin tamamlandığından emin ol
          for (var activity in day.activities) {
            if (!activity.isCompleted) {
              activity.isCompleted = true; // Yerel durumu güncelle
            }
          }
        }
      }
      
      setState(() {
        _day = day;
        _isLocked = day.isLocked;
        _isCompleted = dayProgress?.isCompleted ?? false;
        _correctAnswers = dayProgress?.correctAnswers ?? 0;
        _successRate = dayProgress?.successRate ?? 0.0;
      });
    } catch (e) {
      print(context.l10n.error + e.toString()); // Hata log'u
      setState(() {
        _errorMessage = context.l10n.errorDayLoading + e.toString();
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
        title: _isLoading
            ? Text(context.l10n.dayLoading)
            : Text(context.l10n.dayTitle(widget.dayNumber, (_errorMessage.isEmpty ? _day.title : ""))),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red)))
              : _buildBody(),
    );
  }

  void _showPaywall() async {
    final purchased = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CampPaywall(),
    );
    
    if (purchased == true) {
      // Premium satın alındıktan sonra gün verilerini yeniden yükle
      await _loadDayData();
    }
  }

  Widget _buildBody() {
    return Container(
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
      child: _isLocked
          ? _buildLockedContent()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDayHeader(),
                  const SizedBox(height: 24),
                  _buildDayProgress(),
                  const SizedBox(height: 24),
                  _buildActivities(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildLockedContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock,
            size: 72,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Day ${widget.dayNumber} is Locked',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.dayNumber > 2
                ? 'Unlock all 10 days with premium features'
                : context.l10n.unlockInstruction,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          if (widget.dayNumber > 2)
            ElevatedButton.icon(
              icon: const Icon(Icons.star),
              label: const Text('Unlock for \$1.99'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: _showPaywall,
            )
          else
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: Text(context.l10n.returnToPreviousDay),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () => Navigator.pop(context),
            ),
        ],
      ),
    );
  }

  Widget _buildDayHeader() {
    return Card(
      elevation: 4,
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
              _getDayColor(widget.dayNumber).withOpacity(0.8),
              _getDayColor(widget.dayNumber),
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _day.dayNumber.toString(),
                      style: TextStyle(
                        color: _getDayColor(widget.dayNumber),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _day.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.difficultyLabel + _day.difficulty,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _day.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildHeaderStat(
                  context.l10n.totalQuestionsLabel,
                  '${_day.totalQuestions}',
                  Icons.help_outline,
                ),
                _buildHeaderStat(
                  context.l10n.targetLabel,
                  '${_day.targetCorrect}',
                  Icons.check_circle_outline,
                ),
                _buildHeaderStat(
                  context.l10n.successRateLabel,
                  context.l10n.percentPrefix + '${(_day.targetSuccessRate * 100).toStringAsFixed(0)}',
                  Icons.trending_up,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDayProgress() {
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
            Row(
              children: [
                Icon(Icons.insert_chart, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  context.l10n.dailyProgress,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const Spacer(),
                if (_isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade700, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          context.l10n.completedStatus,
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildProgressStat(
                  context.l10n.correctLabelShort,
                  '$_correctAnswers/${_day.totalQuestions}',
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildProgressStat(
                  context.l10n.targetValueLabel,
                  '${_day.targetCorrect}/${_day.totalQuestions}',
                  Icons.flag,
                  Colors.orange,
                ),
                _buildProgressStat(
                  context.l10n.successLabel,
                  context.l10n.percentPrefix + '${(_successRate * 100).toStringAsFixed(0)}',
                  Icons.trending_up,
                  _successRate >= _day.targetSuccessRate 
                      ? Colors.green 
                      : Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.progressLabel,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _successRate,
              minHeight: 12,
              backgroundColor: Colors.grey[200],
              color: _getProgressColor(_successRate),
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.zeroPercent,
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
                          context.l10n.percentPrefix + '${(_day.targetSuccessRate * 100).toStringAsFixed(0)}',
                          style: const TextStyle(color: Colors.orange, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  context.l10n.fullPercent,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
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

  Widget _buildActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            context.l10n.dailyActivities,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ..._day.activities.map((activity) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: DailyTaskCard(
              activity: activity,
              dayNumber: _day.dayNumber,
              isCompleted: _isCompleted || activity.isCompleted,
              onStartActivity: () => _startActivity(activity),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.view_list),
          label: Text(
            context.l10n.solveAllQuestions,
            style: const TextStyle(fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: _getDayColor(widget.dayNumber),
          ),
          onPressed: _isCompleted ? null : () => _startDailyTest(),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          icon: const Icon(Icons.menu_book),
          label: Text(
            context.l10n.openStudyMaterial,
            style: const TextStyle(fontSize: 16),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () => _openStudyMaterial(),
        ),
        // Test modu için geliştirme butonunu göster
        if (!_isCompleted && _isDebugMode())
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.science, color: Colors.purple),
              label: Text(
                context.l10n.completeDayForTesting,
                style: const TextStyle(color: Colors.purple),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.purple),
              ),
              onPressed: () => _completeDaySimulation(),
            ),
          ),
        const SizedBox(height: 8),
        if (_isCompleted)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.dayCompletedSuccess,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
  
  // Debug modunda olup olmadığını kontrol et
  bool _isDebugMode() {
    bool debugMode = false;
    assert(debugMode = true); // Assert sadece debug modunda çalışır
    return debugMode;
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

  Color _getProgressColor(double progress) {
    if (progress < 0.3) {
      return Colors.red;
    } else if (progress < _day.targetSuccessRate) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  void _startActivity(CampActivity activity) {
    if (_isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.alreadyCompletedDay),
        ),
      );
    }
    
    // Ana uygulamadaki quiz ekranına yönlendir
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizSelectionLauncher(
          title: activity.title, 
          description: activity.description,
          questionCount: activity.questionCount,
          dayNumber: widget.dayNumber, // Gün numarasını direkt geç (eklendi)
          categories: activity.categories, // Aktivite kategorilerini geç (eklendi)
          onComplete: (score) async {
            // Quiz tamamlandığında geri dön ve başarı durumunu işle
            if (!_isCompleted && score >= activity.questionCount * 0.7) {
              // Eğer gerçek bir aktivite tamamladıysa ve %70 başarı sağladıysa
              setState(() {
                activity.isCompleted = true;
              });
              
              // Kayıt (persistance) için aktivite durumunu güncelle
              await _campService.updateActivityCompletion(
                widget.dayNumber, 
                activity.title, 
                true
              );
              
              // Aktivitenin tamamlandığını ve başarı durumunu bildir
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(activity.title + context.l10n.activityCompletedSuccess),
                  backgroundColor: Colors.green,
                ),
              );
              
              // Tüm aktiviteler tamamlandı mı kontrol et
              final allActivitiesCompleted = _day.activities.every((a) => a.isCompleted);
              if (allActivitiesCompleted) {
                // Tüm aktiviteler tamamlandı ise, kullanıcıya bildir ve günü tamamlama seçeneği sun
                Future.delayed(const Duration(milliseconds: 500), () {
                  _showAllActivitiesCompletedDialog();
                });
              }
              
              // Gün verilerini yeniden yükle ve ekranı yenile
              _loadDayData();
            } else if (score >= 0) {
              // Başarısız olsa bile ekranı yenile
              setState(() {});
            }
          },
        ),
      ),
    );
  }
  
  // Tüm aktiviteler tamamlandığında gösterilecek diyalog
  void _showAllActivitiesCompletedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text(context.l10n.allActivitiesCompleted),
          ],
        ),
        content: Text(context.l10n.allActivitiesCompletedMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.later),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              
              // Aktivitelere göre doğru cevap sayısını hesapla - daha gerçekçi hesaplama
              int totalCorrect = 0;
              int totalQuestions = 0;
              
              // Her aktivitenin başarı oranını hesapla
              _day.activities.forEach((activity) {
                if (activity.isCompleted) {
                  totalQuestions += activity.questionCount;
                  
                  // Daha gerçekçi bir puan hesaplama yöntemi kullan
                  // %70 yerine %80 başarı oranı kullanarak yeterlilik gösterir
                  int activityCorrect = (activity.questionCount * 0.8).ceil();
                  totalCorrect += activityCorrect;
                }
              });
              
              // Hesaplanan ortalama skoru kullanarak günü tamamla
              if (totalQuestions > 0) {
                // Puanları normalize et
                int finalScore = (totalCorrect * _day.totalQuestions / totalQuestions).round();
                
                // Minimum başarıyı sağla (en az hedefin %90'ı kadar puan olmalı)
                finalScore = finalScore.clamp(_day.targetCorrect, _day.totalQuestions);
                
                _completeDayWithScore(finalScore);
              }
            },
            child: Text(context.l10n.completeDay),
          ),
        ],
      ),
    );
  }

  void _startDailyTest() {
    // Ana uygulamadaki quiz ekranına yönlendir
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizSelectionLauncher(
          title: context.l10n.dailyTest, 
          description: context.l10n.dayTitle(_day.dayNumber, _day.title) + 
                      context.l10n.dailyTestDescription,
          questionCount: _day.totalQuestions,
          onComplete: (score) async {
            // Quiz tamamlandığında geri dön ve başarı durumunu işle
            if (!_isCompleted && score >= _day.targetCorrect) {
              // Günü tamamla
              await _completeDayWithScore(score);
            } else if (!_isCompleted) {
              // Hedefi tutturamadıysa bildiri göster
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.targetNotReached + 
                               score.toString() + '/' + _day.targetCorrect.toString() + 
                               context.l10n.targetNotReachedEnd),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 4),
                ),
              );
              
              // Başarısız olsa bile ekranı yenile
              setState(() {});
              _loadDayData(); // Verileri yenile
            }
          },
        ),
      ),
    );
  }

  Future<void> _completeDayWithScore(int score) async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Başarı oranını hesapla
      final correctCount = score;
      print('Day ' + widget.dayNumber.toString() + 
            ' completing, correct count: ' + correctCount.toString());
      
      // Zorlanılan konuları belirle (kategorilere göre)
      // Gerçek uygulamada burada quiz sonucu verilerinden kategorilere göre analiz yapılır
      final strugglingTopics = <String>[];
      if (correctCount < _day.targetCorrect) {
        // Eğer hedefin altındaysa, bu günün tüm kategorilerini zorlanilan olarak belirle
        _day.activities.forEach((activity) {
          strugglingTopics.addAll(activity.categories);
        });
      }
      
      // Günü tamamla
      final success = await _campService.completeDay(
        widget.dayNumber,
        correctCount,
        strugglingTopics.toSet().toList(), // Tekrar edenleri filtrele
      );
      
      print('Day ' + widget.dayNumber.toString() + 
            ' completed, success: ' + success.toString());
      
      // Günün durumunu yeniden yükle
      await _loadDayData();
      
      // Bir sonraki günün açıldığını kontrol et ve bildirim göster
      final progress = _campService.getUserProgress();
      final nextDayNumber = widget.dayNumber + 1;
      final nextDay = _campService.getDayByNumber(nextDayNumber);
      final isNextDayUnlocked = nextDay != null && !nextDay.isLocked;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
              ? context.l10n.dayCompletedSuccessfully 
              : context.l10n.dayCompletedBelowTarget),
          backgroundColor: success ? Colors.green : Colors.orange,
          action: isNextDayUnlocked ? SnackBarAction(
            label: context.l10n.goToNextDay + nextDayNumber.toString(),
            onPressed: () {
              // Bir sonraki güne git
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => CampDayScreen(dayNumber: nextDayNumber),
                ),
              );
            },
          ) : null,
        ),
      );
      
      // Rozetleri kontrol et ve dialog göster
      if (success && progress != null) {
        final todayEarnedBadges = progress.earnedBadges
          .where((badge) => 
            badge.earnedDate.difference(DateTime.now()).inHours.abs() < 1 && // Son 1 saat içinde
            (badge.id.contains('day_complete_${widget.dayNumber}') ||
             badge.id.contains('perfect_day_${widget.dayNumber}') ||
             badge.id == 'halfway' ||
             badge.id == 'camp_complete' ||
             badge.id == 'perfect_camp')
          ).toList();
        
        if (todayEarnedBadges.isNotEmpty) {
          // Bir süre sonra rozet dialogüu göster
          Future.delayed(const Duration(seconds: 1), () {
            _showBadgeEarnedDialog(todayEarnedBadges);
          });
        }
      }
    } catch (e) {
      print(context.l10n.error + e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.error + e.toString())),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _showBadgeEarnedDialog(List<CampBadge> badges) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber),
            const SizedBox(width: 8),
            Text(context.l10n.newBadgeEarned),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          height: 100.0 * badges.length,
          child: ListView.builder(
            itemCount: badges.length,
            itemBuilder: (context, index) {
              final badge = badges[index];
              return ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(badge.title),
                subtitle: Text(badge.description),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.great),
          ),
        ],
      ),
    );
  }

  void _openStudyMaterial() {
    // Gerçek uygulamada, çalışma materyalini açma işlemi
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.openingStudyMaterial + _day.materialUrl),
      ),
    );
  }

  // Simüle edilmiş gün tamamlama işlemi
  void _completeDaySimulation() {
    print('_completeDaySimulation called');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.science, color: Colors.purple),
            const SizedBox(width: 8),
            Text(context.l10n.simulationMode),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.simulationDescription),
            const SizedBox(height: 16),
            Text(context.l10n.selectSuccessLevel),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Minimum başarı (tam hedef puan)
                    _runSimulation(_day.targetCorrect);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: Text(context.l10n.minimumSuccess),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Orta başarı (hedef + 1-2 arası)
                    _runSimulation(_day.targetCorrect + 1 + Random().nextInt(2));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text(context.l10n.mediumSuccess),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Yüksek başarı (tam puan)
                    _runSimulation(_day.totalQuestions);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text(context.l10n.highSuccess),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
        ],
      ),
    );
  }
  
  // Belirlenen skorla simülasyonu çalıştır
  void _runSimulation(int simulatedScore) async {
    try {
      // Önce tüm aktiviteleri tamamlanmış olarak işaretle
      for (var activity in _day.activities) {
        if (!activity.isCompleted) {
          activity.isCompleted = true;
          
          // Aktivite durumunu güncelle (her aktiviteyi tek tek kaydet)
          await _campService.updateActivityCompletion(
            widget.dayNumber, 
            activity.title, 
            true
          );
        }
      }
      
      // Günü tamamla
      await _completeDayWithScore(simulatedScore);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.simulationSuccessMessage + 
                      simulatedScore.toString() + 
                      context.l10n.simulationSuccessEnd),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('Simulation error: ' + e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.simulationError + 
                      e.toString().substring(0, min(50, e.toString().length)) + 
                      '...'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}