import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_provider.dart';
import '../screens/main_layout.dart';

/// Custom App Bar Widget
class CustomAppBar extends StatelessWidget {
  final String title;
  final bool isDesktop;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.isDesktop = true,
    this.showBackButton = true,
  });

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
            // Back Button
            if (showBackButton) ...[
              Container(
                decoration: BoxDecoration(
                  color: themeProvider.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: themeProvider.primaryMain,
                    size: 20,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const MainLayout(
                          title: 'Dashboard',
                          selectedIndex: 0,
                        ),
                      ),
                    );
                  },
                  tooltip: 'Back to Dashboard',
                ),
              ),
              SizedBox(width: isNarrow ? 8 : 12),
            ],
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: isNarrow ? 20 : 26,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.primaryMain,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8),

            // User Profile with Dropdown
            PopupMenuButton<String>(
              offset: const Offset(0, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                if (value == 'settings') {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder:
                          (context) => const MainLayout(
                            title: 'Settings',
                            selectedIndex: 4,
                          ),
                    ),
                  );
                }
              },
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: 'settings',
                      child: Row(
                        children: [
                          Icon(
                            Icons.settings_rounded,
                            color: themeProvider.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Settings',
                            style: TextStyle(
                              color: themeProvider.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
              child: Container(
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
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: themeProvider.textPrimary,
                            ),
                          ),
                          Text(
                            'Administrator',
                            style: TextStyle(
                              fontSize: 15,
                              color: themeProvider.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      color: themeProvider.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
