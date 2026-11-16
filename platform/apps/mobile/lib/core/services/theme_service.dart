import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the application's light/dark/system theme settings.
class ThemeService extends ChangeNotifier {
  ThemeService._();
  static final ThemeService instance = ThemeService._();

  static const _key = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  bool get isDark => _themeMode == ThemeMode.dark;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved != null) {
      if (saved == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (saved == 'light') {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.system;
      }
      notifyListeners();
    }
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      _themeMode == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      mode == ThemeMode.dark
          ? 'dark'
          : mode == ThemeMode.light
          ? 'light'
          : 'system',
    );
  }
}
