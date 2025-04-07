import 'package:flutter/material.dart';
import '../services/settings/language_service.dart';
import '../utils/extensions.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  _LanguageSelectionScreenState createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final LanguageService _languageService = LanguageService();
  late String _currentLanguageCode;

  @override
  void initState() {
    super.initState();
    _currentLanguageCode = _languageService.currentLanguageCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.language),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              context.l10n.selectLanguage,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: _languageService.supportedLanguages.length,
              itemBuilder: (context, index) {
                final language = _languageService.supportedLanguages[index];
                final isSelected = language['code'] == _currentLanguageCode;
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: isSelected ? 4 : 1,
                  child: InkWell(
                    onTap: () {
                      _selectLanguage(language['code']!);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected 
                            ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                            : null,
                      ),
                      child: Row(
                        children: [
                          _buildFlagIcon(language['code']!),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              language['name']!,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected 
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(context.l10n.save),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlagIcon(String languageCode) {
    // Return appropriate flag icon based on language code
    switch (languageCode) {
      case 'en':
        return Image.asset(
          'assets/images/american_flag_icon.png',
          width: 32,
          height: 32,
        );
      case 'es':
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipOval(
            child: Text(
              '🇪🇸',
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
          ),
        );
      case 'tr':
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipOval(
            child: Text(
              '🇹🇷',
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
          ),
        );
      default:
        return const Icon(Icons.language, size: 32);
    }
  }

  void _selectLanguage(String languageCode) async {
    setState(() {
      _currentLanguageCode = languageCode;
    });
    
    // Change the app language
    await _languageService.changeLanguage(languageCode);
    
    // Show a confirmation message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.languageChanged),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}
