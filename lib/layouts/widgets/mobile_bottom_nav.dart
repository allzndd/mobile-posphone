import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/theme_provider.dart';

/// Mobile Bottom Navigation
class MobileBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onMenuItemTap;

  const MobileBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onMenuItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.max,
              children: [
                _buildNavItem(
                  context: context,
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  index: 0,
                  isSelected: selectedIndex == 0,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.arrow_downward_rounded,
                  label: 'Incoming',
                  index: 2,
                  isSelected: selectedIndex == 2,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.arrow_upward_rounded,
                  label: 'Outgoing',
                  index: 5,
                  isSelected: selectedIndex == 5,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.apps_rounded,
                  label: 'More',
                  index: -1,
                  isSelected:
                      selectedIndex == 1 ||
                      selectedIndex == 3 ||
                      selectedIndex == 4 ||
                      selectedIndex == 6 ||
                      selectedIndex == 7 ||
                      selectedIndex == 8 ||
                      selectedIndex == 9 ||
                      selectedIndex == 10 ||
                      selectedIndex == 11 ||
                      selectedIndex == 12 ||
                      selectedIndex == 13,
                  showSubmenu: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    bool showSubmenu = false,
  }) {
    final themeProvider = context.watch<ThemeProvider>();

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (showSubmenu) {
            _showMenuLainnya(context);
          } else {
            onMenuItemTap(index);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color:
                isSelected
                    ? themeProvider.primaryMain.withOpacity(0.1)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color:
                    isSelected
                        ? themeProvider.primaryMain
                        : themeProvider.textTertiary,
                size: 22,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color:
                      isSelected
                          ? themeProvider.primaryMain
                          : themeProvider.textTertiary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMenuLainnya(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            decoration: BoxDecoration(
              color: themeProvider.surfaceColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: themeProvider.borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                themeProvider.primaryMain,
                                themeProvider.secondaryMain,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.apps_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'More Menu',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildSubmenuItem(
                            context: context,
                            icon: Icons.inventory_2_rounded,
                            title: 'Products',
                            subtitle: 'Manage products & stock',
                            color: AppTheme.primaryMain,
                            index: 1,
                            isSelected: selectedIndex == 1,
                          ),
                          const Divider(height: 1),
                          _buildSubmenuItem(
                            context: context,
                            icon: Icons.people_rounded,
                            title: 'Customers',
                            subtitle: 'Manage customer data',
                            color: AppTheme.secondaryMain,
                            index: 3,
                            isSelected: selectedIndex == 3,
                          ),
                          const Divider(height: 1),

                          _buildSubmenuItem(
                            context: context,
                            icon: Icons.palette_rounded,
                            title: 'Theme',
                            subtitle: 'Customize colors & appearance',
                            color: AppTheme.accentPurple,
                            index: 6,
                            isSelected: selectedIndex == 6,
                          ),
                          const Divider(height: 1),
                          _buildSubmenuItem(
                            context: context,
                            icon: Icons.branding_watermark_rounded,
                            title: 'Logo & Branding',
                            subtitle: 'Change logo & app name',
                            color: Colors.pink,
                            index: 7,
                            isSelected: selectedIndex == 7,
                          ),
                          const Divider(height: 1),
                          _buildSubmenuItem(
                            context: context,
                            icon: Icons.psychology_rounded,
                            title: 'AI Chat',
                            subtitle: 'AI assistant for business analysis',
                            color: Colors.deepPurple,
                            index: 8,
                            isSelected: selectedIndex == 8,
                          ),
                          const Divider(height: 1),
                          _buildSubmenuItem(
                            context: context,
                            icon: Icons.store,
                            title: 'Stores',
                            subtitle: 'Manage store locations',
                            color: Colors.teal,
                            index: 9,
                            isSelected: selectedIndex == 9,
                          ),
                          const Divider(height: 1),
                          _buildSubmenuItem(
                            context: context,
                            icon: Icons.build_circle_rounded,
                            title: 'Services',
                            subtitle: 'Manage services & repairs',
                            color: Colors.blue,
                            index: 10,
                            isSelected: selectedIndex == 10,
                          ),
                          const Divider(height: 1),
                          _buildSubmenuItem(
                            context: context,
                            icon: Icons.local_shipping_rounded,
                            title: 'Suppliers',
                            subtitle: 'Manage supplier & vendor data',
                            color: Colors.orange,
                            index: 11,
                            isSelected: selectedIndex == 11,
                          ),
                          const Divider(height: 1),
                          _buildSubmenuItem(
                            context: context,
                            icon: Icons.swap_horiz_rounded,
                            title: 'Trade In',
                            subtitle: 'Product trade-in transactions',
                            color: Colors.cyan,
                            index: 12,
                            isSelected: selectedIndex == 12,
                          ),
                          const Divider(height: 1),
                          _buildSubmenuItem(
                            context: context,
                            icon: Icons.assessment_rounded,
                            title: 'Reports',
                            subtitle: 'Complete reports & analytics',
                            color: Colors.indigo,
                            index: 13,
                            isSelected: selectedIndex == 13,
                          ),
                          const Divider(height: 1),
                          _buildSubmenuItem(
                            context: context,
                            icon: Icons.settings_rounded,
                            title: 'Settings',
                            subtitle: 'App & system configuration',
                            color: AppTheme.textSecondary,
                            index: 4,
                            isSelected: selectedIndex == 4,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSubmenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required int index,
    required bool isSelected,
  }) {
    final themeProvider = context.watch<ThemeProvider>();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          onMenuItemTap(index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? color : themeProvider.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: themeProvider.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected ? Icons.check_circle : Icons.chevron_right,
                color: isSelected ? color : themeProvider.textTertiary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
