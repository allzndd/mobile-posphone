import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/theme_provider.dart';
import '../../config/theme_schemes.dart';

class PengaturanScreen extends StatefulWidget {
  const PengaturanScreen({super.key});

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  bool _notificationEnabled = true;
  bool _emailNotification = false;
  bool _soundEnabled = true;
  bool _autoBackup = true;
  String _language = 'Indonesia';
  String _currency = 'IDR';
  String _dateFormat = 'DD/MM/YYYY';

  final List<String> _languages = ['Indonesia', 'English', 'Malaysia'];
  final List<String> _currencies = ['IDR', 'USD', 'MYR'];
  final List<String> _dateFormats = ['DD/MM/YYYY', 'MM/DD/YYYY', 'YYYY-MM-DD'];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(isDesktop)),
          SliverToBoxAdapter(child: _buildProfileSection(isDesktop)),
          SliverToBoxAdapter(child: _buildSettingsSections(isDesktop)),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [themeProvider.primaryMain, themeProvider.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: themeProvider.primaryMain.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
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
                  'Pengaturan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 24 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Kelola preferensi & konfigurasi aplikasi',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isDesktop ? 14 : 12,
                  ),
                ),
              ],
            ),
          ),
          if (isDesktop)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.verified_user, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
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
                if (!isDesktop) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryMain.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Administrator',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.primaryMain,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isDesktop) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryMain.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Administrator',
                style: TextStyle(
                  color: AppTheme.primaryMain,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () => _showEditProfile(),
              icon: Icon(Icons.edit, color: AppTheme.primaryMain),
              tooltip: 'Edit Profil',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingsSections(bool isDesktop) {
    return Container(
      margin: EdgeInsets.only(
        left: isDesktop ? 24 : 12,
        right: isDesktop ? 24 : 12,
        bottom: isDesktop ? 24 : 12,
      ),
      child: Column(
        children: [
          _buildSettingsCard(
            title: 'Notifikasi',
            icon: Icons.notifications_rounded,
            color: AppTheme.accentOrange,
            isDesktop: isDesktop,
            children: [
              _buildSwitchTile(
                'Push Notification',
                'Terima notifikasi real-time',
                Icons.notifications_active,
                _notificationEnabled,
                (value) => setState(() => _notificationEnabled = value),
                isDesktop,
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                'Email Notification',
                'Kirim notifikasi ke email',
                Icons.email_outlined,
                _emailNotification,
                (value) => setState(() => _emailNotification = value),
                isDesktop,
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                'Sound',
                'Aktifkan suara notifikasi',
                Icons.volume_up,
                _soundEnabled,
                (value) => setState(() => _soundEnabled = value),
                isDesktop,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingsCard(
            title: 'Tampilan',
            icon: Icons.palette_rounded,
            color: AppTheme.accentPurple,
            isDesktop: isDesktop,
            children: [
              _buildThemeModeTile(isDesktop),
              const Divider(height: 1),
              _buildThemeSelector(isDesktop),
              const Divider(height: 1),
              _buildDropdownTile(
                'Bahasa',
                'Pilih bahasa aplikasi',
                Icons.language,
                _language,
                _languages,
                (value) => setState(() => _language = value!),
                isDesktop,
              ),
              const Divider(height: 1),
              _buildDropdownTile(
                'Format Tanggal',
                'Format tampilan tanggal',
                Icons.calendar_today,
                _dateFormat,
                _dateFormats,
                (value) => setState(() => _dateFormat = value!),
                isDesktop,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingsCard(
            title: 'Sistem',
            icon: Icons.settings_applications,
            color: AppTheme.primaryMain,
            isDesktop: isDesktop,
            children: [
              _buildDropdownTile(
                'Mata Uang',
                'Mata uang default',
                Icons.attach_money,
                _currency,
                _currencies,
                (value) => setState(() => _currency = value!),
                isDesktop,
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                'Auto Backup',
                'Backup otomatis setiap hari',
                Icons.backup,
                _autoBackup,
                (value) => setState(() => _autoBackup = value),
                isDesktop,
              ),
              const Divider(height: 1),
              _buildActionTile(
                'Clear Cache',
                'Hapus data cache aplikasi',
                Icons.delete_sweep,
                AppTheme.warningColor,
                () => _showClearCacheDialog(),
                isDesktop,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingsCard(
            title: 'Keamanan',
            icon: Icons.security_rounded,
            color: AppTheme.successColor,
            isDesktop: isDesktop,
            children: [
              _buildActionTile(
                'Ubah Password',
                'Perbarui kata sandi akun',
                Icons.lock_outline,
                AppTheme.primaryMain,
                () => _showChangePassword(),
                isDesktop,
              ),
              const Divider(height: 1),
              _buildActionTile(
                'Riwayat Login',
                'Lihat aktivitas login',
                Icons.history,
                AppTheme.textSecondary,
                () => _showLoginHistory(),
                isDesktop,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingsCard(
            title: 'Lainnya',
            icon: Icons.more_horiz,
            color: AppTheme.textSecondary,
            isDesktop: isDesktop,
            children: [
              _buildActionTile(
                'Tentang Aplikasi',
                'Informasi & lisensi',
                Icons.info_outline,
                AppTheme.infoColor,
                () => _showAboutDialog(),
                isDesktop,
              ),
              const Divider(height: 1),
              _buildActionTile(
                'Bantuan & Dukungan',
                'FAQ & hubungi support',
                Icons.help_outline,
                AppTheme.secondaryMain,
                () => _showHelp(),
                isDesktop,
              ),
              const Divider(height: 1),
              _buildActionTile(
                'Logout',
                'Keluar dari akun',
                Icons.logout,
                AppTheme.errorColor,
                () => _showLogoutDialog(),
                isDesktop,
              ),
            ],
          ),
        ],
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
    bool isDesktop,
  ) {
    final themeProvider = context.watch<ThemeProvider>();

    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 20 : 16,
          vertical: isDesktop ? 8 : 4,
        ),
        leading: Icon(icon, color: themeProvider.textSecondary, size: 24),
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
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryMain,
        ),
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    IconData icon,
    String value,
    List<String> items,
    Function(String?) onChanged,
    bool isDesktop,
  ) {
    final themeProvider = context.watch<ThemeProvider>();

    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 20 : 16,
          vertical: isDesktop ? 8 : 4,
        ),
        leading: Icon(icon, color: themeProvider.textSecondary, size: 24),
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
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: themeProvider.cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: themeProvider.borderColor),
          ),
          child: DropdownButton<String>(
            value: value,
            icon: Icon(Icons.arrow_drop_down, color: themeProvider.primaryMain),
            underline: const SizedBox(),
            style: TextStyle(
              color: themeProvider.textPrimary,
              fontSize: isDesktop ? 14 : 13,
              fontWeight: FontWeight.w600,
            ),
            onChanged: onChanged,
            items:
                items.map((item) {
                  return DropdownMenuItem(value: item, child: Text(item));
                }).toList(),
          ),
        ),
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
          'Mode Gelap',
          style: TextStyle(
            fontSize: isDesktop ? 15 : 14,
            fontWeight: FontWeight.w600,
            color: themeProvider.textPrimary,
          ),
        ),
        subtitle: Text(
          themeProvider.isDarkMode ? 'Tema gelap aktif' : 'Tema terang aktif',
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
            'Skema Warna',
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
                        'Pilih Skema Warna',
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
                  'Pilih tema warna yang sesuai dengan preferensi Anda',
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

  void _showEditProfile() {
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
                    color: AppTheme.primaryMain.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.edit, color: AppTheme.primaryMain),
                ),
                const SizedBox(width: 12),
                const Text('Edit Profil'),
              ],
            ),
            content: const Text('Form edit profil akan ditampilkan di sini'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }

  void _showChangePassword() {
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
                    color: AppTheme.primaryMain.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.lock_outline, color: AppTheme.primaryMain),
                ),
                const SizedBox(width: 12),
                const Text('Ubah Password'),
              ],
            ),
            content: const Text('Form ubah password akan ditampilkan di sini'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Ubah'),
              ),
            ],
          ),
    );
  }

  void _showLoginHistory() {
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
                    color: AppTheme.textSecondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.history, color: AppTheme.textSecondary),
                ),
                const SizedBox(width: 12),
                const Text('Riwayat Login'),
              ],
            ),
            content: const Text(
              'Daftar riwayat login akan ditampilkan di sini',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ],
          ),
    );
  }

  void _showClearCacheDialog() {
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
                  child: Icon(
                    Icons.warning_amber,
                    color: AppTheme.warningColor,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Clear Cache'),
              ],
            ),
            content: const Text(
              'Apakah Anda yakin ingin menghapus semua cache?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Cache berhasil dihapus'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.warningColor,
                ),
                child: const Text('Hapus'),
              ),
            ],
          ),
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
                const Text('Tentang Aplikasi'),
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
                  'Aplikasi Point of Sale modern untuk manajemen toko handphone.',
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
                child: const Text('Tutup'),
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
                const Text('Bantuan & Dukungan'),
              ],
            ),
            content: const Text(
              'FAQ dan kontak support akan ditampilkan di sini',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ],
          ),
    );
  }

  void _showLogoutDialog() {
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
                    color: AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.logout, color: AppTheme.errorColor),
                ),
                const SizedBox(width: 12),
                const Text('Konfirmasi Logout'),
              ],
            ),
            content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to login
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
