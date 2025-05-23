import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:us_citizenship_test/utils/extensions.dart';
import '../models/onboarding_page.dart';
import '../models/language_selection_page.dart';
import '../../../widgets/language_selector_widget.dart';

// ABD Bayrağı dalga efekti ve sembollerini çizen özel sınıf
class _AmericanThemePainter extends CustomPainter {
  final Color color;
  
  _AmericanThemePainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    
    // Arkaplan şeritleri (ABD bayrağı şeritleri benzeri)
    final stripeHeight = height / 16;
    final stripePaint = Paint()
      ..color = color.withOpacity(0.05)
      ..style = PaintingStyle.fill;
      
    for (int i = 0; i < 15; i += 2) {
      final stripeY = i * stripeHeight;
      canvas.drawRect(
        Rect.fromLTWH(0, stripeY, width, stripeHeight), 
        stripePaint
      );
    }
    
    // Dalga efekti
    final wavePaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    final wavePath = Path();
    final amplitude = 10.0; // Dalga yüksekliği
    final frequency = 0.05; // Dalga frekansı
    
    // Ekranın sağ tarafındaki dalga efekti
    wavePath.moveTo(width * 0.7, 0);
    for (double y = 0; y < height; y += 5) {
      final x = width * 0.7 + math.sin(y * frequency) * amplitude;
      wavePath.lineTo(x, y);
    }
    canvas.drawPath(wavePath, wavePaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Yıldız efekti çizen özel sınıf - ABD bayrağındaki yıldızları anımsatan
class _StarEffectPainter extends CustomPainter {
  final Color color;
  
  _StarEffectPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    
    // 5 köşeli yıldız çizimi
    drawStar(canvas, size.width * 0.2, size.height * 0.2, 8, 20, 10, paint);
    drawStar(canvas, size.width * 0.7, size.height * 0.3, 8, 15, 7, paint);
    drawStar(canvas, size.width * 0.5, size.height * 0.8, 8, 25, 12, paint);
    drawStar(canvas, size.width * 0.8, size.height * 0.7, 8, 18, 9, paint);
    drawStar(canvas, size.width * 0.1, size.height * 0.6, 8, 12, 6, paint);
  }
  
  // 5 köşeli yıldız çizim fonksiyonu
  void drawStar(Canvas canvas, double cx, double cy, int spikes, double outerRadius, double innerRadius, Paint paint) {
    final path = Path();
    final step = math.pi / spikes;
    
    // Başlangıç noktası
    path.moveTo(cx + outerRadius, cy);
    
    // Yıldızın köşelerini çiz
    for (int i = 1; i < spikes * 2; i++) {
      final r = (i % 2 == 0) ? outerRadius : innerRadius;
      final angle = i * step;
      final x = cx + math.cos(angle) * r;
      final y = cy + math.sin(angle) * r;
      path.lineTo(x, y);
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

// Amerika vatandaşlık temasına uygun onboarding ekranı state sınıfı
class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  // Sayfa kontrolcüsü
  late final PageController _pageController;
  
  // Animasyon kontrolcüleri
  late AnimationController _cardAnimController;
  late AnimationController _imageAnimController;
  late AnimationController _textAnimController;
  late AnimationController _backgroundAnimController;
  late AnimationController _progressAnimController;
  
  // Animasyonlar
  Animation<Offset>? _slideAnimation;
  Animation<double>? _fadeAnimation;
  Animation<double>? _scaleAnimation;
  Animation<Color?>? _backgroundColorAnimation;
  
  // Geçerli sayfa
  int _currentPage = 0;
  
  // Dil seçim ekranını göster veya diğer sayfalara geç
  bool _showLanguageSelection = true;
  final int _numPages = 4; // Toplam sayfa sayısı
  
  // Son sayfa mı kontrolü
  bool get _isLastPage => _currentPage == _numPages - 1;
  
  // Onboarding sayfaları
  List<OnboardingPage> _onboardingPages = [];

  @override
  void initState() {
    super.initState();
    _initAnimationControllers();
    _initPageController();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Lokalizasyon erişimi için didChangeDependencies kullan
    if (_onboardingPages.isEmpty) {
      _initOnboardingPages();
      _createAnimations();
    }
  }
  
  // ABD vatandaşlık temalı sayfaları oluştur
  void _initOnboardingPages() {
    _onboardingPages = [
      // Sayfa 1: Amerikan Bayrağı teması - Uygulamaya Giriş
      OnboardingPage(
        title: context.l10n.onboardingTitle1,
        description: context.l10n.onboardingDesc1,
        imagePath: 'assets/images/onboarding/onboarding1.png',
        backgroundColor: const Color(0xFF041E42), // Navy Blue (Amerikan bayrağındaki lacivert)
        secondaryColor: const Color(0xFFBF0A30), // Amerika bayrağındaki kırmızı
        textColor: Colors.white,
        icon: Icons.flag_outlined,
        symbolImage: 'assets/images/onboarding/onboarding1.png',
      ),
      // Sayfa 2: Bağımsızlık Bildirgesi teması - Kamp Modu
      OnboardingPage(
        title: context.l10n.onboardingTitle2,
        description: context.l10n.onboardingDesc2,
        imagePath: 'assets/images/onboarding/onboarding2.png',
        backgroundColor: const Color(0xFFF2EEE2), // Parşömen rengi (Bağımsızlık Bildirgesi)
        secondaryColor: const Color(0xFFBF0A30), // Amerika bayrağındaki kırmızı
        textColor: const Color(0xFF333333),
        icon: Icons.history_edu_outlined,
        symbolImage: 'assets/images/onboarding/onboarding2.png',
      ),
      // Sayfa 3: Özgürlük Heykeli teması - Alıştırma Testleri
      OnboardingPage(
        title: context.l10n.onboardingTitle3,
        description: context.l10n.onboardingDesc3,
        imagePath: 'assets/images/onboarding/onboarding3.png',
        backgroundColor: const Color(0xFF66CCCC), // Aqua (deniz/gökyüzü rengi)
        secondaryColor: const Color(0xFF7CB342), // Yeşil (özgürlük heykelinin paslanmış bakır rengi)
        textColor: const Color(0xFF333333),
        icon: Icons.account_balance_outlined,
        symbolImage: 'assets/images/onboarding/onboarding3.png',
      ),
      // Sayfa 4: Amerikan Kartalı teması - Çok Dilli Destek
      OnboardingPage(
        title: context.l10n.onboardingTitle4,
        description: context.l10n.onboardingDesc4,
        imagePath: 'assets/images/onboarding/onboarding4.png',
        backgroundColor: const Color(0xFFFFFFFF), // Beyaz
        secondaryColor: const Color(0xFFCD7F32), // Bronz (Amerikan kartalı heykeli)
        textColor: const Color(0xFF333333),
        icon: Icons.language_outlined,
        symbolImage: 'assets/images/onboarding/onboarding4.png',
      ),
    ];
  }
  
  // Sayfa kontrolcüsünü ve dinleyicisini başlat
  void _initPageController() {
    _pageController = PageController();
    _pageController.addListener(_pageListener);
  }
  
  // Sayfa değişikliklerini dinle
  void _pageListener() {
    if (!_pageController.hasClients) return;
    
    final newPage = _pageController.page?.round() ?? 0;
    if (_currentPage != newPage) {
      setState(() {
        _currentPage = newPage;
      });
      
      // Sayfa değiştiğinde animasyonları güncelle
      _updatePageAnimations(newPage);
      _updateBackgroundColor(newPage);
      _updateProgressBar();
    }
  }
  
  // Tüm animasyon kontrolcülerini başlat
  void _initAnimationControllers() {
    // Kart animasyon kontrolcüsü
    _cardAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    // Görsel animasyon kontrolcüsü
    _imageAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Metin animasyon kontrolcüsü
    _textAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    // Arkaplan animasyon kontrolcüsü
    _backgroundAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    // İlerleme çubuğu animasyon kontrolcüsü
    _progressAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 0.25, // Başlangıç değeri (1. sayfa için %25)
    );
    
    // İlk sayfanın animasyonlarını başlat
    _cardAnimController.forward();
    _imageAnimController.forward();
    _textAnimController.forward();
  }
  
  // Animasyonları oluştur
  void _createAnimations() {
    if (_onboardingPages.isEmpty) return; // Boşsa işlem yapma
    
    // Kayma animasyonu
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardAnimController,
      curve: Curves.easeOut,
    ));
    
    // Solma animasyonu
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _imageAnimController,
      curve: Curves.easeIn,
    ));
    
    // Ölçeklendirme animasyonu
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textAnimController,
      curve: Curves.easeInOut,
    ));
    
    try {
      // Arkaplan rengi animasyonu - ilk değer
      _backgroundColorAnimation = ColorTween(
        begin: _onboardingPages[0].backgroundColor,
        end: _onboardingPages[0].backgroundColor,
      ).animate(_backgroundAnimController);
    } catch (e) {
      // Herhangi bir hata durumunda varsayılan renk kullan
      _backgroundColorAnimation = ColorTween(
        begin: const Color(0xFF041E42),
        end: const Color(0xFF041E42),
      ).animate(_backgroundAnimController);
    }
  }
  
  // Sayfa animasyonlarını güncelle
  void _updatePageAnimations(int pageIndex) {
    // Animasyonlar henüz oluşturulmamışsa çık
    if (_slideAnimation == null || _fadeAnimation == null || _scaleAnimation == null) {
      return;
    }
    
    // İçerik animasyonlarını yeniden başlat
    _cardAnimController.reset();
    _imageAnimController.reset();
    _textAnimController.reset();
    
    // Animasyonları sırayla başlat
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _cardAnimController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _imageAnimController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _textAnimController.forward();
    });
  }
  
  // Arkaplan rengini güncelle
  void _updateBackgroundColor(int pageIndex) {
    if (pageIndex >= _onboardingPages.length) return;
    
    Color? beginColor = _backgroundColorAnimation?.value;
    Color? endColor = _onboardingPages[pageIndex].backgroundColor;
    
    // Arkaplan renginin aniden değişmesini önlemek için
    // başlangıç rengi null ise (ilk yükleme), hedef rengi kullan
    if (beginColor == null) {
      beginColor = endColor;
    }
    
    _backgroundColorAnimation = ColorTween(
      begin: beginColor,
      end: endColor,
    ).animate(_backgroundAnimController);
    
    _backgroundAnimController.reset();
    _backgroundAnimController.forward();
  }
  
  // İlerleme çubuğunu güncelle
  void _updateProgressBar() {
    // Sayfa indeksine göre ilerleme değerini hesapla (0-1 arasında)
    final progress = (_currentPage + 1) / _numPages;
    
    // İlerleme çubuğu animasyonunu güncelle
    _progressAnimController.animateTo(
      progress,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  
  // Onboarding tamamlandığında çağrılır
  Future<void> _completeOnboarding() async {
    // Tercihlere onboarding tamamlandı bilgisini kaydet
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    
    // Sonraki ekrana git (Ana ekran)
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/');
  }
  
  // Amerika teması için üst başlık
  Widget _buildAmericanThemeHeader() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF041E42).withOpacity(0.95), // Lacivert (ABD bayrağı)
              const Color(0xFF041E42).withOpacity(0.85),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Amerikan bayrağı yıldızları benzeri göstergeler
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _numPages,
                  (index) => GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _currentPage
                            ? Colors.white // Beyaz (aktif sayfa)
                            : Colors.white.withOpacity(0.25), // Saydam beyaz
                        boxShadow: index == _currentPage
                            ? [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: _onboardingPages.isEmpty || index >= _onboardingPages.length
                        ? Icon(
                            Icons.circle,
                            color: index == _currentPage 
                                ? const Color(0xFF041E42)
                                : const Color(0xFF041E42).withOpacity(0.7),
                            size: 18,
                          )
                        : Icon(
                            _onboardingPages[index].icon,
                            color: index == _currentPage 
                                ? const Color(0xFF041E42) // Lacivert
                                : const Color(0xFF041E42).withOpacity(0.7),
                            size: 18,
                          ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Amerika teması için sayfa içeriği
  Widget _buildAmericanThemePage(OnboardingPage page, int index) {
    return SafeArea(
      child: Column(
        children: [
          // Üst boşluk (header için)
          const SizedBox(height: 100),
          
          // İçerik - Esnek ve scroll edilebilir
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ABD vatandaşlık sembolü ve görsel
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.35, // Ekranın %35'i
                    child: AnimatedBuilder(
                      animation: _imageAnimController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(0.0),
                          child: ScaleTransition(
                            scale: _scaleAnimation ?? const AlwaysStoppedAnimation(0.0),
                            child: child,
                          ),
                        );
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Çevreleyen daire
                          Container(
                            width: 240,
                            height: 240,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: page.secondaryColor.withOpacity(0.15),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          
                          // Yıldız efekti
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _StarEffectPainter(color: page.secondaryColor),
                            ),
                          ),
                          
                          // Ana görsel
                          Hero(
                            tag: 'onboarding_${index}',
                            child: ClipOval(
                              child: Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: page.secondaryColor,
                                    width: 3,
                                  ),
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    page.symbolImage,
                                    fit: BoxFit.cover,
                                    frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                      if (wasSynchronouslyLoaded || frame != null) {
                                        return child;
                                      }
                                      return Container(
                                        color: page.backgroundColor.withOpacity(0.2),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: page.secondaryColor,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Başlık ve açıklama
                  AnimatedBuilder(
                    animation: _textAnimController,
                    builder: (context, child) {
                      return SlideTransition(
                        position: _slideAnimation ?? const AlwaysStoppedAnimation(Offset.zero),
                        child: FadeTransition(
                          opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(0.0),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Başlık
                          Text(
                            page.title,
                            style: const TextStyle(
                              color: Color(0xFF1A365D), // Koyu mavi - tüm başlıklar için aynı
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Açıklama
                          Text(
                            page.description,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 15,
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Alt boşluk (butonlar için güvenli alan)
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Amerika teması için alt butonlar
  Widget _buildAmericanThemeActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFBF0A30).withOpacity(0.95), // Kırmızı (ABD bayrağı)
            const Color(0xFFBF0A30),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Amerikan bayrağı şeridini andıran ilerleme çubuğu
            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Stack(
                children: [
                  AnimatedBuilder(
                    animation: _progressAnimController,
                    builder: (context, child) {
                      return FractionallySizedBox(
                        widthFactor: _progressAnimController.value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.4),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Butonlar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Geç butonu (beyaz, şeffaf)
                TextButton(
                  onPressed: _completeOnboarding,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(context.l10n.skip),
                ),
                
                // İleri/Başla butonu (lacivert, ABD bayrağı renklerine uygun)
                ElevatedButton(
                  onPressed: () {
                    if (_isLastPage) {
                      _completeOnboarding();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF041E42), // Lacivert
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                      side: const BorderSide(color: Colors.white, width: 2),
                    ),
                    elevation: 2,
                    shadowColor: Colors.black26,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isLastPage ? context.l10n.getStarted : context.l10n.next,
                        style: const TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (!_isLastPage) ... [
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ] else ... [
                        const SizedBox(width: 8),
                        const Icon(Icons.flag_rounded, size: 18),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Vatandaşlık temalı arkaplan
          AnimatedBuilder(
            animation: _backgroundAnimController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  color: _backgroundColorAnimation?.value ?? const Color(0xFF041E42),
                ),
                child: child,
              );
            },
            child: Builder(builder: (context) {
              // Boş liste veya index hatasını önle
              final color = _onboardingPages.isNotEmpty && _currentPage < _onboardingPages.length
                  ? _onboardingPages[_currentPage].secondaryColor
                  : const Color(0xFFBF0A30);
              
              return CustomPaint(
                painter: _AmericanThemePainter(color: color),
                child: Container(), // Boş container, CustomPaint arka planı çizecek
              );
            }),
          ),
          
                  // Dil seçim ekranını göster veya normal onboarding sayfalarını göster
          if (_showLanguageSelection) 
            LanguageSelectionPage(
              onLanguageSelected: () {
                setState(() {
                  _showLanguageSelection = false;
                });
              },
            )
          else if (_onboardingPages.isNotEmpty)
            PageView.builder(
              controller: _pageController,
              itemCount: _numPages,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
                _updateBackgroundColor(index);
                _updateProgressBar();
                _updatePageAnimations(index);
              },
              physics: const ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                if (index < _onboardingPages.length) {
                  return _buildAmericanThemePage(_onboardingPages[index], index);
                } else {
                  // Geçersiz index durumunda boş container döndür
                  return Container();
                }
              },
            ),
          
          // Dil seçimi ekranında değilsek, normal onboarding kontrolleri göster
          if (!_showLanguageSelection) ...[            
            // Üst kısım - Bayrak tasarımı ve sayfa göstergeleri
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildAmericanThemeHeader(),
            ),
            
            // Alt kısım - İlerleme ve butonlar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildAmericanThemeActions(),
            ),

            // Dil seçim butonu (sağ üst köşe)
            Positioned(
              top: 40,
              right: 20,
              child: SafeArea(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const LanguageSelectorWidget(
                    inAppBar: false,
                    iconColor: Colors.white,
                    showBorder: true,
                    iconSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _pageController.removeListener(_pageListener);
    _pageController.dispose();
    
    _cardAnimController.dispose();
    _imageAnimController.dispose();
    _textAnimController.dispose();
    _backgroundAnimController.dispose();
    _progressAnimController.dispose();
    
    super.dispose();
  }
}
