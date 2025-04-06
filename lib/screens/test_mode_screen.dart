import 'dart:async';
import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/question_service.dart';
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
    final question = widget.questions[_currentQuestionIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('ABD Vatandaşlık Sınavı'),
        actions: [
          // Zamanlayıcı göstergesi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Row(
                children: [
                  Icon(
                    _isTimerRunning ? Icons.timer : Icons.timer_off,
                    color: _secondsRemaining < 60 ? Colors.red : Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDuration(_secondsRemaining),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
            minHeight: 8,
            backgroundColor: Colors.grey[300],
            color: Colors.blue,
          ),
          
          // Soru ilerleme bilgisi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Soru ${_currentQuestionIndex + 1}/${widget.questions.length}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Geçmek için en az 6 doğru cevap',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Soru kartı
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Soru kartı
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Kategori
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              question.category,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[800],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Soru metni
                          Text(
                            question.question,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // USCIS görevlisi simülasyonu
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.blue[700],
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'USCIS Görevlisi',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        question.question,
                                        style: const TextStyle(
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Cevap seçenekleri
                  Column(
                    children: question.options.map((option) {
                      return _buildAnswerOption(option.text);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          
          // Alt bilgi
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
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
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Önceki'),
                  ),
                
                const SizedBox(width: 16),
                
                // Zamanlayıcı kontrol tuşu
                OutlinedButton.icon(
                  onPressed: _pauseTimer,
                  icon: Icon(_isTimerRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(_isTimerRunning ? 'Duraklat' : 'Devam Et'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Bitir tuşu
                ElevatedButton.icon(
                  onPressed: _finishTest,
                  icon: const Icon(Icons.done_all),
                  label: const Text('Sınavı Bitir'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOption(String text) {
    final isFocused = _results[_currentQuestionIndex] == null;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
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
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
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