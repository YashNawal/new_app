import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  String _currentLanguage = 'English (EN)';
  
  String get currentLanguage => _currentLanguage;

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('language') ?? 'English (EN)';
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _currentLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    notifyListeners();
  }

  String translate(String key) {
    // Basic translation map for demonstration. 
    // In a real app, this would load from JSON files or a more robust system.
    final Map<String, Map<String, String>> translations = {
      'English (EN)': {
        'no_contacts': 'No contacts found',
        'select_client': 'Select Client',
        'amount': 'Amount',
        'date': 'Date',
        'note': 'Note',
      },
      'Hindi (HI)': {
        'no_contacts': 'कोई संपर्क नहीं मिला',
        'select_client': 'ग्राहक चुनें',
        'amount': 'रकम',
        'date': 'तारीख',
        'note': 'नोट',
      },
    };

    return translations[_currentLanguage]?[key] ?? key;
  }
}
