import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class LanguageService {
  static const String _languageKey = 'app_language';
  final ValueNotifier<Locale> _currentLocale = ValueNotifier<Locale>(const Locale('en'));

  // Singleton pattern
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  // Getter for current locale value notifier
  ValueNotifier<Locale> get currentLocale => _currentLocale;

  // Initialize the service and load saved language
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey);
      
      if (savedLanguage != null) {
        _currentLocale.value = Locale(savedLanguage);
      } else {
        // Use device locale if no saved preference
        final deviceLocale = WidgetsBinding.instance.window.locale;
        final languageCode = deviceLocale.languageCode;
        
        // Check if device language is supported, otherwise default to English
        if (['en', 'es', 'tr'].contains(languageCode)) {
          _currentLocale.value = Locale(languageCode);
          // Save this preference
          await prefs.setString(_languageKey, languageCode);
        }
      }
    } catch (e) {
      print('Error loading language preference: $e');
    }
  }

  // Get current language code
  String get currentLanguageCode => _currentLocale.value.languageCode;

  // Change language
  Future<void> changeLanguage(String languageCode) async {
    try {
      if (languageCode != _currentLocale.value.languageCode) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_languageKey, languageCode);
        _currentLocale.value = Locale(languageCode);
      }
    } catch (e) {
      print('Error saving language preference: $e');
    }
  }

  // Get language name from code
  String getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'tr':
        return 'Türkçe';
      default:
        return 'English';
    }
  }

  // Get supported languages
  List<Map<String, String>> get supportedLanguages => [
    {'code': 'en', 'name': 'English'},
    {'code': 'es', 'name': 'Español'},
    {'code': 'tr', 'name': 'Türkçe'},
  ];
}
