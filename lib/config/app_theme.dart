import 'package:flutter/material.dart';

class AppTheme {
// =========================================================
// PRIMARY COLORS
// =========================================================
static const Color primaryDark = Color(0xFF1E3A8A);     // Deep Blue
static const Color primaryMain = Color(0xFF3B82F6);     // Main Blue
static const Color primaryLight = Color(0xFF93C5FD);    // Soft Blue
static const Color primaryWhite = Color(0xFFFFFFFF);    // White

// =========================================================
// SECONDARY COLORS
// =========================================================
static const Color secondaryDark = Color(0xFF10B981);   // Emerald Dark
static const Color secondaryMain = Color(0xFF34D399);   // Emerald Green
static const Color secondaryLight = Color(0xFF6EE7B7);  // Light Green

// =========================================================
// ACCENT COLORS
// =========================================================
static const Color accentRed = Color(0xFFEF4444);
static const Color accentOrange = Color(0xFFF59E0B);
static const Color accentPurple = Color(0xFF8B5CF6);
static const Color accentGreen = Color(0xFF10B981);

// =========================================================
// BRAND COLORS (BARU - UNTUK POS PHONE)
// =========================================================
static const Color brandNeonBlue = Color(0xFF00C6FF);     // Neon Blue
static const Color brandTurquoise = Color(0xFF2EE6A8);    // Turquoise Glow
static const Color brandSkySoft = Color(0xFFE5F4FF);      // Soft Sky Background
static const Color brandDeepNavy = Color(0xFF0A1A2F);     // Deep Navy Premium

// =========================================================
// SURFACE & BACKGROUND
// =========================================================
static const Color backgroundLight = Color(0xFFF5F7FA);
static const Color backgroundWhite = Color(0xFFFFFFFF);
static const Color surfaceLight = Color(0xFFF8FAFC);
static const Color surfaceDark = Color(0xFFF1F5F9);

// =========================================================
// TEXT COLORS
// =========================================================
static const Color textPrimary = Color(0xFF1E293B);
static const Color textSecondary = Color(0xFF64748B);
static const Color textTertiary = Color(0xFF94A3B8);

// =========================================================
// BORDER & DIVIDER
// =========================================================
static const Color borderLight = Color(0xFFE2E8F0);
static const Color borderDark = Color(0xFFCBD5E1);
static const Color dividerColor = Color(0xFFE2E8F0);

// =========================================================
// SEMANTIC COLORS
// =========================================================
static const Color successColor = Color(0xFF10B981);
static const Color warningColor = Color(0xFFF59E0B);
static const Color errorColor = Color(0xFFEF4444);
static const Color infoColor = Color(0xFF3B82F6);

// =========================================================
// GRADIENTS
// =========================================================
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

// NEW: Aurora Gradient for POS UI
static LinearGradient get posAuroraGradient => LinearGradient(
begin: Alignment.topLeft,
end: Alignment.bottomRight,
colors: [
primaryDark,
brandNeonBlue,
brandTurquoise,
primaryLight,
],
);

// NEW: Soft Blue Gradient for backgrounds
static LinearGradient get posSoftBlueGradient => LinearGradient(
begin: Alignment.topCenter,
end: Alignment.bottomCenter,
colors: [
brandSkySoft,
primaryLight,
primaryMain,
],
);

// =========================================================
// TYPOGRAPHY
// =========================================================
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

// =========================================================
// LIGHT THEME (Main)
// =========================================================
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


    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundWhite,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: false,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryMain,
        foregroundColor: primaryWhite,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: TextStyle(
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
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryMain, width: 2),
      ),
    ),

    textTheme: textTheme,
    useMaterial3: true,
    fontFamily: 'SF Pro Display',
  );


// =========================================================
// DARK THEME (Optional)
// =========================================================
static ThemeData get darkTheme => ThemeData(
brightness: Brightness.dark,
colorScheme: ColorScheme.fromSeed(
seedColor: primaryMain,
brightness: Brightness.dark,
),
);

// =========================================================
// SHADOWS
// =========================================================
static BoxShadow get lightShadow => BoxShadow(
color: Colors.black.withOpacity(0.1),
blurRadius: 20,
offset: Offset(0, 8),
);

static BoxShadow get mediumShadow => BoxShadow(
color: Colors.black.withOpacity(0.15),
blurRadius: 30,
offset: Offset(0, 12),
);

// =========================================================
// BORDER RADIUS
// =========================================================
static BorderRadius get smallRadius => BorderRadius.circular(8);
static BorderRadius get mediumRadius => BorderRadius.circular(12);
static BorderRadius get largeRadius => BorderRadius.circular(16);
}
