import 'package:flutter/material.dart';
import '../models/question.dart';

class DifficultQuestionsList extends StatelessWidget {
  final List<Question> questions;

  const DifficultQuestionsList({
    Key? key,
    required this.questions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final question = questions[index];
        return _buildQuestionCard(question, index + 1);
      },
    );
  }

  Widget _buildQuestionCard(Question question, int rank) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red[100],
          child: Text(
            rank.toString(),
            style: TextStyle(
              color: Colors.red[800],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          question.question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          question.category,
          style: const TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
        childrenPadding: const EdgeInsets.all(16.0),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const Text(
            'Doğru Cevap(lar):',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: question.allCorrectAnswers.map((answer) {
              return Chip(
                backgroundColor: Colors.green[100],
                label: Text(
                  answer,
                  style: TextStyle(
                    color: Colors.green[800],
                    fontSize: 13,
                  ),
                ),
              );
            }).toList(),
          ),
          if (question.selectedAnswer != null) ...[
            const SizedBox(height: 16),
            const Text(
              'Senin Cevabın:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Chip(
              backgroundColor: Colors.red[100],
              label: Text(
                question.selectedAnswer!,
                style: TextStyle(
                  color: Colors.red[800],
                  fontSize: 13,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Deneme Sayısı: ${question.attemptCount}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}