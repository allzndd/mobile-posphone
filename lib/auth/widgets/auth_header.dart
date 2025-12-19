import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../config/app_theme.dart';
import '../../config/logo_provider.dart';

/// Widget untuk header auth dengan animasi (logo + title + subtitle)
/// Mendukung:
/// - Icon (default)
/// - Image dari assets
/// - Image dari URL (untuk dynamic logo dari admin panel)
class AuthHeader extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final String? logoAssetPath;
  final String? logoUrl;
  final bool isDesktop;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.logoAssetPath,
    this.logoUrl,
    this.isDesktop = false,
  });

  @override
  State<AuthHeader> createState() => _AuthHeaderState();
}

class _AuthHeaderState extends State<AuthHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo/Icon dengan animasi
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            height: 90,
            width: 90,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient:
                  widget.logoUrl != null || widget.logoAssetPath != null
                      ? null
                      : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.primaryMain, AppTheme.primaryDark],
                      ),
              shape: BoxShape.circle,
              color:
                  widget.logoUrl != null || widget.logoAssetPath != null
                      ? Colors.white
                      : null,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryMain.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: AppTheme.primaryLight.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: ClipOval(child: _buildLogoContent()),
          ),
        ),

        // Title dengan animasi slide & fade
        SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ShaderMask(
              shaderCallback:
                  (bounds) => LinearGradient(
                    colors: [AppTheme.primaryDark, AppTheme.primaryMain],
                  ).createShader(bounds),
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: widget.isDesktop ? 36 : 30,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Subtitle dengan animasi fade
        FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              widget.subtitle,
              style: TextStyle(
                fontSize: widget.isDesktop ? 16 : 15,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  /// Build logo content based on priority: Provider > URL > Asset > Icon
  Widget _buildLogoContent() {
    // Priority 1: Logo dari Provider (untuk logo yang diupload)
    final logoProvider = context.watch<LogoProvider>();
    if (logoProvider.logoPath != null && logoProvider.logoPath!.isNotEmpty) {
      // Check if base64 data URI
      if (logoProvider.logoPath!.startsWith('data:image')) {
        final base64String = logoProvider.logoPath!.split(',')[1];
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              widget.icon ?? Icons.store,
              size: 40,
              color: AppTheme.primaryMain,
            );
          },
        );
      }

      // Check if URL
      if (logoProvider.logoPath!.startsWith('http')) {
        return Image.network(
          logoProvider.logoPath!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              widget.icon ?? Icons.store,
              size: 40,
              color: AppTheme.primaryMain,
            );
          },
        );
      }

      // For local file (Mobile only)
      if (!kIsWeb) {
        return Image.file(
          File(logoProvider.logoPath!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              widget.icon ?? Icons.store,
              size: 40,
              color: AppTheme.primaryMain,
            );
          },
        );
      }
    }

    // Priority 2: Logo dari URL (untuk dynamic logo dari admin panel)
    if (widget.logoUrl != null && widget.logoUrl!.isNotEmpty) {
      return Image.network(
        widget.logoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback ke icon jika URL gagal load
          return Icon(
            widget.icon ?? Icons.store,
            size: 40,
            color: AppTheme.primaryMain,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value:
                  loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
              strokeWidth: 2,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.primaryMain,
              ),
            ),
          );
        },
      );
    }

    // Priority 2: Logo dari Assets (untuk logo lokal)
    if (widget.logoAssetPath != null && widget.logoAssetPath!.isNotEmpty) {
      return Image.asset(
        widget.logoAssetPath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback ke icon jika asset tidak ditemukan
          return Icon(
            widget.icon ?? Icons.store,
            size: 40,
            color: AppTheme.primaryMain,
          );
        },
      );
    }

    // Priority 3: Icon (default)
    return Icon(
      widget.icon ?? Icons.lock_outline,
      size: 40,
      color: Colors.white,
    );
  }
}
