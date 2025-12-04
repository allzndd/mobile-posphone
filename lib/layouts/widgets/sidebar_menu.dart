import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

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

  final List<Map<String, dynamic>> menuItems = [
    {'icon': Icons.dashboard_rounded, 'title': 'Dashboard', 'index': 0},
    {'icon': Icons.inventory_2_rounded, 'title': 'Produk', 'index': 1},
    {
      'icon': Icons.point_of_sale_rounded,
      'title': 'Transaksi',
      'index': 2,
      'hasSubmenu': true,
      'submenu': [
        {'title': 'Transaksi Masuk', 'index': 2, 'icon': Icons.arrow_downward_rounded},
        {'title': 'Transaksi Keluar', 'index': 6, 'icon': Icons.arrow_upward_rounded},
      ]
    },
    {'icon': Icons.people_rounded, 'title': 'Pelanggan', 'index': 3},
    {'icon': Icons.analytics_rounded, 'title': 'Stok', 'index': 4},
    {'icon': Icons.settings_rounded, 'title': 'Pengaturan', 'index': 5},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryDark,
            AppTheme.primaryMain,
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
            margin: isSubmenu ? const EdgeInsets.only(left: 20) : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: widget.isCollapsed ? MainAxisSize.min : MainAxisSize.max,
              mainAxisAlignment: widget.isCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(
                  item['icon'] as IconData,
                  color: Colors.white,
                  size: isSubmenu ? 20 : 24,
                ),
                if (!widget.isCollapsed) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      item['title'] as String,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSubmenu ? 14 : 15,
                        fontWeight: isSubmenu ? FontWeight.w400 : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (item['hasSubmenu'] == true)
                    AnimatedRotation(
                      turns: _isTransaksiExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
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
          child: _isTransaksiExpanded
              ? Column(
                  children: (item['submenu'] as List<Map<String, dynamic>>)
                      .map((subItem) => _buildMenuItem(subItem, true))
                      .toList(),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}