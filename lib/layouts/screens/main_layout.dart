import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/desktop_sidebar.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/mobile_bottom_nav.dart';
import '../../config/app_theme.dart';
import '../../config/theme_provider.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../produk/screens/produk_screen.dart';
import '../../transaksi/screens/transaksimasuk_screen.dart';
import '../../transaksi/screens/transaksikeluar_screen.dart';
import '../../pelanggan/screens/pelanggan_screen.dart';
import '../../stok/screens/stok_screen.dart';
import '../../pengaturan/screens/pengaturan_screen.dart';
import '../../theme/screens/theme_customizer_screen.dart';
// import '../../reports/screens/report_screen.dart';

class MainLayout extends StatefulWidget {
  final Widget? child;
  final String title;
  final int selectedIndex;

  const MainLayout({
    super.key,
    this.child,
    required this.title,
    this.selectedIndex = 0,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  bool _isSidebarCollapsed = false;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
  }

  // Daftar layar untuk navigasi
  final List<Widget> _screens = [
    const DashboardScreen(),
    const ProdukScreen(),
    const TransaksiMasukScreen(),
    const PelangganScreen(),
    const StokScreen(),
    const PengaturanScreen(),
    const TransaksiKeluarScreen(),
    const ThemeCustomizerScreen(),
  ];

  // Judul untuk setiap layar
  final List<String> _screenTitles = [
    'Dashboard',
    'Produk',
    'Transaksi Masuk',
    'Pelanggan',
    'Stok',
    'Pengaturan',
    'Transaksi Keluar',
    'Theme Customizer',
  ];

  void _onMenuItemTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onLogout() {
    // Implementasi logout
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final isTablet = screenWidth > 600 && screenWidth <= 900;

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body:
          isDesktop
              ? _buildDesktopLayout()
              : isTablet
              ? _buildTabletLayout()
              : _buildMobileLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    final themeProvider = context.watch<ThemeProvider>();

    return Row(
      children: [
        // Sidebar
        DesktopSidebar(
          isCollapsed: _isSidebarCollapsed,
          selectedIndex: _currentIndex,
          onCollapseToggle: (value) {
            setState(() => _isSidebarCollapsed = value);
          },
          onMenuItemTap: _onMenuItemTap,
          onLogout: _onLogout,
        ),

        // Main Content
        Expanded(
          child: Column(
            children: [
              CustomAppBar(
                title: _screenTitles[_currentIndex],
                isDesktop: true,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: themeProvider.backgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                    ),
                  ),
                  child:
                      _screens.isNotEmpty && _currentIndex < _screens.length
                          ? _screens[_currentIndex]
                          : const DashboardScreen(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      children: [
        CustomAppBar(title: _screenTitles[_currentIndex], isDesktop: false),
        Expanded(
          child:
              _screens.isNotEmpty && _currentIndex < _screens.length
                  ? _screens[_currentIndex]
                  : const DashboardScreen(),
        ),
        MobileBottomNav(
          selectedIndex: _currentIndex,
          onMenuItemTap: _onMenuItemTap,
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        CustomAppBar(title: _screenTitles[_currentIndex], isDesktop: false),
        Expanded(
          child:
              _screens.isNotEmpty && _currentIndex < _screens.length
                  ? _screens[_currentIndex]
                  : const DashboardScreen(),
        ),
        MobileBottomNav(
          selectedIndex: _currentIndex,
          onMenuItemTap: _onMenuItemTap,
        ),
      ],
    );
  }
}
