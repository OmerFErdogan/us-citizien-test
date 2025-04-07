import 'dart:math';
import 'package:flutter/material.dart';
import 'package:us_civics_test_app/features/camp_mode/models/camp_progress.dart';
import '../models/camp_day.dart';
import '../services/camp_service.dart';
import '../widgets/daily_task_card.dart';
import 'quiz_selection_launcher.dart';

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
    print('_loadDayData çağrıldı - verileri yeniden yüklüyor');
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _campService.initialize();
      
      // İlerleme ve aktivite durumlarını senkronize et (eklendi)
      await _campService.syncProgressWithActivities();
      
      // Günü yükle
      final day = _campService.getDayByNumber(widget.dayNumber);
      
      if (day == null) {
        throw Exception('Gün bulunamadı');
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
      print('Hata: $e'); // Hata log'u
      setState(() {
        _errorMessage = 'Gün yüklenemedi: $e';
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
            ? const Text('Gün Yükleniyor...')
            : Text('Gün ${widget.dayNumber}: ${_errorMessage.isEmpty ? _day.title : ""}'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red)))
              : _buildBody(),
    );
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
            'Bu gün henüz kilitli',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Önceki günü tamamlayarak kilidini açabilirsiniz',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.arrow_back),
            label: const Text('Önceki Güne Dön'),
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
                  decoration: BoxDecoration(
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
                        'Zorluk: ${_day.difficulty}',
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
                  'Toplam Soru',
                  '${_day.totalQuestions}',
                  Icons.help_outline,
                ),
                _buildHeaderStat(
                  'Hedef',
                  '${_day.targetCorrect}',
                  Icons.check_circle_outline,
                ),
                _buildHeaderStat(
                  'Başarı Oranı',
                  '%${(_day.targetSuccessRate * 100).toStringAsFixed(0)}',
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
                  'Günlük İlerleme',
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
                          'Tamamlandı',
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
                  'Doğru',
                  '$_correctAnswers/${_day.totalQuestions}',
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildProgressStat(
                  'Hedef',
                  '${_day.targetCorrect}/${_day.totalQuestions}',
                  Icons.flag,
                  Colors.orange,
                ),
                _buildProgressStat(
                  'Başarı',
                  '%${(_successRate * 100).toStringAsFixed(0)}',
                  Icons.trending_up,
                  _successRate >= _day.targetSuccessRate 
                      ? Colors.green 
                      : Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'İlerleme',
              style: TextStyle(
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
                  '0%',
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
                          '%${(_day.targetSuccessRate * 100).toStringAsFixed(0)}',
                          style: TextStyle(color: Colors.orange, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '100%',
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
            'Günlük Aktiviteler',
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
          label: const Text(
            'Tüm Soruları Çöz',
            style: TextStyle(fontSize: 16),
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
          label: const Text(
            'Çalışma Materyalini Aç',
            style: TextStyle(fontSize: 16),
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
              label: const Text(
                'Günü Test Amaçlı Tamamla',
                style: TextStyle(color: Colors.purple),
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
                    'Bu günü başarıyla tamamladınız!',
                    style: TextStyle(
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
        const SnackBar(
          content: Text('Bu günü zaten tamamladınız. Yine de pratik yapabilirsiniz.'),
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
                  content: Text('${activity.title} başarıyla tamamlandı!'),
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
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Tüm Aktiviteler Tamamlandı!'),
          ],
        ),
        content: Text(
          'Tebrikler! Bu günün tüm aktivitelerini tamamladınız. Günü tamamlamak ve bir sonraki günün kilidini açmak ister misiniz?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Daha Sonra'),
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
            child: Text('Günü Tamamla'),
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
          title: 'Günlük Test', 
          description: 'Gün ${_day.dayNumber}: ${_day.title} için kapsamlı test',
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
                  content: Text('Hedef skorun altında kaldınız (${score}/${_day.targetCorrect}). Tekrar deneyebilirsiniz.'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 4),
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
      print('Gün ${widget.dayNumber} tamamlanıyor, doğru sayısı: $correctCount');
      
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
      
      print('Gün ${widget.dayNumber} tamamlandı, başarı: $success');
      
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
              ? 'Gün başarıyla tamamlandı!' 
              : 'Gün tamamlandı, ancak hedefin altında kaldınız.'),
          backgroundColor: success ? Colors.green : Colors.orange,
          action: isNextDayUnlocked ? SnackBarAction(
            label: '$nextDayNumber. Güne Git',
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
      print('Hata: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
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
            Icon(Icons.emoji_events, color: Colors.amber),
            SizedBox(width: 8),
            Text('Yeni Rozet Kazandınız!'),
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
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text(badge.title),
                subtitle: Text(badge.description),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Harika!'),
          ),
        ],
      ),
    );
  }

  void _openStudyMaterial() {
    // Gerçek uygulamada, çalışma materyalini açma işlemi
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Çalışma materyali açılıyor: ${_day.materialUrl}'),
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
            Icon(Icons.science, color: Colors.purple),
            SizedBox(width: 8),
            Text('Simülasyon Modu'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bu işlem, test amaçlı olarak günü simüle edecek ve başarı ile tamamlayacaktır.'),
            SizedBox(height: 16),
            Text('Başarı seviyesini seçin:'),
            SizedBox(height: 8),
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
                  child: Text('Minimum'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Orta başarı (hedef + 1-2 arası)
                    _runSimulation(_day.targetCorrect + 1 + Random().nextInt(2));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text('Orta'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Yüksek başarı (tam puan)
                    _runSimulation(_day.totalQuestions);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text('Yüksek'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
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
          content: Text('Gün $simulatedScore doğru cevapla simüle edildi'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('Simülasyon hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Simülasyon sırasında bir hata oluştu: ${e.toString().substring(0, min(50, e.toString().length))}...'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}