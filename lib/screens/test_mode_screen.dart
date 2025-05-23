import 'dart:async';
import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/question_service.dart';
import '../utils/extensions.dart';
import '../utils/responsive/responsive_helper.dart';
import 'result_screen.dart';

class TestModeScreen extends StatefulWidget {
  final QuestionService questionService;
  final List<Question> questions;

  const TestModeScreen({
    Key? key,
    required this.questionService,
    required this.questions,
  }) : super(key: key);

  @override
  _TestModeScreenState createState() => _TestModeScreenState();
}

class _TestModeScreenState extends State<TestModeScreen> {
  int _currentQuestionIndex = 0;
  List<bool?> _results = [];
  late Timer _timer;
  int _secondsRemaining = 600; // 10 dakika
  bool _isTimerRunning = true;
  
  @override
  void initState() {
    super.initState();
    // Sonuç listesini null değerlerle başlat (cevap verilmemiş sorular)
    _results = List.generate(widget.questions.length, (index) => null);
    
    // Zamanlayıcıyı başlat
    _startTimer();
  }
  
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
  
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer.cancel();
        _finishTest();
      }
    });
  }
  
  void _pauseTimer() {
    if (_isTimerRunning) {
      _timer.cancel();
    } else {
      _startTimer();
    }
    
    setState(() {
      _isTimerRunning = !_isTimerRunning;
    });
  }
  
  void _answerQuestion(String answer) {
    final question = widget.questions[_currentQuestionIndex];
    final isCorrect = question.isCorrectAnswer(answer);
    
    // Cevabı kaydet
    setState(() {
      _results[_currentQuestionIndex] = isCorrect;
    });
    
    // QuestionService'e cevabı kaydet
    widget.questionService.answerQuestion(question.id, answer);
    
    // Bir sonraki soruya geç veya testi bitir
    if (_currentQuestionIndex < widget.questions.length - 1) {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _currentQuestionIndex++;
        });
      });
    } else {
      Future.delayed(const Duration(milliseconds: 500), () {
        _finishTest();
      });
    }
  }
  
  void _finishTest() {
    _timer.cancel();
    
    // Cevaplandırılmamış soruları yanlış olarak işaretle
    for (int i = 0; i < _results.length; i++) {
      if (_results[i] == null) {
        _results[i] = false;
      }
    }
    
    // Sonuç ekranına git
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          questionService: widget.questionService,
          questions: widget.questions,
          results: _results.cast<bool>(),
          timeSpent: 600 - _secondsRemaining,
          isTestMode: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);
    final isTablet = responsive.isMedium || responsive.isLarge;
    final question = widget.questions[_currentQuestionIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.usExam),
        actions: [
          // Zamanlayıcı göstergesi
          Padding(
            padding: responsive.adaptivePadding(horizontal: 16.0, densityFactor: 0.5),
            child: Center(
              child: Row(
                children: [
                  Icon(
                    _isTimerRunning ? Icons.timer : Icons.timer_off,
                    color: _secondsRemaining < 60 ? Colors.red : Colors.white,
                    size: responsive.adaptiveIconSize(size: 20.0),
                  ),
                  SizedBox(width: responsive.adaptiveIconSize(size: 4.0)),
                  Text(
                    _formatDuration(_secondsRemaining),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: responsive.scaledFontSize(
                        small: 16.0,
                        medium: 18.0,
                        large: 20.0,
                      ),
                      color: _secondsRemaining < 60 ? Colors.red : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // İlerleme çubuğu
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / widget.questions.length,
            minHeight: responsive.adaptiveIconSize(size: 8.0, densityFactor: 0.3),
            backgroundColor: Colors.grey[300],
            color: Colors.blue,
          ),
          
          // Soru ilerleme bilgisi
          Padding(
            padding: responsive.adaptivePadding(
              horizontal: 16.0, 
              vertical: 8.0, 
              densityFactor: 0.5,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.questionProgress(_currentQuestionIndex + 1, widget.questions.length),
                  style: TextStyle(
                    fontSize: responsive.scaledFontSize(
                      small: 16.0,
                      medium: 18.0,
                      large: 20.0,
                    ),
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                Container(
                  width: responsive.isSmall ? 200 : 250,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: responsive.adaptiveIconSize(size: 16.0),
                        color: Colors.blue[700],
                      ),
                      SizedBox(width: responsive.adaptiveIconSize(size: 4.0)),
                      Flexible(
                        child: Text(
                          context.l10n.needSixCorrect,
                          style: TextStyle(
                            fontSize: responsive.scaledFontSize(
                              small: 12.0,
                              medium: 14.0,
                              large: 16.0,
                            ),
                            color: Colors.blue[700],
                            fontStyle: FontStyle.italic,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Ana içerik
          Expanded(
            child: isTablet 
                ? _buildTabletLayout(question, responsive)
                : _buildMobileLayout(question, responsive),
          ),
          
          // Alt bilgi
          Padding(
            padding: responsive.adaptivePadding(
              horizontal: 8.0, 
              vertical: 16.0, 
              densityFactor: 0.5,
            ),
            child: responsive.isSmall ? 
              // Küçük ekranlar için dikey düzenleme
              Column(
                children: [
                  // İlk satır: Geri ve Zamanlayıcı kontrol
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Geri tuşu (ilk soruda gizli)
                      if (_currentQuestionIndex > 0)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _currentQuestionIndex--;
                              });
                            },
                            icon: Icon(
                              Icons.arrow_back,
                              size: responsive.adaptiveIconSize(size: 20.0),
                            ),
                            label: Text(
                              context.l10n.previous,
                              style: TextStyle(
                                fontSize: responsive.scaledFontSize(
                                  small: 12.0,
                                  medium: 14.0,
                                  large: 16.0,
                                ),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: responsive.adaptivePadding(
                                horizontal: 8.0, 
                                vertical: 8.0, 
                                densityFactor: 0.5,
                              ),
                            ),
                          ),
                        ),
                      
                      if (_currentQuestionIndex > 0)
                        SizedBox(width: responsive.adaptiveIconSize(size: 8.0)),
                      
                      // Zamanlayıcı kontrol tuşu
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pauseTimer,
                          icon: Icon(
                            _isTimerRunning ? Icons.pause : Icons.play_arrow,
                            size: responsive.adaptiveIconSize(size: 20.0),
                          ),
                          label: Text(
                            _isTimerRunning ? context.l10n.pause : context.l10n.resume,
                            style: TextStyle(
                              fontSize: responsive.scaledFontSize(
                                small: 12.0,
                                medium: 14.0,
                                large: 16.0,
                              ),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            padding: responsive.adaptivePadding(
                              horizontal: 8.0, 
                              vertical: 8.0, 
                              densityFactor: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: responsive.adaptiveIconSize(size: 8.0)),
                  
                  // İkinci satır: Bitir tuşu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _finishTest,
                      icon: Icon(
                        Icons.done_all,
                        size: responsive.adaptiveIconSize(size: 20.0),
                      ),
                      label: Text(
                        context.l10n.finishExam,
                        style: TextStyle(
                          fontSize: responsive.scaledFontSize(
                            small: 12.0,
                            medium: 14.0,
                            large: 16.0,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: responsive.adaptivePadding(
                          horizontal: 8.0, 
                          vertical: 12.0, 
                          densityFactor: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ) :
              // Büyük ekranlar için yatay düzenleme
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Geri tuşu (ilk soruda gizli)
                  if (_currentQuestionIndex > 0)
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _currentQuestionIndex--;
                        });
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        size: responsive.adaptiveIconSize(size: 20.0),
                      ),
                      label: Text(
                        context.l10n.previous,
                        style: TextStyle(
                          fontSize: responsive.scaledFontSize(
                            small: 14.0,
                            medium: 16.0,
                            large: 18.0,
                          ),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: responsive.adaptivePadding(
                          horizontal: 16.0, 
                          vertical: 8.0, 
                          densityFactor: 0.5,
                        ),
                      ),
                    ),
                  
                  SizedBox(width: responsive.adaptiveIconSize(size: 16.0)),
                  
                  // Zamanlayıcı kontrol tuşu
                  OutlinedButton.icon(
                    onPressed: _pauseTimer,
                    icon: Icon(
                      _isTimerRunning ? Icons.pause : Icons.play_arrow,
                      size: responsive.adaptiveIconSize(size: 20.0),
                    ),
                    label: Text(
                      _isTimerRunning ? context.l10n.pause : context.l10n.resume,
                      style: TextStyle(
                        fontSize: responsive.scaledFontSize(
                          small: 14.0,
                          medium: 16.0,
                          large: 18.0,
                        ),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      padding: responsive.adaptivePadding(
                        horizontal: 16.0, 
                        vertical: 8.0, 
                        densityFactor: 0.5,
                      ),
                    ),
                  ),
                  
                  SizedBox(width: responsive.adaptiveIconSize(size: 16.0)),
                  
                  // Bitir tuşu
                  ElevatedButton.icon(
                    onPressed: _finishTest,
                    icon: Icon(
                      Icons.done_all,
                      size: responsive.adaptiveIconSize(size: 20.0),
                    ),
                    label: Text(
                      context.l10n.finishExam,
                      style: TextStyle(
                        fontSize: responsive.scaledFontSize(
                          small: 14.0,
                          medium: 16.0,
                          large: 18.0,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: responsive.adaptivePadding(
                        horizontal: 16.0, 
                        vertical: 8.0, 
                        densityFactor: 0.5,
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
  
  Widget _buildMobileLayout(Question question, ResponsiveHelper responsive) {
    return SingleChildScrollView(
      padding: responsive.adaptivePadding(
        horizontal: 16.0, 
        vertical: 16.0, 
        densityFactor: 0.5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Soru kartı
          _buildQuestionCard(question, responsive),
          
          SizedBox(height: responsive.adaptiveIconSize(size: 24.0)),
          
          // Cevap seçenekleri
          Column(
            children: question.options.map((option) {
              return _buildAnswerOption(option.text, responsive);
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTabletLayout(Question question, ResponsiveHelper responsive) {
    return Padding(
      padding: responsive.adaptivePadding(
        horizontal: 16.0, 
        vertical: 16.0, 
        densityFactor: 0.5,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sol taraf - Soru kartı
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              child: _buildQuestionCard(question, responsive),
            ),
          ),
          
          SizedBox(width: responsive.adaptiveIconSize(size: 24.0)),
          
          // Sağ taraf - Cevap seçenekleri
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.selectYourAnswer,
                  style: TextStyle(
                    fontSize: responsive.scaledFontSize(
                      small: 18.0,
                      medium: 20.0,
                      large: 22.0,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: responsive.adaptiveIconSize(size: 16.0)),
                
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: question.options.map((option) {
                        return _buildAnswerOption(option.text, responsive);
                      }).toList(),
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

  Widget _buildQuestionCard(Question question, ResponsiveHelper responsive) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: responsive.adaptivePadding(
          horizontal: 16.0, 
          vertical: 16.0,
          densityFactor: 0.5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kategori
            Container(
              padding: responsive.adaptivePadding(
                horizontal: 8.0, 
                vertical: 4.0,
                densityFactor: 0.3,
              ),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                question.category,
                style: TextStyle(
                  fontSize: responsive.scaledFontSize(
                    small: 12.0,
                    medium: 14.0,
                    large: 16.0,
                  ),
                  color: Colors.blue[800],
                ),
              ),
            ),
            SizedBox(height: responsive.adaptiveIconSize(size: 16.0)),
            
            // Soru metni
            Text(
              question.question,
              style: TextStyle(
                fontSize: responsive.scaledFontSize(
                  small: 20.0,
                  medium: 22.0,
                  large: 24.0,
                ),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: responsive.adaptiveIconSize(size: 8.0)),
            
            // USCIS görevlisi simülasyonu
            Container(
              padding: responsive.adaptivePadding(
                horizontal: 12.0, 
                vertical: 12.0,
                densityFactor: 0.5,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue[700],
                    radius: responsive.adaptiveIconSize(size: 20.0),
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: responsive.adaptiveIconSize(size: 18.0),
                    ),
                  ),
                  SizedBox(width: responsive.adaptiveIconSize(size: 12.0)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.uscisOfficer,
                          style: TextStyle(
                            fontSize: responsive.scaledFontSize(
                              small: 12.0,
                              medium: 14.0,
                              large: 16.0,
                            ),
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: responsive.adaptiveIconSize(size: 4.0)),
                        Text(
                          question.question,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: responsive.scaledFontSize(
                              small: 14.0,
                              medium: 16.0,
                              large: 18.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Tablet için ekstra bilgiler
            if (responsive.isMedium || responsive.isLarge)
              Padding(
                padding: EdgeInsets.only(top: responsive.adaptiveIconSize(size: 20.0)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(),
                    SizedBox(height: responsive.adaptiveIconSize(size: 12.0)),
                    Text(
                      context.l10n.examTips,
                      style: TextStyle(
                        fontSize: responsive.scaledFontSize(
                          small: 18.0,
                          medium: 20.0,
                          large: 22.0,
                        ),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: responsive.adaptiveIconSize(size: 12.0)),
                    _buildTipItem(
                      responsive,
                      Icons.lightbulb_outline,
                      context.l10n.answerClearly,
                    ),
                    _buildTipItem(
                      responsive,
                      Icons.volume_up,
                      context.l10n.speakConfidently,
                    ),
                    _buildTipItem(
                      responsive,
                      Icons.access_time,
                      context.l10n.takeYourTime,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTipItem(ResponsiveHelper responsive, IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: responsive.adaptiveIconSize(size: 8.0)),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.blue[700],
            size: responsive.adaptiveIconSize(size: 20.0),
          ),
          SizedBox(width: responsive.adaptiveIconSize(size: 8.0)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: responsive.scaledFontSize(
                  small: 14.0,
                  medium: 16.0,
                  large: 18.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOption(String text, ResponsiveHelper responsive) {
    final isFocused = _results[_currentQuestionIndex] == null;
    
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: responsive.adaptiveIconSize(size: 8.0)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isFocused ? Colors.blue : Colors.transparent,
          width: isFocused ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: () => _answerQuestion(text),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: responsive.adaptivePadding(
            horizontal: 16.0, 
            vertical: 16.0,
            densityFactor: 0.5,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: responsive.scaledFontSize(
                      small: 16.0,
                      medium: 18.0,
                      large: 20.0,
                    ),
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios, 
                size: responsive.adaptiveIconSize(size: 16.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
