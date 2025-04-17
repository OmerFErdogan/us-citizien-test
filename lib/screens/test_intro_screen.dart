import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/question_service.dart';
import '../utils/extensions.dart';
import '../utils/responsive/responsive_helper.dart';
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
    final responsive = ResponsiveHelper.of(context);
    final isTablet = responsive.isMedium || responsive.isLarge;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.testSimulation),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: responsive.adaptivePadding(
                horizontal: 16.0, 
                vertical: 16.0, 
                densityFactor: 0.7,
              ),
              child: isTablet 
                ? _buildTabletLayout(responsive)
                : _buildMobileLayout(responsive),
            ),
    );
  }

  Widget _buildMobileLayout(ResponsiveHelper responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBanner(responsive),
        SizedBox(height: responsive.adaptiveIconSize(size: 24.0)),
        
        _buildSectionTitle(context.l10n.aboutExam, responsive),
        SizedBox(height: responsive.adaptiveIconSize(size: 16.0)),
        
        ..._buildInfoCards(responsive),
        
        SizedBox(height: responsive.adaptiveIconSize(size: 24.0)),
        _buildDisclaimerCard(responsive),
        
        SizedBox(height: responsive.adaptiveIconSize(size: 24.0)),
        _buildStartButton(responsive),
      ],
    );
  }

  Widget _buildTabletLayout(ResponsiveHelper responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBanner(responsive),
        SizedBox(height: responsive.adaptiveIconSize(size: 28.0)),
        
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side - About exam section
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context.l10n.aboutExam, responsive),
                  SizedBox(height: responsive.adaptiveIconSize(size: 16.0)),
                  ..._buildInfoCards(responsive),
                ],
              ),
            ),
            
            // Spacer
            SizedBox(width: responsive.adaptiveIconSize(size: 24.0)),
            
            // Right side - Disclaimer and Start button
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: responsive.adaptivePadding(
                        horizontal: 24.0, 
                        vertical: 24.0, 
                        densityFactor: 0.7,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.startTestSimulation,
                            style: TextStyle(
                              fontSize: responsive.scaledFontSize(
                                small: 18.0, 
                                medium: 22.0, 
                                large: 24.0,
                              ),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: responsive.adaptiveIconSize(size: 16.0)),
                          
                          Text(
                            context.l10n.testDescription,
                            style: TextStyle(
                              fontSize: responsive.scaledFontSize(
                                small: 14.0, 
                                medium: 16.0, 
                                large: 18.0,
                              ),
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: responsive.adaptiveIconSize(size: 24.0)),
                          
                          _buildDisclaimerCard(responsive),
                          SizedBox(height: responsive.adaptiveIconSize(size: 24.0)),
                          
                          _buildStartButton(responsive),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBanner(ResponsiveHelper responsive) {
    return Card(
      elevation: 4,
      color: Colors.blue[700],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: responsive.adaptivePadding(
          horizontal: 20.0, 
          vertical: 20.0, 
          densityFactor: 0.6,
        ),
        child: Row(
          children: [
            Icon(
              Icons.stars,
              color: Colors.white,
              size: responsive.adaptiveIconSize(size: 48.0, densityFactor: 0.7),
            ),
            SizedBox(width: responsive.adaptiveIconSize(size: 16.0)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.officialTestSimulation,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: responsive.scaledFontSize(
                        small: 18.0, 
                        medium: 20.0, 
                        large: 22.0,
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: responsive.adaptiveIconSize(size: 8.0)),
                  Text(
                    context.l10n.experienceRealTest,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
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
    );
  }

  Widget _buildSectionTitle(String title, ResponsiveHelper responsive) {
    return Text(
      title,
      style: TextStyle(
        fontSize: responsive.scaledFontSize(
          small: 20.0, 
          medium: 22.0, 
          large: 24.0,
        ),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  List<Widget> _buildInfoCards(ResponsiveHelper responsive) {
    return [
      _buildInfoCard(
        responsive: responsive,
        icon: Icons.quiz,
        title: context.l10n.civicsQuestions,
        description: context.l10n.uscisOfficerQuestions,
      ),
      _buildInfoCard(
        responsive: responsive,
        icon: Icons.check_circle,
        title: context.l10n.passingCriteria,
        description: context.l10n.needCorrectAnswers,
      ),
      _buildInfoCard(
        responsive: responsive,
        icon: Icons.timer,
        title: context.l10n.tenMinuteTime,
        description: context.l10n.timeDescription,
      ),
      _buildInfoCard(
        responsive: responsive,
        icon: Icons.priority_high,
        title: context.l10n.attention,
        description: context.l10n.realExamNote,
      ),
    ];
  }

  Widget _buildInfoCard({
    required ResponsiveHelper responsive,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: responsive.adaptiveIconSize(size: 12.0)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: responsive.adaptivePadding(
          horizontal: 16.0, 
          vertical: 16.0, 
          densityFactor: 0.5,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(responsive.adaptiveIconSize(size: 8.0)),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.blue[700],
                size: responsive.adaptiveIconSize(size: 24.0),
              ),
            ),
            SizedBox(width: responsive.adaptiveIconSize(size: 16.0)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: responsive.scaledFontSize(
                        small: 16.0,
                        medium: 18.0,
                        large: 20.0,
                      ),
                    ),
                  ),
                  SizedBox(height: responsive.adaptiveIconSize(size: 4.0)),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: responsive.scaledFontSize(
                        small: 14.0,
                        medium: 15.0,
                        large: 16.0,
                      ),
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

  Widget _buildDisclaimerCard(ResponsiveHelper responsive) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: responsive.adaptivePadding(
          horizontal: 16.0, 
          vertical: 16.0, 
          densityFactor: 0.5,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Transform.scale(
              scale: responsive.isLarge ? 1.2 : 1.0,
              child: Checkbox(
                value: _agreesToTerms,
                onChanged: (value) {
                  setState(() {
                    _agreesToTerms = value ?? false;
                  });
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  context.l10n.simulationDisclaimer,
                  style: TextStyle(
                    fontSize: responsive.scaledFontSize(
                      small: 14.0,
                      medium: 15.0,
                      large: 16.0,
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

  Widget _buildStartButton(ResponsiveHelper responsive) {
    return SizedBox(
      width: double.infinity,
      height: responsive.adaptiveIconSize(size: 50.0, densityFactor: 0.6),
      child: ElevatedButton.icon(
        onPressed: _agreesToTerms ? _startTest : null,
        icon: Icon(Icons.play_arrow, size: responsive.adaptiveIconSize(size: 24.0)),
        label: Text(
          context.l10n.startExam,
          style: TextStyle(
            fontSize: responsive.scaledFontSize(
              small: 16.0,
              medium: 18.0,
              large: 20.0,
            ),
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[600],
          padding: responsive.adaptivePadding(
            horizontal: 24.0, 
            vertical: 12.0, 
            densityFactor: 0.5,
          ),
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
          SnackBar(content: Text(context.l10n.errorLoadingQuestions)),
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
        SnackBar(content: Text(context.l10n.error(e.toString()))),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }
}