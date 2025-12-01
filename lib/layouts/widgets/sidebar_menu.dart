import 'package:flutter/material.dart';

/// Sidebar Menu Items
class SidebarMenu extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final menuItems = [
      {'icon': Icons.dashboard, 'title': 'Dashboard', 'index': 0},
      {'icon': Icons.inventory_2, 'title': 'Produk', 'index': 1},
      {'icon': Icons.shopping_cart, 'title': 'Transaksi', 'index': 2},
      {'icon': Icons.people, 'title': 'Pelanggan', 'index': 3},
      {'icon': Icons.assessment, 'title': 'Laporan', 'index': 4},
      {'icon': Icons.settings, 'title': 'Pengaturan', 'index': 5},
    ];

    return ListView.builder(
      itemCount: menuItems.length,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemBuilder: (context, index) {
        final item = menuItems[index];
        final isSelected = selectedIndex == item['index'];

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onMenuItemTap(item['index'] as int),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? Colors.white.withOpacity(0.2)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isSelected
                            ? Colors.white.withOpacity(0.3)
                            : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      color: Colors.white,
                      size: 24,
                    ),
                    if (!isCollapsed) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          item['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
