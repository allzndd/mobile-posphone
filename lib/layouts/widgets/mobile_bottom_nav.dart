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
                  icon: Icons.inventory_2_rounded,
                  label: 'Produk',
                  index: 1,
                  isSelected: selectedIndex == 1,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.point_of_sale_rounded,
                  label: 'Transaksi',
                  index: 2,
                  isSelected: selectedIndex == 2 || selectedIndex == 6,
                  showSubmenu: true,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.people_rounded,
                  label: 'Pelanggan',
                  index: 3,
                  isSelected: selectedIndex == 3,
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
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (showSubmenu) {
            _showTransaksiMenu(context);
          } else {
            onMenuItemTap(index);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryMain.withOpacity(0.1)
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
                color: isSelected ? AppTheme.primaryMain : AppTheme.textTertiary,
                size: 22,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppTheme.primaryMain : AppTheme.textTertiary,
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

  void _showTransaksiMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                  color: AppTheme.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.primaryMain, AppTheme.secondaryMain],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.point_of_sale_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Pilih Transaksi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildSubmenuItem(
                context: context,
                icon: Icons.arrow_downward_rounded,
                title: 'Transaksi Masuk',
                subtitle: 'Kelola penjualan & pembayaran',
                color: AppTheme.successColor,
                index: 2,
                isSelected: selectedIndex == 2,
              ),
              const Divider(height: 1),
              _buildSubmenuItem(
                context: context,
                icon: Icons.arrow_upward_rounded,
                title: 'Transaksi Keluar',
                subtitle: 'Kelola pembelian & pengeluaran',
                color: AppTheme.errorColor,
                index: 6,
                isSelected: selectedIndex == 6,
              ),
              const SizedBox(height: 20),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          onMenuItemTap(index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? color : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: color, size: 24)
              else
                Icon(Icons.chevron_right, color: AppTheme.textTertiary, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
