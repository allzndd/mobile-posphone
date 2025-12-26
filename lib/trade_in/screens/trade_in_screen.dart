import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_provider.dart';

class TradeInScreen extends StatefulWidget {
  const TradeInScreen({super.key});

  @override
  State<TradeInScreen> createState() => _TradeInScreenState();
}

class _TradeInScreenState extends State<TradeInScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Sample data - Structure matched with pos_tukar_tambah
  final List<Map<String, dynamic>> _tradeInData = [
    {
      'id': 1,
      'pelanggan_nama': 'Budi Santoso',
      'toko_nama': 'Toko Pusat',
      'produk_masuk_nama': 'iPhone 11 64GB',
      'produk_masuk_merk': 'Apple',
      'produk_masuk_kondisi': 'Bekas Normal',
      'produk_masuk_harga': 4500000,
      'produk_keluar_nama': 'iPhone 14 Pro 128GB',
      'produk_keluar_merk': 'Apple',
      'produk_keluar_harga': 15000000,
      'selisih_harga': 10500000,
      'transaksi_penjualan_invoice': 'INV-TT-20240115-001',
      'transaksi_pembelian_invoice': 'PO-TT-20240115-001',
      'created_at': DateTime.now().subtract(const Duration(hours: 3)),
    },
    {
      'id': 2,
      'pelanggan_nama': 'Siti Aminah',
      'toko_nama': 'Toko Cabang A',
      'produk_masuk_nama': 'Samsung Galaxy S21',
      'produk_masuk_merk': 'Samsung',
      'produk_masuk_kondisi': 'Bekas Normal',
      'produk_masuk_harga': 5000000,
      'produk_keluar_nama': 'Samsung Galaxy S23 Ultra',
      'produk_keluar_merk': 'Samsung',
      'produk_keluar_harga': 16000000,
      'selisih_harga': 11000000,
      'transaksi_penjualan_invoice': 'INV-TT-20240114-002',
      'transaksi_pembelian_invoice': 'PO-TT-20240114-002',
      'created_at': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'id': 3,
      'pelanggan_nama': 'Ahmad Fauzi',
      'toko_nama': 'Toko Pusat',
      'produk_masuk_nama': 'Xiaomi 12 Pro 256GB',
      'produk_masuk_merk': 'Xiaomi',
      'produk_masuk_kondisi': 'Bekas Baik',
      'produk_masuk_harga': 6500000,
      'produk_keluar_nama': 'Xiaomi 13 Ultra 512GB',
      'produk_keluar_merk': 'Xiaomi',
      'produk_keluar_harga': 12500000,
      'selisih_harga': 6000000,
      'transaksi_penjualan_invoice': 'INV-TT-20240113-003',
      'transaksi_pembelian_invoice': 'PO-TT-20240113-003',
      'created_at': DateTime.now().subtract(const Duration(days: 2)),
    },
  ];

  List<Map<String, dynamic>> get _filteredData {
    return _tradeInData.where((item) {
      final matchSearch =
          _searchQuery.isEmpty ||
          item['pelanggan_nama'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          item['produk_masuk_nama'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          item['produk_keluar_nama'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      return matchSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(isDesktop, themeProvider)),
          SliverToBoxAdapter(child: _buildSearchBar(isDesktop, themeProvider)),
          SliverToBoxAdapter(
            child: _buildSummaryCards(isDesktop, themeProvider),
          ),
          _buildTradeInListSliver(isDesktop, themeProvider),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTradeInDialog(),
        backgroundColor: themeProvider.primaryMain,
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        label: Text(
          isDesktop ? 'Tukar Tambah Baru' : 'Tambah',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDesktop, ThemeProvider themeProvider) {
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
              Icons.swap_horiz_rounded,
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
                  'Tukar Tambah (Trade In)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 24 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_filteredData.length} transaksi tukar tambah',
                  style: TextStyle(
                    color: Colors.white70,
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

  Widget _buildSearchBar(bool isDesktop, ThemeProvider themeProvider) {
    return Padding(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: themeProvider.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: themeProvider.borderColor),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Cari pelanggan atau produk...',
            hintStyle: TextStyle(color: themeProvider.textTertiary),
            border: InputBorder.none,
            icon: const Icon(Icons.search),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(bool isDesktop, ThemeProvider themeProvider) {
    final totalTransaksi = _tradeInData.length;
    final totalNilaiMasuk = _tradeInData.fold<int>(
      0,
      (sum, item) => sum + (item['produk_masuk_harga'] as int),
    );
    final totalNilaiKeluar = _tradeInData.fold<int>(
      0,
      (sum, item) => sum + (item['produk_keluar_harga'] as int),
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total Transaksi',
              '$totalTransaksi',
              Icons.swap_horiz,
              themeProvider.primaryMain,
              themeProvider,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Nilai Trade In',
              'Rp ${_formatCurrency(totalNilaiMasuk)}',
              Icons.call_received,
              themeProvider.successMain,
              themeProvider,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Nilai Penjualan',
              'Rp ${_formatCurrency(totalNilaiKeluar)}',
              Icons.call_made,
              themeProvider.infoMain,
              themeProvider,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    IconData icon,
    Color color,
    ThemeProvider themeProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: themeProvider.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTradeInListSliver(bool isDesktop, ThemeProvider themeProvider) {
    if (_filteredData.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.swap_horiz_outlined,
                size: 80,
                color: themeProvider.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                'Belum ada transaksi tukar tambah',
                style: TextStyle(
                  fontSize: 18,
                  color: themeProvider.textSecondary,
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
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = _filteredData[index];
          return _buildTradeInCard(item, isDesktop, themeProvider);
        }, childCount: _filteredData.length),
      ),
    );
  }

  Widget _buildTradeInCard(
    Map<String, dynamic> item,
    bool isDesktop,
    ThemeProvider themeProvider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDetailDialog(item),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Pelanggan & ID
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 16,
                              color: themeProvider.primaryMain,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item['pelanggan_nama'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${item['id']} • ${item['toko_nama']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: themeProvider.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Trade In Flow
                Row(
                  children: [
                    // Produk Masuk (Trade In)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: themeProvider.successMain.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: themeProvider.successMain.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.call_received,
                                  size: 16,
                                  color: themeProvider.successMain,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Trade In',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: themeProvider.successMain,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['produk_masuk_nama'],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: themeProvider.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['produk_masuk_kondisi'],
                              style: TextStyle(
                                fontSize: 11,
                                color: themeProvider.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Rp ${_formatCurrency(item['produk_masuk_harga'])}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.successMain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        Icons.arrow_forward,
                        color: themeProvider.primaryMain,
                        size: 24,
                      ),
                    ),
                    // Produk Keluar (Penjualan)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: themeProvider.infoMain.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: themeProvider.infoMain.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.call_made,
                                  size: 16,
                                  color: themeProvider.infoMain,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Penjualan',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: themeProvider.infoMain,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['produk_keluar_nama'],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: themeProvider.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Baru',
                              style: TextStyle(
                                fontSize: 11,
                                color: themeProvider.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Rp ${_formatCurrency(item['produk_keluar_harga'])}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.infoMain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Footer: Selisih & Tanggal
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: themeProvider.primaryMain.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selisih Pembayaran',
                            style: TextStyle(
                              fontSize: 12,
                              color: themeProvider.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rp ${_formatCurrency(item['selisih_harga'])}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.primaryMain,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _formatDateTime(item['created_at']),
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
        ),
      ),
    );
  }

  void _showDetailDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) {
        final themeProvider = context.read<ThemeProvider>();
        return AlertDialog(
          backgroundColor: themeProvider.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.swap_horiz, color: themeProvider.primaryMain),
              const SizedBox(width: 12),
              const Expanded(child: Text('Detail Tukar Tambah')),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSectionTitle('Informasi Umum', themeProvider),
                _buildDetailRow('ID', '${item['id']}', themeProvider),
                _buildDetailRow(
                  'Pelanggan',
                  item['pelanggan_nama'],
                  themeProvider,
                ),
                _buildDetailRow('Toko', item['toko_nama'], themeProvider),
                const SizedBox(height: 16),
                _buildSectionTitle('Produk Trade In (Masuk)', themeProvider),
                _buildDetailRow(
                  'Nama Produk',
                  item['produk_masuk_nama'],
                  themeProvider,
                ),
                _buildDetailRow(
                  'Merk',
                  item['produk_masuk_merk'],
                  themeProvider,
                ),
                _buildDetailRow(
                  'Kondisi',
                  item['produk_masuk_kondisi'],
                  themeProvider,
                ),
                _buildDetailRow(
                  'Harga Trade In',
                  'Rp ${_formatCurrency(item['produk_masuk_harga'])}',
                  themeProvider,
                ),
                _buildDetailRow(
                  'Invoice Pembelian',
                  item['transaksi_pembelian_invoice'],
                  themeProvider,
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('Produk Penjualan (Keluar)', themeProvider),
                _buildDetailRow(
                  'Nama Produk',
                  item['produk_keluar_nama'],
                  themeProvider,
                ),
                _buildDetailRow(
                  'Merk',
                  item['produk_keluar_merk'],
                  themeProvider,
                ),
                _buildDetailRow(
                  'Harga Jual',
                  'Rp ${_formatCurrency(item['produk_keluar_harga'])}',
                  themeProvider,
                ),
                _buildDetailRow(
                  'Invoice Penjualan',
                  item['transaksi_penjualan_invoice'],
                  themeProvider,
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('Ringkasan', themeProvider),
                _buildDetailRow(
                  'Selisih Pembayaran',
                  'Rp ${_formatCurrency(item['selisih_harga'])}',
                  themeProvider,
                ),
                _buildDetailRow(
                  'Tanggal',
                  _formatDateTime(item['created_at']),
                  themeProvider,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: themeProvider.primaryMain,
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    ThemeProvider themeProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: themeProvider.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
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

  void _showAddTradeInDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Fitur tambah tukar tambah - Akan diintegrasikan dengan API',
        ),
      ),
    );
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
