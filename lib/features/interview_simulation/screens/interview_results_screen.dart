// import 'package:flutter/material.dart';
// import '../models/interview_models.dart';
// import '../services/interview_service.dart';
// import '../../../utils/extensions.dart';

// class InterviewResultsScreen extends StatelessWidget {
//   final InterviewService interviewService;
//   final InterviewSession session;

//   const InterviewResultsScreen({
//     Key? key,
//     required this.interviewService,
//     required this.session,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(context.l10n.interviewResults),
//         automaticallyImplyLeading: false,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             _buildResultSummary(context),
//             const SizedBox(height: 24),
//             _buildScoreCard(context),
//             const SizedBox(height: 24),
//             _buildResponsesList(context),
//             const SizedBox(height: 32),
//             _buildActionButtons(context),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildResultSummary(BuildContext context) {
//     final bool isPassed = session.isPassed;
    
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       color: isPassed ? Colors.green.shade50 : Colors.red.shade50,
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           children: [
//             Icon(
//               isPassed ? Icons.check_circle : Icons.cancel,
//               size: 64,
//               color: isPassed ? Colors.green : Colors.red,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               isPassed ? context.l10n.interviewPassed : context.l10n.interviewFailed,
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: isPassed ? Colors.green.shade800 : Colors.red.shade800,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               isPassed
//                   ? context.l10n.interviewPassedDesc
//                   : context.l10n.interviewFailedDesc,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: isPassed ? Colors.green.shade700 : Colors.red.shade700,
//               ),
//             ),
//             const SizedBox(height: 16),
//             if (isPassed)
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.green.shade200),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Image.asset(
//                       'assets/images/certificates/citizenship_badge.png',
//                       width: 36,
//                       height: 36,
//                     ),
//                     const SizedBox(width: 12),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           context.l10n.badgeEarned,
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Text(
//                           context.l10n.interviewSimulationBadge,
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey.shade700,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildScoreCard(BuildContext context) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               context.l10n.interviewStats,
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue.shade800,
//               ),
//             ),
//             const SizedBox(height: 16),
//             _buildStatRow(
//               context,
//               context.l10n.correctAnswers,
//               '${session.correctAnswers}/${session.totalQuestions}',
//               Icons.check_circle_outline,
//             ),
//             const Divider(height: 24),
//             _buildStatRow(
//               context,
//               context.l10n.successRate,
//               context.l10n.successRateFormatted('${session.successRate.toStringAsFixed(1)}'),
//               Icons.percent,
//             ),
//             const Divider(height: 24),
//             _buildStatRow(
//               context,
//               context.l10n.interviewDuration,
//               '${session.durationInMinutes} ${context.l10n.minutes}',
//               Icons.timer_outlined,
//             ),
//             const Divider(height: 24),
//             _buildStatRow(
//               context,
//               context.l10n.interviewOfficer,
//               session.officerName ?? 'Unknown',
//               Icons.person_outline,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatRow(
//     BuildContext context,
//     String label,
//     String value,
//     IconData icon,
//   ) {
//     return Row(
//       children: [
//         Icon(icon, color: Colors.blue.shade700, size: 24),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Text(
//             label,
//             style: const TextStyle(fontSize: 16),
//           ),
//         ),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildResponsesList(BuildContext context) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               context.l10n.yourResponses,
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue.shade800,
//               ),
//             ),
//             const SizedBox(height: 16),
//             ListView.separated(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: session.responses.length,
//               separatorBuilder: (context, index) => const Divider(height: 32),
//               itemBuilder: (context, index) {
//                 final response = session.responses[index];
//                 return _buildResponseItem(context, response, index);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildResponseItem(
//     BuildContext context,
//     InterviewResponse response,
//     int index,
//   ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Container(
//               width: 28,
//               height: 28,
//               decoration: BoxDecoration(
//                 color: response.isCorrect ? Colors.green : Colors.red,
//                 shape: BoxShape.circle,
//               ),
//               child: Center(
//                 child: Icon(
//                   response.isCorrect ? Icons.check : Icons.close,
//                   color: Colors.white,
//                   size: 18,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 context.l10n.questionNumber(index + 1),
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             if (response.responseTimeInSeconds != null)
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade200,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   '${response.responseTimeInSeconds} ${context.l10n.sec}',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey.shade700,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.grey.shade100,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Text(
//             response.userResponse,
//             style: const TextStyle(fontSize: 14),
//           ),
//         ),
//         if (response.officerFeedback != null) ...[
//           const SizedBox(height: 8),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Icon(Icons.feedback_outlined, size: 16, color: Colors.grey),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   response.officerFeedback!,
//                   style: TextStyle(
//                     fontSize: 13,
//                     fontStyle: FontStyle.italic,
//                     color: Colors.grey.shade700,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ],
//     );
//   }

//   Widget _buildActionButtons(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         ElevatedButton.icon(
//           icon: const Icon(Icons.home),
//           label: Text(
//             context.l10n.returnToHome,
//             style: const TextStyle(fontSize: 16),
//           ),
//           style: ElevatedButton.styleFrom(
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(30),
//             ),
//           ),
//           onPressed: () => _returnToHome(context),
//         ),
//         const SizedBox(height: 12),
//         OutlinedButton.icon(
//           icon: const Icon(Icons.replay),
//           label: Text(
//             context.l10n.startNewInterview,
//             style: const TextStyle(fontSize: 16),
//           ),
//           style: OutlinedButton.styleFrom(
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(30),
//             ),
//           ),
//           onPressed: () => _startNewInterview(context),
//         ),
//         const SizedBox(height: 12),
//         TextButton.icon(
//           icon: const Icon(Icons.share),
//           label: Text(
//             context.l10n.shareResults,
//             style: const TextStyle(fontSize: 16),
//           ),
//           onPressed: () => _shareResults(context),
//         ),
//       ],
//     );
//   }

//   void _returnToHome(BuildContext context) {
//     // Ana sayfaya dön (tüm mülakat ekranlarını kapat)
//     Navigator.of(context).popUntil((route) => route.isFirst);
//   }

//   void _startNewInterview(BuildContext context) {
//     // Sonuç ekranını kapat ve geri dön (intro ekranına)
//     Navigator.of(context).pop();
//   }

//   void _shareResults(BuildContext context) {
//     // Paylaşım fonksiyonu (demo için bir bildirim göster)
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(context.l10n.comingSoon)),
//     );
//   }
// }
