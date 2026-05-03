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

  static final Map<String, Map<String, String>> _translations = {
    'English (EN)': {
      'app_title': 'Borrow Manager',
      'welcome_back': 'Welcome Back',
      'settings': 'Settings',
      'reminders': 'Reminders',
      'save': 'Save',
      'cancel': 'Cancel',
      'sms': 'SMS',
      'call': 'Call',
      'delete': 'Delete',
      'overdue': 'OVERDUE',
      'upcoming': 'UPCOMING',
      'add_reminder': 'Add Reminder',
      'no_reminders': 'No reminders set',
      'keep_track_reminders': 'Keep track of your payments with reminders',
      'done': 'Done',
      'backup_title': 'Backup & Restore',
      'google_drive_desc': 'Backup your data to Google Drive',
      'backup_now': 'Backup Now',
      'restore_now': 'Restore Now',
      'backup_success': 'Backup successful!',
      'backup_failed': 'Backup failed. Please try again.',
      'restore_success': 'Restore successful! Please restart the app.',
      'restore_failed': 'Restore failed or no backup found.',
      'restore_confirm': 'This will overwrite your current data. Continue?',
    },
    'Hindi (हिन्दी)': {
      'app_title': 'उधार मैनेजर',
      'welcome_back': 'स्वागत है',
      'settings': 'सेटिंग्स',
      'reminders': 'अनुस्मारक',
      'save': 'सहेजें',
      'cancel': 'रद्द करें',
      'sms': 'एसएमएस',
      'call': 'कॉल',
      'delete': 'हटाएं',
      'overdue': 'विलंबित',
      'upcoming': 'आगामी',
      'add_reminder': 'अनुस्मारक जोड़ें',
      'no_reminders': 'कोई अनुस्मारक नहीं',
      'keep_track_reminders': 'अनुस्मारक के साथ अपने भुगतान पर नज़र रखें',
      'done': 'हो गया',
      'backup_title': 'बैकअप और पुनर्स्थापना',
      'google_drive_desc': 'अपना डेटा गूगल ड्राइव पर सुरक्षित करें',
      'backup_now': 'अभी बैकअप लें',
      'restore_now': 'अभी पुनर्स्थापित करें',
      'backup_success': 'बैकअप सफल रहा!',
      'backup_failed': 'बैकअप विफल रहा। कृपया पुनः प्रयास करें।',
      'restore_success': 'पुनर्स्थापना सफल! कृपया ऐप को पुनरारंभ करें।',
      'restore_failed': 'पुનर्स्थापना विफल रही या कोई बैकअप नहीं मिला।',
      'restore_confirm': 'यह आपके वर्तमान डेटा को बदल देगा। जारी रखें?',
    },
    'Marathi (मराठी)': {
      'app_title': 'उधार मॅनेजर',
      'welcome_back': 'स्वागत आहे',
      'settings': 'सेटिंग्ज',
      'reminders': 'स्मरणपत्रे',
      'save': 'जतन करा',
      'cancel': 'रद्द करा',
      'sms': 'एसएमएस',
      'call': 'कॉल',
      'delete': 'हटवा',
      'overdue': 'थकबाकी',
      'upcoming': 'आगाમી',
      'add_reminder': 'स्मरणपत्र जोडा',
      'no_reminders': 'कोणतेही स्मरणपत्र नाही',
      'keep_track_reminders': 'स्मरणपत्रांसह तुमच्या देयकांचा मागोवा ठेवा',
      'done': 'झाले',
      'backup_title': 'बॅकअप आणि पुनर्संचयित',
      'google_drive_desc': 'तुमचा डेटा गूगल ड्राइव्हवर सुरक्षित करा',
      'backup_now': 'आता बॅકअप घ्या',
      'restore_now': 'आता पुनर्संचयित करा',
      'backup_success': 'बॅकअप यशस्वी!',
      'backup_failed': 'बॅकअप अयशस्वी. कृपया पुन्हा प्रयत्न करा.',
      'restore_success': 'पुनर्संचयित यशस्वी! कृपया अॅप पुन्हा सुरू करा.',
      'restore_failed': 'पुनर्संचयित अयशस्वी किंवा कोणताही बॅकअप सापडला नाही.',
      'restore_confirm': 'हे तुमचा सध्याचा डेटा ओव्हरराईट करेल. सुरू ठेवायचे?',
    },
    'Gujarati (ગુજરાતી)': {
      'app_title': 'ઉધાર મેનેજર',
      'welcome_back': 'સ્વાગત છે',
      'settings': 'સેટિંગ્સ',
      'reminders': 'રિમાઇન્ડર્સ',
      'save': 'સાચવો',
      'cancel': 'રદ કરો',
      'sms': 'એસએમએસ',
      'call': 'કોલ',
      'delete': 'કાઢી નાખો',
      'overdue': 'બાકી',
      'upcoming': 'આગામી',
      'add_reminder': 'રિમાઇન્ડર ઉમેરો',
      'no_reminders': 'કોઈ રિમાઇન્ડર નથી',
      'keep_track_reminders': 'રિમાઇન્ડર્સ સાથે તમારા પેમેન્ટ પર નજર રાખો',
      'done': 'થઈ ગયું',
      'backup_title': 'બેકઅપ અને રીસ્ટોર',
      'google_drive_desc': 'તમારો ડેટા ગૂગલ ડ્રાઇવ પર સુરક્ષિત કરો',
      'backup_now': 'હમણાં બેકઅપ લો',
      'restore_now': 'હમણાં રીસ્ટોર કરો',
      'backup_success': 'બેકઅપ સફળ!',
      'backup_failed': 'બેકઅપ નિષ્ફળ. કૃપા કરીને ફરીથી પ્રયાસ કરો.',
      'restore_success': 'રીસ્ટોર સફળ! કૃપા કરીને એપ્લિકેશન ફરીથી પ્રારંભ કરો.',
      'restore_failed': 'રીસ્ટોર નિષ્ફળ થયું અથવા કોઈ બેકઅપ મળ્યું નથી.',
      'restore_confirm': 'આ તમારા વર્તમાન ડેટાને ઓવરરાઈટ કરશે. ચાલુ રાખવું?',
    }
  };

  String translate(String key) {
    return _translations[_currentLanguage]?[key] ?? _translations['English (EN)']?[key] ?? key;
  }
}
