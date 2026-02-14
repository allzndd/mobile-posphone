import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/desktop_sidebar.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/mobile_bottom_nav.dart';
import '../../config/theme_provider.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../produk/screens/produk_screen.dart';
import '../../transaksi/screens/incoming_transaction_screen.dart/index.screen.dart';
import '../../transaksi/screens/outgoing_transaction_screen.dart/index.screen.dart';
import '../../customers/screens/index.screen.dart';
import '../../pengaturan/screens/pengaturan_screen.dart';
import '../../brand/screens/index.screen.dart';
import '../../theme/screens/theme_customizer_screen.dart';
import '../../chat_analysis/screens/chat_analysis_screen.dart';
import '../../store/screens/index.screen.dart';
import '../../services/screens/index.screen.dart';
import '../../suppliers/screens/index.screen.dart';
import '../../trade_in/screens/index.screen.dart';
import '../../reports/screens/index.screen.dart';
import '../../user_management/screens/index.screen.dart';
import '../../expense_category/screens/index.screen.dart';
import '../../color/screens/index.screen.dart';
import '../../ram/screens/index.screen.dart';
import '../../storage/screens/index.screen.dart';
import '../../transaksi/screens/expense_transaction_screen.dart/index.screen.dart';

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

  // Screen list for navigation
  final List<Widget> _screens = [
    const DashboardScreen(), // 0
    const ProdukScreen(), // 1
    const IncomingTransactionIndexScreen(), // 2
    const CustomerIndexScreen(), // 3
    const PengaturanScreen(), // 4
    const OutgoingTransactionIndexScreen(), // 5
    const ThemeCustomizerScreen(), // 6
    const BrandingIndexScreen(), // 7
    const ChatAnalysisScreen(), // 8
    const StoreIndexScreen(), // 9
    const ServiceIndexScreen(), // 10
    const SupplierIndexScreen(), // 11
    const TradeInIndexScreen(), // 12
    const ReportsIndexScreen(), // 13
    const UserManagementScreen(), // 14
    const ExpenseTransactionIndexScreen(), // 15 - expense transaction
    const ExpenseCategoryIndexScreen(), // 16 - placeholder for history
    const ExpenseCategoryIndexScreen(), // 17
    const ColorIndexScreen(), // 18
    const RamIndexScreen(), // 19 - RAM Info
    const StorageIndexScreen(), // 20 - Storage
  ];

  // Title for each screen
  final List<String> _screenTitles = [
    'Dashboard', // 0
    'Products', // 1
    'Incoming Transaction', // 2
    'Customers', // 3
    'Settings', // 4
    'Outgoing Transaction', // 5
    'Theme Customizer', // 6
    'Logo & Branding', // 7
    'AI Business Assistant', // 8
    'Stores', // 9
    'Services & Repairs', // 10
    'Suppliers', // 11
    'Trade In', // 12
    'Reports & Analytics', // 13
    'User Management', // 14
    'Expense Transaction', // 15
    'Transaction History', // 16
    'Expense Categories', // 17
    'Colors', // 18
    'RAM Info', // 19
    'Storage', // 20
  ];

  void _onMenuItemTap(int index) {
    // Safety check to prevent RangeError
    if (index >= 0 && index < _screens.length && index < _screenTitles.length) {
      setState(() {
        _currentIndex = index;
      });
    } else {
      // Fallback to dashboard if index is invalid
      setState(() {
        _currentIndex = 0;
      });
    }
  }

  String get _currentTitle {
    if (_currentIndex >= 0 && _currentIndex < _screenTitles.length) {
      return _screenTitles[_currentIndex];
    }
    return 'Dashboard';
  }

  Widget get _currentScreen {
    if (_currentIndex >= 0 && _currentIndex < _screens.length) {
      return _screens[_currentIndex];
    }
    return const DashboardScreen();
  }

  void _onLogout() {
    // Logout implementation
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
                title: _currentTitle,
                isDesktop: true,
                showBackButton: _currentIndex != 0,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: themeProvider.backgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                    ),
                  ),
                  child: _currentScreen,
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
        CustomAppBar(
          title: _currentTitle,
          isDesktop: false,
          showBackButton: _currentIndex != 0,
        ),
        Expanded(
          child: _currentScreen,
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
        CustomAppBar(
          title: _currentTitle,
          isDesktop: false,
          showBackButton: _currentIndex != 0,
        ),
        Expanded(
          child: _currentScreen,
        ),
        MobileBottomNav(
          selectedIndex: _currentIndex,
          onMenuItemTap: _onMenuItemTap,
        ),
      ],
    );
  }
}

// Placeholder Screen for System Info (RAM & Storage)
class _SystemInfoScreen extends StatelessWidget {
  final String title;

  const _SystemInfoScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: themeProvider.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                title == 'RAM Info' ? Icons.memory_rounded : Icons.storage_rounded,
                size: 64,
                color: themeProvider.primaryMain,
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'System information feature',
                style: TextStyle(
                  fontSize: 14,
                  color: themeProvider.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeProvider.primaryMain,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Back to Dashboard',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

