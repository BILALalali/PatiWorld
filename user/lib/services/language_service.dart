import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';

  Locale _currentLocale = const Locale('tr'); // Default to Turkish

  Locale get currentLocale => _currentLocale;

  String get currentLanguageCode => _currentLocale.languageCode;

  bool get isEnglish => _currentLocale.languageCode == 'en';
  bool get isTurkish => _currentLocale.languageCode == 'tr';

  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('tr', ''), // Turkish
  ];

  // Initialize language service
  Future<void> initialize() async {
    await _loadSavedLanguage();
  }

  // Load saved language from SharedPreferences
  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguageCode = prefs.getString(_languageKey);

      if (savedLanguageCode != null) {
        _currentLocale = Locale(savedLanguageCode);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading saved language: $e');
      // Keep default language (Turkish)
    }
  }

  // Change language
  Future<void> changeLanguage(String languageCode) async {
    if (languageCode == _currentLocale.languageCode) return;

    _currentLocale = Locale(languageCode);
    notifyListeners();

    // Save to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
    } catch (e) {
      debugPrint('Error saving language: $e');
    }
  }

  // Change to English
  Future<void> setEnglish() async {
    await changeLanguage('en');
  }

  // Change to Turkish
  Future<void> setTurkish() async {
    await changeLanguage('tr');
  }

  // Get language name for display
  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'tr':
        return 'Türkçe';
      default:
        return languageCode;
    }
  }

  // Get current language name
  String get currentLanguageName =>
      getLanguageName(_currentLocale.languageCode);

  // Check if language is supported
  bool isLanguageSupported(String languageCode) {
    return supportedLocales.any(
      (locale) => locale.languageCode == languageCode,
    );
  }
}
