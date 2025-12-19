import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../config/logo_provider.dart';
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
    final logoProvider = context.watch<LogoProvider>();
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
            _header(logoProvider, isDark),
            const SizedBox(height: 24),

            _quickStats(),
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
                color: themeProvider.primaryMain,
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
                color: themeProvider.primaryMain,
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
                    child: logoProvider.logoPath != null
                        ? _buildLogoImage(logoProvider.logoPath!, themeProvider)
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
      height: 220,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
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
                Icons.inventory_2,
                size: 14,
                color: themeProvider.textSecondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  "Stok Tersedia",
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
  Widget _trans(String inv, String amount, String method) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppTheme.lightShadow],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Icon(
          Icons.receipt_long,
          color: themeProvider.primaryMain,
          size: 22,
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
          method,
          style: TextStyle(fontSize: 12, color: themeProvider.textSecondary),
        ),
        trailing: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            amount,
            style: TextStyle(
              color: AppTheme.successColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
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
    final themeProvider = context.watch<ThemeProvider>();

    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: themeProvider.textSecondary),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
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
          return Icon(
            Icons.store,
            color: Colors.white,
            size: 28,
          );
        },
      );
    }

    // Check if URL
    if (logoPath.startsWith('http')) {
      return Image.network(
        logoPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.store,
            color: Colors.white,
            size: 28,
          );
        },
      );
    }

    // Untuk file lokal (Mobile only)
    if (!kIsWeb) {
      return Image.file(
        File(logoPath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.store,
            color: Colors.white,
            size: 28,
          );
        },
      );
    }

    // Fallback
    return Icon(
      Icons.store,
      color: Colors.white,
      size: 28,
    );
  }
}
