import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_provider.dart';
import 'report_screen.dart';
import 'sales_report.screen.dart';
import 'tradein_report.screen.dart';
import 'product_report.screen.dart';

class ReportsIndexScreen extends StatefulWidget {
  const ReportsIndexScreen({super.key});

  @override
  State<ReportsIndexScreen> createState() => _ReportsIndexScreenState();
}

class _ReportsIndexScreenState extends State<ReportsIndexScreen>
    with TickerProviderStateMixin {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _searchQuery = '';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _reportTypes = [
    {
      'id': 'sales',
      'title': 'Sales Report',
      'subtitle': 'Sales & revenue analysis',
      'icon': Icons.trending_up,
      'color': const Color(0xFF4CAF50),
    },
    {
      'id': 'trade-in',
      'title': 'Trade In Report',
      'subtitle': 'Product trade-in tracking',
      'icon': Icons.swap_horiz,
      'color': const Color(0xFF2196F3),
    },
    {
      'id': 'products',
      'title': 'Product Report',
      'subtitle': 'Product performance & stock',
      'icon': Icons.inventory_2,
      'color': const Color(0xFFFF9800),
    },
    {
      'id': 'stock',
      'title': 'Stock Report',
      'subtitle': 'Warehouse stock monitoring',
      'icon': Icons.warehouse,
      'color': const Color(0xFF9C27B0),
    },
    {
      'id': 'customers',
      'title': 'Customer Report',
      'subtitle': 'Customer data & analysis',
      'icon': Icons.people,
      'color': const Color(0xFFE91E63),
    },
    {
      'id': 'financial',
      'title': 'Financial Report',
      'subtitle': 'Profit & loss statement',
      'icon': Icons.account_balance,
      'color': const Color(0xFF00BCD4),
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredReports {
    if (_searchQuery.isEmpty) return _reportTypes;
    return _reportTypes.where((report) {
      final title = report['title'].toString().toLowerCase();
      final subtitle = report['subtitle'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query) || subtitle.contains(query);
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
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildModernHeader(isDesktop),
                _buildStatsCards(isDesktop, isTablet),
                _buildDateRangePicker(isDesktop),
                _buildSearchSection(isDesktop),
                _buildReportsGrid(isDesktop, isTablet),
                const SizedBox(height: 80), // Extra bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      margin: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: themeProvider.primaryMain,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: themeProvider.primaryMain.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 28 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                        'Reports & Analytics',
                        style: TextStyle(
                          fontSize: isDesktop ? 24 : 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: isDesktop ? 4 : 2),
                      Text(
                        'Comprehensive business reports',
                        style: TextStyle(
                          fontSize: isDesktop ? 14 : 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(bool isDesktop, bool isTablet) {
    final themeProvider = context.watch<ThemeProvider>();
    final totalReports = _reportTypes.length;
    final filteredCount = _filteredReports.length;

    List<Map<String, dynamic>> stats = [
      {
        'title': 'Available Reports',
        'value': '$totalReports',
        'icon': Icons.description_rounded,
        'color': Colors.blue,
        'subtitle': 'Report types',
      },
      {
        'title': 'Report Results',
        'value': '$filteredCount',
        'icon': Icons.search_rounded,
        'color': Colors.green,
        'subtitle': _searchQuery.isNotEmpty ? 'Found reports' : 'All reports',
      },
    ];

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 20 : 16,
        vertical: 8,
      ),
      child: isDesktop
          ? Row(
              children: stats
                  .map(
                    (stat) => Expanded(
                      child: _buildStatCard(stat, isDesktop),
                    ),
                  )
                  .toList(),
            )
          : Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildStatCard(stats[0], false)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatCard(stats[1], false)),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat, bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();
    final color = stat['color'] as Color;

    return Container(
      margin: EdgeInsets.only(
        right: isDesktop ? 16 : 0,
        bottom: isDesktop ? 0 : 8,
      ),
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
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
            padding: EdgeInsets.all(isDesktop ? 10 : 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(stat['icon'], color: color, size: isDesktop ? 24 : 20),
          ),
          SizedBox(width: isDesktop ? 12 : 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  stat['value'],
                  style: TextStyle(
                    fontSize: isDesktop ? 20 : 16,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textPrimary,
                  ),
                ),
                SizedBox(height: isDesktop ? 2 : 1),
                Text(
                  stat['title'],
                  style: TextStyle(
                    fontSize: isDesktop ? 12 : 10,
                    color: themeProvider.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (stat['subtitle'] != null) ...[
                  Text(
                    stat['subtitle'],
                    style: TextStyle(
                      fontSize: isDesktop ? 10 : 9,
                      color: themeProvider.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangePicker(bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 20 : 16,
        vertical: 8,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeProvider.primaryMain.withOpacity(0.3),
        ),
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
                'Report Period',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDateButton(
                  'From',
                  _startDate,
                  () => _selectDate(true),
                  isDesktop,
                  themeProvider,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateButton(
                  'To',
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
              _buildQuickDateChip('Today', () {
                setState(() {
                  _startDate = DateTime.now();
                  _endDate = DateTime.now();
                });
              }, themeProvider),
              _buildQuickDateChip('7 Days', () {
                setState(() {
                  _startDate = DateTime.now().subtract(const Duration(days: 7));
                  _endDate = DateTime.now();
                });
              }, themeProvider),
              _buildQuickDateChip('30 Days', () {
                setState(() {
                  _startDate = DateTime.now().subtract(const Duration(days: 30));
                  _endDate = DateTime.now();
                });
              }, themeProvider),
              _buildQuickDateChip('This Month', () {
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

  Widget _buildSearchSection(bool isDesktop) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 20 : 16,
        vertical: 8,
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: TextStyle(color: themeProvider.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search reports...',
          hintStyle: TextStyle(
            color: themeProvider.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: themeProvider.textSecondary,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: themeProvider.textSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: themeProvider.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: themeProvider.borderColor.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: themeProvider.primaryMain,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: themeProvider.surfaceColor,
        ),
      ),
    );
  }

  Widget _buildReportsGrid(bool isDesktop, bool isTablet) {
    final themeProvider = context.watch<ThemeProvider>();
    final filteredReports = _filteredReports;

    if (filteredReports.isEmpty) {
      return Container(
        padding: EdgeInsets.all(isDesktop ? 40 : 32),
        child: _buildEmptyState(),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount;
    double childAspectRatio;

    if (isDesktop) {
      crossAxisCount = 3;
      childAspectRatio = 1.4;
    } else if (isTablet) {
      crossAxisCount = 2;
      childAspectRatio = 1.3;
    } else {
      crossAxisCount = 1;
      childAspectRatio = 1.8;
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 20 : 16,
        vertical: 8,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: filteredReports.length,
        itemBuilder: (context, index) {
          final report = filteredReports[index];
          return _buildReportCard(report, isDesktop, themeProvider);
        },
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
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (report['color'] as Color).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openReport(report['id']),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 24 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(isDesktop ? 14 : 12),
                      decoration: BoxDecoration(
                        color: (report['color'] as Color).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        report['icon'] as IconData,
                        color: report['color'] as Color,
                        size: isDesktop ? 32 : 28,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: (report['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: report['color'] as Color,
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
                        fontSize: isDesktop ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report['subtitle'],
                      style: TextStyle(
                        fontSize: isDesktop ? 13 : 12,
                        color: themeProvider.textSecondary,
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

  Widget _buildEmptyState() {
    final themeProvider = context.watch<ThemeProvider>();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: themeProvider.primaryMain.withOpacity(0.1),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Icon(
            Icons.search_off_rounded,
            size: 64,
            color: themeProvider.primaryMain,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'No reports found',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: themeProvider.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Try adjusting your search terms',
          style: TextStyle(fontSize: 14, color: themeProvider.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
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
      'sales': 'Sales Report',
      'trade-in': 'Trade In Report',
      'products': 'Product Report',
      'stock': 'Stock Report',
      'customers': 'Customer Report',
      'financial': 'Financial Report',
    };

    // Navigate to specific report screen based on reportId
    if (reportId == 'sales') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SalesReportScreen(
            startDate: _startDate,
            endDate: _endDate,
          ),
        ),
      );
    } else if (reportId == 'trade-in') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TradeInReportScreen(
            startDate: _startDate,
            endDate: _endDate,
          ),
        ),
      );
    } else if (reportId == 'products') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProductReportScreen(),
        ),
      );
    } else {
      // For other reports, use generic detail screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReportDetailScreen(
            reportId: reportId,
            reportTitle: reportTitles[reportId] ?? 'Report',
            startDate: _startDate,
            endDate: _endDate,
          ),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
