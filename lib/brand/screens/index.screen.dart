import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../config/theme_provider.dart';
import '../../config/logo_provider.dart';
import '../../layouts/screens/main_layout.dart';

class BrandingIndexScreen extends StatefulWidget {
  const BrandingIndexScreen({super.key});

  @override
  State<BrandingIndexScreen> createState() => _BrandingIndexScreenState();
}

class _BrandingIndexScreenState extends State<BrandingIndexScreen> {
  final _appNameController = TextEditingController();
  final _appTaglineController = TextEditingController();
  final _imagePicker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final logoProvider = context.read<LogoProvider>();
    _appNameController.text = logoProvider.appName;
    _appTaglineController.text = logoProvider.appTagline;
  }

  @override
  void dispose() {
    _appNameController.dispose();
    _appTaglineController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 90,
      );

      if (image != null) {
        setState(() => _isLoading = true);

        if (mounted) {
          if (kIsWeb) {
            // Untuk Web: convert image ke base64
            final bytes = await image.readAsBytes();
            final base64String = base64Encode(bytes);
            await context.read<LogoProvider>().setLogo(
              'data:image/png;base64,$base64String',
            );
          } else {
            // Untuk Mobile: simpan path langsung
            await context.read<LogoProvider>().setLogo(image.path);
          }

          setState(() => _isLoading = false);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Logo uploaded successfully'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal upload logo: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _removeLogo() async {
    await context.read<LogoProvider>().removeLogo();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Logo removed successfully'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _saveAppInfo() async {
    final logoProvider = context.read<LogoProvider>();
    await logoProvider.setAppName(_appNameController.text);
    await logoProvider.setAppTagline(_appTaglineController.text);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Application information saved successfully'),
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
            title: const Text('Reset to Default?'),
            content: const Text(
              'All branding settings will be reset to default.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
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
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Branding reset successfully'),
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
    final logoProvider = context.watch<LogoProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final isTablet = screenWidth > 600 && screenWidth <= 900;

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
        body: RefreshIndicator(
          onRefresh: () async {
            // Refresh logic if needed
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildModernHeader(themeProvider, isDesktop),
                _buildInfoCards(
                  themeProvider,
                  logoProvider,
                  isDesktop,
                  isTablet,
                ),
                _buildContent(themeProvider, logoProvider, isDesktop),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(ThemeProvider themeProvider, bool isDesktop) {
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
                        'Brand & Logo',
                        style: TextStyle(
                          fontSize: isDesktop ? 24 : 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: isDesktop ? 4 : 2),
                      Text(
                        'Customize your application identity',
                        style: TextStyle(
                          fontSize: isDesktop ? 14 : 12,
                          color: Colors.white.withOpacity(0.8),
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

  Widget _buildInfoCards(
    ThemeProvider themeProvider,
    LogoProvider logoProvider,
    bool isDesktop,
    bool isTablet,
  ) {
    List<Map<String, dynamic>> info = [
      {
        'title': 'Logo Status',
        'value': logoProvider.logoPath != null ? 'Uploaded' : 'Default',
        'icon': Icons.image_rounded,
        'color': logoProvider.logoPath != null ? Colors.green : Colors.orange,
        'subtitle':
            logoProvider.logoPath != null
                ? 'Custom logo active'
                : 'Using default logo',
      },
      {
        'title': 'App Name',
        'value': logoProvider.appName,
        'icon': Icons.title_rounded,
        'color': Colors.blue,
        'subtitle': 'Application title',
      },
    ];

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 20 : 16,
        vertical: 8,
      ),
      child:
          isDesktop
              ? Row(
                children:
                    info
                        .map(
                          (stat) => Expanded(
                            child: _buildInfoCard(
                              stat,
                              themeProvider,
                              isDesktop,
                            ),
                          ),
                        )
                        .toList(),
              )
              : Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(info[0], themeProvider, false),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInfoCard(info[1], themeProvider, false),
                      ),
                    ],
                  ),
                ],
              ),
    );
  }

  Widget _buildInfoCard(
    Map<String, dynamic> info,
    ThemeProvider themeProvider,
    bool isDesktop,
  ) {
    final color = info['color'] as Color;

    return Container(
      margin: EdgeInsets.only(
        right: isDesktop ? 16 : 0,
        bottom: isDesktop ? 0 : 8,
      ),
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isDesktop ? 10 : 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(info['icon'], color: color, size: isDesktop ? 24 : 20),
          ),
          SizedBox(width: isDesktop ? 12 : 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  info['value'],
                  style: TextStyle(
                    fontSize: isDesktop ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  info['subtitle'],
                  style: TextStyle(
                    fontSize: isDesktop ? 12 : 11,
                    color: themeProvider.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    ThemeProvider themeProvider,
    LogoProvider logoProvider,
    bool isDesktop,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 20 : 16,
        vertical: 8,
      ),
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
      child:
          isDesktop
              ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildLogoSection(
                          themeProvider,
                          logoProvider,
                          isDesktop,
                        ),
                        const SizedBox(height: 24),
                        _buildAppInfoSection(themeProvider, isDesktop),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        _buildPreviewSection(
                          themeProvider,
                          logoProvider,
                          isDesktop,
                        ),
                        const SizedBox(height: 16),
                        _buildActionButtons(themeProvider, isDesktop),
                      ],
                    ),
                  ),
                ],
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLogoSection(themeProvider, logoProvider, isDesktop),
                  const SizedBox(height: 16),
                  _buildAppInfoSection(themeProvider, isDesktop),
                  const SizedBox(height: 16),
                  _buildPreviewSection(themeProvider, logoProvider, isDesktop),
                  const SizedBox(height: 16),
                  _buildActionButtons(themeProvider, isDesktop),
                  const SizedBox(height: 24),
                ],
              ),
    );
  }

  Widget _buildLogoSection(
    ThemeProvider themeProvider,
    LogoProvider logoProvider,
    bool isDesktop,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Logo Application',
          style: TextStyle(
            fontSize: isDesktop ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: themeProvider.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Upload a logo to display on the login page and sidebar',
          style: TextStyle(fontSize: 14, color: themeProvider.textSecondary),
        ),
        const SizedBox(height: 24),
        Center(
          child: Stack(
            children: [
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: themeProvider.primaryMain.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: themeProvider.primaryMain.withOpacity(0.3),
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child:
                      logoProvider.logoPath != null
                          ? _buildLogoImage(
                            logoProvider.logoPath!,
                            themeProvider,
                          )
                          : Icon(
                            Icons.store_rounded,
                            size: 60,
                            color: themeProvider.primaryMain,
                          ),
                ),
              ),
              if (_isLoading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickImage,
                icon: const Icon(Icons.upload_rounded),
                label: Text(
                  logoProvider.logoPath != null ? 'Change Logo' : 'Upload Logo',
                ),
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
            if (logoProvider.logoPath != null) ...[
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _removeLogo,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remove'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildAppInfoSection(ThemeProvider themeProvider, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Application Information',
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
            labelText: 'App Name',
            labelStyle: TextStyle(color: themeProvider.textSecondary),
            hintText: 'Example: POS Phone',
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
            hintText: 'Example: Make business easier',
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
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _saveAppInfo,
            icon: const Icon(Icons.save_rounded),
            label: const Text('Save Information'),
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
    );
  }

  Widget _buildPreviewSection(
    ThemeProvider themeProvider,
    LogoProvider logoProvider,
    bool isDesktop,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: themeProvider.primaryMain.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.visibility_outlined,
                color: themeProvider.primaryMain,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Preview Display',
              style: TextStyle(
                fontSize: isDesktop ? 18 : 16,
                fontWeight: FontWeight.bold,
                color: themeProvider.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildLoginPreview(themeProvider, logoProvider),
        const SizedBox(height: 16),
        _buildSidebarPreview(themeProvider, logoProvider),
      ],
    );
  }

  Widget _buildLoginPreview(
    ThemeProvider themeProvider,
    LogoProvider logoProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: Column(
        children: [
          Text(
            'Login Screen',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: themeProvider.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              gradient:
                  logoProvider.logoPath == null
                      ? LinearGradient(
                        colors: [
                          themeProvider.primaryMain,
                          themeProvider.primaryDark,
                        ],
                      )
                      : null,
              color: logoProvider.logoPath != null ? Colors.white : null,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child:
                  logoProvider.logoPath != null
                      ? _buildLogoImage(logoProvider.logoPath!, themeProvider)
                      : const Icon(
                        Icons.lock_outline,
                        size: 30,
                        color: Colors.white,
                      ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _appNameController.text.isEmpty
                ? logoProvider.appName
                : _appNameController.text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: themeProvider.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            _appTaglineController.text.isEmpty
                ? logoProvider.appTagline
                : _appTaglineController.text,
            style: TextStyle(fontSize: 10, color: themeProvider.textSecondary),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarPreview(
    ThemeProvider themeProvider,
    LogoProvider logoProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [themeProvider.sidebarStart, themeProvider.sidebarEnd],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Sidebar',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child:
                  logoProvider.logoPath != null
                      ? _buildLogoImage(logoProvider.logoPath!, themeProvider)
                      : const Icon(
                        Icons.store_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _appNameController.text.isEmpty
                ? logoProvider.appName
                : _appNameController.text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeProvider themeProvider, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Advanced Settings',
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
            label: const Text('Reset to Default'),
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
    );
  }

  /// Build logo image based on platform (Web vs Mobile)
  Widget _buildLogoImage(String logoPath, ThemeProvider themeProvider) {
    // Check if base64 data URI
    if (logoPath.startsWith('data:image')) {
      final base64String = logoPath.split(',')[1];
      final bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.store_rounded,
            size: 60,
            color: themeProvider.primaryMain,
          );
        },
      );
    }

    // Check if URL
    if (logoPath.startsWith('http')) {
      return Image.network(
        logoPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.store_rounded,
            size: 60,
            color: themeProvider.primaryMain,
          );
        },
      );
    }

    // Untuk file lokal (Mobile only)
    if (!kIsWeb) {
      return Image.file(
        File(logoPath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.store_rounded,
            size: 60,
            color: themeProvider.primaryMain,
          );
        },
      );
    }

    // Fallback
    return Icon(
      Icons.store_rounded,
      size: 60,
      color: themeProvider.primaryMain,
    );
  }
}
