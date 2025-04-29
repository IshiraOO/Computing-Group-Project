import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _themePreferenceKey = 'theme_mode';

  // Singleton instance
  static final ThemeService _instance = ThemeService._internal();

  // Factory constructor
  factory ThemeService() => _instance;

  // Private constructor
  ThemeService._internal();

  // Theme mode
  ThemeMode _themeMode = ThemeMode.system;

  // Getter for current theme mode
  ThemeMode get themeMode => _themeMode;

  // Getter to determine if dark mode is active
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  // Initialize theme service
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeMode = prefs.getString(_themePreferenceKey);

    if (savedThemeMode != null) {
      _themeMode = _getThemeModeFromString(savedThemeMode);
    } else {
      // Set dark theme as default if no preference is saved
      _themeMode = ThemeMode.dark;
      await prefs.setString(_themePreferenceKey, 'dark');
    }

    notifyListeners();
  }

  // Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePreferenceKey, _getStringFromThemeMode(mode));
  }

  // Toggle between light and dark mode
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.system) {
      // If system, switch to light or dark based on current system setting
      final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
      await setThemeMode(brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark);
    } else {
      // Toggle between light and dark
      await setThemeMode(_themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
    }
  }

  // Reset to system theme
  Future<void> useSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }

  // Helper method to convert ThemeMode to String
  String _getStringFromThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  // Helper method to convert String to ThemeMode
  ThemeMode _getThemeModeFromString(String modeString) {
    switch (modeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}