import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:us_citizenship_test/utils/app_localizations_provider.dart';
import 'package:us_citizenship_test/utils/extensions.dart';
import '../models/camp_plan.dart';
import '../services/camp_service.dart';
import 'camp_day_screen.dart';
import 'camp_progress_screen.dart';
import '../../../widgets/camp_paywall.dart';
import '../../../services/revenue_cat_service.dart';

// CampStrings class has been removed and replaced with localization

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
  bool _isPremium = false;

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
      // Premium durumunu kontrol et
      _isPremium = await RevenueCatService.isPremiumUser();
      
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
        _errorMessage = context.l10n.errorLoadingCamp + e.toString();
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
        title: Text(context.l10n.campIntroTitle),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red)))
              : _buildBody(),
    );
  }

  Widget _buildFreemiumBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[100]!, Colors.blue[50]!],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.info, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Free Preview: First 2 days',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Unlock all 10 days with premium features for just \$1.99',
            style: TextStyle(color: Colors.blue[700]),
          ),
        ],
      ),
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
            if (!_isPremium) _buildFreemiumBanner(),
            if (!_isPremium) const SizedBox(height: 24),
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
                  context.l10n.continueToDay + _activeDay.toString() + context.l10n.continueText,
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
                  context.l10n.aboutProgram,
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
              context.l10n.campDescriptionP1,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.campDescriptionP2,
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
                  context.l10n.tenDayPlan,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDayItem(1, context.l10n.americanHistoryBasics, Colors.blue),
            _buildDayItem(2, context.l10n.americanGovConstitution, Colors.indigo),
            _buildDayItem(3, context.l10n.rightsResponsibilities, Colors.teal),
            _buildDayItem(4, context.l10n.politicalSystemParties, Colors.purple),
            _buildDayItem(5, context.l10n.reviewInterim, Colors.orange),
            
            // "Tümünü Gör" butonu
            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.expand_more),
                label: Text(context.l10n.showAllPlan),
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
                  context.l10n.benefits,
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
              context.l10n.fastProgress,
              context.l10n.fastProgressDesc,
            ),
            _buildBenefitItem(
              Icons.dashboard_customize,
              context.l10n.comprehensiveContent,
              context.l10n.comprehensiveContentDesc,
            ),
            _buildBenefitItem(
              Icons.workspace_premium,
              context.l10n.badgesCertificates,
              context.l10n.badgesCertificatesDesc,
            ),
            _buildBenefitItem(
              Icons.trending_up,
              context.l10n.progressTracking,
              context.l10n.progressTrackingDesc,
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
        _hasActiveProgress
            ? ElevatedButton.icon(
                icon: const Icon(Icons.flag),
                label: Text(
                  context.l10n.continueCamp,
                  style: const TextStyle(fontSize: 16),
                ),
                onPressed: () => _navigateToCampDay(_activeDay),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              )
            : ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: Text(
                  context.l10n.startCamp,
                  style: const TextStyle(fontSize: 16),
                ),
                onPressed: _startNewCamp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          icon: Icon(_hasActiveProgress ? Icons.refresh : Icons.info_outline),
          label: Text(
            _hasActiveProgress
                ? context.l10n.resetCamp
                : context.l10n.tenDayCampPlan,
            style: const TextStyle(fontSize: 16),
          ),
          onPressed: _hasActiveProgress ? _resetCamp : () => _showCampInfo(),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Dil hatası için sıfırlama butonu
        OutlinedButton.icon(
          icon: const Icon(Icons.language),
          label: Text(
            "Dil Hatası İçin Tüm Kamp Verilerini Sıfırla",
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
          onPressed: _fullResetCampData,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: BorderSide(color: Colors.red.shade300),
          ),
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
                    context.l10n.tenDayCampPlan,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.dailyFocusDesc,
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
                                  '${day.totalQuestions}' + context.l10n.questionsTargetDifficulty + '${day.targetCorrect}' + context.l10n.correctAnswerText + '${day.difficulty}',
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
    // Premium durumunu kontrol et
    if (!_isPremium) {
      // Freemium kullanıcısı için paywall göster
      final purchased = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const CampPaywall(),
      );
      
      if (purchased == true) {
        setState(() => _isPremium = true);
        // Premium satın alındıktan sonra kampı başlat
        await _actuallyStartCamp();
      }
      return;
    }
    
    // Premium kullanıcısı için direkt kampı başlat
    await _actuallyStartCamp();
  }
  
  Future<void> _actuallyStartCamp() async {
    // Onay dialoğu göster
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.startNewCampTitle),
        content: Text(context.l10n.startNewCampContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancelButtonText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.startButtonText),
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
          
          // Değişiklikleri kaydet (public metot ile)
          await _campService.saveCampPlan();
        }
        
        // Verileri yeniden yükle
        await _loadCampData();
        
        // İlk güne git - Button işlemlerinde burayı geç kontrol et
        if (!_isLoading) {
          _navigateToCampDay(1);
        }
      } catch (e) {
        print(context.l10n.campStartError + e.toString()); // Hata log'u
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${context.l10n.error} ${e.toString()}")),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
  
  // Kamp verilerini sıfırlama
  void _resetCamp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.attention),
        content: Text(context.l10n.resetProgressWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() {
                _isLoading = true;
              });
              
              try {
                await _campService.resetCamp();
                await _loadCampData();
              } catch (e) {
                print('Reset error: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${context.l10n.error} ${e.toString()}")),
                );
              } finally {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            child: Text(context.l10n.reset),
          ),
        ],
      ),
    );
  }
  
  // Kamp hakkında bilgi diyaloğu göster
  void _showCampInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.campTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.campDescription),
            const SizedBox(height: 16),
            Text(
              "10 günlük program:"  // Bu metin ARB dosyalarına taşınabilir
            ),
            const SizedBox(height: 8),
            // Günlerin kısa özeti
            Text("\u2022 Gün 1-2: Amerikan Tarihi ve Anayasası"),
            Text("\u2022 Gün 3-4: Haklar ve Politik Sistem"),
            Text("\u2022 Gün 5: Ara Değerlendirme"),
            Text("\u2022 Gün 6-7: Yerel Yönetimler ve Semboller"),
            Text("\u2022 Gün 8-9: Löderler ve Coğrafya"),
            Text("\u2022 Gün 10: Sınav Hazırlığı"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.ok),
          ),
        ],
      ),
    );
  }
  
  // Dil hatası için tüm kamp verilerini tamamen sıfırlama
  void _fullResetCampData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Dil Hatası İçin Tüm Verileri Sıfırla"),
        content: const Text(
          "Bu işlem, kamp verilerini TAMAMEN silecek ve sıfırdan oluşturacaktır. "
          "Bu işlem, dil karışıklığı sorununu çözmek için gereklidir. "
          "Tüm ilerlemeniz ve kamp durumunuz sıfırlanacaktır. Devam etmek istiyor musunuz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Vazgeç"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() {
                _isLoading = true;
              });
              
              try {
                // Önce SharedPreferences'tan kamp verilerini temizle
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('camp_plan');
                await prefs.remove('user_camp_progress');
                
                // Servisi tamamen yeniden başlat
                await _campService.initialize(locale: appLocalizationsProvider.currentLocale);
                
                // Verileri yeniden yükle
                await _loadCampData();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Tüm veriler başarıyla sıfırlandı. "
                        "Ekran yenilendi. Dil sorunu çözülmüş olmalı."),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 5),
                  ),
                );
              } catch (e) {
                print('Full reset error: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Sıfırlama hatası: " + e.toString())),
                );
              } finally {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text("Tamamen Sıfırla"),
          ),
        ],
      ),
    );
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
          context.l10n.resetCampTitle,
          style: TextStyle(color: Colors.red.shade700),
        ),
        content: Text(context.l10n.resetCampWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancelButtonText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(context.l10n.resetButtonText),
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
          SnackBar(content: Text(context.l10n.progressReset)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${context.l10n.error} ${e.toString()}")),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}