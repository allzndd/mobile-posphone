import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_provider.dart';
import '../../config/logo_provider.dart';

/// Versi sederhana tanpa image picker - menggunakan URL atau icon saja
class LogoBrandingSimpleScreen extends StatefulWidget {
  const LogoBrandingSimpleScreen({super.key});

  @override
  State<LogoBrandingSimpleScreen> createState() =>
      _LogoBrandingSimpleScreenState();
}

class _LogoBrandingSimpleScreenState extends State<LogoBrandingSimpleScreen> {
  final _appNameController = TextEditingController();
  final _appTaglineController = TextEditingController();
  final _logoUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final logoProvider = context.read<LogoProvider>();
    _appNameController.text = logoProvider.appName;
    _appTaglineController.text = logoProvider.appTagline;
    _logoUrlController.text = logoProvider.logoPath ?? '';
  }

  @override
  void dispose() {
    _appNameController.dispose();
    _appTaglineController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final logoProvider = context.read<LogoProvider>();
    await logoProvider.setAppName(_appNameController.text);
    await logoProvider.setAppTagline(_appTaglineController.text);

    if (_logoUrlController.text.isNotEmpty) {
      await logoProvider.setLogo(_logoUrlController.text);
    } else {
      await logoProvider.removeLogo();
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pengaturan berhasil disimpan'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _resetToDefault() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Reset ke Default?'),
            content: const Text(
              'Semua pengaturan branding akan dikembalikan ke default.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Reset'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await context.read<LogoProvider>().resetToDefault();
      final logoProvider = context.read<LogoProvider>();
      setState(() {
        _appNameController.text = logoProvider.appName;
        _appTaglineController.text = logoProvider.appTagline;
        _logoUrlController.text = logoProvider.logoPath ?? '';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Branding berhasil direset'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(themeProvider, isDesktop)),
          SliverToBoxAdapter(child: _buildContent(themeProvider, isDesktop)),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeProvider themeProvider, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
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
              Icons.branding_watermark_rounded,
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
                  'Logo & Branding',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 24 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Personalisasi identitas aplikasi Anda',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isDesktop ? 14 : 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeProvider themeProvider, bool isDesktop) {
    return Container(
      margin: EdgeInsets.all(isDesktop ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInfoCard(themeProvider, isDesktop),
          const SizedBox(height: 24),
          _buildFormSection(themeProvider, isDesktop),
          const SizedBox(height: 24),
          _buildActionButtons(themeProvider, isDesktop),
        ],
      ),
    );
  }

  Widget _buildInfoCard(ThemeProvider themeProvider, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: themeProvider.primaryMain.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.primaryMain.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: themeProvider.primaryMain, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Saat ini menggunakan mode sederhana. Logo dapat diakses melalui URL atau menggunakan icon default.',
              style: TextStyle(
                fontSize: 14,
                color: themeProvider.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection(ThemeProvider themeProvider, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
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
          Text(
            'Pengaturan Aplikasi',
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: themeProvider.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _appNameController,
            style: TextStyle(color: themeProvider.textPrimary),
            decoration: InputDecoration(
              labelText: 'Nama Aplikasi',
              labelStyle: TextStyle(color: themeProvider.textSecondary),
              hintText: 'Contoh: POS Phone',
              hintStyle: TextStyle(color: themeProvider.textTertiary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: themeProvider.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: themeProvider.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeProvider.primaryMain,
                  width: 2,
                ),
              ),
              prefixIcon: Icon(
                Icons.title_rounded,
                color: themeProvider.primaryMain,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _appTaglineController,
            style: TextStyle(color: themeProvider.textPrimary),
            decoration: InputDecoration(
              labelText: 'Tagline',
              labelStyle: TextStyle(color: themeProvider.textSecondary),
              hintText: 'Contoh: Kelola bisnis jadi lebih mudah',
              hintStyle: TextStyle(color: themeProvider.textTertiary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: themeProvider.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: themeProvider.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeProvider.primaryMain,
                  width: 2,
                ),
              ),
              prefixIcon: Icon(
                Icons.description_rounded,
                color: themeProvider.primaryMain,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _logoUrlController,
            style: TextStyle(color: themeProvider.textPrimary),
            decoration: InputDecoration(
              labelText: 'Logo URL (Opsional)',
              labelStyle: TextStyle(color: themeProvider.textSecondary),
              hintText: 'https://example.com/logo.png',
              hintStyle: TextStyle(color: themeProvider.textTertiary),
              helperText: 'Kosongkan untuk menggunakan icon default',
              helperStyle: TextStyle(color: themeProvider.textTertiary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: themeProvider.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: themeProvider.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: themeProvider.primaryMain,
                  width: 2,
                ),
              ),
              prefixIcon: Icon(
                Icons.image_rounded,
                color: themeProvider.primaryMain,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveSettings,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Simpan Pengaturan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.primaryMain,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeProvider themeProvider, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
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
          Text(
            'Pengaturan Lanjutan',
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: themeProvider.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _resetToDefault,
              icon: const Icon(Icons.restore_rounded),
              label: const Text('Reset ke Default'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.red.shade300),
                foregroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
