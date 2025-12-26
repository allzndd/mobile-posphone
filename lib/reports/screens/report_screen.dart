import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_provider.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  final List<Map<String, dynamic>> _reportTypes = [
    {
      'id': 'sales',
      'title': 'Laporan Penjualan',
      'subtitle': 'Analisis penjualan & revenue',
      'icon': Icons.trending_up,
      'color': const Color(0xFF4CAF50),
    },
    {
      'id': 'trade-in',
      'title': 'Laporan Trade In',
      'subtitle': 'Tukar tambah produk',
      'icon': Icons.swap_horiz,
      'color': const Color(0xFF2196F3),
    },
    {
      'id': 'products',
      'title': 'Laporan Produk',
      'subtitle': 'Performa & stok produk',
      'icon': Icons.inventory_2,
      'color': const Color(0xFFFF9800),
    },
    {
      'id': 'stock',
      'title': 'Laporan Stok',
      'subtitle': 'Monitoring stok gudang',
      'icon': Icons.warehouse,
      'color': const Color(0xFF9C27B0),
    },
    {
      'id': 'customers',
      'title': 'Laporan Pelanggan',
      'subtitle': 'Data & analisis pelanggan',
      'icon': Icons.people,
      'color': const Color(0xFFE91E63),
    },
    {
      'id': 'financial',
      'title': 'Laporan Keuangan',
      'subtitle': 'Laporan laba rugi & cashflow',
      'icon': Icons.account_balance,
      'color': const Color(0xFF00BCD4),
    },
  ];

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
          SliverToBoxAdapter(
            child: _buildDateRangePicker(isDesktop, themeProvider),
          ),
          _buildReportGridSliver(isDesktop, themeProvider),
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
              Icons.assessment_rounded,
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
                  'Laporan & Analisis',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 24 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Dashboard reporting lengkap',
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

  Widget _buildDateRangePicker(bool isDesktop, ThemeProvider themeProvider) {
    return Container(
      margin: EdgeInsets.all(isDesktop ? 24 : 16),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.date_range,
                color: themeProvider.primaryMain,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Periode Laporan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDateButton(
                  'Dari',
                  _startDate,
                  () => _selectDate(true),
                  isDesktop,
                  themeProvider,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateButton(
                  'Sampai',
                  _endDate,
                  () => _selectDate(false),
                  isDesktop,
                  themeProvider,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickDateChip('Hari Ini', () {
                setState(() {
                  _startDate = DateTime.now();
                  _endDate = DateTime.now();
                });
              }, themeProvider),
              _buildQuickDateChip('7 Hari', () {
                setState(() {
                  _startDate = DateTime.now().subtract(const Duration(days: 7));
                  _endDate = DateTime.now();
                });
              }, themeProvider),
              _buildQuickDateChip('30 Hari', () {
                setState(() {
                  _startDate = DateTime.now().subtract(
                    const Duration(days: 30),
                  );
                  _endDate = DateTime.now();
                });
              }, themeProvider),
              _buildQuickDateChip('Bulan Ini', () {
                final now = DateTime.now();
                setState(() {
                  _startDate = DateTime(now.year, now.month, 1);
                  _endDate = DateTime(now.year, now.month + 1, 0);
                });
              }, themeProvider),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton(
    String label,
    DateTime date,
    VoidCallback onTap,
    bool isDesktop,
    ThemeProvider themeProvider,
  ) {
    return Material(
      color: themeProvider.backgroundColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: themeProvider.borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: themeProvider.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(date),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickDateChip(
    String label,
    VoidCallback onTap,
    ThemeProvider themeProvider,
  ) {
    return Material(
      color: themeProvider.primaryMain.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: themeProvider.primaryMain,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportGridSliver(bool isDesktop, ThemeProvider themeProvider) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 24 : 16,
        vertical: 8,
      ),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:
              isDesktop ? 3 : (MediaQuery.of(context).size.width > 600 ? 2 : 1),
          childAspectRatio: isDesktop ? 1.5 : 1.3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final report = _reportTypes[index];
          return _buildReportCard(report, isDesktop, themeProvider);
        }, childCount: _reportTypes.length),
      ),
    );
  }

  Widget _buildReportCard(
    Map<String, dynamic> report,
    bool isDesktop,
    ThemeProvider themeProvider,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            report['color'] as Color,
            (report['color'] as Color).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (report['color'] as Color).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openReport(report['id']),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        report['icon'] as IconData,
                        color: Colors.white,
                        size: isDesktop ? 32 : 28,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report['title'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isDesktop ? 18 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report['subtitle'],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
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

  void _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        final themeProvider = context.read<ThemeProvider>();
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: themeProvider.primaryMain,
              onPrimary: Colors.white,
              surface: themeProvider.surfaceColor,
              onSurface: themeProvider.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _openReport(String reportId) {
    final reportTitles = {
      'sales': 'Laporan Penjualan',
      'trade-in': 'Laporan Trade In',
      'products': 'Laporan Produk',
      'stock': 'Laporan Stok',
      'customers': 'Laporan Pelanggan',
      'financial': 'Laporan Keuangan',
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ReportDetailScreen(
              reportId: reportId,
              reportTitle: reportTitles[reportId] ?? 'Laporan',
              startDate: _startDate,
              endDate: _endDate,
            ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// Report Detail Screen
class ReportDetailScreen extends StatefulWidget {
  final String reportId;
  final String reportTitle;
  final DateTime startDate;
  final DateTime endDate;

  const ReportDetailScreen({
    super.key,
    required this.reportId,
    required this.reportTitle,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  void _loadReportData() {
    // Simulate loading
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        title: Text(widget.reportTitle),
        backgroundColor: themeProvider.primaryMain,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportReport,
            tooltip: 'Export PDF',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareReport,
            tooltip: 'Share',
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        themeProvider.primaryMain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Memuat data laporan...',
                      style: TextStyle(color: themeProvider.textSecondary),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: EdgeInsets.all(isDesktop ? 24 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPeriodInfo(isDesktop, themeProvider),
                    const SizedBox(height: 24),
                    _buildReportContent(isDesktop, themeProvider),
                  ],
                ),
              ),
    );
  }

  Widget _buildPeriodInfo(bool isDesktop, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.primaryMain.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.primaryMain.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.date_range, color: themeProvider.primaryMain),
          const SizedBox(width: 12),
          Text(
            'Periode: ${_formatDate(widget.startDate)} - ${_formatDate(widget.endDate)}',
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              fontWeight: FontWeight.w600,
              color: themeProvider.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent(bool isDesktop, ThemeProvider themeProvider) {
    // Sample data based on report type
    switch (widget.reportId) {
      case 'sales':
        return _buildSalesReport(isDesktop, themeProvider);
      case 'trade-in':
        return _buildTradeInReport(isDesktop, themeProvider);
      case 'products':
        return _buildProductsReport(isDesktop, themeProvider);
      case 'stock':
        return _buildStockReport(isDesktop, themeProvider);
      case 'customers':
        return _buildCustomersReport(isDesktop, themeProvider);
      case 'financial':
        return _buildFinancialReport(isDesktop, themeProvider);
      default:
        return const SizedBox();
    }
  }

  Widget _buildSalesReport(bool isDesktop, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryCards(
          [
            {
              'label': 'Total Transaksi',
              'value': '245',
              'icon': Icons.shopping_cart,
              'color': themeProvider.primaryMain,
            },
            {
              'label': 'Total Penjualan',
              'value': 'Rp 125.5 Jt',
              'icon': Icons.monetization_on,
              'color': themeProvider.successMain,
            },
            {
              'label': 'Rata-rata/Transaksi',
              'value': 'Rp 512.2 Rb',
              'icon': Icons.trending_up,
              'color': themeProvider.infoMain,
            },
          ],
          isDesktop,
          themeProvider,
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('Top 5 Produk Terlaris', themeProvider),
        _buildTopProductsList(themeProvider),
      ],
    );
  }

  Widget _buildTradeInReport(bool isDesktop, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryCards(
          [
            {
              'label': 'Total Trade In',
              'value': '45',
              'icon': Icons.swap_horiz,
              'color': themeProvider.primaryMain,
            },
            {
              'label': 'Nilai Trade In',
              'value': 'Rp 32.5 Jt',
              'icon': Icons.call_received,
              'color': themeProvider.successMain,
            },
            {
              'label': 'Nilai Penjualan',
              'value': 'Rp 78.2 Jt',
              'icon': Icons.call_made,
              'color': themeProvider.infoMain,
            },
          ],
          isDesktop,
          themeProvider,
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('Produk Sering di-Trade In', themeProvider),
        _buildTradeInList(themeProvider),
      ],
    );
  }

  Widget _buildProductsReport(bool isDesktop, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryCards(
          [
            {
              'label': 'Total Produk',
              'value': '156',
              'icon': Icons.inventory_2,
              'color': themeProvider.primaryMain,
            },
            {
              'label': 'Stok Tersedia',
              'value': '1,234',
              'icon': Icons.check_circle,
              'color': themeProvider.successMain,
            },
            {
              'label': 'Stok Menipis',
              'value': '12',
              'icon': Icons.warning,
              'color': themeProvider.warningMain,
            },
          ],
          isDesktop,
          themeProvider,
        ),
      ],
    );
  }

  Widget _buildStockReport(bool isDesktop, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryCards(
          [
            {
              'label': 'Stok Masuk',
              'value': '456',
              'icon': Icons.add_circle,
              'color': themeProvider.successMain,
            },
            {
              'label': 'Stok Keluar',
              'value': '378',
              'icon': Icons.remove_circle,
              'color': themeProvider.errorMain,
            },
            {
              'label': 'Adjustment',
              'value': '23',
              'icon': Icons.edit,
              'color': themeProvider.infoMain,
            },
          ],
          isDesktop,
          themeProvider,
        ),
      ],
    );
  }

  Widget _buildCustomersReport(bool isDesktop, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryCards(
          [
            {
              'label': 'Total Pelanggan',
              'value': '1,234',
              'icon': Icons.people,
              'color': themeProvider.primaryMain,
            },
            {
              'label': 'Pelanggan Aktif',
              'value': '876',
              'icon': Icons.person_add,
              'color': themeProvider.successMain,
            },
            {
              'label': 'Pelanggan Baru',
              'value': '45',
              'icon': Icons.trending_up,
              'color': themeProvider.infoMain,
            },
          ],
          isDesktop,
          themeProvider,
        ),
      ],
    );
  }

  Widget _buildFinancialReport(bool isDesktop, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryCards(
          [
            {
              'label': 'Total Pendapatan',
              'value': 'Rp 125.5 Jt',
              'icon': Icons.trending_up,
              'color': themeProvider.successMain,
            },
            {
              'label': 'Total Pengeluaran',
              'value': 'Rp 78.2 Jt',
              'icon': Icons.trending_down,
              'color': themeProvider.errorMain,
            },
            {
              'label': 'Laba Bersih',
              'value': 'Rp 47.3 Jt',
              'icon': Icons.account_balance_wallet,
              'color': themeProvider.primaryMain,
            },
          ],
          isDesktop,
          themeProvider,
        ),
      ],
    );
  }

  Widget _buildSummaryCards(
    List<Map<String, dynamic>> cards,
    bool isDesktop,
    ThemeProvider themeProvider,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 1,
        childAspectRatio: isDesktop ? 2.5 : 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: themeProvider.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (card['color'] as Color).withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (card['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  card['icon'] as IconData,
                  color: card['color'] as Color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      card['label'],
                      style: TextStyle(
                        fontSize: 13,
                        color: themeProvider.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card['value'],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: themeProvider.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTopProductsList(ThemeProvider themeProvider) {
    final products = [
      {'name': 'iPhone 14 Pro', 'sales': 45, 'revenue': 67500000},
      {'name': 'Samsung Galaxy S23', 'sales': 38, 'revenue': 60800000},
      {'name': 'Xiaomi 13 Pro', 'sales': 32, 'revenue': 38400000},
      {'name': 'OPPO Find X6', 'sales': 28, 'revenue': 33600000},
      {'name': 'Vivo X90 Pro', 'sales': 25, 'revenue': 30000000},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: themeProvider.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: themeProvider.borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: themeProvider.primaryMain.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.primaryMain,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'] as String,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: themeProvider.textPrimary,
                      ),
                    ),
                    Text(
                      '${product['sales']} terjual',
                      style: TextStyle(
                        fontSize: 13,
                        color: themeProvider.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Rp ${_formatCurrency(product['revenue'] as int)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.successMain,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTradeInList(ThemeProvider themeProvider) {
    final tradeIns = [
      {'name': 'iPhone 11', 'count': 12, 'value': 54000000},
      {'name': 'Samsung S21', 'count': 9, 'value': 45000000},
      {'name': 'Xiaomi 12', 'count': 8, 'value': 48000000},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tradeIns.length,
      itemBuilder: (context, index) {
        final item = tradeIns[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: themeProvider.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: themeProvider.borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] as String,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: themeProvider.textPrimary,
                      ),
                    ),
                    Text(
                      '${item['count']} unit',
                      style: TextStyle(
                        fontSize: 13,
                        color: themeProvider.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Rp ${_formatCurrency(item['value'] as int)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.primaryMain,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export PDF - Akan diintegrasikan')),
    );
  }

  void _shareReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share Report - Akan diintegrasikan')),
    );
  }

  String _formatCurrency(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)} Jt';
    }
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
