import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the app's locale (language) preference.
/// Supported: English, Swahili, Shona, French, Portuguese.
class LocaleService extends ChangeNotifier {
  LocaleService._();
  static final LocaleService instance = LocaleService._();

  static const _key = 'locale_code';

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  static const supportedLocales = [
    SupportedLanguage('English', Locale('en')),
    SupportedLanguage('Kiswahili', Locale('sw')),
    SupportedLanguage('Shona', Locale('sn')),
    SupportedLanguage('Setswana', Locale('tn')),
    SupportedLanguage('Ndebele', Locale('nd')),
    SupportedLanguage('Français', Locale('fr')),
    SupportedLanguage('Português', Locale('pt')),
  ];

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved != null) {
      _locale = Locale(saved);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }
}

class SupportedLanguage {
  const SupportedLanguage(this.displayName, this.locale);
  final String displayName;
  final Locale locale;
}
