import 'package:flutter/material.dart';

/// Konfigurasi tema aplikasi yang dapat dikustomisasi dari admin panel Laravel
class AppTheme {
  // TODO: Nanti data ini akan diambil dari API Laravel
  // Untuk sekarang menggunakan default values

  // Primary Colors
  static const Color primaryDark = Color(0xFF1E3A8A); // Dark Blue
  static const Color primaryMain = Color(0xFF3B82F6); // Blue
  static const Color primaryLight = Color(0xFF93C5FD); // Light Blue
  static const Color primaryWhite = Color(0xFFFFFFFF); // White

  // Background Configuration
  static const String backgroundImageUrl = 'assets/images/login_background.jpg';
  static const bool useBackgroundImage =
      false; // Set false untuk menggunakan gradient

  // Logo Configuration
  static const String? logoUrl = null; // URL logo dari API (dynamic)
  static const String? logoAssetPath = null; // Path logo dari assets
  // Jika keduanya null, akan pakai icon default

  // Gradient Background Colors
  static const List<Color> gradientColors = [
    primaryDark,
    primaryMain,
    primaryLight,
  ];

  // Text Colors
  static const Color textPrimary = primaryDark;
  static Color? textSecondary = Colors.grey[600];
  static Color? textTertiary = Colors.grey[700];

  // Border Colors
  static Color? borderColor = Colors.grey[300];

  // Fill Colors
  static Color? fillColor = Colors.grey[50];

  // Method untuk mendapatkan gradient background
  static LinearGradient getBackgroundGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: gradientColors,
    );
  }

  // Method untuk mendapatkan gradient dengan opacity (untuk overlay)
  static LinearGradient getOverlayGradient() {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        primaryDark.withOpacity(0.6),
        primaryMain.withOpacity(0.4),
        primaryLight.withOpacity(0.3),
      ],
    );
  }

  // ThemeData untuk aplikasi
  static ThemeData getLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryMain,
        primary: primaryMain,
      ),
      useMaterial3: true,
      fontFamily: 'SF Pro Display',
    );
  }

  // TODO: Fungsi untuk load theme dari API
  // static Future<void> loadThemeFromAPI() async {
  //   // Implementasi fetch dari Laravel API
  //   // GET /api/theme-config
  //   // Response: {
  //   //   "primary_dark": "#1E3A8A",
  //   //   "primary_main": "#3B82F6",
  //   //   "primary_light": "#93C5FD",
  //   //   "background_image": "url_gambar",
  //   //   "use_background_image": true
  //   // }
  // }
}
