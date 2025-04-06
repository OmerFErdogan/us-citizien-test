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
      padding: const EdgeInsets.all(16.0),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final question = questions[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: Text(
                question.question,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Kategori: ${question.category}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red[300]!, width: 1),
                ),
                child: const Center(
                  child: Icon(Icons.warning_amber, color: Colors.red, size: 20),
                ),
              ),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              childrenPadding: const EdgeInsets.all(16.0),
              children: [
                const Divider(),
                const SizedBox(height: 8),
                
                // Doğru cevaplar
                const Text(
                  'Doğru Cevap:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                
                ...question.allCorrectAnswers.map((correctAnswer) => 
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(correctAnswer),
                        ),
                      ],
                    ),
                  )
                ),
                
                const SizedBox(height: 12),
                
                // Sizin cevabınız
                if (question.selectedAnswer != null) ...[
                  const Text(
                    'Sizin Cevabınız:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.cancel,
                        color: Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          question.selectedAnswer!,
                          style: const TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Pratik yapmak için buton
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Bu soruyu pratik etmek için Flashcard veya Quiz ekranına yönlendirme eklenebilir
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bu özellik yakında eklenecek')),
                    );
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Bu Soruyu Pratik Et'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}