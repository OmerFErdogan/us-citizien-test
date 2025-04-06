import 'package:flutter/material.dart';

class CategoryProgressChart extends StatelessWidget {
  final Map<String, Map<String, dynamic>> categoryStats;
  final int maxCategoriesToShow;

  const CategoryProgressChart({
    Key? key,
    required this.categoryStats,
    this.maxCategoriesToShow = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Gösterilecek kategori sayısını sınırla
    final categoriesToShow = categoryStats.entries
        .take(maxCategoriesToShow)
        .toList();

    return categoriesToShow.isEmpty
        ? const Center(child: Text('Henüz kategori verisi bulunmamaktadır.'))
        : LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Grafik başlığı
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Kategori',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            'Başarı Oranı',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Grafikler
                  Expanded(
                    child: ListView.builder(
                      itemCount: categoriesToShow.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final entry = categoriesToShow[index];
                        final category = entry.key;
                        final stats = entry.value;
                        
                        final successRate = stats['successRate'] as double;
                        final attemptedCount = stats['attemptedCount'] as int;
                        final totalCount = stats['totalCount'] as int;
                        
                        // Kategorinin kısaltılmış adı (eğer çok uzunsa)
                        final shortCategoryName = category.length > 15
                            ? '${category.substring(0, 15)}...'
                            : category;
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              // Kategori adı
                              Expanded(
                                flex: 2,
                                child: Text(
                                  shortCategoryName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              
                              // Bar chart
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      children: [
                                        // Gri arkaplan bar
                                        Container(
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                        
                                        // Renkli ilerleme barı
                                        FractionallySizedBox(
                                          widthFactor: successRate.clamp(0.0, 1.0),
                                          child: Container(
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: _getColorForScore(successRate * 100),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                        
                                        // İstatistik metni
                                        Positioned.fill(
                                          child: Center(
                                            child: Text(
                                              '%${(successRate * 100).toStringAsFixed(1)} ($attemptedCount/$totalCount)',
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Daha fazla kategori varsa bilgi göster
                  if (categoryStats.length > maxCategoriesToShow)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '+ ${categoryStats.length - maxCategoriesToShow} daha fazla kategori',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              );
            },
          );
  }

  Color _getColorForScore(double score) {
    if (score >= 90) return Colors.green[700]!;
    if (score >= 80) return Colors.green;
    if (score >= 70) return Colors.blue;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}