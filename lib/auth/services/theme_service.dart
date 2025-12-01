import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/theme_config.dart';

/// Service untuk mengelola tema aplikasi dan branding configuration
class ThemeService {
  static ThemeConfig? _currentTheme;

  // Laravel API URL (Laragon default: localhost:80)
  static const String baseUrl = 'http://localhost';

  /// Get current theme configuration
  static ThemeConfig getCurrentTheme() {
    return _currentTheme ?? ThemeConfig.defaultTheme();
  }

  /// Fetch theme configuration from Laravel API
  static Future<ThemeConfig> fetchThemeConfig() async {
    try {
      // Fetch dari API Laravel
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/branding-config/public'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        _currentTheme = ThemeConfig.fromJson(json);
        return _currentTheme!;
      } else {
        // Jika response tidak 200, gunakan default
        _currentTheme = ThemeConfig.defaultTheme();
        return _currentTheme!;
      }
    } catch (e) {
      // Jika error (network, timeout, dll), gunakan default theme
      print('Error loading theme config: $e');
      _currentTheme = ThemeConfig.defaultTheme();
      return _currentTheme!;
    }
  }

  /// Load theme configuration from Laravel API (alias for fetchThemeConfig)
  static Future<ThemeConfig> loadThemeFromAPI() async {
    return fetchThemeConfig();
  }

  /// Refresh theme dari API
  static Future<void> refreshTheme() async {
    await fetchThemeConfig();
  }
}
