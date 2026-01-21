import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/theme_provider.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/models/user_model.dart';

/// Mobile Bottom Navigation
class MobileBottomNav extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onMenuItemTap;

  const MobileBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onMenuItemTap,
  });

  @override
  State<MobileBottomNav> createState() => _MobileBottomNavState();
}

class _MobileBottomNavState extends State<MobileBottomNav> {
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await AuthService.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

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
                  isSelected: widget.selectedIndex == 0,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.arrow_downward_rounded,
                  label: 'Incoming',
                  index: 2,
                  isSelected: widget.selectedIndex == 2,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.arrow_upward_rounded,
                  label: 'Outgoing',
                  index: 5,
                  isSelected: widget.selectedIndex == 5,
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
  }) {
    final themeProvider = context.watch<ThemeProvider>();

    return Expanded(
      child: GestureDetector(
        onTap: () {
          widget.onMenuItemTap(index);
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
                            isSelected: widget.selectedIndex == 1,
                          ),
                          const Divider(height: 1),
                          _buildSubmenuItem(
                            context: context,
                            icon: Icons.people_rounded,
                            title: 'Customers',
                            subtitle: 'Manage customer data',
                            color: AppTheme.secondaryMain,
                            index: 3,
                            isSelected: widget.selectedIndex == 3,
                          ),
                          const Divider(height: 1),

                          _buildSubmenuItem(
                            context: context,
                            icon: Icons.palette_rounded,
                            title: 'Theme',
                            subtitle: 'Customize colors & appearance',
                            color: AppTheme.accentPurple,
                            index: 6,
                            isSelected: widget.selectedIndex == 6,
                          ),
                          const Divider(height: 1),
                          _buildSubmenuItem(
                            context: context,
                            icon: Icons.branding_watermark_rounded,
                            title: 'Logo & Branding',
                            subtitle: 'Change logo & app name',
                            color: Colors.pink,
                            index: 7,
                            isSelected: widget.selectedIndex == 7,
                          ),
                          const Divider(height: 1),
                          _buildSubmenuItem(
                            context: context,
                            icon: Icons.psychology_rounded,
                            title: 'AI Chat',
                            subtitle: 'AI assistant for business analysis',
                            color: Colors.deepPurple,
                            index: 8,
                            isSelected: widget.selectedIndex == 8,
                          ),
                          // Stores - only for owner
                          if (_currentUser?.roleId == 2) ...[
                            const Divider(height: 1),
                            _buildSubmenuItem(
                              context: context,
                              icon: Icons.store,
                              title: 'Stores',
                              subtitle: 'Manage store locations',
                              color: Colors.teal,
                              index: 9,
                              isSelected: widget.selectedIndex == 9,
                            ),
                          ],
                          const Divider(height: 1),
                          _buildSubmenuItem(
                            context: context,
                            icon: Icons.build_circle_rounded,
                            title: 'Services',
                            subtitle: 'Manage services & repairs',
                            color: Colors.blue,
                            index: 10,
                            isSelected: widget.selectedIndex == 10,
                          ),
                          const Divider(height: 1),
                          _buildSubmenuItem(
                            context: context,
                            icon: Icons.local_shipping_rounded,
                            title: 'Suppliers',
                            subtitle: 'Manage supplier & vendor data',
                            color: Colors.orange,
                            index: 11,
                            isSelected: widget.selectedIndex == 11,
                          ),
                          const Divider(height: 1),
                          _buildSubmenuItem(
                            context: context,
                            icon: Icons.swap_horiz_rounded,
                            title: 'Trade In',
                            subtitle: 'Product trade-in transactions',
                            color: Colors.cyan,
                            index: 12,
                            isSelected: widget.selectedIndex == 12,
                          ),
                          // Reports - only for owner
                          if (_currentUser?.roleId == 2) ...[
                            const Divider(height: 1),
                            _buildSubmenuItem(
                              context: context,
                              icon: Icons.assessment_rounded,
                              title: 'Reports',
                              subtitle: 'Complete reports & analytics',
                              color: Colors.indigo,
                              index: 13,
                              isSelected: widget.selectedIndex == 13,
                            ),
                          ],
                          // Show User Management only for owners (role_id = 2)
                          if (_currentUser?.roleId == 2) ...[
                            const Divider(height: 1),
                            _buildSubmenuItem(
                              context: context,
                              icon: Icons.manage_accounts_rounded,
                              title: 'User Management',
                              subtitle: 'Manage admin accounts',
                              color: Colors.purple,
                              index: 14,
                              isSelected: widget.selectedIndex == 14,
                            ),
                          ],
                          const Divider(height: 1),
                          _buildSubmenuItem(
                            context: context,
                            icon: Icons.settings_rounded,
                            title: 'Settings',
                            subtitle: 'App & system configuration',
                            color: AppTheme.textSecondary,
                            index: 4,
                            isSelected: widget.selectedIndex == 4,
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
          widget.onMenuItemTap(index);
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
