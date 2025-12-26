import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_provider.dart';

class StockHistoryScreen extends StatefulWidget {
  const StockHistoryScreen({super.key});

  @override
  State<StockHistoryScreen> createState() => _StockHistoryScreenState();
}

class _StockHistoryScreenState extends State<StockHistoryScreen> {
  String _selectedType = 'Semua';
  String _selectedToko = 'Semua Toko';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Sample data - Structure matched with pos_log_stok
  final List<Map<String, dynamic>> _logStokData = [
    {
      'id': 1,
      'produk_nama': 'iPhone 14 Pro',
      'toko_nama': 'Toko Pusat',
      'stok_sebelum': 10,
      'stok_sesudah': 8,
      'perubahan': -2,
      'tipe': 'Keluar',
      'referensi': 'TRX-20240115-001',
      'keterangan': 'Penjualan transaksi',
      'pengguna_nama': 'Admin Toko',
      'created_at': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'id': 2,
      'produk_nama': 'Samsung Galaxy S23',
      'toko_nama': 'Toko Cabang A',
      'stok_sebelum': 5,
      'stok_sesudah': 15,
      'perubahan': 10,
      'tipe': 'Masuk',
      'referensi': 'PO-20240115-002',
      'keterangan': 'Pembelian dari supplier',
      'pengguna_nama': 'Manager Cabang',
      'created_at': DateTime.now().subtract(const Duration(hours: 5)),
    },
    {
      'id': 3,
      'produk_nama': 'iPhone 14 Pro',
      'toko_nama': 'Toko Pusat',
      'stok_sebelum': 8,
      'stok_sesudah': 9,
      'perubahan': 1,
      'tipe': 'Retur',
      'referensi': 'RTR-20240114-001',
      'keterangan': 'Retur dari pelanggan',
      'pengguna_nama': 'Admin Toko',
      'created_at': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'id': 4,
      'produk_nama': 'Xiaomi 13 Pro',
      'toko_nama': 'Toko Cabang B',
      'stok_sebelum': 12,
      'stok_sesudah': 10,
      'perubahan': -2,
      'tipe': 'Adjustment',
      'referensi': 'ADJ-20240114-003',
      'keterangan': 'Stock opname - item rusak',
      'pengguna_nama': 'Owner',
      'created_at': DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    },
  ];

  List<Map<String, dynamic>> get _filteredData {
    return _logStokData.where((item) {
      final matchType =
          _selectedType == 'Semua' || item['tipe'] == _selectedType;
      final matchToko =
          _selectedToko == 'Semua Toko' || item['toko_nama'] == _selectedToko;
      final matchSearch =
          _searchQuery.isEmpty ||
          item['produk_nama'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          item['referensi'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      return matchType && matchToko && matchSearch;
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
          SliverToBoxAdapter(child: _buildFilters(isDesktop, themeProvider)),
          _buildLogListSliver(isDesktop, themeProvider),
        ],
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
              Icons.history,
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
                  'Riwayat Stok',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 24 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_filteredData.length} catatan perubahan stok',
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

  Widget _buildFilters(bool isDesktop, ThemeProvider themeProvider) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      child: Column(
        children: [
          // Search Bar
          Container(
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
                hintText: 'Cari produk atau referensi...',
                hintStyle: TextStyle(color: themeProvider.textTertiary),
                border: InputBorder.none,
                icon: const Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Filter Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip(
                'Tipe',
                _selectedType,
                ['Semua', 'Masuk', 'Keluar', 'Retur', 'Adjustment'],
                (value) => setState(() => _selectedType = value),
                themeProvider,
              ),
              _buildFilterChip(
                'Toko',
                _selectedToko,
                ['Semua Toko', 'Toko Pusat', 'Toko Cabang A', 'Toko Cabang B'],
                (value) => setState(() => _selectedToko = value),
                themeProvider,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String currentValue,
    List<String> options,
    Function(String) onSelected,
    ThemeProvider themeProvider,
  ) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder:
          (context) =>
              options
                  .map(
                    (option) =>
                        PopupMenuItem(value: option, child: Text(option)),
                  )
                  .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: themeProvider.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: themeProvider.primaryMain),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: $currentValue',
              style: TextStyle(
                color: themeProvider.primaryMain,
                fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildLogListSliver(bool isDesktop, ThemeProvider themeProvider) {
    if (_filteredData.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 80,
                color: themeProvider.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                'Tidak ada riwayat stok',
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

    if (isDesktop) {
      return SliverToBoxAdapter(child: _buildDesktopTable(themeProvider));
    } else {
      return SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final item = _filteredData[index];
            return _buildMobileCard(item, themeProvider);
          }, childCount: _filteredData.length),
        ),
      );
    }
  }

  Widget _buildDesktopTable(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(1),
                5: FlexColumnWidth(1),
                6: FlexColumnWidth(2),
                7: FlexColumnWidth(1.5),
              },
              children: [
                _buildTableHeader(themeProvider),
                ..._filteredData.map(
                  (item) => _buildTableRow(item, themeProvider),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TableRow _buildTableHeader(ThemeProvider themeProvider) {
    final headers = [
      'Produk',
      'Toko',
      'Sebelum',
      'Sesudah',
      'Perubahan',
      'Tipe',
      'Referensi',
      'Waktu',
    ];

    return TableRow(
      decoration: BoxDecoration(color: themeProvider.primaryMain),
      children:
          headers
              .map(
                (header) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Text(
                    header,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }

  TableRow _buildTableRow(
    Map<String, dynamic> item,
    ThemeProvider themeProvider,
  ) {
    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: themeProvider.borderColor, width: 1),
        ),
      ),
      children: [
        _buildTableCell(item['produk_nama'], themeProvider),
        _buildTableCell(item['toko_nama'], themeProvider),
        _buildTableCell(item['stok_sebelum'].toString(), themeProvider),
        _buildTableCell(item['stok_sesudah'].toString(), themeProvider),
        _buildChangeCell(item['perubahan'], themeProvider),
        _buildTypeCell(item['tipe'], themeProvider),
        _buildTableCell(item['referensi'], themeProvider),
        _buildTableCell(_formatDateTime(item['created_at']), themeProvider),
      ],
    );
  }

  Widget _buildTableCell(String text, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Text(text, style: TextStyle(color: themeProvider.textPrimary)),
    );
  }

  Widget _buildChangeCell(int change, ThemeProvider themeProvider) {
    final color =
        change > 0 ? themeProvider.successMain : themeProvider.errorMain;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Text(
        '${change > 0 ? '+' : ''}$change',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTypeCell(String tipe, ThemeProvider themeProvider) {
    Color bgColor;
    Color textColor;

    switch (tipe) {
      case 'Masuk':
        bgColor = themeProvider.successMain.withOpacity(0.1);
        textColor = themeProvider.successMain;
        break;
      case 'Keluar':
        bgColor = themeProvider.errorMain.withOpacity(0.1);
        textColor = themeProvider.errorMain;
        break;
      case 'Retur':
        bgColor = themeProvider.warningMain.withOpacity(0.1);
        textColor = themeProvider.warningMain;
        break;
      default:
        bgColor = themeProvider.infoMain.withOpacity(0.1);
        textColor = themeProvider.infoMain;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          tipe,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildMobileCard(
    Map<String, dynamic> item,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item['produk_nama'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.textPrimary,
                        ),
                      ),
                    ),
                    _buildTypeBadge(item['tipe'], themeProvider),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.store,
                      size: 16,
                      color: themeProvider.textTertiary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item['toko_nama'],
                      style: TextStyle(color: themeProvider.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Stok: ',
                          style: TextStyle(color: themeProvider.textSecondary),
                        ),
                        Text(
                          '${item['stok_sebelum']}',
                          style: TextStyle(
                            color: themeProvider.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: themeProvider.textTertiary,
                        ),
                        Text(
                          '${item['stok_sesudah']}',
                          style: TextStyle(
                            color: themeProvider.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${item['perubahan'] > 0 ? '+' : ''}${item['perubahan']}',
                      style: TextStyle(
                        color:
                            item['perubahan'] > 0
                                ? themeProvider.successMain
                                : themeProvider.errorMain,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['referensi'],
                      style: TextStyle(
                        color: themeProvider.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatDateTime(item['created_at']),
                      style: TextStyle(
                        color: themeProvider.textTertiary,
                        fontSize: 12,
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

  Widget _buildTypeBadge(String tipe, ThemeProvider themeProvider) {
    Color bgColor;
    Color textColor;

    switch (tipe) {
      case 'Masuk':
        bgColor = themeProvider.successMain.withOpacity(0.1);
        textColor = themeProvider.successMain;
        break;
      case 'Keluar':
        bgColor = themeProvider.errorMain.withOpacity(0.1);
        textColor = themeProvider.errorMain;
        break;
      case 'Retur':
        bgColor = themeProvider.warningMain.withOpacity(0.1);
        textColor = themeProvider.warningMain;
        break;
      default:
        bgColor = themeProvider.infoMain.withOpacity(0.1);
        textColor = themeProvider.infoMain;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        tipe,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
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
              Icon(Icons.info_outline, color: themeProvider.primaryMain),
              const SizedBox(width: 12),
              const Text('Detail Perubahan Stok'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Produk', item['produk_nama'], themeProvider),
                _buildDetailRow('Toko', item['toko_nama'], themeProvider),
                _buildDetailRow(
                  'Stok Sebelum',
                  '${item['stok_sebelum']}',
                  themeProvider,
                ),
                _buildDetailRow(
                  'Stok Sesudah',
                  '${item['stok_sesudah']}',
                  themeProvider,
                ),
                _buildDetailRow(
                  'Perubahan',
                  '${item['perubahan'] > 0 ? '+' : ''}${item['perubahan']}',
                  themeProvider,
                ),
                _buildDetailRow('Tipe', item['tipe'], themeProvider),
                _buildDetailRow('Referensi', item['referensi'], themeProvider),
                _buildDetailRow(
                  'Keterangan',
                  item['keterangan'],
                  themeProvider,
                ),
                _buildDetailRow(
                  'Pengguna',
                  item['pengguna_nama'] ?? '-',
                  themeProvider,
                ),
                _buildDetailRow(
                  'Waktu',
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
            width: 100,
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
