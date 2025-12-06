import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/branding_provider.dart';
import '../../config/app_theme.dart';
import '../../config/theme_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final branding = context.watch<BrandingProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(branding, isDark),
            const SizedBox(height: 24),

            _quickStats(),
            const SizedBox(height: 28),

            Text(
              "Grafik Penjualan",
              style: AppTheme.textTheme.displayMedium?.copyWith(
                color: AppTheme.primaryMain,
              ),
            ),
            const SizedBox(height: 16),
            _salesChart(isDark),
            const SizedBox(height: 32),

            Text(
              "Produk Terlaris",
              style: AppTheme.textTheme.displayMedium?.copyWith(
                color: AppTheme.primaryMain,
              ),
            ),
            const SizedBox(height: 16),
            _topProducts(),
            const SizedBox(height: 32),

            Text(
              "Stok Menipis",
              style: AppTheme.textTheme.displayMedium?.copyWith(
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            _lowStockList(isDark),
            const SizedBox(height: 32),

            Text(
              "Riwayat Transaksi",
              style: AppTheme.textTheme.displayMedium?.copyWith(
                color: AppTheme.primaryMain,
              ),
            ),
            const SizedBox(height: 16),
            _trans("INV-0012", "Rp 2.500.000", "Tunai"),
            _trans("INV-0011", "Rp 1.200.000", "QRIS"),
            _trans("INV-0010", "Rp 800.000", "Debit"),
            const SizedBox(height: 28),

            Text(
              "Shortcut Pembayaran",
              style: AppTheme.textTheme.displayMedium?.copyWith(
                color: AppTheme.primaryMain,
              ),
            ),
            const SizedBox(height: 16),
            _paymentShortcuts(),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------
  Widget _header(BrandingProvider branding, bool isDark) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [themeProvider.primaryMain, themeProvider.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.store, color: Colors.white, size: 34),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Selamat Datang!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  branding.appName,
                  style: TextStyle(color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppTheme.primaryMain,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  "Hari Ini",
                  style: TextStyle(
                    color: AppTheme.primaryMain,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _stat(
                "Penjualan",
                "Rp 5.200.000",
                Icons.attach_money,
                Colors.green,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _stat(
                "Transaksi",
                "12",
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
                "234",
                Icons.inventory_2,
                themeProvider.secondaryMain,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _stat(
                "Pelanggan",
                "89",
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(.2), blurRadius: 12)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(title, style: TextStyle(color: Colors.grey[600])),
            ],
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
      height: 220,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.lightShadow],
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              color: themeProvider.primaryMain,
              barWidth: 4,
              spots: const [
                FlSpot(0, 2),
                FlSpot(1, 3.2),
                FlSpot(2, 2.8),
                FlSpot(3, 4.1),
                FlSpot(4, 3.9),
                FlSpot(5, 5.2),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // PRODUK TERLARIS
  // ------------------------------------------------------------
  Widget _topProducts() {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _product("Samsung S24 Ultra", "Rp 16.999.000"),
          _product("iPhone 15 Pro", "Rp 18.999.000"),
          _product("Xiaomi 13T", "Rp 7.499.000"),
          _product("Oppo Reno 10", "Rp 6.999.000"),
        ],
      ),
    );
  }

  Widget _product(String name, String price) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(14),
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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            price,
            style: TextStyle(
              color: AppTheme.primaryMain,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.inventory_2, size: 16),
              const SizedBox(width: 6),
              Text(
                "Stok Tersedia",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
    final List<Map<String, dynamic>> items = [
      {"name": "Vivo Y21", "stock": 2},
      {"name": "Samsung A14", "stock": 1},
      {"name": "Oppo A57", "stock": 3},
    ];

    return Column(
      children:
          items
              .map((e) => _lowStockItem(e["name"], e["stock"] as int, isDark))
              .toList(),
    );
  }

  Widget _lowStockItem(String name, int stock, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(.3)),
        boxShadow: [AppTheme.lightShadow],
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "Sisa $stock",
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // RIWAYAT TRANSAKSI
  // ------------------------------------------------------------
  Widget _trans(String inv, String amount, String method) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.lightShadow],
      ),
      child: ListTile(
        leading: const Icon(Icons.receipt_long, color: Colors.blue),
        title: Text(
          inv,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(method),
        trailing: Text(
          amount,
          style: TextStyle(
            color: AppTheme.successColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // PAYMENT SHORTCUT
  // ------------------------------------------------------------
  Widget _paymentShortcuts() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _pay(Icons.money, "Tunai", Colors.green),
        _pay(Icons.qr_code, "QRIS", Colors.blue),
        _pay(Icons.credit_card, "Kartu", Colors.orange),
        _pay(Icons.wallet, "E-Wallet", AppTheme.accentPurple),
      ],
    );
  }

  Widget _pay(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
