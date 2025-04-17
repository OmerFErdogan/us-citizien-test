import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:auto_size_text/auto_size_text.dart';
import '../models/question.dart';
import '../services/question_service.dart';
import '../utils/extensions.dart';
import '../utils/responsive/responsive.dart';

class FlashcardScreen extends StatefulWidget {
  final QuestionService questionService;
  final List<String>? categories;
  final int maxCardCount;

  const FlashcardScreen({
    Key? key,
    required this.questionService,
    this.categories,
    this.maxCardCount = 20,
  }) : super(key: key);

  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation; // Eğrili animasyon için yeni değişken

  List<Question> _questions = [];
  Map<String, Color> _categoryColorMap = {};
  int _currentCardIndex = 0;
  int _knownCount = 0;
  int _unknownCount = 0;
  bool _isCardFlipped = false;
  bool _isLoading = true;

  final List<Color> _categoryColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    // AnimationController oluştur - 800ms süreli
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // CurvedAnimation ile daha gerçekçi kart çevirme hissi
    _flipAnimation = CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    
    _loadFlashcards();
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  Future<void> _loadFlashcards() async {
    setState(() => _isLoading = true);

    try {
      await widget.questionService.loadQuestions();

      // 1) Kategori filtresi uygula
      List<Question> availableQuestions = _getFilteredQuestions();

      // 2) Öncelikle yanlış cevaplanan soruları seç
      List<Question> priorityQuestions = availableQuestions
          .where((q) => q.isAttempted && !q.isMarkedCorrect)
          .toList();

      // 3) Eğer yeterli değilse, cevaplanmamışları ekle
      priorityQuestions = _addUnansweredQuestions(priorityQuestions, availableQuestions);

      // 4) Hâlâ eksik varsa, rastgele sorular ekle
      priorityQuestions = _addRandomQuestions(priorityQuestions, availableQuestions);

      // 5) Tüm seçilen kartları karıştır
      priorityQuestions.shuffle();

      // 6) Kategori-renk eşlemesini oluştur
      _createCategoryColorMap(priorityQuestions);

      setState(() {
        _questions = priorityQuestions;
        _currentCardIndex = 0;
        _knownCount = 0;
        _unknownCount = 0;
        _isCardFlipped = false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorLoading(e.toString())))
        );
      }
    }
  }

  List<Question> _getFilteredQuestions() {
    if (widget.categories != null && widget.categories!.isNotEmpty) {
      return widget.questionService.getQuestionsByCategories(widget.categories!);
    } else {
      return widget.questionService.getAllQuestions();
    }
  }

  List<Question> _addUnansweredQuestions(List<Question> priorityQuestions, List<Question> all) {
    if (priorityQuestions.length < widget.maxCardCount) {
      final countNeeded = widget.maxCardCount - priorityQuestions.length;
      final unanswered = all.where((q) => !q.isAttempted).take(countNeeded).toList();
      priorityQuestions.addAll(unanswered);
    }
    return priorityQuestions;
  }

  List<Question> _addRandomQuestions(List<Question> priorityQuestions, List<Question> all) {
    if (priorityQuestions.length < widget.maxCardCount) {
      final remainingCount = widget.maxCardCount - priorityQuestions.length;
      final selectedIds = priorityQuestions.map((q) => q.id).toSet();
      final remainingQuestions = all.where((q) => !selectedIds.contains(q.id)).toList();
      remainingQuestions.shuffle();
      priorityQuestions.addAll(remainingQuestions.take(remainingCount));
    }
    return priorityQuestions;
  }

  void _createCategoryColorMap(List<Question> questions) {
    final categories = questions.map((q) => q.category).toSet().toList();
    _categoryColorMap = {};
    for (int i = 0; i < categories.length; i++) {
      _categoryColorMap[categories[i]] = _categoryColors[i % _categoryColors.length];
    }
  }

  /// Bilmiyorum (yanlış) veya Biliyorum (doğru) buton tıklama işlemleri tek metod
  void _markCard({required bool known}) {
    if (_questions.isEmpty || _currentCardIndex >= _questions.length) return;
    final question = _questions[_currentCardIndex];

    // known = true ise, ilk doğru cevabı işaretle
    final answerText = known ? question.correctAnswer : "";

    // Serviste güncelle
    widget.questionService.answerQuestion(question.id, answerText);

    setState(() {
      known ? _knownCount++ : _unknownCount++;
    });

    _nextCard();
  }

  void _nextCard() {
    if (_currentCardIndex < _questions.length - 1) {
      setState(() {
        _currentCardIndex++;
        _isCardFlipped = false;
      });
      _flipController.reset();
    } else {
      _showSummaryDialog();
    }
  }

  void _previousCard() {
    if (_currentCardIndex > 0) {
      setState(() {
        _currentCardIndex--;
        _isCardFlipped = false;
      });
      _flipController.reset();
    }
  }
  
  void _flipCard() {
    if (_isCardFlipped) {
      // Kartı ön yüzüne çevir
      setState(() => _isCardFlipped = false);
      _flipController.reverse();
    } else {
      // Kartı arka yüzüne çevir
      setState(() => _isCardFlipped = true);
      _flipController.forward();
    }
  }

  void _showSummaryDialog() {
    // Get responsive helper for responsive design
    final responsive = ResponsiveHelper.of(context);
    
    final double titleFontSize = responsive.value(small: 18.0, medium: 20.0, large: 22.0);
    final double textFontSize = responsive.value(small: 14.0, medium: 15.0, large: 16.0);
    final double iconSize = responsive.value(small: 32.0, medium: 36.0, large: 40.0);
    final double spacing = responsive.value(small: 12.0, medium: 16.0, large: 20.0);
    final double barHeight = responsive.value(small: 8.0, medium: 10.0, large: 12.0);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.realizingDream),
        titleTextStyle: TextStyle(
          fontSize: titleFontSize, 
          fontWeight: FontWeight.bold, 
          color: Colors.blue[700],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/eagle_icon.png',
                      width: iconSize,
                      height: iconSize,
                      color: Colors.blue[800],
                    ),
                    SizedBox(width: spacing / 2),
                    Flexible(
                      child: Text(
                        context.l10n.citizenshipJourney,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: textFontSize,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: spacing / 2),
                Text(
                  context.l10n.libertyAwaits,
                  style: TextStyle(
                    fontStyle: FontStyle.italic, 
                    color: Colors.grey[600],
                    fontSize: textFontSize - 2,
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryItem(
                  icon: Icons.check_circle,
                  value: _knownCount.toString(),
                  label: context.l10n.knewIt,
                  color: Colors.green,
                ),
                _buildSummaryItem(
                  icon: Icons.cancel,
                  value: _unknownCount.toString(),
                  label: context.l10n.stillLearning,
                  color: Colors.red,
                ),
              ],
            ),
            SizedBox(height: spacing),
            LinearProgressIndicator(
              value: _knownCount / (_knownCount + _unknownCount),
              backgroundColor: Colors.red[100],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              minHeight: barHeight,
            ),
            SizedBox(height: spacing / 2),
            Text(
              context.l10n.successRate(((_knownCount / (_knownCount + _unknownCount)) * 100).toStringAsFixed(1)),
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: textFontSize,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Ana ekrana dön
            },
            child: Text(
              context.l10n.backToHome,
              style: TextStyle(fontSize: textFontSize),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Kartları yeniden başlat
              setState(() {
                _currentCardIndex = 0;
                _isCardFlipped = false;
                _knownCount = 0;
                _unknownCount = 0;
              });
              _flipController.reset();
            },
            child: Text(
              context.l10n.studyAgain,
              style: TextStyle(fontSize: textFontSize),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    bool isLargeScreen = false, // Geriye dönük uyumluluk için korundu
  }) {
    final responsive = ResponsiveHelper.of(context);
    
    // Sabit değerler yerine uyarlanabilir değerler kullan
    final iconSize = responsive.adaptiveIconSize(size: 32.0, densityFactor: 0.6);
    final spacingHeight = responsive.heightPercent(1.0); // Ekran yüksekliğinin %1'i
    final valueFontSize = responsive.scaledFontSize(small: 24.0, medium: 26.0, large: 28.0);
    final labelFontSize = responsive.scaledFontSize(small: 14.0, medium: 15.0, large: 16.0);
    
    return Column(
      children: [
        Icon(icon, size: iconSize, color: color),
        SizedBox(height: spacingHeight),
        AutoSizeText(
          value,
          style: TextStyle(
            fontSize: valueFontSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          minFontSize: 18.0,
          maxLines: 1,
        ),
        AutoSizeText(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: labelFontSize,
          ),
          minFontSize: 12.0,
          maxLines: 1,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.libertyCards),
        backgroundColor: Colors.red.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            tooltip: context.l10n.shuffle,
            onPressed: () {
              if (_questions.isNotEmpty) {
                setState(() {
                  _questions.shuffle();
                  _currentCardIndex = 0;
                  _isCardFlipped = false;
                  _knownCount = 0;
                  _unknownCount = 0;
                });
                _flipController.reset();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: context.l10n.refreshData,
            onPressed: _loadFlashcards,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _questions.isEmpty
              ? _buildEmptyState()
              : LayoutBuilder(
                  builder: (context, constraints) {
                    // Responsive helper kullanarak ekran bilgilerini al
                    final responsive = ResponsiveHelper.of(context);
                    final screenWidth = constraints.maxWidth;
                    final screenHeight = constraints.maxHeight;
                    
                    // Responsive helper ile ekran boyutlarını belirle
                    final isLargeScreen = responsive.isLarge;
                    final isMediumScreen = responsive.isMedium;
                    
                    // Öncelikle genişlik bazlı karar verme
                    // Sadece geniş ekranlar ve yatay konumdaki orta boy ekranlar geniş yerleşim kullanacak
                    final useWideLayout = responsive.shouldUseWideLayout;
                    
                    return useWideLayout 
                        ? _buildWideFlashcardContent(screenWidth, screenHeight, isLargeScreen, isMediumScreen)
                        : _buildStandardFlashcardContent(screenWidth, screenHeight, isLargeScreen, isMediumScreen);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final responsive = ResponsiveHelper.of(context);
        
        final double iconSize = responsive.value(small: 80.0, medium: 100.0, large: 120.0);
        final double spacing = responsive.value(small: 16.0, medium: 20.0, large: 24.0);
        final double titleFontSize = responsive.value(small: 18.0, medium: 20.0, large: 24.0);
        final double textFontSize = responsive.value(small: 14.0, medium: 16.0, large: 18.0);
        final double buttonHeight = responsive.value(small: 40.0, medium: 45.0, large: 50.0);
        final double buttonFontSize = responsive.value(small: 16.0, medium: 17.0, large: 18.0);
        
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/statue_of_liberty_icon.png',
                width: iconSize,
                height: iconSize,
                color: Colors.blue[700],
              ),
              SizedBox(height: spacing),
              Text(
                context.l10n.noCardsFound,
                style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: spacing / 2),
              Text(
                context.l10n.pleaseSelectCategory,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: textFontSize),
              ),
              SizedBox(height: spacing * 1.5),
              SizedBox(
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: _loadFlashcards,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing * 2,
                      vertical: spacing / 2
                    ),
                  ),
                  child: Text(
                    context.l10n.startLearning,
                    style: TextStyle(fontSize: buttonFontSize),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Normal dikey yönlendirilmiş yerleşim (telefon için)
  Widget _buildStandardFlashcardContent(double screenWidth, double screenHeight, bool isLargeScreen, bool isMediumScreen) {
    final responsive = ResponsiveHelper.of(context);
    final progressPercent =
        _questions.isEmpty ? 0.0 : (_currentCardIndex + 1) / _questions.length;
    
    final double padding = responsive.value(small: 16.0, medium: 20.0, large: 24.0);
    final double spacing = responsive.value(small: 8.0, medium: 16.0, large: 24.0);
    final double fontSize = responsive.value(small: 14.0, medium: 16.0, large: 18.0);

    return Column(
      children: [
        // Üst kısım: progress bar, sayaç, vs.
        _buildProgressIndicatorAndStats(progressPercent, isLargeScreen: isLargeScreen),

        // Ortadaki kart
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: GestureDetector(
              onTap: _flipCard,
              child: _questions.isNotEmpty
                      ? _buildFlipCard(_questions[_currentCardIndex], isLargeScreen: isLargeScreen)
                      : const SizedBox(),
            ),
          ),
        ),

        // Alt butonlar
        _buildBottomButtons(isLargeScreen: isLargeScreen),
      ],
    );
  }
  
  // Geniş ekran için yan yana yerleşim (tablet/yatay mod)
  Widget _buildWideFlashcardContent(double screenWidth, double screenHeight, bool isLargeScreen, bool isMediumScreen) {
    final responsive = ResponsiveHelper.of(context);
    final progressPercent =
        _questions.isEmpty ? 0.0 : (_currentCardIndex + 1) / _questions.length;
    
    final double padding = responsive.value(small: 16.0, medium: 20.0, large: 24.0);
    final double spacing = responsive.value(small: 8.0, medium: 16.0, large: 24.0);
    
    return Column(
      children: [
        // Üst kısım: progress bar, sayaç, vs.
        _buildProgressIndicatorAndStats(progressPercent, isLargeScreen: isLargeScreen),
        
        // Ana içerik
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sol taraf: Bilgi kartları
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: GestureDetector(
                    onTap: _flipCard,
                    child: _questions.isNotEmpty
                            ? _buildFlipCard(_questions[_currentCardIndex], isLargeScreen: isLargeScreen)
                            : const SizedBox(),
                  ),
                ),
              ),
              
              // Sağ taraf: Butonlar ve ek bilgiler
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: _buildSideButtons(isLargeScreen: isLargeScreen),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // Geniş ekran için sağ taraftaki butonlar
  Widget _buildSideButtons({bool isLargeScreen = false}) { // isLargeScreen parametresi geriye dönük uyumluluk için korundu
    final responsive = ResponsiveHelper.of(context);
    final double buttonHeight = responsive.value(small: 50.0, medium: 55.0, large: 60.0);
    final double fontSize = responsive.value(small: 16.0, medium: 17.0, large: 18.0);
    final double iconSize = responsive.value(small: 24.0, medium: 26.0, large: 28.0);
    final double spacing = responsive.value(small: 16.0, medium: 18.0, large: 20.0);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Gezinme butonları
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: _currentCardIndex > 0 ? _previousCard : null,
              icon: Icon(Icons.arrow_back, size: iconSize),
              label: Text(context.l10n.previous, style: TextStyle(fontSize: fontSize)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
            SizedBox(width: spacing),
            ElevatedButton.icon(
              onPressed: _currentCardIndex < _questions.length - 1 ? _nextCard : null,
              icon: Icon(Icons.arrow_forward, size: iconSize),
              label: Text(context.l10n.next, style: TextStyle(fontSize: fontSize)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
          ],
        ),
        
        SizedBox(height: spacing * 2),
        
        // Biliyorum/Bilmiyorum butonları
        Text(
          _isCardFlipped ? context.l10n.knewIt : context.l10n.tapToFlip,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: spacing),
        
        // Bilmiyorum butonu
        SizedBox(
          height: buttonHeight,
          child: ElevatedButton.icon(
            onPressed: _isCardFlipped ? () => _markCard(known: false) : null,
            icon: Icon(Icons.close, size: iconSize),
            label: Text(context.l10n.stillLearning, style: TextStyle(fontSize: fontSize)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              disabledBackgroundColor: Colors.red[100],
            ),
          ),
        ),
        SizedBox(height: spacing),
        
        // Biliyorum butonu
        SizedBox(
          height: buttonHeight,
          child: ElevatedButton.icon(
            onPressed: _isCardFlipped ? () => _markCard(known: true) : null,
            icon: Icon(Icons.check, size: iconSize),
            label: Text(context.l10n.knewIt, style: TextStyle(fontSize: fontSize)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[400],
              disabledBackgroundColor: Colors.green[100],
            ),
          ),
        ),
        
        if (_knownCount > 0 || _unknownCount > 0) ... [
          SizedBox(height: spacing * 2),
          // Oturum istatistikleri büyük gösterim
          Container(
            padding: responsive.adaptivePadding(horizontal: 16.0, vertical: 16.0, densityFactor: 0.7),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(responsive.widthPercent(3)),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                AutoSizeText(
                  context.l10n.flashcardStats,
                  style: TextStyle(
                    fontSize: responsive.scaledFontSize(small: 16.0, medium: 17.0, large: 18.0),
                    fontWeight: FontWeight.bold,
                  ),
                  minFontSize: 14.0,
                  maxLines: 1,
                ),
                SizedBox(height: responsive.heightPercent(2)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSummaryItem(
                      icon: Icons.check_circle,
                      value: _knownCount.toString(),
                      label: context.l10n.knewIt,
                      color: Colors.green,
                      // isLargeScreen artık gerekli değil
                    ),
                    _buildSummaryItem(
                      icon: Icons.cancel,
                      value: _unknownCount.toString(),
                      label: context.l10n.stillLearning,
                      color: Colors.red,
                      // isLargeScreen artık gerekli değil
                    ),
                  ],
                ),
                SizedBox(height: responsive.heightPercent(1.5)),
                LinearProgressIndicator(
                  value: _knownCount / (_knownCount + _unknownCount),
                  backgroundColor: Colors.red[100],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  minHeight: responsive.heightPercent(1.0), // Yüksekliğin %1'i
                ),
                SizedBox(height: responsive.heightPercent(1.0)),
                AutoSizeText(
                  context.l10n.successRate(((_knownCount / (_knownCount + _unknownCount)) * 100).toStringAsFixed(1)),
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: responsive.scaledFontSize(small: 14.0, medium: 16.0, large: 18.0)
                  ),
                  minFontSize: 12.0,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProgressIndicatorAndStats(double progressPercent, {bool isLargeScreen = false}) { // isLargeScreen parametresi geriye dönük uyumluluk için korundu
    final responsive = ResponsiveHelper.of(context);
    final double padding = responsive.value(small: 16.0, medium: 18.0, large: 20.0);
    final double spacing = responsive.value(small: 8.0, medium: 10.0, large: 12.0);
    final double fontSize = responsive.value(small: 16.0, medium: 17.0, large: 18.0);
    final double barHeight = responsive.value(small: 8.0, medium: 9.0, large: 10.0);
    final double badgeFontSize = responsive.value(small: 12.0, medium: 13.0, large: 14.0);
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: spacing),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${context.l10n.card} ${_currentCardIndex + 1}/${_questions.length}',
                style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
              ),
              if (_questions.isNotEmpty && _currentCardIndex < _questions.length)
                Container(
                  padding: responsive.adaptivePadding(
                    horizontal: 8.0, 
                    vertical: 4.0,
                    densityFactor: 0.5
                  ),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(_questions[_currentCardIndex].category)
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(responsive.widthPercent(2)),
                  ),
                  child: AutoSizeText(
                    _questions[_currentCardIndex].category,
                    style: TextStyle(
                      fontSize: responsive.scaledFontSize(small: 12.0, medium: 13.0, large: 14.0),
                      color: _getCategoryColor(_questions[_currentCardIndex].category),
                      fontWeight: FontWeight.bold,
                    ),
                    minFontSize: 10.0,
                    maxLines: 1,
                  ),
                ),
            ],
          ),
          SizedBox(height: spacing),
          // İlerleme çubuğu
          ClipRRect(
            borderRadius: BorderRadius.circular(isLargeScreen ? 6 : 4),
            child: LinearProgressIndicator(
              value: progressPercent,
              minHeight: barHeight,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
          // Oturum istatistikleri
          if (_knownCount > 0 || _unknownCount > 0)
            Padding(
              padding: EdgeInsets.only(top: spacing),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSessionStats(
                    text: '${context.l10n.knewIt}: $_knownCount',
                    color: Colors.green,
                    isLargeScreen: isLargeScreen,
                  ),
                  SizedBox(width: spacing),
                  _buildSessionStats(
                    text: '${context.l10n.stillLearning}: $_unknownCount',
                    color: Colors.red,
                    isLargeScreen: isLargeScreen,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSessionStats({required String text, required Color color, bool isLargeScreen = false}) { // isLargeScreen parametresi geriye dönük uyumluluk için korundu
    final responsive = ResponsiveHelper.of(context);
    final horizontalPadding = responsive.value(small: 8.0, medium: 9.0, large: 10.0);
    final verticalPadding = responsive.value(small: 4.0, medium: 5.0, large: 6.0);
    final borderRadius = responsive.value(small: 4.0, medium: 5.0, large: 6.0);
    final fontSize = responsive.value(small: 12.0, medium: 13.0, large: 14.0);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding, 
        vertical: verticalPadding
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBottomButtons({bool isLargeScreen = false}) { // isLargeScreen parametresi geriye dönük uyumluluk için korundu
    final responsive = ResponsiveHelper.of(context);
    final double padding = responsive.value(small: 16.0, medium: 18.0, large: 20.0);
    final double iconSize = responsive.value(small: 24.0, medium: 27.0, large: 30.0);
    final double buttonHeight = responsive.value(small: 40.0, medium: 44.0, large: 48.0);
    final double fontSize = responsive.value(small: 14.0, medium: 15.0, large: 16.0);
    
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, size: iconSize),
            onPressed: _currentCardIndex > 0 ? _previousCard : null,
            color: Colors.blue,
            iconSize: iconSize,
          ),
          ElevatedButton.icon(
            onPressed: _isCardFlipped ? () => _markCard(known: false) : null,
            icon: Icon(Icons.close, size: isLargeScreen ? iconSize * 0.8 : iconSize * 0.75),
            label: Text(
              context.l10n.stillLearning, 
              style: TextStyle(fontSize: fontSize),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              disabledBackgroundColor: Colors.red[100],
              minimumSize: Size(isLargeScreen ? 140 : 120, buttonHeight),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _isCardFlipped ? () => _markCard(known: true) : null,
            icon: Icon(Icons.check, size: isLargeScreen ? iconSize * 0.8 : iconSize * 0.75),
            label: Text(
              context.l10n.knewIt,
              style: TextStyle(fontSize: fontSize),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[400],
              disabledBackgroundColor: Colors.green[100],
              minimumSize: Size(isLargeScreen ? 140 : 120, buttonHeight),
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward, size: iconSize),
            onPressed: _currentCardIndex < _questions.length - 1 ? _nextCard : null,
            color: Colors.blue,
            iconSize: iconSize,
          ),
        ],
      ),
    );
  }

  Widget _buildFlipCard(Question question, {bool isLargeScreen = false}) { // isLargeScreen parametresi geriye dönük uyumluluk için korundu
    final responsive = ResponsiveHelper.of(context);
    final elevation = responsive.value(small: 8.0, medium: 9.0, large: 10.0);
    final borderRadius = responsive.value(small: 20.0, medium: 22.0, large: 24.0);
    
    // GestureDetector'un büyüklüğünü sınırlamak yerine Stack'i sınırlayalım
    return LayoutBuilder(
      builder: (context, constraints) {
        // Mevcut container boyutlarını kullan
        final double cardWidth = constraints.maxWidth;
        final double cardHeight = constraints.maxHeight;

        return AnimatedBuilder(
          animation: _flipAnimation, // _flipController yerine eğrili animasyonu kullan
          builder: (context, child) {
            // 0..1 aralığında animasyon değeri, 0..pi aralığında açı
            final angle = _flipAnimation.value * math.pi;
            
            // 0.5 eşiğinde kart yüzü değişimi
            final showFrontSide = _flipAnimation.value <= 0.5;

            return Stack(
              // Stack'in maksimum büyüklüğünü belirle
              children: [
                // Ön yüz
                AnimatedOpacity(
                  opacity: showFrontSide ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 250),
                  child: Transform(
                    // Görüntünün ortasından döndür
                    alignment: Alignment.center,
                    // Perspektif ve dönüş
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // perspektif
                      ..rotateY(angle),
                    child: Card(
                      elevation: elevation,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(borderRadius),
                        child: SizedBox(
                          width: cardWidth,
                          height: cardHeight,
                          child: _buildCardFront(question, isLargeScreen: responsive.isLarge),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Arka yüz
                AnimatedOpacity(
                  opacity: showFrontSide ? 0.0 : 1.0,
                  duration: Duration(milliseconds: 250),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // perspektif
                      ..rotateY(angle - math.pi), // Arka yüz için 180 derece çevrilmiş başla
                    child: Card(
                      elevation: elevation,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(borderRadius),
                        child: SizedBox(
                          width: cardWidth,
                          height: cardHeight,
                          child: _buildCardBack(question, isLargeScreen: responsive.isLarge),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCardFront(Question question, {bool isLargeScreen = false}) { // isLargeScreen parametresi geriye dönük uyumluluk için korundu
    final responsive = ResponsiveHelper.of(context);
    final categoryColor = _getCategoryColor(question.category);
    
    // Sabit değerler yerine ekran boyutuna göre orantısal değerler kullan
    final double padding = responsive.widthPercent(4); // Ekran genişliğinin %4'ü
    final double spacing = responsive.heightPercent(2.5); // Ekran yüksekliğinin %2.5'i
    
    // Font boyutları için scaledFontSize kullan
    final double fontSize = responsive.scaledFontSize(small: 22.0, medium: 24.0, large: 26.0);
    final double badgeFontSize = responsive.scaledFontSize(small: 12.0, medium: 13.0, large: 14.0);
    
    // İkon boyutu için adaptiveIconSize kullan
    final double iconSize = responsive.adaptiveIconSize(size: 48.0, densityFactor: 0.6);
    
    // Border radius için ekran genişliğiyle orantısal değer
    final double borderRadius = responsive.widthPercent(3);

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            categoryColor.withOpacity(0.1),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Kategori etiketi
          Container(
            padding: responsive.adaptivePadding(
              horizontal: 10.0, 
              vertical: 4.0,
              densityFactor: 0.5
            ),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(borderRadius * 0.7),
            ),
            child: AutoSizeText(
              question.category,
              style: TextStyle(
                fontSize: badgeFontSize,
                color: categoryColor,
                fontWeight: FontWeight.bold,
              ),
              minFontSize: 10.0,
              maxLines: 1,
            ),
          ),
          SizedBox(height: spacing),
          Icon(Icons.help_outline, size: iconSize, color: categoryColor),
          SizedBox(height: spacing),
          // Soru metni
          Expanded(
            child: Center(
              child: AutoSizeText(
                question.question,
                style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                minFontSize: 16.0,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // Alt bilgi kutusu
          Container(
            margin: EdgeInsets.only(top: spacing),
            padding: responsive.adaptivePadding(
              horizontal: 8.0, 
              vertical: 8.0,
              densityFactor: 0.5
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(borderRadius * 0.7),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.touch_app, 
                  size: responsive.adaptiveIconSize(size: 20.0), 
                  color: Colors.grey
                ),
                SizedBox(width: responsive.value(small: 8.0, medium: 9.0, large: 10.0)),
                AutoSizeText(
                  context.l10n.tapToFlip,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: responsive.scaledFontSize(small: 14.0, medium: 15.0, large: 16.0),
                  ),
                  minFontSize: 12.0,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(Question question, {bool isLargeScreen = false}) { // isLargeScreen parametresi geriye dönük uyumluluk için korundu
    final responsive = ResponsiveHelper.of(context);
    final double padding = responsive.widthPercent(4); // Ekran genişliğinin %4'ü
    final double spacing = responsive.heightPercent(2); // Ekran yüksekliğinin %2'si
    final double fontSize = responsive.scaledFontSize(small: 16.0, medium: 18.0, large: 20.0);
    final double titleFontSize = responsive.scaledFontSize(small: 16.0, medium: 18.0, large: 20.0);
    final double iconSize = responsive.adaptiveIconSize(size: 48.0, densityFactor: 0.6);
    final double borderRadius = responsive.widthPercent(3);
    final double answerCardPadding = responsive.widthPercent(2);
    final double answerIconSize = responsive.adaptiveIconSize(size: 20.0, densityFactor: 0.5);
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.green[50]!,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: iconSize, color: Colors.green),
          SizedBox(height: spacing),
          AutoSizeText(
            context.l10n.answer,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
            minFontSize: 14.0,
            maxLines: 1,
          ),
          SizedBox(height: spacing),
          // Cevaplar listesi
          Expanded(
            child: _buildAnswerList(
              question.allCorrectAnswers,
              spacing: spacing,
              borderRadius: borderRadius,
              answerCardPadding: answerCardPadding,
              answerIconSize: answerIconSize,
              fontSize: fontSize
            ),
          ),
          // Alt butonlar
          Container(
            margin: EdgeInsets.only(top: spacing),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBackCardHint(
                  Icons.close, 
                  context.l10n.stillLearning, 
                  Colors.red[400],
                ),
                _buildBackCardHint(
                  Icons.check, 
                  context.l10n.knewIt, 
                  Colors.green[400],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Cevap listesi widget'ı - kaydırma gerekmeyecek şekilde tasarlandı
  Widget _buildAnswerList(
    List<String> answers, {
    required double spacing,
    required double borderRadius,
    required double answerCardPadding,
    required double answerIconSize,
    required double fontSize,
  }) {
    final responsive = ResponsiveHelper.of(context);
    
    // Cevapların kaydırılabilir bir listede gösterilmesi
    return ListView.builder(
      // Physics'i ClampingScrollPhysics yapmak, ana container'dan taşmayı önler
      physics: ClampingScrollPhysics(),
      // Taşma riskini azaltmak için shrinkWrap true yap
      shrinkWrap: true,
      itemCount: answers.length,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: spacing * 0.5),
          padding: EdgeInsets.all(answerCardPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius * 0.7),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle, 
                color: Colors.green, 
                size: answerIconSize
              ),
              SizedBox(width: responsive.widthPercent(1.5)),
              Expanded(
                child: AutoSizeText(
                  answers[index],
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  minFontSize: 12.0,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackCardHint(IconData icon, String label, Color? color, {bool isLargeScreen = false}) { // isLargeScreen parametresi artık kullanılmıyor
    final responsive = ResponsiveHelper.of(context);
    final iconSize = responsive.adaptiveIconSize(size: 20.0);
    final spacing = responsive.heightPercent(0.5);
    final fontSize = responsive.scaledFontSize(small: 12.0, medium: 13.0, large: 14.0);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: iconSize),
        SizedBox(height: spacing),
        AutoSizeText(
          label,
          style: TextStyle(fontSize: fontSize, color: color),
          minFontSize: 10.0,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    return _categoryColorMap[category] ?? Colors.blue;
  }
}
