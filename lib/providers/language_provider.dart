/*import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale? _currentLocale;
  final List<Locale> _supportedLocales = const [
    Locale('en', 'US'), // English
    Locale('fr', 'FR'), // French
    Locale('ar', 'TN'), // Arabic (Tunisia)
    Locale('ru', 'RU'), // Russian
    Locale('ja', 'JP'), // Japanese
    Locale('zh', 'CN'), // Chinese
  ];

  static const String _languageKey = 'selected_language';
  static const String _firstLaunchKey = 'first_launch';

  Locale get currentLocale => _currentLocale ?? const Locale('fr', 'FR'); // Default to French since app is currently in French
  List<Locale> get supportedLocales => _supportedLocales;

  Future<void> initializeLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isFirstLaunch = prefs.getBool(_firstLaunchKey) ?? true;

    if (isFirstLaunch) {
      _currentLocale = _detectDeviceLanguage();
      await prefs.setBool(_firstLaunchKey, false);
      await _saveLanguagePreference(_currentLocale!.languageCode);
    } else {
      final String? savedLanguage = prefs.getString(_languageKey);
      if (savedLanguage != null) {
        _currentLocale = Locale(savedLanguage);
      } else {
        _currentLocale = _detectDeviceLanguage();
      }
    }
    notifyListeners();
  }

  Locale _detectDeviceLanguage() {
    try {
      String deviceLanguage = Platform.localeName.split('_')[0];
      for (Locale locale in _supportedLocales) {
        if (locale.languageCode == deviceLanguage) {
          return locale;
        }
      }
    } catch (e) {
      print('Error detecting device language: $e');
    }
    return const Locale('fr', 'FR'); // Fallback to French
  }

  Future<void> changeLanguage(String languageCode) async {
    Locale? newLocale;
    for (Locale locale in _supportedLocales) {
      if (locale.languageCode == languageCode) {
        newLocale = locale;
        break;
      }
    }

    if (newLocale != null) {
      _currentLocale = newLocale;
      await _saveLanguagePreference(languageCode);
      notifyListeners();
    }
  }

  Future<void> _saveLanguagePreference(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  String getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇺🇸 English';
      case 'fr':
        return '🇫🇷 Français';
      case 'ar':
        return '🇹🇳 العربية';
      case 'ru':
        return '🇷🇺 Русский';
      case 'ja':
        return '🇯🇵 日本語';
      case 'zh':
        return '🇨🇳 中文';
      default:
        return 'Unknown';
    }
  }

  bool get isRTL => _currentLocale?.languageCode == 'ar';
}*/