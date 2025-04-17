// import 'package:flutter/material.dart';
// import '../models/interview_models.dart';
// import '../services/interview_service.dart';
// import '../../../utils/extensions.dart';

// class InterviewSettingsScreen extends StatefulWidget {
//   final InterviewService interviewService;
//   final InterviewSettings initialSettings;

//   const InterviewSettingsScreen({
//     Key? key,
//     required this.interviewService,
//     required this.initialSettings,
//   }) : super(key: key);

//   @override
//   _InterviewSettingsScreenState createState() => _InterviewSettingsScreenState();
// }

// class _InterviewSettingsScreenState extends State<InterviewSettingsScreen> {
//   late InterviewSettings _settings;
//   bool _isSaving = false;

//   @override
//   void initState() {
//     super.initState();
//     _settings = widget.initialSettings;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(context.l10n.interviewSettings),
//         actions: [
//           _isSaving
//               ? const Padding(
//                   padding: EdgeInsets.all(16.0),
//                   child: SizedBox(
//                     height: 24,
//                     width: 24,
//                     child: CircularProgressIndicator(color: Colors.white),
//                   ),
//                 )
//               : IconButton(
//                   icon: const Icon(Icons.save),
//                   tooltip: context.l10n.save,
//                   onPressed: _saveSettings,
//                 ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildSectionTitle(context.l10n.generalSettings),
//             const SizedBox(height: 8),
//             _buildQuestionCountSetting(),
//             const Divider(height: 24),
            
//             _buildSectionTitle(context.l10n.contentSettings),
//             const SizedBox(height: 8),
//             _buildSwitchSetting(
//               title: context.l10n.includePersonalQuestions,
//               subtitle: context.l10n.includePersonalQuestionsDesc,
//               value: _settings.includePersonalQuestions,
//               onChanged: (value) {
//                 setState(() {
//                   _settings = _settings.copyWith(includePersonalQuestions: value);
//                 });
//               },
//             ),
//             _buildSwitchSetting(
//               title: context.l10n.includeN400Questions,
//               subtitle: context.l10n.includeN400QuestionsDesc,
//               value: _settings.includeN400Questions,
//               onChanged: (value) {
//                 setState(() {
//                   _settings = _settings.copyWith(includeN400Questions: value);
//                 });
//               },
//             ),
//             const Divider(height: 24),
            
//             _buildSectionTitle(context.l10n.difficultySettings),
//             const SizedBox(height: 8),
//             _buildSwitchSetting(
//               title: context.l10n.strictMode,
//               subtitle: context.l10n.strictModeDesc,
//               value: _settings.useStrictMode,
//               onChanged: (value) {
//                 setState(() {
//                   _settings = _settings.copyWith(useStrictMode: value);
//                 });
//               },
//             ),
//             _buildSwitchSetting(
//               title: context.l10n.timedResponses,
//               subtitle: context.l10n.timedResponsesDesc,
//               value: _settings.useTimedResponses,
//               onChanged: (value) {
//                 setState(() {
//                   _settings = _settings.copyWith(useTimedResponses: value);
//                 });
//               },
//             ),
//             const Divider(height: 24),
            
//             _buildSectionTitle(context.l10n.accessibilitySettings),
//             const SizedBox(height: 8),
//             _buildSwitchSetting(
//               title: context.l10n.useAudio,
//               subtitle: context.l10n.useAudioDesc,
//               value: _settings.useAudio,
//               onChanged: (value) {
//                 setState(() {
//                   _settings = _settings.copyWith(useAudio: value);
//                 });
//               },
//             ),
//             _buildSwitchSetting(
//               title: context.l10n.useVoiceInput,
//               subtitle: context.l10n.useVoiceInputDesc,
//               value: _settings.useVoiceInput,
//               onChanged: (value) {
//                 setState(() {
//                   _settings = _settings.copyWith(useVoiceInput: value);
//                 });
//               },
//             ),
//             const SizedBox(height: 24),
            
//             _buildResetButton(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Text(
//       title,
//       style: TextStyle(
//         fontSize: 18,
//         fontWeight: FontWeight.bold,
//         color: Colors.blue.shade800,
//       ),
//     );
//   }

//   Widget _buildQuestionCountSetting() {
//     return Card(
//       elevation: 0,
//       color: Colors.grey.shade100,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               context.l10n.questionCount,
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               context.l10n.questionCountDesc,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey.shade700,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('5', style: TextStyle(color: Colors.grey.shade700)),
//                 Expanded(
//                   child: Slider(
//                     value: _settings.questionCount.toDouble(),
//                     min: 5,
//                     max: 20,
//                     divisions: 15,
//                     label: _settings.questionCount.toString(),
//                     onChanged: (value) {
//                       setState(() {
//                         _settings = _settings.copyWith(
//                           questionCount: value.round(),
//                         );
//                       });
//                     },
//                   ),
//                 ),
//                 Text('20', style: TextStyle(color: Colors.grey.shade700)),
//               ],
//             ),
//             Center(
//               child: Text(
//                 '${_settings.questionCount} ${context.l10n.questions}',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSwitchSetting({
//     required String title,
//     required String subtitle,
//     required bool value,
//     required ValueChanged<bool> onChanged,
//   }) {
//     return Card(
//       elevation: 0,
//       color: Colors.grey.shade100,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: SwitchListTile(
//         title: Text(
//           title,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         subtitle: Text(
//           subtitle,
//           style: TextStyle(
//             fontSize: 14,
//             color: Colors.grey.shade700,
//           ),
//         ),
//         value: value,
//         onChanged: onChanged,
//         activeColor: Colors.blue.shade700,
//         contentPadding: const EdgeInsets.all(16),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//     );
//   }

//   Widget _buildResetButton() {
//     return Center(
//       child: TextButton.icon(
//         icon: const Icon(Icons.restore, color: Colors.red),
//         label: Text(
//           context.l10n.resetToDefault,
//           style: const TextStyle(color: Colors.red),
//         ),
//         onPressed: _resetSettings,
//       ),
//     );
//   }

//   void _resetSettings() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(context.l10n.resetSettings),
//         content: Text(context.l10n.resetSettingsConfirm),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(context.l10n.cancel),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               setState(() {
//                 _settings = const InterviewSettings();
//               });
//             },
//             child: Text(context.l10n.reset),
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _saveSettings() async {
//     setState(() {
//       _isSaving = true;
//     });

//     try {
//       await widget.interviewService.saveSettings(_settings);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(context.l10n.settingsSaved)),
//         );
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('${context.l10n.errorSavingSettings}: $e')),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isSaving = false;
//         });
//       }
//     }
//   }
// }
