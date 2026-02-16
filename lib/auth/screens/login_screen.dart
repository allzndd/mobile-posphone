import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:convert';
import '../../layouts/screens/main_layout.dart';
import '../../layouts/screens/version_check_wrapper.dart';
import '../../component/validation_handler.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_card.dart';
import '../widgets/auth_header.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/social_login_button.dart';
import '../widgets/divider_with_text.dart';
import '../../config/logo_provider.dart';
import '../../config/theme_provider.dart';
import 'register_screen.dart';
import '../providers/branding_provider.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load branding config saat screen dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BrandingProvider>().loadThemeConfig();
      context.read<LogoProvider>();

      // Debug: Print logo URL
      print('DEBUG - Logo URL: ${context.read<BrandingProvider>().logoUrl}');
      print('DEBUG - App Name: ${context.read<BrandingProvider>().appName}');
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Call API login
        final loginResponse = await AuthService.login(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (mounted) {
          setState(() => _isLoading = false);

          // Get logoProvider from context
          final logoProvider = context.read<LogoProvider>();

          // Tampilkan dialog sukses menggunakan ValidationHandler
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              // Auto close dialog setelah 1.5 detik
              Future.delayed(const Duration(milliseconds: 1500), () {
                if (Navigator.canPop(dialogContext)) {
                  Navigator.pop(dialogContext);
                  
                  // Navigate ke MainLayout setelah dialog tertutup
                  if (mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder:
                            (context) => VersionCheckWrapper(
                              child: MainLayout(
                                child: Container(),
                                title: 'Dashboard Kasir',
                                selectedIndex: 0,
                              ),
                              title: 'Dashboard Kasir',
                            ),
                      ),
                    );
                  }
                }
              });

              // Tampilkan dialog sukses
              return Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: Material(
                    borderRadius: BorderRadius.circular(24),
                    elevation: 12,
                    shadowColor: Colors.green.withOpacity(0.2),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 400, minWidth: 280),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.white, Colors.grey.shade50],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.green.shade400, Colors.green.shade600],
                                ),
                                borderRadius: BorderRadius.circular(40),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check_circle_outline_rounded,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Login Berhasil',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade800,
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Selamat datang, di ${logoProvider.appName}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                height: 1.5,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);

          // Tampilkan pesan error menggunakan ValidationHandler
          await context.showError(
            title: 'Login Gagal',
            message: e.toString().replaceAll('Exception: ', ''),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final isTablet = size.width >= 600 && size.width < 1200;
    final branding = context.watch<BrandingProvider>();
    final logoProvider = context.watch<LogoProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              themeProvider.primaryMain.withOpacity(0.05),
              themeProvider.backgroundColor,
              themeProvider.primaryMain.withOpacity(0.03),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 40,
                vertical: 20,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isMobile ? double.infinity : (isTablet ? 500 : 450),
                ),
                child: Card(
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  color: themeProvider.surfaceColor,
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 24 : 40),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo & Welcome
                          Column(
                            children: [
                              Container(
                                width: isMobile ? 80 : 100,
                                height: isMobile ? 80 : 100,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      themeProvider.primaryMain,
                                      themeProvider.primaryMain.withOpacity(
                                        0.8,
                                      ),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: themeProvider.primaryMain
                                          .withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child:
                                      logoProvider.logoPath != null &&
                                              logoProvider.logoPath!.isNotEmpty
                                          ? _buildLogoImage(
                                            logoProvider.logoPath!,
                                            themeProvider,
                                            isMobile,
                                          )
                                          : Icon(
                                            Icons.store,
                                            size: isMobile ? 40 : 50,
                                            color: Colors.white,
                                          ),
                                ),
                              ),
                              SizedBox(height: isMobile ? 20 : 24),
                              Text(
                                logoProvider.appName,
                                style: TextStyle(
                                  fontSize: isMobile ? 26 : 32,
                                  fontWeight: FontWeight.bold,
                                  color: themeProvider.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                logoProvider.appTagline,
                                style: TextStyle(
                                  fontSize: isMobile ? 14 : 16,
                                  color: themeProvider.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          SizedBox(height: isMobile ? 32 : 40),

                          // Email Field
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Email Address',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: themeProvider.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(
                                  color: themeProvider.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Enter your email',
                                  hintStyle: TextStyle(
                                    color: themeProvider.textSecondary,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: themeProvider.primaryMain,
                                  ),
                                  filled: true,
                                  fillColor: themeProvider.backgroundColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: themeProvider.borderColor,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: themeProvider.primaryMain,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                                validator: ValidationHandler.validateEmail,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Password Field
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Password',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: themeProvider.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                style: TextStyle(
                                  color: themeProvider.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Enter your password',
                                  hintStyle: TextStyle(
                                    color: themeProvider.textSecondary,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: themeProvider.primaryMain,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: themeProvider.textSecondary,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                  filled: true,
                                  fillColor: themeProvider.backgroundColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: themeProvider.borderColor,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: themeProvider.primaryMain,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                                validator: ValidationHandler.validatePassword,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Remember Me & Forgot Password
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                      },
                                      activeColor: themeProvider.primaryMain,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Remember me',
                                    style: TextStyle(
                                      color: themeProvider.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: themeProvider.primaryMain,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isMobile ? 28 : 32),

                          // Login Button
                          Container(
                            height: 54,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  themeProvider.primaryMain,
                                  themeProvider.primaryMain.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: themeProvider.primaryMain.withOpacity(
                                    0.3,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child:
                                  _isLoading
                                      ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Text(
                                        'Sign In',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                            ),
                          ),
                          SizedBox(height: isMobile ? 24 : 32),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: themeProvider.borderColor,
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  'OR',
                                  style: TextStyle(
                                    color: themeProvider.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: themeProvider.borderColor,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Social Login Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildSocialButton(
                                icon: Icons.g_mobiledata,
                                onTap: () {},
                                themeProvider: themeProvider,
                              ),
                              const SizedBox(width: 12),
                              _buildSocialButton(
                                icon: Icons.facebook,
                                onTap: () {},
                                themeProvider: themeProvider,
                              ),
                              const SizedBox(width: 12),
                              _buildSocialButton(
                                icon: Icons.apple,
                                onTap: () {},
                                themeProvider: themeProvider,
                              ),
                            ],
                          ),
                          SizedBox(height: isMobile ? 24 : 32),

                          // Register Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                  color: themeProvider.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const RegisterScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: themeProvider.primaryMain,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required VoidCallback onTap,
    required ThemeProvider themeProvider,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: themeProvider.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: themeProvider.borderColor, width: 1),
        ),
        child: Icon(icon, size: 28, color: themeProvider.textPrimary),
      ),
    );
  }

  /// Build logo image based on platform and URL type
  Widget _buildLogoImage(
    String logoPath,
    ThemeProvider themeProvider,
    bool isMobile,
  ) {
    // Check if base64 data URI
    if (logoPath.startsWith('data:image')) {
      final base64String = logoPath.split(',')[1];
      final bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        width: isMobile ? 80 : 100,
        height: isMobile ? 80 : 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.store,
            color: Colors.white,
            size: isMobile ? 40 : 50,
          );
        },
      );
    }

    // Check if URL (starts with http/https)
    if (logoPath.startsWith('http')) {
      return Image.network(
        logoPath,
        width: isMobile ? 80 : 100,
        height: isMobile ? 80 : 100,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.store,
            color: Colors.white,
            size: isMobile ? 40 : 50,
          );
        },
      );
    }

    // For local file path
    if (kIsWeb) {
      // Web tidak support Image.file, gunakan icon saja
      return Icon(Icons.store, color: Colors.white, size: isMobile ? 40 : 50);
    } else {
      // Mobile support Image.file
      return Image.file(
        File(logoPath),
        width: isMobile ? 80 : 100,
        height: isMobile ? 80 : 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.store,
            color: Colors.white,
            size: isMobile ? 40 : 50,
          );
        },
      );
    }
  }
}
