import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme_schemes.dart';

class ThemeProvider extends ChangeNotifier {
  late ThemeColorScheme _currentScheme;
  bool _isDarkMode = false;

  ThemeProvider() {
    _currentScheme = ThemeColorScheme.presets[0]; // Default: Blue Ocean
    _loadTheme();
  }

  ThemeColorScheme get currentScheme => _currentScheme;
  bool get isDarkMode => _isDarkMode;

  // Primary colors
  Color get primaryDark => _currentScheme.primaryDark;
  Color get primaryMain => _currentScheme.primaryMain;
  Color get primaryLight => _currentScheme.primaryLight;

  // Secondary colors
  Color get secondaryDark => _currentScheme.secondaryDark;
  Color get secondaryMain => _currentScheme.secondaryMain;
  Color get secondaryLight => _currentScheme.secondaryLight;

  // Sidebar colors
  Color get sidebarStart => _currentScheme.sidebarStart;
  Color get sidebarEnd => _currentScheme.sidebarEnd;

  // Background colors (dark/light mode)
  Color get backgroundColor =>
      _isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
  Color get surfaceColor =>
      _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  Color get cardColor => _isDarkMode ? const Color(0xFF2D2D2D) : Colors.white;

  // Text colors (dark/light mode)
  Color get textPrimary =>
      _isDarkMode ? const Color(0xFFE0E0E0) : const Color(0xFF1F2937);
  Color get textSecondary =>
      _isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF6B7280);
  Color get textTertiary =>
      _isDarkMode ? const Color(0xFF808080) : const Color(0xFF9CA3AF);

  // Border colors (dark/light mode)
  Color get borderColor =>
      _isDarkMode ? const Color(0xFF3D3D3D) : const Color(0xFFE5E7EB);

  // Status colors (fixed - tidak terpengaruh dark mode)
  Color get successMain => const Color(0xFF10B981); // Green
  Color get errorMain => const Color(0xFFEF4444); // Red
  Color get warningMain => const Color(0xFFF59E0B); // Orange/Yellow
  Color get infoMain => const Color(0xFF3B82F6); // Blue

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeName = prefs.getString('theme_name');
      final darkMode = prefs.getBool('dark_mode') ?? false;

      if (themeName != null) {
        final scheme = ThemeColorScheme.presets.firstWhere(
          (scheme) => scheme.name == themeName,
          orElse: () => ThemeColorScheme.presets[0],
        );
        _currentScheme = scheme;
      }

      _isDarkMode = darkMode;
      notifyListeners();
    } catch (e) {
      // If error, use default
      _currentScheme = ThemeColorScheme.presets[0];
      _isDarkMode = false;
    }
  }

  Future<void> setTheme(ThemeColorScheme scheme) async {
    _currentScheme = scheme;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_name', scheme.name);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('dark_mode', _isDarkMode);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('dark_mode', value);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> resetToDefault() async {
    await setTheme(ThemeColorScheme.presets[0]);
  }
}
