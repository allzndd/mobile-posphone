import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onMenuItemTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryMain,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Pelanggan'),
        ],
      ),
    );
  }
}
