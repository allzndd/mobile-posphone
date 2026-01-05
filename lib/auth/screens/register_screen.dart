import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:convert';
import '../../component/validation_handler.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_card.dart';
import '../widgets/auth_header.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/social_login_button.dart';
import '../widgets/divider_with_text.dart';
import '../../config/app_theme.dart';
import '../../config/theme_provider.dart';
import '../../config/logo_provider.dart';
import '../providers/branding_provider.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        context.showErrorSnack('Anda harus menyetujui syarat dan ketentuan');
        return;
      }

      setState(() => _isLoading = true);

      try {
        // Call API register
        await AuthService.register(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
          _confirmPasswordController.text,
        );

        if (mounted) {
          setState(() => _isLoading = false);

          // Tampilkan pesan sukses menggunakan ValidationHandler
          context.showSuccess(
            title: 'Registrasi Berhasil!',
            message: 'Akun Anda telah berhasil dibuat. Silakan login dengan akun Anda.',
            onPressed: () {
              Navigator.of(context).pop(); // Tutup dialog
              Navigator.of(context).pop(); // Kembali ke login screen
            },
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          
          // Tampilkan error message menggunakan ValidationHandler
          context.showErrorSnack(e.toString().replaceFirst('Exception: ', ''));
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
    final themeProvider = context.watch<ThemeProvider>();
    final logoProvider = context.watch<LogoProvider>();

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
                                      themeProvider.primaryMain.withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: themeProvider.primaryMain.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: logoProvider.logoPath != null && logoProvider.logoPath!.isNotEmpty
                                      ? _buildLogoImage(logoProvider.logoPath!, themeProvider, isMobile)
                                      : Icon(
                                          Icons.person_add_outlined,
                                          size: isMobile ? 40 : 50,
                                          color: Colors.white,
                                        ),
                                ),
                              ),
                              SizedBox(height: isMobile ? 20 : 24),
                              Text(
                                branding.appName,
                                style: TextStyle(
                                  fontSize: isMobile ? 26 : 32,
                                  fontWeight: FontWeight.bold,
                                  color: themeProvider.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Daftar untuk mulai mengelola toko Anda',
                                style: TextStyle(
                                  fontSize: isMobile ? 14 : 16,
                                  color: themeProvider.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          SizedBox(height: isMobile ? 32 : 40),

                          // Name Field
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Full Name',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: themeProvider.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _nameController,
                                keyboardType: TextInputType.name,
                                style: TextStyle(color: themeProvider.textPrimary),
                                decoration: InputDecoration(
                                  hintText: 'Enter your full name',
                                  hintStyle: TextStyle(color: themeProvider.textSecondary),
                                  prefixIcon: Icon(
                                    Icons.person_outline,
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
                                validator: (value) => ValidationHandler.validateMinLength(value, 3, 'Nama'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

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
                                style: TextStyle(color: themeProvider.textPrimary),
                                decoration: InputDecoration(
                                  hintText: 'Enter your email',
                                  hintStyle: TextStyle(color: themeProvider.textSecondary),
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
                                style: TextStyle(color: themeProvider.textPrimary),
                                decoration: InputDecoration(
                                  hintText: 'Create a password',
                                  hintStyle: TextStyle(color: themeProvider.textSecondary),
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
                                        _isPasswordVisible = !_isPasswordVisible;
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
                          const SizedBox(height: 20),

                          // Confirm Password Field
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Confirm Password',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: themeProvider.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: !_isConfirmPasswordVisible,
                                style: TextStyle(color: themeProvider.textPrimary),
                                decoration: InputDecoration(
                                  hintText: 'Confirm your password',
                                  hintStyle: TextStyle(color: themeProvider.textSecondary),
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: themeProvider.primaryMain,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isConfirmPasswordVisible
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: themeProvider.textSecondary,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
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
                                validator: (value) => ValidationHandler.validateConfirmPassword(
                                  _passwordController.text,
                                  value,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Terms & Conditions
                          Row(
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: Checkbox(
                                  value: _agreeToTerms,
                                  onChanged: (value) {
                                    setState(() {
                                      _agreeToTerms = value ?? false;
                                    });
                                  },
                                  activeColor: themeProvider.primaryMain,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Wrap(
                                  children: [
                                    Text(
                                      'I agree to ',
                                      style: TextStyle(
                                        color: themeProvider.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Text(
                                        'Terms & Conditions',
                                        style: TextStyle(
                                          color: themeProvider.primaryMain,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isMobile ? 28 : 32),

                          // Register Button
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
                                  color: themeProvider.primaryMain.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Create Account',
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
                                padding: const EdgeInsets.symmetric(horizontal: 16),
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

                          // Login Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: TextStyle(
                                  color: themeProvider.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Sign In',
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
          border: Border.all(
            color: themeProvider.borderColor,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 28,
          color: themeProvider.textPrimary,
        ),
      ),
    );
  }

  /// Build logo image based on platform and URL type
  Widget _buildLogoImage(String logoPath, ThemeProvider themeProvider, bool isMobile) {
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
          return Icon(Icons.person_add_outlined, color: Colors.white, size: isMobile ? 40 : 50);
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
          return Icon(Icons.person_add_outlined, color: Colors.white, size: isMobile ? 40 : 50);
        },
      );
    }

    // For local file path
    if (kIsWeb) {
      // Web tidak support Image.file, gunakan icon saja
      return Icon(Icons.person_add_outlined, color: Colors.white, size: isMobile ? 40 : 50);
    } else {
      // Mobile support Image.file
      return Image.file(
        File(logoPath),
        width: isMobile ? 80 : 100,
        height: isMobile ? 80 : 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.person_add_outlined, color: Colors.white, size: isMobile ? 40 : 50);
        },
      );
    }
  }
}
