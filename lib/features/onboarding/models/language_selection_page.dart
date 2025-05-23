import 'package:flutter/material.dart';
import '../../../services/settings/language_service.dart';
import '../../../utils/extensions.dart';

class LanguageSelectionPage extends StatelessWidget {
  final Function() onLanguageSelected;
  
  const LanguageSelectionPage({
    Key? key,
    required this.onLanguageSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageService = LanguageService();
    final languages = languageService.supportedLanguages;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF041E42), // Koyu mavi (ABD bayrağı)
            const Color(0xFF0A3161), // Orta mavi
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Dil seçimi başlığı
          Text(
            context.l10n.languageSelectionTitle,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          
          // Alt başlık
          Text(
            context.l10n.languageSelectionSubtitle,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),
          
          // ABD bayrağı ikonu
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 10,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/flag.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 40),
          
          // Desteklenen dil butonları
          // Dil seçenekleri için bir ValueNotifier kullanalım
          ValueListenableBuilder<Locale>(
            valueListenable: languageService.currentLocale,
            builder: (context, currentLocale, _) {
              return Column(
                children: [
                  ...languages.map((language) {
                    final isSelected = currentLocale.languageCode == language['code'];
                    final flagEmoji = _getLanguageFlag(language['code']!);
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildLanguageButton(
                        context,
                        flagEmoji,
                        language['name']!,
                        language['code']!,
                        isSelected,
                        () async {
                          await languageService.changeLanguage(language['code']!);
                          // Devam butonuna basılana kadar bekle
                        },
                      ),
                    );
                  }).toList(),
                  
                  const SizedBox(height: 24),
                  
                  // Devam butonu
                  ElevatedButton(
                    onPressed: () {
                      // Dil seçildiğinde bir sonraki ekrana geç
                      onLanguageSelected();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF041E42),
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 5,
                    ),
                    child: Text(
                      context.l10n.continueButton,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 20),
          
          // Alt bilgi notu
          Text(
            context.l10n.languageNote,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  // Dil seçim butonu
  Widget _buildLanguageButton(
    BuildContext context,
    String flag, 
    String name, 
    String code,
    bool isSelected,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected 
            ? const Color(0xFFBF0A30) // Seçili ise kırmızı (ABD bayrağı kırmızısı)
            : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? const Color(0xFFBF0A30) : Colors.grey.shade300,
            width: 2,
          ),
        ),
        elevation: isSelected ? 4 : 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(flag, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 16),
          Text(
            name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (isSelected) ...[
            const SizedBox(width: 12),
            const Icon(Icons.check_circle, color: Colors.white),
          ],
        ],
      ),
    );
  }

  // Dil koduna göre bayrak emojisi döndürür
  String _getLanguageFlag(String code) {
    switch (code) {
      case 'en':
        return '🇺🇸';
      case 'es':
        return '🇪🇸';
      case 'tr':
        return '🇹🇷';
      default:
        return '🇺🇸';
    }
  }
}
