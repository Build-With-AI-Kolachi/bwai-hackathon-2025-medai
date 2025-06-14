import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  String _selectedLanguage = 'English';
  String _languageCode = 'en';

  String get selectedLanguage => _selectedLanguage;
  String get languageCode => _languageCode;

  void setLanguage(String name, String code) {
    _selectedLanguage = name;
    _languageCode = code;
    notifyListeners();
  }
}
