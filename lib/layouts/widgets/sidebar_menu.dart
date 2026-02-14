import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/theme_provider.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/models/user_model.dart';

class SidebarMenu extends StatefulWidget {
  final bool isCollapsed;
  final int selectedIndex;
  final Function(int) onMenuItemTap;

  const SidebarMenu({
    super.key,
    required this.isCollapsed,
    required this.selectedIndex,
    required this.onMenuItemTap,
  });

  @override
  State<SidebarMenu> createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> {
  bool _isTransaksiExpanded = false;
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

  List<Map<String, dynamic>> get menuItems {
    final baseItems = <Map<String, dynamic>>[];
    
    // Dashboard - available for all
    baseItems.add({'icon': Icons.dashboard_rounded, 'title': 'Dashboard', 'index': 0});
    
    // Products - available for all
    baseItems.add({'icon': Icons.inventory_2_rounded, 'title': 'Products', 'index': 1});
    
    // Transactions - available for all
    baseItems.add({
      'icon': Icons.point_of_sale_rounded,
      'title': 'Transactions',
      'index': 2,
      'hasSubmenu': true,
      'submenu': [
        {'title': 'Incoming', 'index': 2, 'icon': Icons.arrow_downward_rounded},
        {'title': 'Outgoing', 'index': 5, 'icon': Icons.arrow_upward_rounded},
        {'title': 'Expense Transaction', 'index': 15, 'icon': Icons.receipt_long_rounded},
      ],
    });
    
    // Customers - available for all
    baseItems.add({'icon': Icons.people_rounded, 'title': 'Customers', 'index': 3});
    
    // AI Chat - available for all
    baseItems.add({'icon': Icons.psychology_rounded, 'title': 'AI Chat', 'index': 8});
    
    // Stores - only for owner (role_id = 2)
    if (_currentUser?.roleId == 2) {
      baseItems.add({'icon': Icons.store, 'title': 'Stores', 'index': 9});
    }
    
    // Services - available for all
    baseItems.add({'icon': Icons.build_circle_rounded, 'title': 'Services', 'index': 10});
    
    // Suppliers - available for all
    baseItems.add({'icon': Icons.local_shipping_rounded, 'title': 'Suppliers', 'index': 11});
    
    // Trade In - available for all
    baseItems.add({'icon': Icons.swap_horiz_rounded, 'title': 'Trade In', 'index': 12});
    
    // Reports - only for owner (role_id = 2)
    if (_currentUser?.roleId == 2) {
      baseItems.add({'icon': Icons.assessment_rounded, 'title': 'Reports', 'index': 13});
    }
    
    // Theme - available for all
    baseItems.add({'icon': Icons.palette_rounded, 'title': 'Theme', 'index': 6});
    
    // Logo & Branding - available for all
    baseItems.add({
      'icon': Icons.branding_watermark_rounded,
      'title': 'Logo & Branding',
      'index': 7,
    });

    // Expense Categories - available for all
    baseItems.add({
      'icon': Icons.category_rounded,
      'title': 'Expense Categories',
      'index': 17,
    });

    // Colors - available for all
    baseItems.add({
      'icon': Icons.color_lens_rounded,
      'title': 'Colors',
      'index': 18,
    });

    // RAM - available for all
    baseItems.add({
      'icon': Icons.memory_rounded,
      'title': 'RAM',
      'index': 19,
    });

    // Storage - available for all
    baseItems.add({
      'icon': Icons.storage_rounded,
      'title': 'Storage',
      'index': 20,
    });

    // User Management - only for owners (role_id = 2)
    if (_currentUser?.roleId == 2) {
      baseItems.add({
        'icon': Icons.manage_accounts_rounded,
        'title': 'User Management',
        'index': 14,
      });
    }

    baseItems.add({
      'icon': Icons.settings_rounded,
      'title': 'Settings',
      'index': 4,
    });

    return baseItems;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider?>();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeProvider?.sidebarStart ?? AppTheme.primaryDark,
            themeProvider?.sidebarEnd ?? AppTheme.primaryMain,
          ],
        ),
      ),
      child: ListView.builder(
        itemCount: menuItems.length,
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemBuilder: (context, index) {
          final item = menuItems[index];
          final hasSubmenu = item['hasSubmenu'] == true;

          if (hasSubmenu && !widget.isCollapsed) {
            return _buildMenuItemWithSubmenu(item);
          }

          return _buildMenuItem(item, false);
        },
      ),
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item, bool isSubmenu) {
    final isSelected = widget.selectedIndex == item['index'];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isCollapsed ? 8 : (isSubmenu ? 12 : 12),
        vertical: 4,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (item['hasSubmenu'] == true && !widget.isCollapsed) {
              setState(() {
                _isTransaksiExpanded = !_isTransaksiExpanded;
              });
            } else {
              widget.onMenuItemTap(item['index'] as int);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(
              horizontal: widget.isCollapsed ? 12 : (isSubmenu ? 12 : 16),
              vertical: 12,
            ),
            margin:
                isSubmenu ? const EdgeInsets.only(left: 20) : EdgeInsets.zero,
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? Colors.white.withOpacity(0.25)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border:
                  isSelected
                      ? Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      )
                      : null,
            ),
            child: Row(
              mainAxisSize:
                  widget.isCollapsed ? MainAxisSize.min : MainAxisSize.max,
              mainAxisAlignment:
                  widget.isCollapsed
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
              children: [
                Icon(
                  item['icon'] as IconData,
                  color:
                      isSelected ? Colors.white : Colors.white.withOpacity(0.9),
                  size: isSubmenu ? 20 : 24,
                ),
                if (!widget.isCollapsed) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      item['title'] as String,
                      style: TextStyle(
                        color:
                            isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.9),
                        fontSize: isSubmenu ? 14 : 15,
                        fontWeight:
                            isSelected
                                ? FontWeight.w600
                                : (isSubmenu
                                    ? FontWeight.w400
                                    : FontWeight.w500),
                      ),
                    ),
                  ),
                  if (item['hasSubmenu'] == true)
                    AnimatedRotation(
                      turns: _isTransaksiExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color:
                            isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.9),
                        size: 20,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItemWithSubmenu(Map<String, dynamic> item) {
    return Column(
      children: [
        _buildMenuItem(item, false),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child:
              _isTransaksiExpanded
                  ? Column(
                    children:
                        (item['submenu'] as List<Map<String, dynamic>>)
                            .map((subItem) => _buildMenuItem(subItem, true))
                            .toList(),
                  )
                  : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
