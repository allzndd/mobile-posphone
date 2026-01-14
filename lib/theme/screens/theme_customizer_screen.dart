import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/theme_provider.dart';
import '../../config/theme_schemes.dart';

class ThemeCustomizerScreen extends StatefulWidget {
  const ThemeCustomizerScreen({super.key});

  @override
  State<ThemeCustomizerScreen> createState() => _ThemeCustomizerScreenState();
}

class _ThemeCustomizerScreenState extends State<ThemeCustomizerScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final isTablet = screenWidth > 600 && screenWidth <= 900;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 500));
          setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(isDesktop ? 20 : (isSmallScreen ? 12 : 16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModernHeader(isDesktop, isSmallScreen, themeProvider),
              SizedBox(height: isDesktop ? 20 : 16),
              _buildStatsCards(isDesktop, isTablet, isSmallScreen, themeProvider),
              SizedBox(height: isDesktop ? 20 : 16),
              _buildThemePresets(isDesktop, isTablet, isSmallScreen, themeProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(bool isDesktop, bool isSmallScreen, ThemeProvider themeProvider) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : (isSmallScreen ? 16 : 20)),
      decoration: BoxDecoration(
        color: themeProvider.primaryMain,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: themeProvider.primaryMain.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isDesktop ? 12 : 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.palette_rounded,
              color: Colors.white,
              size: isDesktop ? 28 : 24,
            ),
          ),
          SizedBox(width: isDesktop ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Theme Customizer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 24 : (isSmallScreen ? 16 : 18),
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (!isSmallScreen) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Personalisasi warna & tampilan aplikasi',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: isDesktop ? 14 : 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(bool isDesktop, bool isTablet, bool isSmallScreen, ThemeProvider themeProvider) {
    final scheme = themeProvider.currentScheme;
    final totalThemes = ThemeColorScheme.presets.length;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Tema Aktif',
            scheme.name,
            scheme.icon,
            themeProvider.primaryMain,
            isDesktop,
            isSmallScreen,
            themeProvider,
          ),
        ),
        SizedBox(width: isDesktop ? 16 : 12),
        Expanded(
          child: _buildStatCard(
            'Total Preset',
            '$totalThemes Tema',
            Icons.auto_awesome,
            themeProvider.secondaryMain,
            isDesktop,
            isSmallScreen,
            themeProvider,
          ),
        ),
        if (!isSmallScreen) ...[
          SizedBox(width: isDesktop ? 16 : 12),
          Expanded(
            child: _buildStatCard(
              'Quick Action',
              'Reset',
              Icons.restart_alt,
              AppTheme.warningColor,
              isDesktop,
              isSmallScreen,
              themeProvider,
              onTap: () => _showResetDialog(themeProvider),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDesktop,
    bool isSmallScreen,
    ThemeProvider themeProvider,
    {VoidCallback? onTap}
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(isDesktop ? 20 : (isSmallScreen ? 12 : 16)),
          decoration: BoxDecoration(
            color: themeProvider.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: themeProvider.borderColor.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(isDesktop ? 10 : 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isDesktop ? 24 : (isSmallScreen ? 18 : 20),
                ),
              ),
              SizedBox(height: isDesktop ? 12 : 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: isDesktop ? 13 : (isSmallScreen ? 10 : 11),
                  color: themeProvider.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: isDesktop ? 16 : (isSmallScreen ? 12 : 14),
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemePresets(bool isDesktop, bool isTablet, bool isSmallScreen, ThemeProvider themeProvider) {
    int crossAxisCount;
    if (isDesktop) {
      crossAxisCount = 4;
    } else if (isTablet) {
      crossAxisCount = 3;
    } else if (isSmallScreen) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 2;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 4 : 0),
          child: Row(
            children: [
              Text(
                'Pilih Tema',
                style: TextStyle(
                  fontSize: isDesktop ? 20 : (isSmallScreen ? 16 : 18),
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 12 : 10,
                  vertical: isDesktop ? 6 : 4,
                ),
                decoration: BoxDecoration(
                  color: themeProvider.primaryMain.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${ThemeColorScheme.presets.length} Preset',
                  style: TextStyle(
                    fontSize: isDesktop ? 12 : 10,
                    fontWeight: FontWeight.w600,
                    color: themeProvider.primaryMain,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isDesktop ? 16 : 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: isDesktop ? 1.0 : (isSmallScreen ? 0.85 : 0.9),
            crossAxisSpacing: isDesktop ? 16 : 12,
            mainAxisSpacing: isDesktop ? 16 : 12,
          ),
          itemCount: ThemeColorScheme.presets.length,
          itemBuilder: (context, index) {
            final scheme = ThemeColorScheme.presets[index];
            final isActive = themeProvider.currentScheme.name == scheme.name;

            return _buildThemeCard(
              scheme,
              isActive,
              isDesktop,
              isSmallScreen,
              themeProvider,
            );
          },
        ),
      ],
    );
  }

  Widget _buildThemeCard(
    ThemeColorScheme scheme,
    bool isActive,
    bool isDesktop,
    bool isSmallScreen,
    ThemeProvider themeProvider,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          themeProvider.setTheme(scheme);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tema ${scheme.name} diterapkan'),
              backgroundColor: scheme.primaryMain,
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(isDesktop ? 16 : (isSmallScreen ? 10 : 12)),
          decoration: BoxDecoration(
            color: themeProvider.surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? scheme.primaryMain : themeProvider.borderColor.withOpacity(0.3),
              width: isActive ? 2.5 : 1,
            ),
            boxShadow: isActive ? [
              BoxShadow(
                color: scheme.primaryMain.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ] : [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: isDesktop ? 56 : (isSmallScreen ? 44 : 50),
                height: isDesktop ? 56 : (isSmallScreen ? 44 : 50),
                decoration: BoxDecoration(
                  color: scheme.primaryMain,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primaryMain.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  scheme.icon,
                  color: Colors.white,
                  size: isDesktop ? 28 : (isSmallScreen ? 22 : 24),
                ),
              ),
              SizedBox(height: isDesktop ? 12 : 8),
              Text(
                scheme.name,
                style: TextStyle(
                  fontSize: isDesktop ? 14 : (isSmallScreen ? 11 : 12),
                  fontWeight: FontWeight.bold,
                  color: isActive ? scheme.primaryMain : themeProvider.textPrimary,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              SizedBox(height: isDesktop ? 8 : 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildColorDot(scheme.primaryMain, isSmallScreen),
                  SizedBox(width: isSmallScreen ? 3 : 4),
                  _buildColorDot(scheme.secondaryMain, isSmallScreen),
                  SizedBox(width: isSmallScreen ? 3 : 4),
                  _buildColorDot(scheme.primaryLight, isSmallScreen),
                ],
              ),
              if (isActive) ...[
                SizedBox(height: isDesktop ? 8 : 6),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 12 : (isSmallScreen ? 8 : 10),
                    vertical: isDesktop ? 4 : 3,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primaryMain,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: isSmallScreen ? 10 : 12,
                      ),
                      SizedBox(width: isSmallScreen ? 3 : 4),
                      Text(
                        'Aktif',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 9 : 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorDot(Color color, bool isSmallScreen) {
    return Container(
      width: isSmallScreen ? 10 : 12,
      height: isSmallScreen ? 10 : 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: isSmallScreen ? 1.5 : 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.restart_alt, color: AppTheme.warningColor),
                ),
                const SizedBox(width: 12),
                const Text('Reset Tema'),
              ],
            ),
            content: const Text('Kembalikan tema ke default (Blue Ocean)?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  themeProvider.resetToDefault();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Tema berhasil di-reset ke default'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.warningColor,
                ),
                child: const Text('Reset'),
              ),
            ],
          ),
    );
  }
}
