import '../models/theme_config.dart';

/// Service untuk mengelola tema aplikasi
/// TODO: Implementasi koneksi ke Laravel API
class ThemeService {
  static ThemeConfig? _currentTheme;

  /// Get current theme configuration
  static ThemeConfig getCurrentTheme() {
    return _currentTheme ?? ThemeConfig.defaultTheme();
  }

  /// Load theme configuration from Laravel API
  /// TODO: Implementasi fetch dari API
  static Future<ThemeConfig> loadThemeFromAPI() async {
    try {
      // TODO: Implementasi HTTP request ke Laravel
      // final response = await http.get(
      //   Uri.parse('${API_BASE_URL}/api/theme-config'),
      // );
      //
      // if (response.statusCode == 200) {
      //   final json = jsonDecode(response.body);
      //   _currentTheme = ThemeConfig.fromJson(json['data']);
      //   return _currentTheme!;
      // }

      // Sementara return default theme
      _currentTheme = ThemeConfig.defaultTheme();
      return _currentTheme!;
    } catch (e) {
      // Jika error, gunakan default theme
      _currentTheme = ThemeConfig.defaultTheme();
      return _currentTheme!;
    }
  }

  /// Refresh theme dari API
  static Future<void> refreshTheme() async {
    await loadThemeFromAPI();
  }
}
