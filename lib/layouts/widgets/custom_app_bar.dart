import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_provider.dart';

/// Custom App Bar Widget
class CustomAppBar extends StatelessWidget {
  final String title;
  final bool isDesktop;

  const CustomAppBar({super.key, required this.title, this.isDesktop = true});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 400;

    return SafeArea(
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: themeProvider.surfaceColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: isNarrow ? 12 : 20),
        child: Row(
        children: [
          if (!isDesktop)
            IconButton(
              icon: Icon(Icons.menu, color: themeProvider.textPrimary),
              onPressed: () {
                // TODO: Open drawer
              },
            ),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: isNarrow ? 16 : 20,
                fontWeight: FontWeight.bold,
                color: themeProvider.primaryMain,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 8),

          // Search Button
          IconButton(
            icon: Icon(Icons.search, color: themeProvider.textSecondary),
            onPressed: () {},
            iconSize: isNarrow ? 20 : 24,
          ),

          // Notification Button
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  color: themeProvider.textSecondary,
                ),
                onPressed: () {},
                iconSize: isNarrow ? 20 : 24,
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  height: 8,
                  width: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 4),

          // User Profile
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isNarrow ? 8 : 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: themeProvider.primaryLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: isNarrow ? 14 : 18,
                  backgroundColor: themeProvider.primaryMain,
                  child: Text(
                    'A',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isNarrow ? 12 : 14,
                    ),
                  ),
                ),
                if (isDesktop && !isNarrow) ...[
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Admin',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: themeProvider.textPrimary,
                        ),
                      ),
                      Text(
                        'Administrator',
                        style: TextStyle(
                          fontSize: 11,
                          color: themeProvider.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
