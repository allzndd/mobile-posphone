import 'package:flutter/material.dart';

class ThemeColorScheme {
  final String name;
  final Color primaryDark;
  final Color primaryMain;
  final Color primaryLight;
  final Color secondaryDark;
  final Color secondaryMain;
  final Color secondaryLight;
  final Color sidebarStart;
  final Color sidebarEnd;
  final IconData icon;

  const ThemeColorScheme({
    required this.name,
    required this.primaryDark,
    required this.primaryMain,
    required this.primaryLight,
    required this.secondaryDark,
    required this.secondaryMain,
    required this.secondaryLight,
    required this.sidebarStart,
    required this.sidebarEnd,
    required this.icon,
  });

  // Predefined color schemes
  static const List<ThemeColorScheme> presets = [
    ThemeColorScheme(
      name: 'Blue Ocean',
      primaryDark: Color(0xFF1E3A8A),
      primaryMain: Color(0xFF3B82F6),
      primaryLight: Color(0xFF93C5FD),
      secondaryDark: Color(0xFF10B981),
      secondaryMain: Color(0xFF34D399),
      secondaryLight: Color(0xFF6EE7B7),
      sidebarStart: Color(0xFF1E3A8A),
      sidebarEnd: Color(0xFF3B82F6),
      icon: Icons.water_drop,
    ),
    ThemeColorScheme(
      name: 'Purple Dream',
      primaryDark: Color(0xFF6B21A8),
      primaryMain: Color(0xFF9333EA),
      primaryLight: Color(0xFFC084FC),
      secondaryDark: Color(0xFFDB2777),
      secondaryMain: Color(0xFFF472B6),
      secondaryLight: Color(0xFFFBBF24),
      sidebarStart: Color(0xFF6B21A8),
      sidebarEnd: Color(0xFF9333EA),
      icon: Icons.auto_awesome,
    ),
    ThemeColorScheme(
      name: 'Green Forest',
      primaryDark: Color(0xFF065F46),
      primaryMain: Color(0xFF059669),
      primaryLight: Color(0xFF34D399),
      secondaryDark: Color(0xFF047857),
      secondaryMain: Color(0xFF10B981),
      secondaryLight: Color(0xFF6EE7B7),
      sidebarStart: Color(0xFF065F46),
      sidebarEnd: Color(0xFF059669),
      icon: Icons.eco,
    ),
    ThemeColorScheme(
      name: 'Orange Sunset',
      primaryDark: Color(0xFFC2410C),
      primaryMain: Color(0xFFF59E0B),
      primaryLight: Color(0xFFFBBF24),
      secondaryDark: Color(0xFFEA580C),
      secondaryMain: Color(0xFFFB923C),
      secondaryLight: Color(0xFFFDBA74),
      sidebarStart: Color(0xFFC2410C),
      sidebarEnd: Color(0xFFF59E0B),
      icon: Icons.wb_sunny,
    ),
    ThemeColorScheme(
      name: 'Red Fire',
      primaryDark: Color(0xFF991B1B),
      primaryMain: Color(0xFFEF4444),
      primaryLight: Color(0xFFF87171),
      secondaryDark: Color(0xFFB91C1C),
      secondaryMain: Color(0xFFF87171),
      secondaryLight: Color(0xFFFCA5A5),
      sidebarStart: Color(0xFF991B1B),
      sidebarEnd: Color(0xFFEF4444),
      icon: Icons.local_fire_department,
    ),
    ThemeColorScheme(
      name: 'Teal Ocean',
      primaryDark: Color(0xFF115E59),
      primaryMain: Color(0xFF14B8A6),
      primaryLight: Color(0xFF5EEAD4),
      secondaryDark: Color(0xFF0F766E),
      secondaryMain: Color(0xFF2DD4BF),
      secondaryLight: Color(0xFF99F6E4),
      sidebarStart: Color(0xFF115E59),
      sidebarEnd: Color(0xFF14B8A6),
      icon: Icons.waves,
    ),
    ThemeColorScheme(
      name: 'Pink Blossom',
      primaryDark: Color(0xFF9F1239),
      primaryMain: Color(0xFFDB2777),
      primaryLight: Color(0xFFF472B6),
      secondaryDark: Color(0xFFBE185D),
      secondaryMain: Color(0xFFEC4899),
      secondaryLight: Color(0xFFF9A8D4),
      sidebarStart: Color(0xFF9F1239),
      sidebarEnd: Color(0xFFDB2777),
      icon: Icons.favorite,
    ),
    ThemeColorScheme(
      name: 'Indigo Night',
      primaryDark: Color(0xFF312E81),
      primaryMain: Color(0xFF4F46E5),
      primaryLight: Color(0xFF818CF8),
      secondaryDark: Color(0xFF3730A3),
      secondaryMain: Color(0xFF6366F1),
      secondaryLight: Color(0xFFA5B4FC),
      sidebarStart: Color(0xFF312E81),
      sidebarEnd: Color(0xFF4F46E5),
      icon: Icons.nightlight,
    ),
  ];
}
