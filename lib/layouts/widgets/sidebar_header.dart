import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_provider.dart';
import '../../auth/providers/branding_provider.dart';

/// Sidebar Header - Logo & App Name
class SidebarHeader extends StatelessWidget {
  final bool isCollapsed;

  const SidebarHeader({super.key, required this.isCollapsed});

  @override
  Widget build(BuildContext context) {
    final branding = context.watch<BrandingProvider>();
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
                  branding.logoUrl != null && branding.logoUrl!.isNotEmpty
                      ? Image.network(
                        branding.logoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.store,
                            color: Colors.white,
                            size: 28,
                          );
                        },
                      )
                      : const Icon(Icons.store, color: Colors.white, size: 28),
            ),
          ),
          if (!isCollapsed) ...[
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    branding.appName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    branding.appTagline,
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
}
