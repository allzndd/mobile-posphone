import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Widget untuk header auth (logo + title + subtitle)
/// Mendukung:
/// - Icon (default)
/// - Image dari assets
/// - Image dari URL (untuk dynamic logo dari admin panel)
class AuthHeader extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo/Icon
        Container(
          height: 80,
          width: 80,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient:
                logoUrl != null || logoAssetPath != null
                    ? null
                    : const LinearGradient(
                      colors: [AppTheme.primaryMain, AppTheme.primaryDark],
                    ),
            shape: BoxShape.circle,
            color:
                logoUrl != null || logoAssetPath != null ? Colors.white : null,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryMain.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(child: _buildLogoContent()),
        ),

        // Title
        Text(
          title,
          style: TextStyle(
            fontSize: isDesktop ? 32 : 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Subtitle
        Text(
          subtitle,
          style: TextStyle(
            fontSize: isDesktop ? 16 : 14,
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Build logo content based on priority: URL > Asset > Icon
  Widget _buildLogoContent() {
    // Priority 1: Logo dari URL (untuk dynamic logo dari admin panel)
    if (logoUrl != null && logoUrl!.isNotEmpty) {
      return Image.network(
        logoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback ke icon jika URL gagal load
          return Icon(
            icon ?? Icons.store,
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
    if (logoAssetPath != null && logoAssetPath!.isNotEmpty) {
      return Image.asset(
        logoAssetPath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback ke icon jika asset tidak ditemukan
          return Icon(
            icon ?? Icons.store,
            size: 40,
            color: AppTheme.primaryMain,
          );
        },
      );
    }

    // Priority 3: Icon (default)
    return Icon(icon ?? Icons.lock_outline, size: 40, color: Colors.white);
  }
}
