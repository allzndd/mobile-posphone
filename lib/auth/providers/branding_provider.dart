import 'package:flutter/material.dart';
import '../models/theme_config.dart';
import '../services/theme_service.dart';

/// Provider untuk mengelola branding configuration secara global
class BrandingProvider extends ChangeNotifier {
  ThemeConfig _themeConfig = ThemeConfig.defaultTheme();
  bool _isLoading = false;
  String? _error;

  ThemeConfig get themeConfig => _themeConfig;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get appName => _themeConfig.appName;
  String get appTagline => _themeConfig.appTagline;
  String? get logoUrl => _themeConfig.logoUrl;

  /// Load theme configuration from API
  Future<void> loadThemeConfig() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final config = await ThemeService.fetchThemeConfig();
      _themeConfig = config;
      _error = null;
    } catch (e) {
      _error = e.toString();
      // Gunakan default theme jika gagal load
      _themeConfig = ThemeConfig.defaultTheme();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update theme config (untuk testing)
  void updateThemeConfig(ThemeConfig config) {
    _themeConfig = config;
    notifyListeners();
  }
}
