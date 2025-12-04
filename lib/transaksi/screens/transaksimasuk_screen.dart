import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

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

  // Sample transaction data
  final List<Map<String, dynamic>> _transactions = [
    {
      'id': 'TRX001',
      'date': '2025-12-04 10:30',
      'customer': 'Ahmad Yani',
      'items': 3,
      'total': 23497000,
      'payment': 'Tunai',
      'status': 'Selesai',
      'cashier': 'Budi',
      'products': [
        {'name': 'iPhone 15 Pro Max', 'qty': 1, 'price': 21999000},
        {'name': 'AirPods Pro', 'qty': 1, 'price': 3799000},
        {'name': 'Case iPhone', 'qty': 1, 'price': 299000},
      ],
    },
    {
      'id': 'TRX002',
      'date': '2025-12-04 11:15',
      'customer': 'Siti Nurhaliza',
      'items': 2,
      'total': 20498000,
      'payment': 'QRIS',
      'status': 'Selesai',
      'cashier': 'Andi',
      'products': [
        {'name': 'Samsung S24 Ultra', 'qty': 1, 'price': 19999000},
        {'name': 'Fast Charger 65W', 'qty': 1, 'price': 499000},
      ],
    },
    {
      'id': 'TRX003',
      'date': '2025-12-04 12:00',
      'customer': 'Budi Santoso',
      'items': 1,
      'total': 3799000,
      'payment': 'Debit',
      'status': 'Pending',
      'cashier': 'Budi',
      'products': [
        {'name': 'AirPods Pro 2nd Gen', 'qty': 1, 'price': 3799000},
      ],
    },
    {
      'id': 'TRX004',
      'date': '2025-12-04 13:45',
      'customer': 'Dewi Lestari',
      'items': 4,
      'total': 1496000,
      'payment': 'E-Wallet',
      'status': 'Selesai',
      'cashier': 'Andi',
      'products': [
        {'name': 'Case iPhone Clear', 'qty': 2, 'price': 299000},
        {'name': 'Screen Protector', 'qty': 2, 'price': 149000},
      ],
    },
    {
      'id': 'TRX005',
      'date': '2025-12-03 15:20',
      'customer': 'Rizki Ramadhan',
      'items': 1,
      'total': 21999000,
      'payment': 'Tunai',
      'status': 'Dibatalkan',
      'cashier': 'Budi',
      'products': [
        {'name': 'iPhone 15 Pro Max', 'qty': 1, 'price': 21999000},
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
      final matchesSearch = trx['customer']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          trx['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus =
          _filterStatus == 'Semua' || trx['status'] == _filterStatus;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final isTablet = screenWidth > 600 && screenWidth <= 900;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
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
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.successColor, AppTheme.secondaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.successColor.withOpacity(0.3),
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
        .fold<int>(0, (sum, t) => sum + (t['total'] as int));
    final transaksiHariIni = _transactions
        .where((t) => t['date'].toString().startsWith('2025-12-04'))
        .length;
    final pending = _transactions.where((t) => t['status'] == 'Pending').length;

    return Container(
      margin: EdgeInsets.all(isDesktop ? 24 : 16),
      child: isDesktop
          ? Row(
              children: [
                Expanded(
                    child: _buildStatCard(
                        'Total Transaksi',
                        '$totalTransaksi',
                        Icons.receipt_long,
                        AppTheme.primaryMain,
                        isDesktop)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildStatCard(
                        'Total Pendapatan',
                        'Rp ${_formatPrice(totalPendapatan)}',
                        Icons.account_balance_wallet,
                        AppTheme.successColor,
                        isDesktop)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildStatCard('Hari Ini', '$transaksiHariIni',
                        Icons.today, AppTheme.accentOrange, isDesktop)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildStatCard('Pending', '$pending',
                        Icons.pending_actions, AppTheme.warningColor, isDesktop)),
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
                            isDesktop)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildStatCard(
                            'Pendapatan',
                            'Rp ${_formatPrice(totalPendapatan)}',
                            Icons.account_balance_wallet,
                            AppTheme.successColor,
                            isDesktop)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _buildStatCard('Hari Ini', '$transaksiHariIni',
                            Icons.today, AppTheme.accentOrange, isDesktop)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildStatCard('Pending', '$pending',
                            Icons.pending_actions, AppTheme.warningColor, isDesktop)),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
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
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      color: Colors.white,
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
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Cari transaksi / customer...',
          hintStyle: TextStyle(color: AppTheme.textTertiary),
          prefixIcon: Icon(Icons.search, color: AppTheme.successColor),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: AppTheme.textTertiary),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: DropdownButton<String>(
        value: _filterStatus,
        icon: Icon(Icons.filter_list, color: AppTheme.successColor),
        underline: const SizedBox(),
        isExpanded: true,
        style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
        onChanged: (value) => setState(() => _filterStatus = value!),
        items: _statusOptions.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPeriodFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: DropdownButton<String>(
        value: _filterPeriod,
        icon: Icon(Icons.calendar_today, color: AppTheme.successColor),
        underline: const SizedBox(),
        isExpanded: true,
        style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
        onChanged: (value) => setState(() => _filterPeriod = value!),
        items: _periodOptions.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
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
    final isActive = _isListView == isList;
    return Material(
      color: isActive ? AppTheme.successColor : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => setState(() => _isListView = isList),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            color: isActive ? Colors.white : AppTheme.textTertiary,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList(bool isDesktop, bool isTablet) {
    final transactions = _filteredTransactions;

    if (transactions.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: 80, color: AppTheme.textTertiary),
              const SizedBox(height: 16),
              Text(
                'Tidak ada transaksi',
                style: TextStyle(
                  fontSize: 18,
                  color: AppTheme.textSecondary,
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
            (context, index) => _buildTransactionCard(transactions[index], isDesktop),
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
    final statusColor = _getStatusColor(trx['status']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
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
                              color: AppTheme.successColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.receipt,
                                color: AppTheme.successColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trx['id'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  trx['date'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textTertiary,
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
                          horizontal: 12, vertical: 6),
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
                          Icons.person, 'Customer', trx['customer']),
                    ),
                    Expanded(
                      child: _buildInfoItem(Icons.shopping_bag_outlined, 'Items',
                          '${trx['items']} produk'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(Icons.payment, 'Pembayaran',
                          trx['payment']),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                          Icons.person_outline, 'Kasir', trx['cashier']),
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
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      'Rp ${_formatPrice(trx['total'])}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.successColor,
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
    final statusColor = _getStatusColor(trx['status']);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
                        color: AppTheme.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.receipt,
                          color: AppTheme.successColor, size: 20),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
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
                  trx['id'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  trx['customer'],
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Text(
                  '${trx['items']} produk • ${trx['payment']}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Rp ${_formatPrice(trx['total'])}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.successColor,
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
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textTertiary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textTertiary,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
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
    return FloatingActionButton.extended(
      onPressed: _showNewTransaction,
      backgroundColor: AppTheme.successColor,
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
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                          colors: [AppTheme.successColor, AppTheme.secondaryDark],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.receipt, color: Colors.white, size: 24),
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
                            trx['id'],
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textTertiary,
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
                _buildDetailRow('Tanggal', trx['date']),
                _buildDetailRow('Customer', trx['customer']),
                _buildDetailRow('Kasir', trx['cashier']),
                _buildDetailRow('Pembayaran', trx['payment']),
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
                ...(trx['products'] as List).map((product) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${product['qty']}x ${product['name']}',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        ),
                        Text(
                          'Rp ${_formatPrice(product['price'] * product['qty'])}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
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
                      'Rp ${_formatPrice(trx['total'])}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.successColor,
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
                          backgroundColor: AppTheme.successColor,
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
                color: AppTheme.textTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppTheme.textPrimary,
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.successColor, AppTheme.secondaryDark],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_shopping_cart, color: Colors.white),
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
            child: const Text('Proses'),
          ),
        ],
      ),
    );
  }
}
