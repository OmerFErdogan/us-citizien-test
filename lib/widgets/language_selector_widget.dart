import 'package:flutter/material.dart';
import '../services/settings/language_service.dart';
import '../utils/extensions.dart';

class LanguageSelectorWidget extends StatelessWidget {
  final bool inAppBar;
  final Color? iconColor;
  final bool showBorder;
  final double iconSize;
  
  const LanguageSelectorWidget({
    Key? key, 
    this.inAppBar = true,
    this.iconColor,
    this.showBorder = true,
    this.iconSize = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageService = LanguageService();

    return ValueListenableBuilder<Locale>(
      valueListenable: languageService.currentLocale,
      builder: (context, locale, _) {
        return PopupMenuButton<String>(
          tooltip: context.l10n.changeLanguage,
          onSelected: (code) async {
            await languageService.changeLanguage(code);
          },
          // AppBar'da ise belirgin bir ikon oluştur
          icon: inAppBar
              ? Icon(
                  Icons.language,
                  color: Colors.blue.shade800,
                  size: 24, // Daha büyük ikon
                )
              : null,
          // Belirginliği artırmak için ek özellikler
          padding: EdgeInsets.zero, // Tıklama alanını artır
          iconSize: 24,
          splashRadius: 24,
          enableFeedback: true, // Dokunma geri bildirimi sağla
          // AppBar'da değilse, özel bir buton görünümü uygula
          child: !inAppBar
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: showBorder ? Border.all(color: Colors.white.withOpacity(0.7)) : null,
                    color: Colors.blue.withOpacity(0.15),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.language, size: iconSize, color: iconColor ?? Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        '${_getLanguageFlag(locale.languageCode)} ${languageService.getLanguageName(locale.languageCode)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: iconColor ?? Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : null,
          itemBuilder: (context) {
            return languageService.supportedLanguages
                .map((language) => PopupMenuItem<String>(
                      value: language['code'],
                      child: Row(
                        children: [
                          Text(
                            _getLanguageFlag(language['code']!),
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 8),
                          Text(language['name']!),
                          const SizedBox(width: 8),
                          if (language['code'] == locale.languageCode)
                            const Icon(Icons.check, color: Colors.green),
                        ],
                      ),
                    ))
                .toList();
          },
        );
      },
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
