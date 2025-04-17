// import 'package:flutter/material.dart';
// import '../models/interview_models.dart';
// import '../services/interview_service.dart';
// import 'interview_settings_screen.dart';
// import 'interview_simulation_screen.dart';
// import 'past_interviews_screen.dart';
// import '../../../utils/extensions.dart';

// class InterviewIntroScreen extends StatefulWidget {
//   final InterviewService interviewService;

//   const InterviewIntroScreen({
//     Key? key,
//     required this.interviewService,
//   }) : super(key: key);

//   @override
//   _InterviewIntroScreenState createState() => _InterviewIntroScreenState();
// }

// class _InterviewIntroScreenState extends State<InterviewIntroScreen> {
//   late UscisOfficer _officer;
//   late InterviewSettings _settings;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     setState(() {
//       _isLoading = true;
//     });

//     // Mevcut memur ve ayarları al
//     _officer = widget.interviewService.getCurrentOfficer();
//     _settings = widget.interviewService.getCurrentSettings();

//     setState(() {
//       _isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Görüşme Simülasyonu'),
//         elevation: 0,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   _buildIntroCard(),
//                   const SizedBox(height: 24),
//                   _buildOfficerCard(),
//                   const SizedBox(height: 24),
//                   _buildWhatToExpectCard(),
//                   const SizedBox(height: 24),
//                   _buildTipsCard(),
//                   const SizedBox(height: 32),
//                   _buildActionButtons(),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _buildIntroCard() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Colors.blue.shade700,
//               Colors.indigo.shade900,
//             ],
//           ),
//         ),
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.account_balance, color: Colors.white, size: 32),
//                 const SizedBox(width: 12),
//                 Text(
//                   context.l10n.interviewSimulation,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Text(
//               context.l10n.interviewIntroDescription,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.white.withOpacity(0.9),
//                 fontSize: 16,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildOfficerCard() {
//     return Card(
//       elevation: 3,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.person, color: Colors.blue.shade700),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Görüşme Memurunuz', // Sabit metin kullandık
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue.shade700,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: 40,
//                   backgroundColor: Colors.grey.shade200,
//                   backgroundImage: AssetImage(_officer.avatarImagePath),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         _officer.name,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         _officer.position,
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey.shade700,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       OutlinedButton.icon(
//                         icon: const Icon(Icons.refresh, size: 16),
//                         label: const Text('Memuru Değiştir'), // Sabit metin kullandık
//                         style: OutlinedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                           textStyle: const TextStyle(fontSize: 12),
//                         ),
//                         onPressed: () {
//                           widget.interviewService.changeOfficer();
//                           setState(() {
//                             _officer = widget.interviewService.getCurrentOfficer();
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildWhatToExpectCard() {
//     return Card(
//       elevation: 3,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.info_outline, color: Colors.blue.shade700),
//                 const SizedBox(width: 8),
//                 Text(
//                   context.l10n.whatToExpect,
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue.shade700,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             _buildExpectationItem(
//               Icons.question_answer,
//               context.l10n.civicsQuestions,
//               context.l10n.civicsQuestionsDesc,
//             ),
//             const SizedBox(height: 12),
//             _buildExpectationItem(
//               Icons.person_outline,
//               context.l10n.personalQuestions,
//               context.l10n.personalQuestionsDesc,
//             ),
//             const SizedBox(height: 12),
//             _buildExpectationItem(
//               Icons.description_outlined,
//               context.l10n.formReview,
//               context.l10n.formReviewDesc,
//             ),
//             const SizedBox(height: 12),
//             _buildExpectationItem(
//               Icons.menu_book,
//               context.l10n.englishTest,
//               context.l10n.englishTestDesc,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildExpectationItem(IconData icon, String title, String description) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: Colors.blue.shade50,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(icon, color: Colors.blue.shade700, size: 24),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 description,
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey.shade700,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTipsCard() {
//     return Card(
//       elevation: 3,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.lightbulb_outline, color: Colors.orange),
//                 const SizedBox(width: 8),
//                 Text(
//                   context.l10n.interviewTips,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.orange,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             _buildTipItem(context.l10n.tipSpeak),
//             _buildTipItem(context.l10n.tipListen),
//             _buildTipItem(context.l10n.tipAnswer),
//             _buildTipItem(context.l10n.tipStay),
//             _buildTipItem(context.l10n.tipDress),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTipItem(String tip) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             '• ',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.orange,
//             ),
//           ),
//           Expanded(
//             child: Text(
//               tip,
//               style: const TextStyle(fontSize: 14),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButtons() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         ElevatedButton.icon(
//           icon: const Icon(Icons.play_circle_fill),
//           label: Text(
//             context.l10n.startInterview,
//             style: const TextStyle(fontSize: 18),
//           ),
//           style: ElevatedButton.styleFrom(
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(30),
//             ),
//             backgroundColor: Colors.green,
//           ),
//           onPressed: () => _startInterview(),
//         ),
//         const SizedBox(height: 12),
//         OutlinedButton.icon(
//           icon: const Icon(Icons.settings),
//           label: Text(
//             context.l10n.interviewSettings,
//             style: const TextStyle(fontSize: 16),
//           ),
//           style: OutlinedButton.styleFrom(
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(30),
//             ),
//           ),
//           onPressed: () => _navigateToSettings(),
//         ),
//         const SizedBox(height: 12),
//         TextButton.icon(
//           icon: const Icon(Icons.history),
//           label: Text(
//             context.l10n.pastInterviews,
//             style: const TextStyle(fontSize: 16),
//           ),
//           onPressed: () => _navigateToPastInterviews(),
//         ),
//       ],
//     );
//   }

//   void _startInterview() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => InterviewSimulationScreen(
//           interviewService: widget.interviewService,
//         ),
//       ),
//     ).then((_) => _loadData());
//   }

//   void _navigateToSettings() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => InterviewSettingsScreen(
//           interviewService: widget.interviewService,
//           initialSettings: _settings,
//         ),
//       ),
//     ).then((_) => _loadData());
//   }

//   void _navigateToPastInterviews() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => PastInterviewsScreen(
//           interviewService: widget.interviewService,
//         ),
//       ),
//     );
//   }
// }
