// import 'package:flutter/material.dart';
// import '../models/interview_models.dart';
// import '../services/interview_service.dart';
// import 'interview_results_screen.dart';
// import '../../../utils/extensions.dart';

// class PastInterviewsScreen extends StatefulWidget {
//   final InterviewService interviewService;

//   const PastInterviewsScreen({
//     Key? key,
//     required this.interviewService,
//   }) : super(key: key);

//   @override
//   _PastInterviewsScreenState createState() => _PastInterviewsScreenState();
// }

// class _PastInterviewsScreenState extends State<PastInterviewsScreen> {
//   late List<InterviewSession> _pastSessions;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadPastSessions();
//   }

//   Future<void> _loadPastSessions() async {
//     setState(() {
//       _isLoading = true;
//     });

//     _pastSessions = widget.interviewService.getPastSessions();
//     _pastSessions.sort((a, b) => b.date.compareTo(a.date)); // En yeni en üstte

//     setState(() {
//       _isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(context.l10n.pastInterviews),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _pastSessions.isEmpty
//               ? _buildEmptyState()
//               : _buildSessionsList(),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.history, size: 64, color: Colors.grey.shade400),
//           const SizedBox(height: 16),
//           Text(
//             context.l10n.noPastInterviews,
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey.shade600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             context.l10n.completeInterviewToSee,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey.shade600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSessionsList() {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: _pastSessions.length,
//       itemBuilder: (context, index) {
//         final session = _pastSessions[index];
//         final successRate = session.successRate.toStringAsFixed(0);
//         final isPassed = session.isPassed;
        
//         return Card(
//           margin: const EdgeInsets.only(bottom: 16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//             side: BorderSide(
//               color: isPassed ? Colors.green.shade200 : Colors.red.shade200,
//               width: 1,
//             ),
//           ),
//           child: InkWell(
//             onTap: () => _viewSessionDetails(session),
//             borderRadius: BorderRadius.circular(12),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         _formatDate(session.date),
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.grey.shade700,
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: isPassed ? Colors.green.shade50 : Colors.red.shade50,
//                           borderRadius: BorderRadius.circular(30),
//                           border: Border.all(
//                             color: isPassed ? Colors.green.shade300 : Colors.red.shade300,
//                           ),
//                         ),
//                         child: Text(
//                           isPassed ? context.l10n.passed : context.l10n.failed,
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
//                             color: isPassed ? Colors.green.shade700 : Colors.red.shade700,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   Row(
//                     children: [
//                       _buildStatItem(
//                         Icons.check_circle_outline,
//                         '${session.correctAnswers}/${session.totalQuestions}',
//                         context.l10n.correctAnswers,
//                       ),
//                       const SizedBox(width: 24),
//                       _buildStatItem(
//                         Icons.percent,
//                         '$successRate%',
//                         context.l10n.successRate,
//                       ),
//                       const SizedBox(width: 24),
//                       _buildStatItem(
//                         Icons.timer_outlined,
//                         '${session.durationInMinutes} ${context.l10n.minutes}',
//                         context.l10n.duration,
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     '${context.l10n.interviewWith}: ${session.officerName}',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey.shade700,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildStatItem(IconData icon, String value, String label) {
//     return Expanded(
//       child: Column(
//         children: [
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(icon, size: 16, color: Colors.blue.shade700),
//               const SizedBox(width: 4),
//               Text(
//                 value,
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blue.shade700,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey.shade600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     // Basit formatlama, gerekirse intl paketi kullanılabilir
//     return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
//   }

//   void _viewSessionDetails(InterviewSession session) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => InterviewResultsScreen(
//           interviewService: widget.interviewService,
//           session: session,
//         ),
//       ),
//     );
//   }
// }
