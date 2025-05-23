import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Global localization provider 
class AppLocalizationsProvider {
  // Singleton pattern
  static final AppLocalizationsProvider _instance = AppLocalizationsProvider._internal();
  
  factory AppLocalizationsProvider() {
    return _instance;
  }
  
  AppLocalizationsProvider._internal();

  // Current locale
  Locale _currentLocale = const Locale('en');
  
  // Current AppLocalizations instance
  AppLocalizations? _appLocalizations;

  // Initialize with a given locale
  Future<void> initialize(Locale locale) async {
    _currentLocale = locale;
    
    // AppLocalizations'u oluştur
    try {
      _appLocalizations = await AppLocalizations.delegate.load(locale);
    } catch (e) {
      print('Error initializing AppLocalizations: $e');
      // Fallback to English
      _appLocalizations = await AppLocalizations.delegate.load(const Locale('en'));
    }
  }

  // Get current AppLocalizations
  AppLocalizations? get localizations => _appLocalizations;

  // Get current locale
  Locale get currentLocale => _currentLocale;

  // Update locale
  Future<void> updateLocale(Locale locale) async {
    await initialize(locale);
  }
}

// Global instance for easy access
final appLocalizationsProvider = AppLocalizationsProvider();
