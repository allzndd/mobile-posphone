import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/theme_provider.dart';

class TransaksiMasukScreen extends StatefulWidget {
  const TransaksiMasukScreen({super.key});

  @override
  State<TransaksiMasukScreen> createState() => _TransaksiMasukScreenState();
}

class _TransaksiMasukScreenState extends State<TransaksiMasukScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _filterStatus = 'Semua';
  String _filterPeriod = 'Hari Ini';
  bool _isListView = true;

  final List<String> _statusOptions = [
    'Semua',
    'Selesai',
    'Pending',
    'Dibatalkan',
  ];

  final List<String> _periodOptions = [
    'Hari Ini',
    'Minggu Ini',
    'Bulan Ini',
    'Semua',
  ];

  // Sample transaction data - Structure matched with web-posphone
  // pos_transaksi table: id, owner_id, pos_toko_id, pos_pelanggan_id, pos_tukar_tambah_id,
  // pos_supplier_id, is_transaksi_masuk (1=incoming/sales), invoice, total_harga, keterangan, status, metode_pembayaran
  // pos_transaksi_item table: id, pos_transaksi_id, pos_produk_id, pos_service_id, quantity,
  // harga_satuan, subtotal, diskon, garansi, garansi_expires_at, pajak
  final List<Map<String, dynamic>> _transactions = [
    {
      'id': 1,
      'owner_id': 1,
      'pos_toko_id': 1,
      'pos_pelanggan_id': 1,
      'pos_tukar_tambah_id': null,
      'pos_supplier_id': null,
      'is_transaksi_masuk': 1, // Incoming/Sales
      'invoice': 'INV-20251204-001',
      'total_harga': 23497000,
      'keterangan': 'Pembelian paket iPhone bundle',
      'status': 'Selesai',
      'metode_pembayaran': 'Tunai',
      'created_at': '2025-12-04 10:30:00',
      'customer_name': 'Ahmad Yani', // From relationship
      'toko_name': 'Toko Pusat', // From relationship
      'items': [
        {
          'id': 1,
          'pos_transaksi_id': 1,
          'pos_produk_id': 1,
          'pos_service_id': null,
          'quantity': 1,
          'harga_satuan': 21999000,
          'subtotal': 21999000,
          'diskon': 0,
          'garansi': 12, // months
          'garansi_expires_at': '2026-12-04',
          'pajak': 0,
          'produk_nama': 'iPhone 15 Pro Max', // From relationship
        },
        {
          'id': 2,
          'pos_transaksi_id': 1,
          'pos_produk_id': 3,
          'pos_service_id': null,
          'quantity': 1,
          'harga_satuan': 3799000,
          'subtotal': 3799000,
          'diskon': 0,
          'garansi': 12,
          'garansi_expires_at': '2026-12-04',
          'pajak': 0,
          'produk_nama': 'AirPods Pro 2nd Gen',
        },
        {
          'id': 3,
          'pos_transaksi_id': 1,
          'pos_produk_id': 4,
          'pos_service_id': null,
          'quantity': 1,
          'harga_satuan': 299000,
          'subtotal': 299000,
          'diskon': 0,
          'garansi': 0,
          'garansi_expires_at': null,
          'pajak': 0,
          'produk_nama': 'Case iPhone Clear',
        },
      ],
    },
    {
      'id': 2,
      'owner_id': 1,
      'pos_toko_id': 1,
      'pos_pelanggan_id': 2,
      'pos_tukar_tambah_id': null,
      'pos_supplier_id': null,
      'is_transaksi_masuk': 1,
      'invoice': 'INV-20251204-002',
      'total_harga': 20498000,
      'keterangan': null,
      'status': 'Selesai',
      'metode_pembayaran': 'QRIS',
      'created_at': '2025-12-04 11:15:00',
      'customer_name': 'Siti Nurhaliza',
      'toko_name': 'Toko Pusat',
      'items': [
        {
          'id': 4,
          'pos_transaksi_id': 2,
          'pos_produk_id': 2,
          'pos_service_id': null,
          'quantity': 1,
          'harga_satuan': 19999000,
          'subtotal': 19999000,
          'diskon': 0,
          'garansi': 12,
          'garansi_expires_at': '2026-12-04',
          'pajak': 0,
          'produk_nama': 'Samsung Galaxy S24 Ultra',
        },
        {
          'id': 5,
          'pos_transaksi_id': 2,
          'pos_produk_id': 5,
          'pos_service_id': null,
          'quantity': 1,
          'harga_satuan': 499000,
          'subtotal': 499000,
          'diskon': 0,
          'garansi': 6,
          'garansi_expires_at': '2026-06-04',
          'pajak': 0,
          'produk_nama': 'Fast Charger 65W',
        },
      ],
    },
    {
      'id': 3,
      'owner_id': 1,
      'pos_toko_id': 1,
      'pos_pelanggan_id': 3,
      'pos_tukar_tambah_id': null,
      'pos_supplier_id': null,
      'is_transaksi_masuk': 1,
      'invoice': 'INV-20251204-003',
      'total_harga': 3799000,
      'keterangan': 'Menunggu pembayaran',
      'status': 'Pending',
      'metode_pembayaran': 'Debit',
      'created_at': '2025-12-04 12:00:00',
      'customer_name': 'Budi Santoso',
      'toko_name': 'Toko Pusat',
      'items': [
        {
          'id': 6,
          'pos_transaksi_id': 3,
          'pos_produk_id': 3,
          'pos_service_id': null,
          'quantity': 1,
          'harga_satuan': 3799000,
          'subtotal': 3799000,
          'diskon': 0,
          'garansi': 12,
          'garansi_expires_at': '2026-12-04',
          'pajak': 0,
          'produk_nama': 'AirPods Pro 2nd Gen',
        },
      ],
    },
    {
      'id': 4,
      'owner_id': 1,
      'pos_toko_id': 1,
      'pos_pelanggan_id': 4,
      'pos_tukar_tambah_id': null,
      'pos_supplier_id': null,
      'is_transaksi_masuk': 1,
      'invoice': 'INV-20251204-004',
      'total_harga': 1496000,
      'keterangan': null,
      'status': 'Selesai',
      'metode_pembayaran': 'E-Wallet',
      'created_at': '2025-12-04 13:45:00',
      'customer_name': 'Dewi Lestari',
      'toko_name': 'Toko Pusat',
      'items': [
        {
          'id': 7,
          'pos_transaksi_id': 4,
          'pos_produk_id': 4,
          'pos_service_id': null,
          'quantity': 2,
          'harga_satuan': 299000,
          'subtotal': 598000,
          'diskon': 0,
          'garansi': 0,
          'garansi_expires_at': null,
          'pajak': 0,
          'produk_nama': 'Case iPhone Clear',
        },
        {
          'id': 8,
          'pos_transaksi_id': 4,
          'pos_produk_id': 6,
          'pos_service_id': null,
          'quantity': 6,
          'harga_satuan': 149000,
          'subtotal': 894000,
          'diskon': 0,
          'garansi': 0,
          'garansi_expires_at': null,
          'pajak': 4000,
          'produk_nama': 'Screen Protector Premium',
        },
      ],
    },
    {
      'id': 5,
      'owner_id': 1,
      'pos_toko_id': 1,
      'pos_pelanggan_id': 5,
      'pos_tukar_tambah_id': null,
      'pos_supplier_id': null,
      'is_transaksi_masuk': 1,
      'invoice': 'INV-20251203-005',
      'total_harga': 21999000,
      'keterangan': 'Dibatalkan karena stok habis',
      'status': 'Dibatalkan',
      'metode_pembayaran': 'Tunai',
      'created_at': '2025-12-03 15:20:00',
      'customer_name': 'Rizki Ramadhan',
      'toko_name': 'Toko Pusat',
      'items': [
        {
          'id': 9,
          'pos_transaksi_id': 5,
          'pos_produk_id': 1,
          'pos_service_id': null,
          'quantity': 1,
          'harga_satuan': 21999000,
          'subtotal': 21999000,
          'diskon': 0,
          'garansi': 12,
          'garansi_expires_at': '2026-12-03',
          'pajak': 0,
          'produk_nama': 'iPhone 15 Pro Max',
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    return _transactions.where((trx) {
      final matchesSearch =
          (trx['customer_name']?.toString().toLowerCase() ?? '').contains(
            _searchQuery.toLowerCase(),
          ) ||
          (trx['invoice']?.toString().toLowerCase() ?? '').contains(
            _searchQuery.toLowerCase(),
          );
      final matchesStatus =
          _filterStatus == 'Semua' || trx['status'] == _filterStatus;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final isTablet = screenWidth > 600 && screenWidth <= 900;

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(isDesktop)),
          SliverToBoxAdapter(child: _buildStatsCards(isDesktop)),
          SliverToBoxAdapter(child: _buildFilterSection(isDesktop)),
          _buildTransactionList(isDesktop, isTablet),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [themeProvider.primaryMain, themeProvider.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: themeProvider.primaryMain.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isDesktop ? 12 : 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.arrow_downward_rounded,
              color: Colors.white,
              size: isDesktop ? 28 : 24,
            ),
          ),
          SizedBox(width: isDesktop ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transaksi Masuk',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 24 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Kelola penjualan & pembayaran',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isDesktop ? 14 : 12,
                  ),
                ),
              ],
            ),
          ),
          if (isDesktop) ...[
            _buildHeaderAction(
              icon: Icons.add_shopping_cart,
              label: 'Transaksi Baru',
              onTap: () => _showNewTransaction(),
            ),
            const SizedBox(width: 8),
            _buildHeaderAction(
              icon: Icons.print_outlined,
              label: 'Cetak Laporan',
              onTap: () {},
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(bool isDesktop) {
    final totalTransaksi = _transactions.length;
    final totalPendapatan = _transactions
        .where((t) => t['status'] == 'Selesai')
        .fold<int>(0, (sum, t) => sum + (t['total_harga'] as int));
    final transaksiHariIni =
        _transactions
            .where((t) => t['date'].toString().startsWith('2025-12-04'))
            .length;
    final pending = _transactions.where((t) => t['status'] == 'Pending').length;

    return Container(
      margin: EdgeInsets.all(isDesktop ? 24 : 16),
      child:
          isDesktop
              ? Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Transaksi',
                      '$totalTransaksi',
                      Icons.receipt_long,
                      AppTheme.primaryMain,
                      isDesktop,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Total Pendapatan',
                      'Rp ${_formatPrice(totalPendapatan)}',
                      Icons.account_balance_wallet,
                      AppTheme.successColor,
                      isDesktop,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Hari Ini',
                      '$transaksiHariIni',
                      Icons.today,
                      AppTheme.accentOrange,
                      isDesktop,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Pending',
                      '$pending',
                      Icons.pending_actions,
                      AppTheme.warningColor,
                      isDesktop,
                    ),
                  ),
                ],
              )
              : Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Transaksi',
                          '$totalTransaksi',
                          Icons.receipt_long,
                          AppTheme.primaryMain,
                          isDesktop,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Pendapatan',
                          'Rp ${_formatPrice(totalPendapatan)}',
                          Icons.account_balance_wallet,
                          AppTheme.successColor,
                          isDesktop,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Hari Ini',
                          '$transaksiHariIni',
                          Icons.today,
                          AppTheme.accentOrange,
                          isDesktop,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Pending',
                          '$pending',
                          Icons.pending_actions,
                          AppTheme.warningColor,
                          isDesktop,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDesktop,
  ) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Icon(Icons.trending_up, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: isDesktop ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              color: themeProvider.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      color: themeProvider.surfaceColor,
      child: Column(
        children: [
          if (isDesktop)
            Row(
              children: [
                Expanded(flex: 2, child: _buildSearchBar()),
                const SizedBox(width: 16),
                Expanded(child: _buildStatusFilter()),
                const SizedBox(width: 16),
                Expanded(child: _buildPeriodFilter()),
                const SizedBox(width: 16),
                _buildViewToggle(),
              ],
            )
          else ...[
            _buildSearchBar(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatusFilter()),
                const SizedBox(width: 12),
                Expanded(child: _buildPeriodFilter()),
                const SizedBox(width: 12),
                _buildViewToggle(),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final themeProvider = context.read<ThemeProvider>();
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Cari transaksi / customer...',
          hintStyle: TextStyle(color: themeProvider.textTertiary),
          prefixIcon: Icon(
            Icons.search,
            color: context.read<ThemeProvider>().primaryMain,
          ),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.clear, color: themeProvider.textTertiary),
                    onPressed: () => setState(() => _searchQuery = ''),
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    final themeProvider = context.read<ThemeProvider>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: DropdownButton<String>(
        value: _filterStatus,
        icon: Icon(
          Icons.filter_list,
          color: context.read<ThemeProvider>().primaryMain,
        ),
        underline: const SizedBox(),
        isExpanded: true,
        style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
        onChanged: (value) => setState(() => _filterStatus = value!),
        items:
            _statusOptions.map((option) {
              return DropdownMenuItem(value: option, child: Text(option));
            }).toList(),
      ),
    );
  }

  Widget _buildPeriodFilter() {
    final themeProvider = context.read<ThemeProvider>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: DropdownButton<String>(
        value: _filterPeriod,
        icon: Icon(
          Icons.calendar_today,
          color: context.read<ThemeProvider>().primaryMain,
        ),
        underline: const SizedBox(),
        isExpanded: true,
        style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
        onChanged: (value) => setState(() => _filterPeriod = value!),
        items:
            _periodOptions.map((option) {
              return DropdownMenuItem(value: option, child: Text(option));
            }).toList(),
      ),
    );
  }

  Widget _buildViewToggle() {
    final themeProvider = context.read<ThemeProvider>();
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildViewButton(Icons.view_list_rounded, true),
          _buildViewButton(Icons.grid_view_rounded, false),
        ],
      ),
    );
  }

  Widget _buildViewButton(IconData icon, bool isList) {
    final themeProvider = context.watch<ThemeProvider>();
    final isActive = _isListView == isList;
    return Material(
      color:
          isActive
              ? context.read<ThemeProvider>().primaryMain
              : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => setState(() => _isListView = isList),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            color: isActive ? Colors.white : themeProvider.textTertiary,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList(bool isDesktop, bool isTablet) {
    final themeProvider = context.watch<ThemeProvider>();
    final transactions = _filteredTransactions;

    if (transactions.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 80,
                color: themeProvider.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                'Tidak ada transaksi',
                style: TextStyle(
                  fontSize: 18,
                  color: themeProvider.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isListView) {
      return SliverPadding(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) =>
                _buildTransactionCard(transactions[index], isDesktop),
            childCount: transactions.length,
          ),
        ),
      );
    } else {
      final crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);
      return SliverPadding(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) =>
                _buildTransactionGridCard(transactions[index], isDesktop),
            childCount: transactions.length,
          ),
        ),
      );
    }
  }

  Widget _buildTransactionCard(Map<String, dynamic> trx, bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();
    final statusColor = _getStatusColor(trx['status']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showTransactionDetail(trx),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 20 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: themeProvider.cardColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.receipt,
                              color: context.read<ThemeProvider>().primaryMain,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trx['invoice'] ?? 'INV-${trx['id']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  trx['created_at'] ?? '-',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: themeProvider.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        trx['status'],
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.person,
                        'Customer',
                        trx['customer_name'] ?? '-',
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.shopping_bag_outlined,
                        'Items',
                        '${trx['items']?.length ?? 0} produk',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.payment,
                        'Pembayaran',
                        trx['metode_pembayaran'] ?? '-',
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.store,
                        'Toko',
                        trx['toko_name'] ?? '-',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Pembayaran',
                      style: TextStyle(
                        fontSize: 14,
                        color: themeProvider.textSecondary,
                      ),
                    ),
                    Text(
                      'Rp ${_formatPrice(trx['total_harga'])}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: context.read<ThemeProvider>().primaryMain,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionGridCard(Map<String, dynamic> trx, bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();
    final statusColor = _getStatusColor(trx['status']);

    return Container(
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showTransactionDetail(trx),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: themeProvider.cardColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.receipt,
                        color: context.read<ThemeProvider>().primaryMain,
                        size: 20,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        trx['status'],
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  trx['invoice'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  trx['customer_name'],
                  style: TextStyle(
                    fontSize: 12,
                    color: themeProvider.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Text(
                  '${trx['items'].length} produk • ${trx['metode_pembayaran']}',
                  style: TextStyle(
                    fontSize: 11,
                    color: themeProvider.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Rp ${_formatPrice(trx['total_harga'])}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.read<ThemeProvider>().primaryMain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    final themeProvider = context.watch<ThemeProvider>();
    return Row(
      children: [
        Icon(icon, size: 16, color: themeProvider.textTertiary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: themeProvider.textTertiary,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFAB() {
    final themeProvider = context.watch<ThemeProvider>();

    return FloatingActionButton.extended(
      onPressed: _showNewTransaction,
      backgroundColor: themeProvider.primaryMain,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        'Transaksi Baru',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Selesai':
        return AppTheme.successColor;
      case 'Pending':
        return AppTheme.warningColor;
      case 'Dibatalkan':
        return AppTheme.errorColor;
      default:
        return AppTheme.textTertiary;
    }
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  void _showTransactionDetail(Map<String, dynamic> trx) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                context.read<ThemeProvider>().primaryMain,
                                context.read<ThemeProvider>().primaryDark,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.receipt,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Detail Transaksi',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                trx['invoice'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      context.read<ThemeProvider>().primaryMain,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildDetailRow('Invoice', trx['invoice']),
                    _buildDetailRow('Tanggal', trx['created_at']),
                    _buildDetailRow('Customer', trx['customer_name']),
                    _buildDetailRow('Toko', trx['toko_name']),
                    _buildDetailRow('Pembayaran', trx['metode_pembayaran']),
                    _buildDetailRow('Status', trx['status']),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text(
                      'Produk',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...(trx['items'] as List).map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item['quantity']}x ${item['produk_nama']}',
                                style: TextStyle(
                                  color:
                                      context
                                          .read<ThemeProvider>()
                                          .textSecondary,
                                ),
                              ),
                            ),
                            Text(
                              'Rp ${_formatPrice(item['subtotal'])}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color:
                                    context.read<ThemeProvider>().textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Rp ${_formatPrice(trx['total_harga'])}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: context.read<ThemeProvider>().primaryMain,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.print),
                            label: const Text('Cetak'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.check),
                            label: const Text('Tutup'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  context.read<ThemeProvider>().primaryMain,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final themeProvider = context.watch<ThemeProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: themeProvider.textTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: themeProvider.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNewTransaction() {
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
                    gradient: LinearGradient(
                      colors: [
                        context.read<ThemeProvider>().primaryMain,
                        context.read<ThemeProvider>().primaryDark,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.add_shopping_cart,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Transaksi Baru'),
              ],
            ),
            content: const Text('Form transaksi baru akan ditampilkan di sini'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.read<ThemeProvider>().primaryMain,
                ),
                child: const Text('Proses'),
              ),
            ],
          ),
    );
  }
}
