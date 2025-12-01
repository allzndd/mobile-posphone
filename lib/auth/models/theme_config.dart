/// Model untuk konfigurasi tema yang akan diambil dari Laravel API
class ThemeConfig {
  final String primaryDark;
  final String primaryMain;
  final String primaryLight;
  final String? backgroundImageUrl;
  final bool useBackgroundImage;
  final String? logoUrl;
  final String appName;

  ThemeConfig({
    required this.primaryDark,
    required this.primaryMain,
    required this.primaryLight,
    this.backgroundImageUrl,
    this.useBackgroundImage = false,
    this.logoUrl,
    this.appName = 'Mobile PosPhone',
  });

  /// Factory untuk membuat ThemeConfig dari JSON response API
  factory ThemeConfig.fromJson(Map<String, dynamic> json) {
    return ThemeConfig(
      primaryDark: json['primary_dark'] ?? '#1E3A8A',
      primaryMain: json['primary_main'] ?? '#3B82F6',
      primaryLight: json['primary_light'] ?? '#93C5FD',
      backgroundImageUrl: json['background_image_url'],
      useBackgroundImage: json['use_background_image'] ?? false,
      logoUrl: json['logo_url'],
      appName: json['app_name'] ?? 'Mobile PosPhone',
    );
  }

  /// Convert to JSON untuk save/update
  Map<String, dynamic> toJson() {
    return {
      'primary_dark': primaryDark,
      'primary_main': primaryMain,
      'primary_light': primaryLight,
      'background_image_url': backgroundImageUrl,
      'use_background_image': useBackgroundImage,
      'logo_url': logoUrl,
      'app_name': appName,
    };
  }

  /// Default theme configuration
  factory ThemeConfig.defaultTheme() {
    return ThemeConfig(
      primaryDark: '#1E3A8A',
      primaryMain: '#3B82F6',
      primaryLight: '#93C5FD',
      useBackgroundImage: false,
      appName: 'Mobile PosPhone',
    );
  }
}
