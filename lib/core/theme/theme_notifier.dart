import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme notifier for managing dynamic theme switching
/// Supports light, dark, and system themes with persistent storage
class ThemeNotifier extends ValueNotifier<ThemeMode> {
  static const String _themeKey = 'theme_mode';

  ThemeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  /// Load saved theme preference from shared preferences
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey) ?? 'light';

      switch (savedTheme) {
        case 'dark':
          value = ThemeMode.dark;
          break;
        case 'system':
          value = ThemeMode.system;
          break;
        default:
          value = ThemeMode.light;
      }
    } catch (e) {
      // Fallback to light theme if loading fails
      value = ThemeMode.light;
    }
  }

  /// Set theme mode and persist to shared preferences
  Future<void> setTheme(ThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      String themeString = '';
      switch (themeMode) {
        case ThemeMode.light:
          themeString = 'light';
          break;
        case ThemeMode.dark:
          themeString = 'dark';
          break;
        case ThemeMode.system:
          themeString = 'system';
          break;
      }

      await prefs.setString(_themeKey, themeString);
      value = themeMode;
    } catch (e) {
      // Silent fail - theme will remain current value
      debugPrint('Failed to save theme preference: $e');
    }
  }

  /// Toggle between light and dark themes (excluding system)
  Future<void> toggleTheme() async {
    final newTheme =
        value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setTheme(newTheme);
  }

  /// Get current theme as string for UI display
  String get currentThemeString {
    switch (value) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
}
