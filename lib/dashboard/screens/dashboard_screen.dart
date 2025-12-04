import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../config/app_theme.dart';
import '../../auth/providers/branding_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  int _currentBannerIndex = 0;
  late PageController _bannerController;
  late AnimationController _headerAnimationController;
  
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _bannerController = PageController();
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _headerAnimationController.forward();
    
    // Auto-scroll banner
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients) {
        int nextPage = (_currentBannerIndex + 1) % 3;
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _headerAnimationController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final branding = context.watch<BrandingProvider>();
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final isTablet = size.width > 600 && size.width <= 900;
    final horizontalPadding = isDesktop ? 40.0 : isTablet ? 24.0 : 16.0;

    return Container(
      color: AppTheme.backgroundLight,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              _buildWelcomeHeader(branding, isDesktop),
              const SizedBox(height: 24),
              
              // Quick Stats Cards
              _buildQuickStats(isDesktop, isTablet),
              const SizedBox(height: 24),
              
              // Action Buttons
              _buildActionButtons(isDesktop),
              const SizedBox(height: 32),
              
              // Product Section
              _buildProductSection(isDesktop),
              const SizedBox(height: 32),
              
              // Transaction History
              _buildTransactionHistory(isDesktop),
              const SizedBox(height: 32),
              
              // Payment Shortcuts
              _buildPaymentShortcuts(isDesktop),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BrandingProvider branding, bool isDesktop) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryMain, AppTheme.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryMain.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: EdgeInsets.all(isDesktop ? 28 : 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.phone_android_rounded,
              color: Colors.white,
              size: isDesktop ? 40 : 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 24 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  branding.appName,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isDesktop ? 16 : 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 20 : 16,
              vertical: isDesktop ? 12 : 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: AppTheme.primaryMain,
                  size: isDesktop ? 20 : 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Hari Ini',
                  style: TextStyle(
                    color: AppTheme.primaryMain,
                    fontWeight: FontWeight.bold,
                    fontSize: isDesktop ? 14 : 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(bool isDesktop, bool isTablet) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isDesktop ? 4 : isTablet ? 2 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isDesktop ? 1.8 : 1.3,
      children: [
        _buildStatCard(
          icon: Icons.attach_money_rounded,
          title: 'Penjualan',
          value: 'Rp 5.2 Jt',
          color: AppTheme.accentGreen,
          isDesktop: isDesktop,
        ),
        _buildStatCard(
          icon: Icons.receipt_long_rounded,
          title: 'Transaksi',
          value: '12',
          color: AppTheme.primaryMain,
          isDesktop: isDesktop,
        ),
        _buildStatCard(
          icon: Icons.inventory_2_rounded,
          title: 'Produk',
          value: '234',
          color: AppTheme.accentOrange,
          isDesktop: isDesktop,
        ),
        _buildStatCard(
          icon: Icons.people_rounded,
          title: 'Pelanggan',
          value: '89',
          color: AppTheme.accentPurple,
          isDesktop: isDesktop,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isDesktop,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Hitung ukuran responsif berdasarkan lebar card
        final cardWidth = constraints.maxWidth;
        final padding = cardWidth < 150 ? 8.0 : (cardWidth < 200 ? 10.0 : 12.0);
        final iconPadding = cardWidth < 150 ? 8.0 : (cardWidth < 200 ? 9.0 : 10.0);
        final iconSize = cardWidth < 150 ? 18.0 : (cardWidth < 200 ? 20.0 : 22.0);
        final valueSize = cardWidth < 150 ? 16.0 : (cardWidth < 200 ? 18.0 : 20.0);
        final titleSize = cardWidth < 150 ? 10.0 : (cardWidth < 200 ? 11.0 : 12.0);
        final spacing = cardWidth < 150 ? 4.0 : 6.0;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(iconPadding),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: iconSize,
                ),
              ),
              SizedBox(height: spacing),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: valueSize,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: titleSize,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(bool isDesktop) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.qr_code_scanner_rounded,
            label: 'Scan Barcode',
            gradient: LinearGradient(
              colors: [AppTheme.primaryMain, AppTheme.primaryDark],
            ),
            onPressed: () {},
            isDesktop: isDesktop,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            icon: Icons.add_shopping_cart_rounded,
            label: 'Input Manual',
            gradient: LinearGradient(
              colors: [AppTheme.accentGreen, const Color(0xFF059669)],
            ),
            onPressed: () {},
            isDesktop: isDesktop,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required LinearGradient gradient,
    required VoidCallback onPressed,
    required bool isDesktop,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: isDesktop ? 20 : 16,
              horizontal: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: isDesktop ? 24 : 20,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 16 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// Tambahkan metode ini di dalam _DashboardScreenState

Widget _buildProductSection(bool isDesktop) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Daftar Produk',
        style: AppTheme.textTheme.displayMedium?.copyWith(
          color: AppTheme.primaryMain,
        ),
      ),
      const SizedBox(height: 16),
      SizedBox(
        height: isDesktop ? 180 : 140,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildProductCard('Samsung S24 Ultra', 'Rp 16.999.000', 3, isDesktop),
            _buildProductCard('iPhone 15 Pro', 'Rp 18.999.000', 2, isDesktop),
            _buildProductCard('Xiaomi 13T', 'Rp 7.499.000', 5, isDesktop),
            _buildProductCard('Oppo Reno 10', 'Rp 6.999.000', 4, isDesktop),
          ],
        ),
      ),
    ],
  );
}

Widget _buildProductCard(String name, String price, int stock, bool isDesktop) {
  return Container(
    width: isDesktop ? 220 : 180,
    margin: const EdgeInsets.only(right: 16),
    decoration: BoxDecoration(
      color: AppTheme.backgroundWhite,
      borderRadius: AppTheme.mediumRadius,
      boxShadow: [AppTheme.lightShadow],
    ),
    padding: EdgeInsets.all(isDesktop ? 20 : 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: AppTheme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isDesktop ? 17 : 15,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          price,
          style: AppTheme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.primaryMain,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Row(
          children: [
            Icon(Icons.inventory_2, color: AppTheme.textTertiary, size: 16),
            const SizedBox(width: 6),
            Text(
              'Stok: $stock',
              style: AppTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textTertiary,
                fontSize: isDesktop ? 13 : 12,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildTransactionHistory(bool isDesktop) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Riwayat Transaksi',
        style: AppTheme.textTheme.displayMedium?.copyWith(
          color: AppTheme.primaryMain,
        ),
      ),
      const SizedBox(height: 16),
      ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildTransactionTile('INV-0012', 'Rp 2.500.000', 'Tunai', 'Selesai', isDesktop),
          _buildTransactionTile('INV-0011', 'Rp 1.200.000', 'QRIS', 'Selesai', isDesktop),
          _buildTransactionTile('INV-0010', 'Rp 800.000', 'Debit', 'Selesai', isDesktop),
        ],
      ),
    ],
  );
}

Widget _buildTransactionTile(String inv, String amount, String method, String status, bool isDesktop) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: AppTheme.backgroundWhite,
      borderRadius: AppTheme.mediumRadius,
      boxShadow: [AppTheme.lightShadow],
    ),
    child: ListTile(
      leading: Icon(Icons.receipt_long, color: AppTheme.primaryMain),
      title: Text(
        inv,
        style: AppTheme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: isDesktop ? 16 : 14,
        ),
      ),
      subtitle: Text(
        '$method • $status',
        style: AppTheme.textTheme.bodyMedium?.copyWith(
          fontSize: isDesktop ? 14 : 12,
        ),
      ),
      trailing: Text(
        amount,
        style: AppTheme.textTheme.bodyLarge?.copyWith(
          color: AppTheme.successColor,
          fontWeight: FontWeight.bold,
          fontSize: isDesktop ? 16 : 14,
        ),
      ),
    ),
  );
}

Widget _buildPaymentShortcuts(bool isDesktop) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Shortcut Pembayaran',
        style: AppTheme.textTheme.displayMedium?.copyWith(
          color: AppTheme.primaryMain,
        ),
      ),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildPaymentShortcut(Icons.money, 'Tunai', AppTheme.successColor, isDesktop),
          _buildPaymentShortcut(Icons.qr_code, 'QRIS', AppTheme.primaryMain, isDesktop),
          _buildPaymentShortcut(Icons.credit_card, 'Debit', AppTheme.accentOrange, isDesktop),
          _buildPaymentShortcut(Icons.account_balance_wallet, 'E-Wallet', AppTheme.accentPurple, isDesktop),
        ],
      ),
    ],
  );
}

Widget _buildPaymentShortcut(IconData icon, String label, Color color, bool isDesktop) {
  return Column(
    children: [
      Container(
        padding: EdgeInsets.all(isDesktop ? 18 : 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: AppTheme.mediumRadius,
        ),
        child: Icon(icon, color: color, size: isDesktop ? 32 : 28),
      ),
      const SizedBox(height: 8),
      Text(
        label,
        style: AppTheme.textTheme.bodyMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: isDesktop ? 15 : 13,
        ),
      ),
    ],
  );
}
}