import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryDark = Color(0xFF1E3A8A);     // Dark Blue
  static const Color primaryMain = Color(0xFF3B82F6);     // Blue
  static const Color primaryLight = Color(0xFF93C5FD);    // Light Blue
  static const Color primaryWhite = Color(0xFFFFFFFF);    // White

  // Secondary Colors
  static const Color secondaryDark = Color(0xFF10B981);   // Green
  static const Color secondaryMain = Color(0xFF34D399);   // Bright Green
  static const Color secondaryLight = Color(0xFF6EE7B7);  // Light Green

  // Accent Colors
  static const Color accentRed = Color(0xFFEF4444);      // Red
  static const Color accentOrange = Color(0xFFF59E0B);   // Orange
  static const Color accentPurple = Color(0xFF8B5CF6);   // Purple
  static const Color accentGreen = Color(0xFF10B981);    // Green

  // Background & Surface Colors
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color surfaceDark = Color(0xFFF1F5F9);

  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B);    // Dark Slate
  static const Color textSecondary = Color(0xFF64748B);  // Slate Gray
  static const Color textTertiary = Color(0xFF94A3B8);   // Light Slate

  // Border & Divider Colors
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFFCBD5E1);
  static const Color dividerColor = Color(0xFFE2E8F0);

  // Semantic Colors
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF3B82F6);

  // Gradient Configurations
  static LinearGradient get primaryGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primaryMain, primaryLight],
  );

  static LinearGradient get secondaryGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryDark, secondaryMain, secondaryLight],
  );

  // Typography
  static TextTheme get textTheme => TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: textPrimary,
      letterSpacing: -0.5,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: textSecondary,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: textTertiary,
    ),
  );

  // Light Theme Configuration
  static ThemeData get lightTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryMain,
      primary: primaryMain,
      secondary: secondaryMain,
      background: backgroundLight,
      surface: backgroundWhite,
      error: errorColor,
    ),
    scaffoldBackgroundColor: backgroundLight,
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundWhite,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryMain,
        foregroundColor: primaryWhite,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryMain, width: 2),
      ),
    ),
    textTheme: textTheme,
    useMaterial3: true,
    fontFamily: 'SF Pro Display',
  );

  // Dark Theme (Optional)
  static ThemeData get darkTheme => ThemeData(
    // Konfigurasi tema gelap
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryMain,
      brightness: Brightness.dark,
    ),
    // Tambahkan konfigurasi lain untuk tema gelap
  );

  // Utility Methods
  static BoxShadow get lightShadow => BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 20,
    offset: const Offset(0, 8),
  );

  static BoxShadow get mediumShadow => BoxShadow(
    color: Colors.black.withOpacity(0.15),
    blurRadius: 30,
    offset: const Offset(0, 12),
  );

  // Border Radius
  static BorderRadius get smallRadius => BorderRadius.circular(8);
  static BorderRadius get mediumRadius => BorderRadius.circular(12);
  static BorderRadius get largeRadius => BorderRadius.circular(16);
}