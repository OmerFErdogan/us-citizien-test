import 'package:flutter/material.dart';
import '../models/camp_plan.dart';
import '../services/camp_service.dart';
import 'camp_day_screen.dart';
import 'camp_progress_screen.dart';

class CampIntroScreen extends StatefulWidget {
  const CampIntroScreen({
    Key? key,
  }) : super(key: key);

  @override
  _CampIntroScreenState createState() => _CampIntroScreenState();
}

class _CampIntroScreenState extends State<CampIntroScreen> {
  bool _isLoading = true;
  late CampPlan _campPlan;
  final CampService _campService = CampService();
  bool _hasActiveProgress = false;
  int _activeDay = 0;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCampData();
  }

  Future<void> _loadCampData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _campService.initialize();
      
      // İlerleme ve aktivite durumlarını senkronize et
      await _campService.syncProgressWithActivities();
      
      _campPlan = _campService.getCampPlan();
      
      // Aktif kamp ilerlemesi var mı kontrol et
      final progress = _campService.getUserProgress();
      _hasActiveProgress = progress != null;
      
      // Aktif günü belirle
      if (_hasActiveProgress) {
        final activeDay = _campService.getActiveDay();
        _activeDay = activeDay?.dayNumber ?? 1;
      }
    } catch (e) {
      print('Hata: $e'); // Hata log'u
      setState(() {
        _errorMessage = 'Kamp verisi yüklenemedi: $e';
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
        title: const Text('10 Günde Vatandaşlık'),
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildCampDescription(),
            const SizedBox(height: 24),
            _buildCampStructure(),
            const SizedBox(height: 24),
            _buildBenefits(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
              Colors.blue.shade700,
              Colors.indigo.shade900,
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.flag, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Text(
                  _campPlan.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _campPlan.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            if (_hasActiveProgress)
              OutlinedButton.icon(
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: Text(
                  'Gün $_activeDay\'e Devam Et',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                onPressed: () => _navigateToCampDay(_activeDay),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampDescription() {
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
                Icon(Icons.schedule, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'Program Hakkında',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '10 Günde Vatandaşlık programı, ABD vatandaşlık sınavına hızlı ve etkili bir şekilde hazırlanmanızı sağlayan yoğunlaştırılmış bir çalışma kampıdır. Her gün farklı bir konu üzerinde çalışarak, sistematik bir yaklaşımla sınavın tüm alanlarını kapsarsınız.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 8),
            Text(
              'Program, en az 8 günün başarıyla tamamlanmasını gerektiren, günlük hedeflere dayalı bir yaklaşım sunar. Her gün sabah, öğle ve akşam oturumlarından oluşur.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampStructure() {
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
                Icon(Icons.view_timeline, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  '10 Günlük Plan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDayItem(1, 'Amerikan Tarihi Temelleri', Colors.blue),
            _buildDayItem(2, 'Amerikan Hükümeti ve Anayasa', Colors.indigo),
            _buildDayItem(3, 'Haklar ve Sorumluluklar', Colors.teal),
            _buildDayItem(4, 'Politik Sistem ve Partiler', Colors.purple),
            _buildDayItem(5, 'Tekrar ve Ara Değerlendirme', Colors.orange),
            
            // "Tümünü Gör" butonu
            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.expand_more),
                label: const Text('Tüm Planı Gör'),
                onPressed: () => _showFullPlan(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayItem(int day, String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefits() {
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
                Icon(Icons.stars, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'Faydaları',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildBenefitItem(
              Icons.speed,
              'Hızlı İlerleme',
              'Sadece 10 günde sistematik öğrenme',
            ),
            _buildBenefitItem(
              Icons.dashboard_customize,
              'Kapsamlı İçerik',
              'Vatandaşlık sınavının tüm konu alanlarını kapsar',
            ),
            _buildBenefitItem(
              Icons.workspace_premium,
              'Rozetler ve Sertifikalar',
              'İlerlemenizi göstermenin somut yolları',
            ),
            _buildBenefitItem(
              Icons.trending_up,
              'İlerleme Takibi',
              'Gelişiminizi günlük olarak görün',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue.shade700, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.play_circle_fill),
          label: Text(
            _hasActiveProgress ? 'Kampa Devam Et' : 'Kampa Başla',
            style: const TextStyle(fontSize: 18),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: () => _hasActiveProgress
              ? _navigateToCampDay(_activeDay)
              : _startNewCamp(),
        ),
        const SizedBox(height: 12),
        if (_hasActiveProgress)
          OutlinedButton.icon(
            icon: const Icon(Icons.bar_chart),
            label: const Text(
              'İlerleme Durumunu Gör',
              style: TextStyle(fontSize: 16),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () => _navigateToProgressScreen(),
          ),
        const SizedBox(height: 12),
        if (_hasActiveProgress)
          TextButton.icon(
            icon: Icon(Icons.refresh, color: Colors.red.shade700),
            label: Text(
              'Kampı Sıfırla',
              style: TextStyle(color: Colors.red.shade700, fontSize: 16),
            ),
            onPressed: () => _showResetConfirmation(),
          ),
      ],
    );
  }

  void _showFullPlan() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '10 Günlük Kamp Planı',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Her gün farklı bir konuya odaklanarak, vatandaşlık sınavı için gereken tüm bilgileri sistematik olarak öğrenin.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: _campPlan.days.length,
                      itemBuilder: (context, index) {
                        final day = _campPlan.days[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 1,
                          child: ListTile(
                            leading: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _getDayColor(day.dayNumber),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  day.dayNumber.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              day.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(day.description),
                                const SizedBox(height: 4),
                                Text(
                                  '${day.totalQuestions} soru | Hedef: ${day.targetCorrect} doğru | ${day.difficulty}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            isThreeLine: true,
                            trailing: Icon(
                              day.isLocked ? Icons.lock : Icons.lock_open,
                              color: day.isLocked ? Colors.grey : Colors.green,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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

  void _startNewCamp() async {
    // Onay dialoğu göster
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Kamp Başlat'),
        content: const Text(
          '10 günlük vatandaşlık kampına başlamak üzeresiniz. Her gün düzenli olarak çalışmanız önerilir. Başlamak istiyor musunuz?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Başlat'),
          ),
        ],
      ),
    ) ?? false;
    
    if (confirmed) {
      try {
        setState(() {
          _isLoading = true;
        });
        
        // Yeni kamp başlat
        await _campService.startNewCamp();
        
        // İlk günün kilidini açmaya emin olalım
        final day = _campService.getDayByNumber(1);
        if (day != null && day.isLocked) {
          // İlk günün kilidini aç
          final dayIndex = _campPlan.days.indexOf(day);
          _campPlan.days[dayIndex] = day.copyWith(isLocked: false);
          
          // Değişiklikleri kaydet (servisi güncellemek için)
          await _campService.initialize();
        }
        
        // Verileri yeniden yükle
        await _loadCampData();
        
        // İlk güne git
        _navigateToCampDay(1);
      } catch (e) {
        print('Kamp başlatma hatası: $e'); // Hata log'u
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToCampDay(int dayNumber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CampDayScreen(
          dayNumber: dayNumber,
        ),
      ),
    ).then((_) {
      // Geri döndüğünde verileri yenile
      _loadCampData();
    });
  }

  void _navigateToProgressScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CampProgressScreen(),
      ),
    ).then((_) => _loadCampData());
  }

  void _showResetConfirmation() async {
    // Onay dialoğu göster
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Kampı Sıfırla',
          style: TextStyle(color: Colors.red.shade700),
        ),
        content: const Text(
          'Dikkat! Bu işlem mevcut kamp ilerlemenizi tamamen silecek ve sıfırdan başlamanız gerekecek. Bu işlem geri alınamaz. Devam etmek istiyor musunuz?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Sıfırla'),
          ),
        ],
      ),
    ) ?? false;
    
    if (confirmed) {
      try {
        setState(() {
          _isLoading = true;
        });
        
        // Kampı sıfırla
        await _campService.resetCamp();
        
        // Verileri yeniden yükle
        await _loadCampData();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kamp sıfırlandı')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}