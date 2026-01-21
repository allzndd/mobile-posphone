import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/models/user_model.dart';
import '../../config/logo_provider.dart';
import '../../config/app_theme.dart';
import '../../config/theme_provider.dart';
import '../../layouts/screens/main_layout.dart';
import '../services/dashboard_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _dashboardStats = {};
  List<dynamic> _topProducts = [];
  List<dynamic> _lowStock = [];
  List<dynamic> _recentTransactions = [];
  List<FlSpot> _salesChartData = [];
  String _selectedPeriod = 'week'; // week, month, year
  Map<String, double> _periodProfits = {
    'today': 0,
    'week': 0,
    'month': 0,
    'year': 0,
  };
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
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

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        DashboardService.getDashboardStats(),
        DashboardService.getTopProducts(limit: 4),
        DashboardService.getLowStock(threshold: 5),
        DashboardService.getRecentTransactions(limit: 10),
        DashboardService.getSalesChart(period: _selectedPeriod),
      ]);

      // Debug logging
      print('=== DASHBOARD DEBUG ===');
      print('Stats Response: ${results[0]}');
      print('Top Products Response: ${results[1]}');
      print('Low Stock Response: ${results[2]}');
      print('Recent Transactions Response: ${results[3]}');
      print('Sales Chart Response: ${results[4]}');
      print('======================');

      if (mounted) {
        setState(() {
          if (results[0]['success'] == true) {
            _dashboardStats = results[0]['data'] ?? {};
            print('Dashboard Stats Data: $_dashboardStats');

            // Get period profits from API response
            _periodProfits['today'] =
                (_dashboardStats['today_profit'] ?? 0).toDouble();
            _periodProfits['week'] =
                (_dashboardStats['week_profit'] ?? 0).toDouble();
            _periodProfits['month'] =
                (_dashboardStats['month_profit'] ?? 0).toDouble();
            _periodProfits['year'] =
                (_dashboardStats['year_profit'] ?? 0).toDouble();
          }
          if (results[1]['success'] == true) {
            _topProducts = results[1]['data'] ?? [];
          }
          if (results[2]['success'] == true) {
            _lowStock = results[2]['data'] ?? [];
          }
          if (results[3]['success'] == true) {
            _recentTransactions = results[3]['data'] ?? [];
          }
          if (results[4]['success'] == true && results[4]['data'] != null) {
            final chartData = results[4]['data'] as List;
            _salesChartData =
                chartData.asMap().entries.map((entry) {
                  return FlSpot(
                    entry.key.toDouble(),
                    (entry.value['value'] ?? 0).toDouble(),
                  );
                }).toList();
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading dashboard: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final logoProvider = context.watch<LogoProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        _showLogoutDialog();
      },
      child: Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        body: RefreshIndicator(
          onRefresh: _loadDashboardData,
          child:
              _isLoading
                  ? Center(
                    child: CircularProgressIndicator(
                      color: themeProvider.primaryMain,
                    ),
                  )
                  : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _header(logoProvider, isDark),
                        const SizedBox(height: 24),
                        _quickStats(),
                        const SizedBox(height: 28),
                        _buildQuickAccessSection(),
                        const SizedBox(height: 28),
                        Text(
                          "Grafik Penjualan",
                          style: AppTheme.textTheme.displayMedium?.copyWith(
                            color: themeProvider.primaryMain,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _salesChart(isDark),
                        const SizedBox(height: 32),
                        Text(
                          "Produk Terlaris",
                          style: AppTheme.textTheme.displayMedium?.copyWith(
                            color: themeProvider.primaryMain,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _topProducts.isEmpty
                            ? _emptyState('Tidak ada data produk terlaris')
                            : _topProductsList(),
                        const SizedBox(height: 32),
                        Text(
                          "Stok Menipis",
                          style: AppTheme.textTheme.displayMedium?.copyWith(
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _lowStock.isEmpty
                            ? _emptyState('Semua stok dalam kondisi baik')
                            : _lowStockList(isDark),
                        const SizedBox(height: 32),
                        Text(
                          "Riwayat Transaksi",
                          style: AppTheme.textTheme.displayMedium?.copyWith(
                            color: themeProvider.primaryMain,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _recentTransactions.isEmpty
                            ? _emptyState('Tidak ada transaksi terbaru')
                            : _transactionList(),
                      ],
                    ),
                  ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.logout, color: Colors.red),
                ),
                const SizedBox(width: 12),
                const Text('Konfirmasi Logout'),
              ],
            ),
            content: const Text(
              'Apakah Anda yakin ingin keluar dari aplikasi?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Close confirmation dialog first
                  Navigator.pop(context);

                  try {
                    // Call logout API
                    await AuthService.logout();

                    // Navigate to login screen
                    if (mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false, // Remove all previous routes
                      );
                    }
                  } catch (e) {
                    // Jika error, tetap navigate ke login karena token sudah dihapus
                    if (mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------
  Widget _header(LogoProvider logoProvider, bool isDark) {
    final themeProvider = context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 400;

    return Container(
      padding: EdgeInsets.all(isNarrow ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [themeProvider.primaryMain, themeProvider.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isNarrow ? 10 : 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: isNarrow ? 28 : 32,
                    height: isNarrow ? 28 : 32,
                    child:
                        logoProvider.logoPath != null
                            ? _buildLogoImage(
                              logoProvider.logoPath!,
                              themeProvider,
                            )
                            : Icon(
                              Icons.store,
                              color: Colors.white,
                              size: isNarrow ? 28 : 32,
                            ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Selamat Datang!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isNarrow ? 18 : 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      logoProvider.appName,
                      style: TextStyle(color: Colors.white.withOpacity(0.9)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isNarrow) const SizedBox(height: 12),
          if (!isNarrow)
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: themeProvider.primaryMain,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Hari Ini",
                      style: TextStyle(
                        color: themeProvider.primaryMain,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // QUICK STATS
  // ------------------------------------------------------------
  Widget _quickStats() {
    final themeProvider = context.watch<ThemeProvider>();

    final totalProfit = _dashboardStats['total_profit'] ?? 0;
    final totalTransactions = _dashboardStats['total_transactions'] ?? 0;
    final totalProducts = _dashboardStats['total_products'] ?? 0;
    final totalCustomers = _dashboardStats['total_customers'] ?? 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _stat(
                "Total Profit",
                _formatCurrency(totalProfit),
                Icons.attach_money,
                Colors.green,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _stat(
                "Transaksi",
                totalTransactions.toString(),
                Icons.receipt_long,
                themeProvider.primaryMain,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _stat(
                "Produk",
                totalProducts.toString(),
                Icons.inventory_2,
                themeProvider.secondaryMain,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _stat(
                "Pelanggan",
                totalCustomers.toString(),
                Icons.people,
                themeProvider.primaryLight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _stat(String title, String value, IconData icon, Color color) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(.2), blurRadius: 12)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    color: themeProvider.textSecondary,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // GRAFIK PENJUALAN
  // ------------------------------------------------------------
  Widget _salesChart(bool isDark) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppTheme.lightShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan period selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Grafik Profit',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '7 Hari Terakhir',
                    style: TextStyle(
                      fontSize: 12,
                      color: themeProvider.textSecondary,
                    ),
                  ),
                ],
              ),
              // Period Dropdown
              PopupMenuButton<String>(
                initialValue: _selectedPeriod,
                onSelected: (value) {
                  setState(() => _selectedPeriod = value);
                  _loadDashboardData();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: themeProvider.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: themeProvider.primaryLight),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedPeriod == 'week'
                            ? 'Mingguan'
                            : _selectedPeriod == 'month'
                            ? 'Bulanan'
                            : 'Tahunan',
                        style: TextStyle(
                          color: themeProvider.primaryMain,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        color: themeProvider.primaryMain,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: 'week',
                        child: Text(
                          'Mingguan',
                          style: TextStyle(
                            fontWeight:
                                _selectedPeriod == 'week'
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'month',
                        child: Text(
                          'Bulanan',
                          style: TextStyle(
                            fontWeight:
                                _selectedPeriod == 'month'
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'year',
                        child: Text(
                          'Tahunan',
                          style: TextStyle(
                            fontWeight:
                                _selectedPeriod == 'year'
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Chart
          SizedBox(
            height: 200,
            child:
                _salesChartData.isEmpty
                    ? Center(
                      child: Text(
                        'Tidak ada data grafik',
                        style: TextStyle(color: themeProvider.textTertiary),
                      ),
                    )
                    : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 2000000,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: themeProvider.textTertiary.withOpacity(
                                0.1,
                              ),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 45,
                              interval: 4000000,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  'Rp ${(value / 1000000).toStringAsFixed(0)}jt',
                                  style: TextStyle(
                                    color: themeProvider.textTertiary,
                                    fontSize: 10,
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= 0 &&
                                    value.toInt() < _salesChartData.length) {
                                  // Show date labels (simplified)
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      'Day ${value.toInt() + 1}',
                                      style: TextStyle(
                                        color: themeProvider.textTertiary,
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minY: 0,
                        lineBarsData: [
                          LineChartBarData(
                            spots: _salesChartData,
                            isCurved: true,
                            color: themeProvider.primaryMain,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: themeProvider.primaryMain,
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  themeProvider.primaryMain.withOpacity(0.3),
                                  themeProvider.primaryMain.withOpacity(0.05),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
          ),
          const SizedBox(height: 20),

          // Period Summary Cards
          Row(
            children: [
              Expanded(
                child: _periodCard(
                  'Hari Ini',
                  _periodProfits['today']!,
                  themeProvider,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _periodCard(
                  'Minggu Ini',
                  _periodProfits['week']!,
                  themeProvider,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _periodCard(
                  'Bulan Ini',
                  _periodProfits['month']!,
                  themeProvider,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _periodCard(
                  'Tahun Ini',
                  _periodProfits['year']!,
                  themeProvider,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _periodCard(String label, double amount, ThemeProvider theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.primaryLight.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.textTertiary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: theme.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            _formatCurrency(amount),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // PRODUK TERLARIS
  // ------------------------------------------------------------
  Widget _topProductsList() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _topProducts.length,
        itemBuilder: (context, index) {
          final product = _topProducts[index];
          return _product(
            product['name'] ?? 'Unknown Product',
            _formatCurrency(product['price'] ?? 0),
            product['sold'] ?? 0,
          );
        },
      ),
    );
  }

  Widget _product(String name, String price, int sold) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.lightShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: themeProvider.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            price,
            style: TextStyle(
              color: themeProvider.primaryMain,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            children: [
              Icon(
                Icons.shopping_cart,
                size: 14,
                color: themeProvider.textSecondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Terjual: $sold',
                  style: TextStyle(
                    color: themeProvider.textSecondary,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // STOK MENIPIS
  // ------------------------------------------------------------
  Widget _lowStockList(bool isDark) {
    return Column(
      children:
          _lowStock
              .map(
                (item) => _lowStockItem(
                  item['name'] ?? 'Unknown Product',
                  item['stock'] ?? 0,
                  isDark,
                ),
              )
              .toList(),
    );
  }

  Widget _lowStockItem(String name, int stock, bool isDark) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(.3)),
        boxShadow: [AppTheme.lightShadow],
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: themeProvider.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "Sisa $stock",
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // RIWAYAT TRANSAKSI
  // ------------------------------------------------------------
  Widget _transactionList() {
    return Column(
      children:
          _recentTransactions
              .map(
                (trans) => _trans(
                  trans['invoice_number'] ?? '-',
                  trans['customer']?['name'] ?? '-',
                  _formatCurrency(trans['total_price'] ?? 0),
                  trans['transaction_type'] ?? 'income',
                  trans['payment']?['status'] ?? 'Selesai',
                ),
              )
              .toList(),
    );
  }

  Widget _trans(
    String inv,
    String customer,
    String amount,
    String type,
    String status,
  ) {
    final themeProvider = context.watch<ThemeProvider>();
    final isIncome = type == 'income';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.lightShadow],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isIncome ? AppTheme.successColor : AppTheme.errorColor)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isIncome ? Icons.arrow_upward : Icons.arrow_downward,
            color: isIncome ? AppTheme.successColor : AppTheme.errorColor,
            size: 20,
          ),
        ),
        title: Text(
          inv,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: themeProvider.textPrimary,
          ),
        ),
        subtitle: Text(
          customer,
          style: TextStyle(fontSize: 12, color: themeProvider.textSecondary),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                amount,
                style: TextStyle(
                  color: isIncome ? AppTheme.successColor : AppTheme.errorColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              status,
              style: TextStyle(fontSize: 10, color: themeProvider.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // QUICK ACCESS MENU - Modern M-Banking Style
  // ------------------------------------------------------------
  Widget _buildQuickAccessSection() {
    final themeProvider = context.watch<ThemeProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Quick Access",
              style: AppTheme.textTheme.displayMedium?.copyWith(
                color: themeProvider.primaryMain,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: themeProvider.primaryMain.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "All Features",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.primaryMain,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildMenuGrid(),
      ],
    );
  }

  Widget _buildMenuGrid() {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 4 : 4;

    final menuItems = <Map<String, dynamic>>[
      {
        'icon': Icons.inventory_2_rounded,
        'title': 'Products',
        'color': const Color(0xFF4CAF50),
        'index': 1,
      },
      {
        'icon': Icons.people_rounded,
        'title': 'Customers',
        'color': const Color(0xFF2196F3),
        'index': 3,
      },
      {
        'icon': Icons.psychology_rounded,
        'title': 'AI Chat',
        'color': const Color(0xFF9C27B0),
        'index': 8,
      },
      {
        'icon': Icons.palette_rounded,
        'title': 'Theme',
        'color': const Color(0xFFE91E63),
        'index': 6,
      },
      {
        'icon': Icons.branding_watermark_rounded,
        'title': 'Logo',
        'color': const Color(0xFFFF4081),
        'index': 7,
      },
      {
        'icon': Icons.build_circle_rounded,
        'title': 'Services',
        'color': const Color(0xFF3F51B5),
        'index': 10,
      },
      {
        'icon': Icons.local_shipping_rounded,
        'title': 'Suppliers',
        'color': const Color(0xFFFF9800),
        'index': 11,
      },
      {
        'icon': Icons.swap_horiz_rounded,
        'title': 'Trade In',
        'color': const Color(0xFF00BCD4),
        'index': 12,
      },
    ];

    // Add Stores only for owner (role_id = 2)
    if (_currentUser?.roleId == 2) {
      menuItems.add({
        'icon': Icons.store_rounded,
        'title': 'Stores',
        'color': const Color(0xFF00BCD4),
        'index': 9,
      });
    }

    // Add Reports only for owner (role_id = 2)
    if (_currentUser?.roleId == 2) {
      menuItems.add({
        'icon': Icons.assessment_rounded,
        'title': 'Reports',
        'color': const Color(0xFF673AB7),
        'index': 13,
      });
    }

    // Add User Management only for owners (role_id = 2)
    if (_currentUser?.roleId == 2) {
      menuItems.add({
        'icon': Icons.manage_accounts_rounded,
        'title': 'Users',
        'color': const Color(0xFF9C27B0),
        'index': 14,
      });
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.0,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _buildMenuCard(
          icon: item['icon'] as IconData,
          title: item['title'] as String,
          color: item['color'] as Color,
          onTap: () => _navigateToScreen(item['index'] as int),
        );
      },
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    final themeProvider = context.watch<ThemeProvider>();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: themeProvider.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToScreen(int index) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (context) =>
                MainLayout(title: _getScreenTitle(index), selectedIndex: index),
      ),
    );
  }

  String _getScreenTitle(int index) {
    final titles = {
      1: 'Products',
      3: 'Customers',
      4: 'Settings',
      6: 'Theme Customizer',
      8: 'AI Business Assistant',
      9: 'Stores',
      10: 'Services & Repairs',
      11: 'Suppliers',
      12: 'Trade In',
      13: 'Reports & Analytics',
      14: 'User Management',
    };
    return titles[index] ?? 'Dashboard';
  }

  Widget _emptyState(String message) {
    final themeProvider = context.watch<ThemeProvider>();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: themeProvider.textTertiary, fontSize: 14),
        ),
      ),
    );
  }

  String _formatCurrency(dynamic value) {
    try {
      final number = value is String ? double.parse(value) : value.toDouble();
      // Format dengan pemisah ribuan titik, tanpa desimal
      final formatter = NumberFormat('#,##0', 'id_ID');
      return 'Rp ${formatter.format(number)}';
    } catch (e) {
      return 'Rp 0';
    }
  }

  /// Build logo image based on platform (Web vs Mobile)
  Widget _buildLogoImage(String logoPath, ThemeProvider themeProvider) {
    // Check if base64 data URI
    if (logoPath.startsWith('data:image')) {
      final base64String = logoPath.split(',')[1];
      final bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.store, color: Colors.white, size: 28);
        },
      );
    }

    // Check if URL
    if (logoPath.startsWith('http')) {
      return Image.network(
        logoPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.store, color: Colors.white, size: 28);
        },
      );
    }

    // Untuk file lokal (Mobile only)
    if (!kIsWeb) {
      return Image.file(
        File(logoPath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.store, color: Colors.white, size: 28);
        },
      );
    }

    // Fallback
    return Icon(Icons.store, color: Colors.white, size: 28);
  }
}
