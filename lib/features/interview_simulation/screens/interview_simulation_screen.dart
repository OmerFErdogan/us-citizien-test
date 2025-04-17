// import 'dart:async';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:uuid/uuid.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:record/record.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import '../models/interview_models.dart';
// import '../services/interview_service.dart';
// import '../widgets/officer_avatar_widget.dart';
// import 'interview_results_screen.dart';
// import '../../../utils/extensions.dart';

// class InterviewSimulationScreen extends StatefulWidget {
//   final InterviewService interviewService;

//   const InterviewSimulationScreen({
//     Key? key,
//     required this.interviewService,
//   }) : super(key: key);

//   @override
//   _InterviewSimulationScreenState createState() => _InterviewSimulationScreenState();
// }

// class _InterviewSimulationScreenState extends State<InterviewSimulationScreen> {
//   late List<InterviewQuestion> _questions;
//   late UscisOfficer _officer;
//   late InterviewSettings _settings;
  
//   final List<InterviewResponse> _responses = [];
//   final TextEditingController _textController = TextEditingController();
  
//   int _currentQuestionIndex = 0;
//   bool _isSubmitting = false;
//   bool _isAudioPlaying = false;
//   bool _isRecording = false;
  
//   DateTime? _interviewStartTime;
//   DateTime? _questionStartTime;
  
//   Timer? _responseTimer;
//   int _responseTimeInSeconds = 0;
  
//   final ScrollController _scrollController = ScrollController();
//   final Uuid _uuid = const Uuid();
  
//   // Ses ile ilgili değişkenler
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   final Record _recorder = Record();
//   final stt.SpeechToText _speech = stt.SpeechToText();

//   @override
//   void initState() {
//     super.initState();
//     _initializeInterview();
//   }

//   @override
//   void dispose() {
//     _textController.dispose();
//     _responseTimer?.cancel();
//     _scrollController.dispose();
//     _audioPlayer.dispose();
//     _recorder.dispose();
//     super.dispose();
//   }

//   Future<void> _initializeInterview() async {
//     // Memuru ve ayarları al
//     _officer = widget.interviewService.getCurrentOfficer();
//     _settings = widget.interviewService.getCurrentSettings();
    
//     // Soru setini oluştur
//     _questions = widget.interviewService.generateInterviewQuestionSet();
    
//     // Görüşme başlangıç zamanını kaydet
//     _interviewStartTime = DateTime.now();
//     _startQuestionTimer();
    
//     // Speech to text özelliğini başlat
//     if (_settings.useVoiceInput) {
//       await _initializeSpeechToText();
//     }
    
//     setState(() {});
//   }
  
//   Future<void> _initializeSpeechToText() async {
//     // Konuşma tanıma özelliğini başlat
//     await _speech.initialize();
//   }

//   void _startQuestionTimer() {
//     // Bir önceki zamanlayıcıyı iptal et
//     _responseTimer?.cancel();
//     _responseTimeInSeconds = 0;
//     _questionStartTime = DateTime.now();
    
//     // Yeni zamanlayıcı başlat (eğer zamanlanmış yanıtlar etkinse)
//     if (_settings.useTimedResponses) {
//       _responseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//         setState(() {
//           _responseTimeInSeconds++;
//         });
//       });
//     }
//   }

//   Future<void> _submitAnswer() async {
//     if (_textController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(context.l10n.pleaseEnterAnswer)),
//       );
//       return;
//     }
    
//     setState(() {
//       _isSubmitting = true;
//     });
    
//     // Yanıtı değerlendir
//     final currentQuestion = _questions[_currentQuestionIndex];
//     final userResponse = _textController.text.trim();
//     final isCorrect = widget.interviewService.evaluateAnswer(currentQuestion, userResponse);
    
//     // Yanıt süresini hesapla
//     final responseTime = _settings.useTimedResponses
//         ? _responseTimeInSeconds
//         : DateTime.now().difference(_questionStartTime!).inSeconds;
    
//     // Memur geri bildirimi oluştur
//     final officerFeedback = widget.interviewService.generateOfficerFeedback(
//       isCorrect,
//       currentQuestion.type,
//     );
    
//     // Yanıtı kaydet
//     final response = InterviewResponse(
//       questionId: currentQuestion.id,
//       userResponse: userResponse,
//       isCorrect: isCorrect,
//       timestamp: DateTime.now(),
//       responseTimeInSeconds: responseTime,
//       officerFeedback: officerFeedback,
//     );
    
//     _responses.add(response);
    
//     // Kısa bir bekleme ekle (daha gerçekçi bir deneyim için)
//     await Future.delayed(const Duration(milliseconds: 800));
    
//     setState(() {
//       _isSubmitting = false;
//     });
    
//     // Memur geri bildirimini göster
//     _showOfficerFeedback(officerFeedback);
    
//     // Sonraki soruya geç veya görüşmeyi tamamla
//     await Future.delayed(const Duration(seconds: 1));
//     _nextQuestion();
//   }

//   void _showOfficerFeedback(String feedback) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             CircleAvatar(
//               radius: 16,
//               backgroundImage: AssetImage(_officer.avatarImagePath),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 feedback,
//                 style: const TextStyle(fontSize: 14),
//               ),
//             ),
//           ],
//         ),
//         duration: const Duration(seconds: 2),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//     );
//   }

//   void _nextQuestion() {
//     _textController.clear();
    
//     if (_currentQuestionIndex < _questions.length - 1) {
//       setState(() {
//         _currentQuestionIndex++;
//       });
//       _startQuestionTimer();
//     } else {
//       _finishInterview();
//     }
//   }

//   Future<void> _finishInterview() async {
//     // Görüşme süresini hesapla
//     final interviewDuration = DateTime.now().difference(_interviewStartTime!);
    
//     // Doğru cevap sayısını hesapla
//     final correctAnswers = _responses.where((r) => r.isCorrect).length;
    
//     // Oturum bilgilerini oluştur
//     final session = InterviewSession(
//       id: _uuid.v4(),
//       date: _interviewStartTime!,
//       totalQuestions: _questions.length,
//       correctAnswers: correctAnswers,
//       settings: _settings,
//       responses: _responses,
//       isCompleted: true,
//       durationInMinutes: interviewDuration.inMinutes,
//       officerName: _officer.name,
//     );
    
//     // Oturumu kaydet
//     await widget.interviewService.saveSession(session);
    
//     // Sonuç ekranına geç
//     if (mounted) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => InterviewResultsScreen(
//             interviewService: widget.interviewService,
//             session: session,
//           ),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_questions == null || _questions.isEmpty) {
//       return Scaffold(
//         appBar: AppBar(title: Text(context.l10n.interviewSimulation)),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }
    
//     final currentQuestion = _questions[_currentQuestionIndex];
    
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: const Text('Görüşme Simülasyonu'),
//         actions: [
//           TextButton.icon(
//             icon: const Icon(Icons.exit_to_app, color: Colors.white),
//             label: Text(
//               context.l10n.endInterview,
//               style: const TextStyle(color: Colors.white),
//             ),
//             onPressed: () => _showEndInterviewDialog(),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           _buildProgressBar(),
//           Expanded(
//             child: SingleChildScrollView(
//               controller: _scrollController,
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   _buildInterviewHeader(),
//                   const SizedBox(height: 24),
//                   _buildQuestionCard(currentQuestion),
//                   const SizedBox(height: 16),
//                   if (_settings.useTimedResponses) _buildTimer(),
//                   const SizedBox(height: 16),
//                   _buildAnswerInput(),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProgressBar() {
//     final progress = (_currentQuestionIndex + 1) / _questions.length;
    
//     return Container(
//       height: 8,
//       color: Colors.grey.shade200,
//       child: Row(
//         children: [
//           Expanded(
//             flex: (_currentQuestionIndex + 1) * 100 ~/ _questions.length,
//             child: Container(
//               color: Colors.green,
//             ),
//           ),
//           Expanded(
//             flex: 100 - ((_currentQuestionIndex + 1) * 100 ~/ _questions.length),
//             child: Container(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInterviewHeader() {
//     // Basit header kullanıyoruz, debug bilgiler olmadan
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         CircleAvatar(
//           radius: 32,
//           backgroundImage: AssetImage(_officer.avatarImagePath),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 _officer.name,
//                 style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 _officer.position,
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey.shade700,
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                 child: Text(
//                   'Görüşme Devam Ediyor',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.green.shade700,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               Text(
//                 'Soru ${_currentQuestionIndex + 1} / ${_questions.length}',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey.shade600,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildQuestionCard(InterviewQuestion question) {
//     Color cardColor;
//     IconData iconData;
    
//     // Soru tipine göre renk ve ikon belirle
//     switch (question.type) {
//       case InterviewQuestionType.civics:
//         cardColor = Colors.blue.shade50;
//         iconData = Icons.help_outline;
//         break;
//       case InterviewQuestionType.personal:
//         cardColor = Colors.green.shade50;
//         iconData = Icons.person_outline;
//         break;
//       case InterviewQuestionType.n400:
//         cardColor = Colors.orange.shade50;
//         iconData = Icons.description_outlined;
//         break;
//       case InterviewQuestionType.englishReading:
//         cardColor = Colors.purple.shade50;
//         iconData = Icons.menu_book;
//         break;
//       case InterviewQuestionType.englishWriting:
//         cardColor = Colors.indigo.shade50;
//         iconData = Icons.edit;
//         break;
//     }
    
//     return Card(
//       elevation: 3,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       color: cardColor,
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Icon(iconData, color: Colors.grey.shade700, size: 24),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Text(
//                     question.question,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             if (question.context != null) ...[
//               const SizedBox(height: 16),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.7),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.grey.shade300),
//                 ),
//                 child: Text(
//                   question.context!,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey.shade800,
//                     fontStyle: FontStyle.italic,
//                   ),
//                 ),
//               ),
//             ],
//             if (question.hint != null) ...[
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Icon(Icons.lightbulb_outline, color: Colors.amber.shade700, size: 18),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       question.hint!,
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.amber.shade900,
//                         fontStyle: FontStyle.italic,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//             if (_settings.useAudio && question.audioPath.isNotEmpty) ...[
//               const SizedBox(height: 16),
//               OutlinedButton.icon(
//                 icon: Icon(
//                   _isAudioPlaying ? Icons.pause : Icons.volume_up,
//                   size: 20,
//                 ),
//                 label: Text(
//                   _isAudioPlaying
//                       ? context.l10n.pauseAudio
//                       : context.l10n.listenQuestion,
//                 ),
//                 style: OutlinedButton.styleFrom(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 8,
//                   ),
//                 ),
//                 onPressed: _isAudioPlaying ? _pauseAudio : _playAudio,
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTimer() {
//     // 30 saniye ve üzerinde ise renk değiştirelim
//     final isLongTime = _responseTimeInSeconds >= 30;
    
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: isLongTime ? Colors.red.shade50 : Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(30),
//         border: Border.all(
//           color: isLongTime ? Colors.red.shade300 : Colors.grey.shade300,
//         ),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             Icons.timer,
//             size: 18,
//             color: isLongTime ? Colors.red : Colors.grey.shade700,
//           ),
//           const SizedBox(width: 8),
//           Text(
//             '${context.l10n.responseTime}: ${_responseTimeInSeconds} ${context.l10n.seconds}',
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: isLongTime ? Colors.red : Colors.grey.shade700,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAnswerInput() {
//     final currentQuestion = _questions[_currentQuestionIndex];
//     final isEnglishWriting = currentQuestion.type == InterviewQuestionType.englishWriting;
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         Text(
//           context.l10n.yourAnswer,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextField(
//           controller: _textController,
//           decoration: InputDecoration(
//             hintText: context.l10n.typeYourAnswer,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             fillColor: Colors.white,
//             filled: true,
//           ),
//           maxLines: isEnglishWriting ? 3 : 1,
//           textCapitalization: TextCapitalization.sentences,
//           autofocus: true,
//           enabled: !_isSubmitting,
//         ),
//         const SizedBox(height: 8),
//         if (_settings.useVoiceInput) ...[
//           OutlinedButton.icon(
//             icon: Icon(
//               _isRecording ? Icons.stop : Icons.mic,
//               color: _isRecording ? Colors.red : Colors.blue,
//             ),
//             label: Text(
//               _isRecording ? context.l10n.stopRecording : context.l10n.startRecording,
//               style: TextStyle(
//                 color: _isRecording ? Colors.red : Colors.blue,
//               ),
//             ),
//             style: OutlinedButton.styleFrom(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(30),
//               ),
//             ),
//             onPressed: _isSubmitting ? null : _toggleRecording,
//           ),
//           const SizedBox(height: 16),
//         ],
//         ElevatedButton.icon(
//           icon: const Icon(Icons.send),
//           label: Text(
//             _isSubmitting
//                 ? context.l10n.processing
//                 : context.l10n.submitAnswer,
//             style: const TextStyle(fontSize: 16),
//           ),
//           style: ElevatedButton.styleFrom(
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(30),
//             ),
//           ),
//           onPressed: _isSubmitting ? null : _submitAnswer,
//         ),
//       ],
//     );
//   }

//   void _playAudio() async {
//     try {
//       final currentQuestion = _questions[_currentQuestionIndex];
//       if (currentQuestion.audioPath.isNotEmpty) {
//         await _audioPlayer.setAsset(currentQuestion.audioPath);
//         await _audioPlayer.play();
//         setState(() {
//           _isAudioPlaying = true;
//         });
        
//         // Ses dosyası bittiğinde durumu güncelle
//         _audioPlayer.playerStateStream.listen((state) {
//           if (state.processingState == ProcessingState.completed) {
//             setState(() {
//               _isAudioPlaying = false;
//             });
//           }
//         });
//       }
//     } catch (e) {
//       print('Audio oynatma hatası: $e');
//       setState(() {
//         _isAudioPlaying = false;
//       });
//     }
//   }

//   void _pauseAudio() async {
//     if (_audioPlayer.playing) {
//       await _audioPlayer.pause();
//     }
//     setState(() {
//       _isAudioPlaying = false;
//     });
//   }

//   Future<void> _toggleRecording() async {
//     if (_isRecording) {
//       // Kaydı durdur
//       final path = await _recorder.stop();
//       setState(() {
//         _isRecording = false;
//       });
      
//       // Kaydı yazıya dönüştür (gerçek uygulamada Speech-to-Text API kullanılabilir)
//       // Şu an için basit bir demo metin ekliyoruz
//       if (path != null) {
//         // Gerçek uygulamada burada ses dosyası yazıya dönüştürülebilir
//         setState(() {
//           final currentText = _textController.text;
//           _textController.text = currentText.isEmpty 
//               ? "I understand the question and I'll answer it."
//               : currentText + " And to add more, I would say this is correct.";
//         });
//       }
//     } else {
//       // Kaydı başlat
//       final hasPermission = await _recorder.hasPermission();
//       if (hasPermission) {
//         await _recorder.start();
//         setState(() {
//           _isRecording = true;
//         });
        
//         // Demo için 5 saniye sonra otomatik olarak durdur
//         Future.delayed(const Duration(seconds: 5), () {
//           if (mounted && _isRecording) {
//             _toggleRecording();
//           }
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Mikrofon izni gerekli")),
//         );
//       }
//     }
//   }

//   void _showEndInterviewDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(context.l10n.endInterview),
//         content: Text(context.l10n.endInterviewConfirm),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(context.l10n.continueInterview),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Navigator.pop(context);
//             },
//             child: Text(context.l10n.endInterview),
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//           ),
//         ],
//       ),
//     );
//   }
// }
