import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class TransaksiKeluarScreen extends StatefulWidget {
  const TransaksiKeluarScreen({super.key});

  @override
  State<TransaksiKeluarScreen> createState() => _TransaksiKeluarScreenState();
}

class _TransaksiKeluarScreenState extends State<TransaksiKeluarScreen> {
  String _searchQuery = '';
  String _filterStatus = 'Semua';
  String _filterPeriod = 'Hari Ini';

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

  // Sample data
  final List<Map<String, dynamic>> _transactions = [
    {
      'id': 'OUT001',
      'date': '2025-12-04 09:00',
      'supplier': 'PT Elektronik Jaya',
      'items': 5,
      'total': 45000000,
      'payment': 'Transfer',
      'status': 'Selesai',
      'pic': 'Admin',
      'products': [
        {'name': 'iPhone 15 Pro Max', 'qty': 2, 'price': 21000000},
        {'name': 'Samsung S24 Ultra', 'qty': 3, 'price': 19000000},
      ],
    },
    {
      'id': 'OUT002',
      'date': '2025-12-04 10:30',
      'supplier': 'CV Aksesoris Handphone',
      'items': 50,
      'total': 5500000,
      'payment': 'Tunai',
      'status': 'Selesai',
      'pic': 'Admin',
      'products': [
        {'name': 'Case Universal', 'qty': 30, 'price': 150000},
        {'name': 'Screen Protector', 'qty': 20, 'price': 100000},
      ],
    },
    {
      'id': 'OUT003',
      'date': '2025-12-04 14:00',
      'supplier': 'UD Audio Premium',
      'items': 10,
      'total': 35000000,
      'payment': 'Transfer',
      'status': 'Pending',
      'pic': 'Manager',
      'products': [
        {'name': 'AirPods Pro 2nd Gen', 'qty': 10, 'price': 3500000},
      ],
    },
    {
      'id': 'OUT004',
      'date': '2025-12-03 11:00',
      'supplier': 'PT Charger Solution',
      'items': 20,
      'total': 8000000,
      'payment': 'Transfer',
      'status': 'Dibatalkan',
      'pic': 'Admin',
      'products': [
        {'name': 'Fast Charger 65W', 'qty': 20, 'price': 400000},
      ],
    },
  ];

  List<Map<String, dynamic>> get _filteredTransactions {
    return _transactions.where((trx) {
      final matchesSearch = trx['supplier']
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

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(isDesktop)),
          SliverToBoxAdapter(child: _buildStatsCards(isDesktop)),
          SliverToBoxAdapter(child: _buildFilterSection(isDesktop)),
          _buildTransactionList(isDesktop),
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
          colors: [AppTheme.errorColor, AppTheme.accentRed],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.errorColor.withOpacity(0.3),
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
                Icons.arrow_upward_rounded,
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
                    'Transaksi Keluar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isDesktop ? 24 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Kelola pembelian & pengeluaran',
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
                icon: Icons.add_box_outlined,
                label: 'Pengeluaran Baru',
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
    final totalPengeluaran = _transactions
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
                    child: _buildStatCard('Total Transaksi', '$totalTransaksi',
                        Icons.receipt_long, AppTheme.primaryMain, isDesktop)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildStatCard(
                        'Total Pengeluaran',
                        'Rp ${_formatPrice(totalPengeluaran)}',
                        Icons.account_balance_wallet,
                        AppTheme.errorColor,
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
                            'Pengeluaran',
                            'Rp ${_formatPrice(totalPengeluaran)}',
                            Icons.account_balance_wallet,
                            AppTheme.errorColor,
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
              Icon(Icons.trending_down, color: color, size: 20),
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
          hintText: 'Cari transaksi / supplier...',
          hintStyle: TextStyle(color: AppTheme.textTertiary),
          prefixIcon: Icon(Icons.search, color: AppTheme.errorColor),
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
        icon: Icon(Icons.filter_list, color: AppTheme.errorColor),
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
        icon: Icon(Icons.calendar_today, color: AppTheme.errorColor),
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

  Widget _buildTransactionList(bool isDesktop) {
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
                              color: AppTheme.errorColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.shopping_cart_outlined,
                                color: AppTheme.errorColor, size: 20),
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
                          Icons.business, 'Supplier', trx['supplier']),
                    ),
                    Expanded(
                      child: _buildInfoItem(Icons.inventory_2_outlined, 'Items',
                          '${trx['items']} produk'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                          Icons.payment, 'Pembayaran', trx['payment']),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                          Icons.person_outline, 'PIC', trx['pic']),
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
                      'Total Pengeluaran',
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
                        color: AppTheme.errorColor,
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
      backgroundColor: AppTheme.errorColor,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        'Pengeluaran Baru',
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
                          colors: [AppTheme.errorColor, AppTheme.accentRed],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.shopping_cart, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Detail Transaksi Keluar',
                            style: TextStyle(
                              fontSize: 18,
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
                _buildDetailRow('Supplier', trx['supplier']),
                _buildDetailRow('PIC', trx['pic']),
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
                        color: AppTheme.errorColor,
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
                          backgroundColor: AppTheme.errorColor,
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
                  colors: [AppTheme.errorColor, AppTheme.accentRed],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_box_outlined, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Text('Pengeluaran Baru'),
          ],
        ),
        content: const Text('Form pengeluaran baru akan ditampilkan di sini'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Proses'),
          ),
        ],
      ),
    );
  }
}
