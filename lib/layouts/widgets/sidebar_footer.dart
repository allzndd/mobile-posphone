import 'package:flutter/material.dart';

/// Sidebar Footer - Collapse & Logout
class SidebarFooter extends StatelessWidget {
  final bool isCollapsed;
  final Function(bool) onCollapseToggle;
  final VoidCallback onLogout;

  const SidebarFooter({
    super.key,
    required this.isCollapsed,
    required this.onCollapseToggle,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(color: Colors.white24, height: 1),
        const SizedBox(height: 12),

        // Collapse/Expand Button
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 8 : 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onCollapseToggle(!isCollapsed),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isCollapsed ? 12 : 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisSize: isCollapsed ? MainAxisSize.min : MainAxisSize.max,
                  mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                  children: [
                    Icon(
                      isCollapsed ? Icons.chevron_right : Icons.chevron_left,
                      color: Colors.white,
                      size: 24,
                    ),
                    if (!isCollapsed) ...[
                      const SizedBox(width: 16),
                      const Text(
                        'Collapse',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),

        // Logout Button
        Padding(
          padding: EdgeInsets.all(isCollapsed ? 8 : 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onLogout,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isCollapsed ? 12 : 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: isCollapsed ? MainAxisSize.min : MainAxisSize.max,
                  mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.logout, color: Colors.white, size: 24),
                    if (!isCollapsed) ...[
                      const SizedBox(width: 16),
                      const Text(
                        'Logout',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
