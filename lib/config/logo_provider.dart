import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoProvider extends ChangeNotifier {
  String? _logoPath;
  String _appName = 'POS Phone';
  String _appTagline = 'Kelola bisnis jadi lebih mudah';

  LogoProvider() {
    _loadLogo();
  }

  String? get logoPath => _logoPath;
  String get appName => _appName;
  String get appTagline => _appTagline;

  Future<void> _loadLogo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _logoPath = prefs.getString('app_logo_path');
      _appName = prefs.getString('app_name') ?? 'POS Phone';
      _appTagline =
          prefs.getString('app_tagline') ?? 'Kelola bisnis jadi lebih mudah';
      notifyListeners();
    } catch (e) {
      // Use default values
    }
  }

  Future<void> setLogo(String path) async {
    _logoPath = path;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_logo_path', path);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> setAppName(String name) async {
    _appName = name;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_name', name);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> setAppTagline(String tagline) async {
    _appTagline = tagline;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_tagline', tagline);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> removeLogo() async {
    _logoPath = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('app_logo_path');
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> resetToDefault() async {
    _logoPath = null;
    _appName = 'POS Phone';
    _appTagline = 'Kelola bisnis jadi lebih mudah';
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('app_logo_path');
      await prefs.remove('app_name');
      await prefs.remove('app_tagline');
    } catch (e) {
      // Handle error silently
    }
  }
}
