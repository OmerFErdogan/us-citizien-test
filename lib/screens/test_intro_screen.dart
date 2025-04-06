import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/question_service.dart';
import '../utils/extensions.dart';
import 'test_mode_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';



class TestIntroScreen extends StatefulWidget {
  final QuestionService questionService;

  const TestIntroScreen({
    Key? key,
    required this.questionService,
  }) : super(key: key);

  @override
  _TestIntroScreenState createState() => _TestIntroScreenState();
}

class _TestIntroScreenState extends State<TestIntroScreen> {
  bool _isLoading = false;
  bool _agreesToTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ABD Vatandaşlık Sınavı Simülasyonu'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner
                  Card(
                    elevation: 4,
                    color: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(
                            Icons.stars,
                            color: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Resmi Vatandaşlık Sınavı Simülasyonu',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Gerçek ABD Vatandaşlık sınav tecrübesini yaşayın',
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
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Sınav hakkında bilgi
                  const Text(
                    'Sınav Hakkında',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildInfoCard(
                    icon: Icons.quiz,
                    title: '10 Sivil Eğitim Sorusu',
                    description: 'USCIS görevlisi sınav sırasında 100 soruluk listeden 10 soru sorar.',
                  ),
                  _buildInfoCard(
                    icon: Icons.check_circle,
                    title: 'Geçme Kriteri: 6/10',
                    description: 'Sınavı geçmek için 10 sorudan en az 6 tanesini doğru cevaplamalısınız.',
                  ),
                  _buildInfoCard(
                    icon: Icons.timer,
                    title: '10 Dakika Süre',
                    description: 'Bu simülasyonda, tüm soruları cevaplamak için 10 dakikanız var.',
                  ),
                  _buildInfoCard(
                    icon: Icons.priority_high,
                    title: 'Dikkat',
                    description: 'Gerçek sınavda, soruları sözlü olarak cevaplandırmanız gerekir ve sınav yapan USCIS görevlisi sınavı istediği zaman durdurabilir.',
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Onay kutusu
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _agreesToTerms,
                            onChanged: (value) {
                              setState(() {
                                _agreesToTerms = value ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: Text(
                              'Bu simülasyonun yalnızca pratik amaçlı olduğunu ve gerçek sınavdan farklı olabileceğini anlıyorum.',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Başlatma butonu
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _agreesToTerms ? _startTest : null,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Sınavı Başlat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        disabledForegroundColor: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.blue[700],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startTest() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Tüm soruları yükle
      await widget.questionService.loadQuestions();
      
      // Rastgele 10 soru seç
      final questions = widget.questionService.getRandomQuestions(10);
      
      if (questions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Soru yüklenirken hata oluştu!')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // Test ekranına geçiş yap
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TestModeScreen(
            questionService: widget.questionService,
            questions: questions,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }
}