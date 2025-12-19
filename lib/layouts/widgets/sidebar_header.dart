import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../config/theme_provider.dart';
import '../../config/logo_provider.dart';

/// Sidebar Header - Logo & App Name
class SidebarHeader extends StatelessWidget {
  final bool isCollapsed;

  const SidebarHeader({super.key, required this.isCollapsed});

  @override
  Widget build(BuildContext context) {
    final logoProvider = context.watch<LogoProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 24,
        horizontal: isCollapsed ? 15 : 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [themeProvider.sidebarStart, themeProvider.sidebarEnd],
        ),
      ),
      child: Row(
        mainAxisSize: isCollapsed ? MainAxisSize.min : MainAxisSize.max,
        mainAxisAlignment:
            isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  logoProvider.logoPath != null &&
                          logoProvider.logoPath!.isNotEmpty
                      ? _buildLogoImage(logoProvider.logoPath!, themeProvider)
                      : Icon(
                        Icons.store,
                        color: themeProvider.primaryMain,
                        size: 28,
                      ),
            ),
          ),
          if (!isCollapsed) ...[
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    logoProvider.appName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    logoProvider.appTagline,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build logo image based on platform and URL type
  Widget _buildLogoImage(String logoPath, ThemeProvider themeProvider) {
    // Check if base64 data URI
    if (logoPath.startsWith('data:image')) {
      final base64String = logoPath.split(',')[1];
      final bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.store, color: themeProvider.primaryMain, size: 28);
        },
      );
    }

    // Check if URL (starts with http/https)
    if (logoPath.startsWith('http')) {
      return Image.network(
        logoPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.store, color: themeProvider.primaryMain, size: 28);
        },
      );
    }

    // For local file path
    if (kIsWeb) {
      // Web tidak support Image.file, gunakan network/asset saja
      return Icon(Icons.store, color: themeProvider.primaryMain, size: 28);
    } else {
      // Mobile support Image.file
      return Image.file(
        File(logoPath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.store, color: themeProvider.primaryMain, size: 28);
        },
      );
    }
  }
}
