import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/theme_provider.dart';
import '../../config/theme_schemes.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/screens/login_screen.dart';
import '../../layouts/screens/main_layout.dart';

class PengaturanScreen extends StatefulWidget {
  const PengaturanScreen({super.key});

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    final themeProvider = context.watch<ThemeProvider>();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        // Navigate ke dashboard (index 0)
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder:
                  (context) =>
                      const MainLayout(title: 'Dashboard', selectedIndex: 0),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(isDesktop)),
            SliverToBoxAdapter(child: _buildProfileSection(isDesktop)),
            SliverToBoxAdapter(child: _buildSettingsSections(isDesktop)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      margin: EdgeInsets.all(isDesktop ? 20 : 16),
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
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 28 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isDesktop ? 12 : 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.settings_rounded,
                    color: Colors.white,
                    size: isDesktop ? 28 : 24,
                  ),
                ),
                SizedBox(width: isDesktop ? 16 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isDesktop ? 28 : 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage your preferences',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: isDesktop ? 15 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      margin: EdgeInsets.all(isDesktop ? 24 : 12),
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isDesktop ? 80 : 60,
            height: isDesktop ? 80 : 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryMain, AppTheme.secondaryMain],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'AD',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isDesktop ? 28 : 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: isDesktop ? 20 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin User',
                  style: TextStyle(
                    fontSize: isDesktop ? 20 : 16,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'admin@posphone.com',
                  style: TextStyle(
                    fontSize: isDesktop ? 14 : 12,
                    color: themeProvider.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSections(bool isDesktop) {
    final tampilanCard = _buildSettingsCard(
      title: 'Display',
      icon: Icons.palette_rounded,
      color: AppTheme.accentPurple,
      isDesktop: isDesktop,
      children: [
        _buildThemeModeTile(isDesktop),
        const Divider(height: 1),
        _buildThemeSelector(isDesktop),
      ],
    );

    final lainnyaCard = _buildSettingsCard(
      title: 'Other',
      icon: Icons.more_horiz,
      color: AppTheme.textSecondary,
      isDesktop: isDesktop,
      children: [
        _buildActionTile(
          'About Application',
          'Information & license',
          Icons.info_outline,
          AppTheme.infoColor,
          () => _showAboutDialog(),
          isDesktop,
        ),
        const Divider(height: 1),
        _buildActionTile(
          'Help & Support',
          'FAQ & contact support',
          Icons.help_outline,
          AppTheme.secondaryMain,
          () => _showHelp(),
          isDesktop,
        ),
        const Divider(height: 1),
        _buildActionTile(
          'Logout',
          'Sign out from account',
          Icons.logout,
          AppTheme.errorColor,
          () => _showLogoutDialog(),
          isDesktop,
        ),
      ],
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 20 : 16,
        vertical: isDesktop ? 20 : 16,
      ),
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 1200 : double.infinity,
          ),
          child:
              isDesktop
                  ? Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: tampilanCard),
                          const SizedBox(width: 20),
                          Expanded(child: lainnyaCard),
                        ],
                      ),
                    ],
                  )
                  : Column(
                    children: [
                      tampilanCard,
                      const SizedBox(height: 16),
                      lainnyaCard,
                      const SizedBox(height: 24),
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required Color color,
    required bool isDesktop,
    required List<Widget> children,
  }) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeProvider.borderColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(isDesktop ? 20 : 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isDesktop ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isDesktop,
  ) {
    final themeProvider = context.watch<ThemeProvider>();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 20 : 16,
            vertical: isDesktop ? 8 : 4,
          ),
          leading: Icon(icon, color: color, size: 24),
          title: Text(
            title,
            style: TextStyle(
              fontSize: isDesktop ? 15 : 14,
              fontWeight: FontWeight.w600,
              color: themeProvider.textPrimary,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: isDesktop ? 13 : 12,
              color: themeProvider.textTertiary,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: themeProvider.textTertiary,
          ),
        ),
      ),
    );
  }

  Widget _buildThemeModeTile(bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();

    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 20 : 16,
          vertical: isDesktop ? 8 : 4,
        ),
        leading: Icon(
          themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
          color: themeProvider.textSecondary,
          size: 24,
        ),
        title: Text(
          'Dark Mode',
          style: TextStyle(
            fontSize: isDesktop ? 15 : 14,
            fontWeight: FontWeight.w600,
            color: themeProvider.textPrimary,
          ),
        ),
        subtitle: Text(
          themeProvider.isDarkMode ? 'Dark theme active' : 'Light theme active',
          style: TextStyle(
            fontSize: isDesktop ? 13 : 12,
            color: themeProvider.textTertiary,
          ),
        ),
        trailing: Switch(
          value: themeProvider.isDarkMode,
          onChanged: (value) {
            themeProvider.toggleDarkMode();
          },
          activeColor: AppTheme.primaryMain,
        ),
      ),
    );
  }

  Widget _buildThemeSelector(bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showThemeSelector(),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 20 : 16,
            vertical: isDesktop ? 8 : 4,
          ),
          leading: Icon(
            themeProvider.currentScheme.icon,
            color: themeProvider.textSecondary,
            size: 24,
          ),
          title: Text(
            'Color Scheme',
            style: TextStyle(
              fontSize: isDesktop ? 15 : 14,
              fontWeight: FontWeight.w600,
              color: themeProvider.textPrimary,
            ),
          ),
          subtitle: Text(
            themeProvider.currentScheme.name,
            style: TextStyle(
              fontSize: isDesktop ? 13 : 12,
              color: themeProvider.textTertiary,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      themeProvider.primaryMain,
                      themeProvider.secondaryMain,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: themeProvider.borderColor,
                    width: 2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: themeProvider.textTertiary),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeSelector() {
    showDialog(
      context: context,
      builder: (context) {
        final themeProvider = context.watch<ThemeProvider>();
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: themeProvider.primaryMain.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.palette,
                        color: themeProvider.primaryMain,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Select Color Scheme',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose the color theme that suits your preference',
                  style: TextStyle(
                    fontSize: 14,
                    color: themeProvider.textTertiary,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.5,
                        ),
                    itemCount: ThemeColorScheme.presets.length,
                    itemBuilder: (context, index) {
                      final scheme = ThemeColorScheme.presets[index];
                      final isSelected =
                          themeProvider.currentScheme.name == scheme.name;

                      return InkWell(
                        onTap: () {
                          themeProvider.setTheme(scheme);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                scheme.primaryMain,
                                scheme.secondaryMain,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? Colors.white
                                      : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: scheme.primaryMain.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Icon(
                                  scheme.icon,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              if (isSelected)
                                const Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              Positioned(
                                bottom: 12,
                                left: 12,
                                right: 12,
                                child: Text(
                                  scheme.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAboutDialog() {
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
                    color: AppTheme.infoColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.info_outline, color: AppTheme.infoColor),
                ),
                const SizedBox(width: 12),
                const Text('About Application'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'POS Phone',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(color: AppTheme.textTertiary),
                ),
                const SizedBox(height: 16),
                Text(
                  'Modern Point of Sale application for phone store management.',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 16),
                Text(
                  '© 2025 POS Phone. All rights reserved.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textTertiary),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showHelp() {
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
                    color: AppTheme.secondaryMain.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.help_outline,
                    color: AppTheme.secondaryMain,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Help & Support'),
              ],
            ),
            content: const Text(
              'FAQ and support contact will be displayed here',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.logout, color: AppTheme.errorColor),
                ),
                const SizedBox(width: 12),
                const Text('Confirm Logout'),
              ],
            ),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Show loading indicator
                  Navigator.pop(dialogContext);
                  
                  // Show loading dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (loadingContext) => WillPopScope(
                      onWillPop: () async => false,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: AppTheme.primaryMain,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Signing out...',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );

                  try {
                    // Call logout API
                    await AuthService.logout();
                    
                    // Small delay to ensure everything is cleaned up
                    await Future.delayed(const Duration(milliseconds: 300));
                  } catch (e) {
                    print('Logout error: $e');
                  }

                  // Navigate to login screen (use root navigator)
                  if (mounted) {
                    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }
}
