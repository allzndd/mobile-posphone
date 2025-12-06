import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_provider.dart';
import 'sidebar_header.dart';
import 'sidebar_menu.dart';
import 'sidebar_footer.dart';

/// Desktop Sidebar Widget
class DesktopSidebar extends StatelessWidget {
  final bool isCollapsed;
  final int selectedIndex;
  final Function(bool) onCollapseToggle;
  final Function(int) onMenuItemTap;
  final VoidCallback onLogout;

  const DesktopSidebar({
    super.key,
    required this.isCollapsed,
    required this.selectedIndex,
    required this.onCollapseToggle,
    required this.onMenuItemTap,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      width: isCollapsed ? 80 : 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [themeProvider.sidebarStart, themeProvider.sidebarEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: themeProvider.primaryMain.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          SidebarHeader(isCollapsed: isCollapsed),
          const SizedBox(height: 20),
          Expanded(
            child: SidebarMenu(
              isCollapsed: isCollapsed,
              selectedIndex: selectedIndex,
              onMenuItemTap: onMenuItemTap,
            ),
          ),
          SidebarFooter(
            isCollapsed: isCollapsed,
            onCollapseToggle: onCollapseToggle,
            onLogout: onLogout,
          ),
        ],
      ),
    );
  }
}
