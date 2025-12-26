import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_provider.dart';

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Sample data - Structure matched with pos_service
  final List<Map<String, dynamic>> _serviceData = [
    {
      'id': 1,
      'nama': 'Ganti LCD iPhone 14 Pro',
      'keterangan':
          'Penggantian layar LCD original dengan garansi 6 bulan. Termasuk jasa pemasangan dan testing.',
      'harga': 3500000,
      'durasi': '2-3 Jam',
      'pelanggan_nama': 'Budi Santoso',
      'toko_nama': 'Toko Pusat',
      'status': 'Selesai',
      'created_at': DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      'id': 2,
      'nama': 'Service Charging Samsung',
      'keterangan':
          'Perbaikan port charging tidak bisa charge. Cleaning dan replacement port USB-C.',
      'harga': 250000,
      'durasi': '1-2 Jam',
      'pelanggan_nama': 'Siti Aminah',
      'toko_nama': 'Toko Cabang A',
      'status': 'Proses',
      'created_at': DateTime.now().subtract(const Duration(hours: 5)),
    },
    {
      'id': 3,
      'nama': 'Ganti Baterai iPhone 12',
      'keterangan':
          'Penggantian baterai original dengan kapasitas penuh. Battery health turun ke 75%.',
      'harga': 850000,
      'durasi': '1 Jam',
      'pelanggan_nama': 'Ahmad Fauzi',
      'toko_nama': 'Toko Pusat',
      'status': 'Menunggu',
      'created_at': DateTime.now().subtract(const Duration(hours: 1)),
    },
    {
      'id': 4,
      'nama': 'Software Update & Reset',
      'keterangan':
          'Update iOS ke versi terbaru, backup data, dan factory reset untuk optimasi performa.',
      'harga': 150000,
      'durasi': '30 Menit',
      'pelanggan_nama': 'Dewi Lestari',
      'toko_nama': 'Toko Cabang B',
      'status': 'Selesai',
      'created_at': DateTime.now().subtract(const Duration(days: 5)),
    },
  ];

  List<Map<String, dynamic>> get _filteredData {
    return _serviceData.where((item) {
      final matchSearch =
          _searchQuery.isEmpty ||
          item['nama'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          item['pelanggan_nama'].toString().toLowerCase().contains(
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
            child: _buildStatusSummary(isDesktop, themeProvider),
          ),
          _buildServiceListSliver(isDesktop, themeProvider),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddServiceDialog(),
        backgroundColor: themeProvider.primaryMain,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          isDesktop ? 'Tambah Service' : 'Tambah',
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
              Icons.build_circle_rounded,
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
                  'Service & Perbaikan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 24 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_filteredData.length} layanan service',
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
            hintText: 'Cari service atau pelanggan...',
            hintStyle: TextStyle(color: themeProvider.textTertiary),
            border: InputBorder.none,
            icon: const Icon(Icons.search),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSummary(bool isDesktop, ThemeProvider themeProvider) {
    final menunggu =
        _serviceData.where((item) => item['status'] == 'Menunggu').length;
    final proses =
        _serviceData.where((item) => item['status'] == 'Proses').length;
    final selesai =
        _serviceData.where((item) => item['status'] == 'Selesai').length;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatusCard(
              'Menunggu',
              menunggu,
              themeProvider.warningMain,
              Icons.schedule,
              themeProvider,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatusCard(
              'Proses',
              proses,
              themeProvider.infoMain,
              Icons.build,
              themeProvider,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatusCard(
              'Selesai',
              selesai,
              themeProvider.successMain,
              Icons.check_circle,
              themeProvider,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    String label,
    int count,
    Color color,
    IconData icon,
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
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: themeProvider.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceListSliver(bool isDesktop, ThemeProvider themeProvider) {
    if (_filteredData.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.build_circle_outlined,
                size: 80,
                color: themeProvider.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                'Belum ada layanan service',
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
          return _buildServiceCard(item, isDesktop, themeProvider);
        }, childCount: _filteredData.length),
      ),
    );
  }

  Widget _buildServiceCard(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['nama'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${item['id']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: themeProvider.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(item['status'], themeProvider),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item['keterangan'],
                  style: TextStyle(
                    color: themeProvider.textSecondary,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      Icons.person,
                      item['pelanggan_nama'],
                      themeProvider,
                    ),
                    _buildInfoChip(
                      Icons.store,
                      item['toko_nama'],
                      themeProvider,
                    ),
                    _buildInfoChip(
                      Icons.access_time,
                      item['durasi'],
                      themeProvider,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rp ${_formatCurrency(item['harga'])}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.primaryMain,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: themeProvider.infoMain,
                            size: 20,
                          ),
                          onPressed: () => _showEditServiceDialog(item),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: themeProvider.errorMain,
                            size: 20,
                          ),
                          onPressed: () => _confirmDelete(item),
                        ),
                      ],
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

  Widget _buildStatusBadge(String status, ThemeProvider themeProvider) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'Menunggu':
        bgColor = themeProvider.warningMain.withOpacity(0.1);
        textColor = themeProvider.warningMain;
        break;
      case 'Proses':
        bgColor = themeProvider.infoMain.withOpacity(0.1);
        textColor = themeProvider.infoMain;
        break;
      case 'Selesai':
        bgColor = themeProvider.successMain.withOpacity(0.1);
        textColor = themeProvider.successMain;
        break;
      default:
        bgColor = themeProvider.textTertiary.withOpacity(0.1);
        textColor = themeProvider.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    IconData icon,
    String text,
    ThemeProvider themeProvider,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: themeProvider.textTertiary),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(color: themeProvider.textSecondary, fontSize: 12),
        ),
      ],
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
              Icon(Icons.build_circle, color: themeProvider.primaryMain),
              const SizedBox(width: 12),
              const Expanded(child: Text('Detail Service')),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('ID', '${item['id']}', themeProvider),
                _buildDetailRow('Nama Service', item['nama'], themeProvider),
                _buildDetailRow(
                  'Keterangan',
                  item['keterangan'],
                  themeProvider,
                ),
                _buildDetailRow(
                  'Harga',
                  'Rp ${_formatCurrency(item['harga'])}',
                  themeProvider,
                ),
                _buildDetailRow('Durasi', item['durasi'], themeProvider),
                _buildDetailRow(
                  'Pelanggan',
                  item['pelanggan_nama'],
                  themeProvider,
                ),
                _buildDetailRow('Toko', item['toko_nama'], themeProvider),
                _buildDetailRow('Status', item['status'], themeProvider),
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

  void _showAddServiceDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur tambah service - Akan diintegrasikan dengan API'),
      ),
    );
  }

  void _showEditServiceDialog(Map<String, dynamic> item) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Edit service: ${item['nama']}')));
  }

  void _confirmDelete(Map<String, dynamic> item) {
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
              Icon(Icons.warning, color: themeProvider.errorMain),
              const SizedBox(width: 12),
              const Text('Konfirmasi Hapus'),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus service "${item['nama']}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Service berhasil dihapus')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.errorMain,
              ),
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
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
